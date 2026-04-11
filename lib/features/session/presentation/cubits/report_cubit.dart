import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permis_app/core/constants/app_constants.dart';
import 'package:permis_app/features/session/data/models/candidate_model.dart';

class ReportState {
  final String wilaya;
  final DateTime? depositDate;
  final DateTime? examDate;
  final List<CandidateModel> candidatesB;
  final List<CandidateModel> candidatesA;

  const ReportState({
    this.wilaya = AppConstants.defaultWilaya,
    this.depositDate,
    this.examDate,
    this.candidatesB = const [],
    this.candidatesA = const [],
  });

  ReportState copyWith({
    String? wilaya,
    DateTime? depositDate,
    DateTime? examDate,
    List<CandidateModel>? candidatesB,
    List<CandidateModel>? candidatesA,
  }) {
    return ReportState(
      wilaya: wilaya ?? this.wilaya,
      depositDate: depositDate ?? this.depositDate,
      examDate: examDate ?? this.examDate,
      candidatesB: candidatesB ?? this.candidatesB,
      candidatesA: candidatesA ?? this.candidatesA,
    );
  }

  bool get isHeaderValid =>
      depositDate != null &&
      examDate != null &&
      wilaya.trim().isNotEmpty;

  int get totalCandidates => candidatesB.length + candidatesA.length;
}

class ReportCubit extends Cubit<ReportState> {
  ReportCubit() : super(const ReportState());

  void updateWilaya(String wilaya) {
    emit(state.copyWith(wilaya: wilaya));
  }

  void updateDepositDate(DateTime date) {
    emit(state.copyWith(depositDate: date));
  }

  void updateExamDate(DateTime date) {
    emit(state.copyWith(examDate: date));
  }

  // ── Category B ──
  void addCandidateB(CandidateModel candidate) {
    if (state.candidatesB.length >= AppConstants.maxCandidatesB) return;
    emit(state.copyWith(candidatesB: [...state.candidatesB, candidate]));
  }

  void updateCandidateB(int index, CandidateModel candidate) {
    final list = List<CandidateModel>.from(state.candidatesB);
    list[index] = candidate;
    emit(state.copyWith(candidatesB: list));
  }

  void removeCandidateB(int index) {
    final list = List<CandidateModel>.from(state.candidatesB);
    list.removeAt(index);
    emit(state.copyWith(candidatesB: list));
  }

  // ── Category A ──
  void addCandidateA(CandidateModel candidate) {
    if (state.candidatesA.length >= AppConstants.maxCandidatesA) return;
    emit(state.copyWith(candidatesA: [...state.candidatesA, candidate]));
  }

  void updateCandidateA(int index, CandidateModel candidate) {
    final list = List<CandidateModel>.from(state.candidatesA);
    list[index] = candidate;
    emit(state.copyWith(candidatesA: list));
  }

  void removeCandidateA(int index) {
    final list = List<CandidateModel>.from(state.candidatesA);
    list.removeAt(index);
    emit(state.copyWith(candidatesA: list));
  }

  void reset() {
    emit(const ReportState());
  }
}
