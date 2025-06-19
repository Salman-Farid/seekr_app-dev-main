import 'package:equatable/equatable.dart';

class BusDetectionState extends Equatable {
  final String message;
  final bool loading;
  final int processCount;
  const BusDetectionState({
    required this.message,
    required this.loading,
    required this.processCount,
  });

  BusDetectionState copyWith({
    String? message,
    bool? loading,
    int? processCount,
  }) {
    return BusDetectionState(
      message: message ?? this.message,
      loading: loading ?? this.loading,
      processCount: processCount ?? this.processCount,
    );
  }

  factory BusDetectionState.init() =>
      const BusDetectionState(message: '', loading: false, processCount: 0);

  @override
  String toString() =>
      'BusDetectionState(message: $message, loading: $loading, processCount: $processCount)';

  @override
  List<Object> get props => [message, loading, processCount];
}
