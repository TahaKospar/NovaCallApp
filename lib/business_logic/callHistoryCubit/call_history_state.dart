part of 'call_history_cubit.dart';

abstract class CallHistoryState {}

class CallHistoryInitial extends CallHistoryState {}

class CallHistoryLoading extends CallHistoryState {}

class CallHistoryLoaded extends CallHistoryState {
  final List<CallModel> calls;
  CallHistoryLoaded(this.calls);
}

class FrequentContactsLoaded extends CallHistoryState {
  final List<Map<String, dynamic>> contacts;
  FrequentContactsLoaded(this.contacts);
}

class CallHistoryError extends CallHistoryState {
  final String message;
  CallHistoryError(this.message);
}