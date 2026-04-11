import 'package:permis_app/features/session/data/models/candidate_model.dart';

class ReportModel {
  final String id;
  final String wilaya;
  final DateTime depositDate;
  final DateTime examDate;
  final List<CandidateModel> candidatesB;
  final List<CandidateModel> candidatesA;
  final DateTime createdAt;
  final String? pdfPath;

  const ReportModel({
    required this.id,
    required this.wilaya,
    required this.depositDate,
    required this.examDate,
    required this.candidatesB,
    required this.candidatesA,
    required this.createdAt,
    this.pdfPath,
  });

  ReportModel copyWith({
    String? id,
    String? wilaya,
    DateTime? depositDate,
    DateTime? examDate,
    List<CandidateModel>? candidatesB,
    List<CandidateModel>? candidatesA,
    DateTime? createdAt,
    String? pdfPath,
  }) {
    return ReportModel(
      id: id ?? this.id,
      wilaya: wilaya ?? this.wilaya,
      depositDate: depositDate ?? this.depositDate,
      examDate: examDate ?? this.examDate,
      candidatesB: candidatesB ?? this.candidatesB,
      candidatesA: candidatesA ?? this.candidatesA,
      createdAt: createdAt ?? this.createdAt,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'wilaya': wilaya,
        'depositDate': depositDate.toIso8601String(),
        'examDate': examDate.toIso8601String(),
        'candidatesB': candidatesB.map((c) => c.toJson()).toList(),
        'candidatesA': candidatesA.map((c) => c.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'pdfPath': pdfPath,
      };

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      wilaya: json['wilaya'] as String,
      depositDate: DateTime.parse(json['depositDate'] as String),
      examDate: DateTime.parse(json['examDate'] as String),
      candidatesB: (json['candidatesB'] as List)
          .map((e) => CandidateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      candidatesA: (json['candidatesA'] as List)
          .map((e) => CandidateModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      pdfPath: json['pdfPath'] as String?,
    );
  }

  int get totalCandidates => candidatesB.length + candidatesA.length;

  /// Count candidates by exam type across both categories
  int countByExamType(String examType) {
    return candidatesB.where((c) => c.examType == examType).length +
        candidatesA.where((c) => c.examType == examType).length;
  }
}
