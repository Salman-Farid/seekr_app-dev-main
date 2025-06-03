import 'package:seekr_app/domain/chat/chat_context.dart';
import 'package:seekr_app/domain/chat/chat_token.dart';
import 'package:seekr_app/domain/chat/message_request.dart';

abstract class IChatRepo {
  Future<ChatContext> sendMessage(MessageRequest data);
  Stream<ChatToken> getResponseStream(String streamId);
  Stream<String> getResponseStreamString(String streamId);
}
