class CandidateModel {
  final String registrationNumber;
  final String fullName;
  final DateTime dateOfBirth;
  final String examType;
  final String category;

  const CandidateModel({
    required this.registrationNumber,
    required this.fullName,
    required this.dateOfBirth,
    required this.examType,
    required this.category,
  });

  CandidateModel copyWith({
    String? registrationNumber,
    String? fullName,
    DateTime? dateOfBirth,
    String? examType,
    String? category,
  }) {
    return CandidateModel(
      registrationNumber: registrationNumber ?? this.registrationNumber,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      examType: examType ?? this.examType,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() => {
        'registrationNumber': registrationNumber,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'examType': examType,
        'category': category,
      };

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      registrationNumber: json['registrationNumber'] as String,
      fullName: json['fullName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      examType: json['examType'] as String,
      category: json['category'] as String,
    );
  }
}
