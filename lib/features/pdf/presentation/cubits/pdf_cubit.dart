import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permis_app/features/pdf/data/pdf_generator.dart';
import 'package:permis_app/features/session/data/models/report_model.dart';
import 'package:permis_app/features/session/data/repositories/session_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:permis_app/features/session/presentation/cubits/report_cubit.dart';

// ── States ──
abstract class PdfState {}

class PdfInitial extends PdfState {}

class PdfLoading extends PdfState {}

class PdfSuccess extends PdfState {
  final Uint8List bytes;
  final String filePath; // Empty on Web
  PdfSuccess({required this.bytes, required this.filePath});
}

class PdfError extends PdfState {
  final String message;
  PdfError(this.message);
}

// ── Cubit ──
class PdfCubit extends Cubit<PdfState> {
  final SessionRepository _repository;

  PdfCubit(this._repository) : super(PdfInitial());

  Future<void> generateFromState(ReportState reportState) async {
    emit(PdfLoading());
    try {
      final report = ReportModel(
        id: const Uuid().v4(),
        wilaya: reportState.wilaya,
        depositDate: reportState.depositDate ?? DateTime.now(),
        examDate: reportState.examDate ?? DateTime.now(),
        candidatesB: reportState.candidatesB,
        candidatesA: reportState.candidatesA,
        createdAt: DateTime.now(),
      );

      final bytes = await PdfGenerator.generate(report);

      String filePath = '';
      if (!kIsWeb) {
        // Save PDF file locally
        final dir = await getApplicationDocumentsDirectory();
        final pdfDir = Directory('${dir.path}/permis_pdfs');
        if (!await pdfDir.exists()) {
          await pdfDir.create(recursive: true);
        }
        filePath = '${pdfDir.path}/report_${report.id.substring(0, 8)}.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
      } else {
        // On web we just have the bytes for layout/printing
        filePath = 'web_report_${report.id.substring(0, 8)}.pdf';
      }

      // Save report with PDF path to Hive
      final savedReport = report.copyWith(pdfPath: filePath);
      await _repository.saveReport(savedReport);

      emit(PdfSuccess(bytes: bytes, filePath: filePath));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> viewExistingPdf(ReportModel report) async {
    emit(PdfLoading());
    try {
      if (!kIsWeb && report.pdfPath != null) {
        final file = File(report.pdfPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          emit(PdfSuccess(bytes: bytes, filePath: report.pdfPath!));
          return;
        }
      }
      // Regenerate if file not found or on web
      final bytes = await PdfGenerator.generate(report);
      emit(PdfSuccess(bytes: bytes, filePath: report.pdfPath ?? ''));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }
}
