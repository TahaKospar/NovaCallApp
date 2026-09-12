import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:novacall/data/model/call_model.dart';
import 'package:novacall/data/services/call_history_service.dart';

part 'call_history_state.dart';

class CallHistoryCubit extends Cubit<CallHistoryState> {
  final CallHistoryService _service;
  StreamSubscription? _subscription;

  List<Map<String, dynamic>> _frequentContacts = [];
  List<Map<String, dynamic>> get frequentContacts => _frequentContacts;

  CallHistoryCubit({CallHistoryService? service})
      : _service = service ?? CallHistoryService(),
        super(CallHistoryInitial());

  void loadHistory() {
    emit(CallHistoryLoading());

    _subscription?.cancel();
    _subscription = _service.getCallHistory().listen(
      (calls) {
        emit(CallHistoryLoaded(calls));
      },
      onError: (error) {
        emit(CallHistoryError(error.toString()));
      },
    );
  }

  Future<void> loadFrequentContacts() async {
    try {
      _frequentContacts = await _service.getFrequentContacts();
      emit(FrequentContactsLoaded(_frequentContacts));
    } catch (e) {
      emit(CallHistoryError(e.toString()));
    }
  }

  Future<void> saveCall(CallModel call) async {
    await _service.saveCall(call);
  }

  Future<void> deleteCall(String callId) async {
    await _service.deleteCall(callId);
  }

  Future<void> clearHistory() async {
    await _service.clearHistory();
    loadHistory();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}