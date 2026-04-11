import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permis_app/features/session/data/models/report_model.dart';
import 'package:permis_app/features/session/data/repositories/session_repository.dart';

class SessionHistoryState {
  final List<ReportModel> sessions;
  final bool isLoading;

  const SessionHistoryState({
    this.sessions = const [],
    this.isLoading = false,
  });

  SessionHistoryState copyWith({
    List<ReportModel>? sessions,
    bool? isLoading,
  }) {
    return SessionHistoryState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SessionHistoryCubit extends Cubit<SessionHistoryState> {
  final SessionRepository _repository;

  SessionHistoryCubit(this._repository) : super(const SessionHistoryState());

  void loadSessions() {
    emit(state.copyWith(isLoading: true));
    final sessions = _repository.getAllReports();
    emit(SessionHistoryState(sessions: sessions, isLoading: false));
  }

  Future<void> deleteSession(String id) async {
    await _repository.deleteReport(id);
    loadSessions();
  }
}
