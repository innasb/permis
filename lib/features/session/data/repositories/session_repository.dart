import 'dart:convert';
import 'package:hive_ce/hive_ce.dart';
import 'package:permis_app/features/session/data/models/report_model.dart';

class SessionRepository {
  final Box<String> _box;

  SessionRepository(this._box);

  Future<void> saveReport(ReportModel report) async {
    await _box.put(report.id, jsonEncode(report.toJson()));
  }

  List<ReportModel> getAllReports() {
    return _box.values
        .map((json) => ReportModel.fromJson(
            jsonDecode(json) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  ReportModel? getReport(String id) {
    final json = _box.get(id);
    if (json == null) return null;
    return ReportModel.fromJson(
        jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> deleteReport(String id) async {
    await _box.delete(id);
  }
}
