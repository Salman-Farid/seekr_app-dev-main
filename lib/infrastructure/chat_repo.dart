import 'package:flutter_easylogger/flutter_logger.dart';
import 'package:flutter_http_sse/client/sse_client.dart';
import 'package:flutter_http_sse/model/sse_request.dart';
import 'package:http/http.dart';
import 'package:seekr_app/domain/chat/chat_context.dart';
import 'package:seekr_app/domain/chat/chat_token.dart';
import 'package:seekr_app/domain/chat/i_chat_repo.dart';
import 'package:seekr_app/domain/chat/message_request.dart';

class ChatRepo extends IChatRepo {
  final SSEClient sseClient;
  final client = Client();

  ChatRepo({required this.sseClient});

  @override
  Stream<ChatToken> getResponseStream(String streamId) {
    final request = SSERequest(
      url: 'https://chatbot.com.ngrok.app/result_stream/$streamId',
      headers: {"Accept": 'text/event-stream'},
      onData: (data) => Logger.i("SSE Data $data"),
      onError: (error) {
        Logger.e("SSE Error: $error");
      },
      onDone: () => Logger.i("SSE Stream closed"),
      retry: true,
    );
    final stream = sseClient.connect('sse_connection_$streamId', request);
    return stream.map<ChatToken>((event) => ChatToken.fromMap(event.data));
  }

  @override
  Future<ChatContext> sendMessage(MessageRequest data) async {
    if (data.image == null) {
      Logger.i("Session ID: ${data.toJson()}");
    }
    final response = await client.post(
      Uri.parse('https://chatbot.com.ngrok.app/chat/'),
      body: data.toJson(),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    final context = ChatContext.fromJson(response.body, data.text);
    Logger.i(
        "Chat Response: ${response.body}, status: ${response.statusCode}, context: $context");

    return context;
  }

  @override
  Stream<String> getResponseStreamString(String streamId) {
    final request = SSERequest(
      url: 'https://chatbot.com.ngrok.app/result_stream/$streamId',
      headers: {"Accept": 'text/event-stream'},
      onData: (data) => Logger.i("SSE Data $data"),
      onError: (error) {
        Logger.e("SSE Error: $error");
      },
      onDone: () => Logger.i("SSE Stream closed"),
      retry: true,
    );
    final stream = sseClient.connect('sse_connection_$streamId', request);
    return stream.map<String>((event) => event.data.toString());
  }
}
