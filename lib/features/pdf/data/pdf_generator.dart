import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permis_app/features/session/data/models/report_model.dart';

class PdfGenerator {
  static const PdfColor _headerColor = PdfColor.fromInt(0xFFEEEEEE);

  // Row measurements (must be consistent between table and overlay)
  static const double _headerH = 18;
  static const double _rowH = 15;
  static const double _separatorH = 6;

  // Section sizes
  static const int _bRows = 15;
  static const int _aRows = 10;

  static Future<Uint8List> generate(ReportModel report) async {
    final regularData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
    final boldData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
    final regular = pw.Font.ttf(regularData);
    final bold = pw.Font.ttf(boldData);

    final dateFormat = DateFormat('yyyy/MM/dd');
    final pdf = pw.Document();

    final baseStyle = pw.TextStyle(font: regular, fontSize: 9);
    final boldStyle =
        pw.TextStyle(font: bold, fontSize: 9, fontWeight: pw.FontWeight.bold);
    final headerStyle =
        pw.TextStyle(font: bold, fontSize: 11, fontWeight: pw.FontWeight.bold);
    final subHeaderStyle =
        pw.TextStyle(font: bold, fontSize: 9, fontWeight: pw.FontWeight.bold);
    final titleStyle =
        pw.TextStyle(font: bold, fontSize: 13, fontWeight: pw.FontWeight.bold);
    final smallStyle = pw.TextStyle(font: regular, fontSize: 8);
    final smallBoldStyle =
        pw.TextStyle(font: bold, fontSize: 8, fontWeight: pw.FontWeight.bold);
    final cellStyle = pw.TextStyle(font: regular, fontSize: 7);
    final cellBoldStyle =
        pw.TextStyle(font: bold, fontSize: 7, fontWeight: pw.FontWeight.bold);
    final categoryStyle =
        pw.TextStyle(font: bold, fontSize: 22, fontWeight: pw.FontWeight.bold);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // ── TOP HEADER ──
              pw.Center(
                child: pw.Text(
                  'الجمهورية الجزائرية الديمقراطية الشعبية',
                  style: headerStyle,
                  textDirection: pw.TextDirection.rtl,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  'وزارة الداخلية و الجماعات المحلية و التهيئة العمرانية',
                  style: subHeaderStyle,
                  textDirection: pw.TextDirection.rtl,
                ),
              ),
              pw.SizedBox(height: 10),

              // ── stamp LEFT | المندوبية RIGHT ──
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // LEFT: stamp box
                  pw.Container(
                    width: 130,
                    height: 55,
                    decoration:
                        pw.BoxDecoration(border: pw.Border.all(width: 0.8)),
                    child: pw.Center(
                      child: pw.Text(
                        'ختم مدرسة تعليم السياقة',
                        style: smallBoldStyle,
                        textDirection: pw.TextDirection.rtl,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  // RIGHT: المندوبية
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'المندوبية الوطنية للأمن في الطرق',
                          style: boldStyle,
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.right,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'لولاية: ${report.wilaya}',
                          style: baseStyle,
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // ── TITLE BOX ──
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 24, vertical: 7),
                  decoration:
                      pw.BoxDecoration(border: pw.Border.all(width: 1.2)),
                  child: pw.Text(
                    'قائمة المترشحين لامتحان رخصة السياقة',
                    style: titleStyle,
                    textDirection: pw.TextDirection.rtl,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                  'النموذج رقم : 01',
                  style: smallStyle,
                  textDirection: pw.TextDirection.rtl,
                ),
                ]
              ),
              pw.SizedBox(height: 6),

              // ── INFO LINE ──
              // Visual order right→left: مركز الامتحان | تاريخ الايداع | تاريخ الامتحان
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  // Leftmost on paper
                  pw.Text(
                    'تاريخ الامتحان : ${dateFormat.format(report.examDate)}',
                    style: smallStyle,
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Text(
                    'تاريخ الايداع : ${dateFormat.format(report.depositDate)}',
                    style: smallStyle,
                    textDirection: pw.TextDirection.rtl,
                  ),
                  // Rightmost on paper
                  pw.Text(
                    'مركز الامتحان : ..................................',
                    style: smallStyle,
                    textDirection: pw.TextDirection.rtl,
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'إسم و لقب المفتش : ..................................',
                  style: smallStyle,
                  textDirection: pw.TextDirection.rtl,
                ),
              ),
              pw.SizedBox(height: 8),

              // ── COMBINED TABLE WITH STACKED CATEGORY LETTERS ──
              _buildCombinedTable(
                report: report,
                dateFormat: dateFormat,
                cellStyle: cellStyle,
                cellBoldStyle: cellBoldStyle,
                categoryStyle: categoryStyle,
              ),
              pw.SizedBox(height: 8),

              // ── FOOTER: stamp LEFT | stats RIGHT ──
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 45,
                    child: pw.Container(
                      height: 80,
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(width: 0.8)),
                      child: pw.Center(
                        child: pw.Text(
                          'ختم و إمضاء المفتش',
                          style: smallBoldStyle,
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    flex: 55,
                    child: _buildFooterTable(report, cellStyle, cellBoldStyle),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Builds the combined B+A table.
  /// الصنف column is removed from the table itself.
  /// Instead, the letter B/A is painted as an overlay using pw.Stack,
  /// positioned over the center of each section's rows.
  static pw.Widget _buildCombinedTable({
    required ReportModel report,
    required DateFormat dateFormat,
    required pw.TextStyle cellStyle,
    required pw.TextStyle cellBoldStyle,
    required pw.TextStyle categoryStyle,
  }) {
    // Column widths — NO الصنف column (it's an overlay)
    // Visual order left→right on paper (RTL):
    // النتيجة | تاريخ الإمتحان | طبيعة الإمتحان | الصنف(overlay) | تاريخ الميلاد | اللقب و الإسم | رقم التسجيل | الرقم
    final columnWidths = {
      0: const pw.FixedColumnWidth(40),  // النتيجة
      1: const pw.FixedColumnWidth(56),  // تاريخ الإمتحان
      2: const pw.FixedColumnWidth(62),  // طبيعة الإمتحان
      3: const pw.FixedColumnWidth(30),  // الصنف (cell exists but content = overlay)
      4: const pw.FixedColumnWidth(56),  // تاريخ الميلاد
      5: const pw.FlexColumnWidth(3),    // اللقب و الإسم
      6: const pw.FixedColumnWidth(52),  // رقم التسجيل
      7: const pw.FixedColumnWidth(26),  // الرقم
    };

    final headers = [
      'النتيجة',
      'تاريخ الإمتحان',
      'طبيعة الإمتحان',
      'الصنف',
      'تاريخ الميلاد',
      'اللقب و الإسم',
      'رقم التسجيل',
      'الرقم',
    ];

    pw.TableRow headerRow() => pw.TableRow(
          decoration: const pw.BoxDecoration(color: _headerColor),
          children: headers.map((h) => _tc(h, cellBoldStyle, _headerH)).toList(),
        );

    pw.TableRow dataRow(int index, dynamic c, DateFormat fmt) {
      return pw.TableRow(
        children: [
          _tc('', cellStyle, _rowH),
          _tc(c != null ? fmt.format(report.examDate) : '', cellStyle, _rowH),
          _tc(c?.examType ?? '', cellStyle, _rowH),
          _tc('', cellStyle, _rowH), // الصنف cell — kept EMPTY, letter is overlay
          _tc(c != null ? fmt.format(c.dateOfBirth) : '', cellStyle, _rowH),
          _tc(c?.fullName ?? '', cellStyle, _rowH),
          _tc(c?.registrationNumber ?? '', cellStyle, _rowH),
          _tc('${(index + 1).toString().padLeft(2, '0')}', cellStyle, _rowH),
        ],
      );
    }

    pw.TableRow separatorRow() => pw.TableRow(
          decoration: const pw.BoxDecoration(color: _headerColor),
          children: List.generate(8, (_) => _tc('', cellBoldStyle, _separatorH)),
        );

    final List<pw.TableRow> rows = [
      headerRow(),
      ...List.generate(_bRows, (i) {
        final bool has = i < report.candidatesB.length;
        return dataRow(i, has ? report.candidatesB[i] : null, dateFormat);
      }),
      separatorRow(),
      headerRow(),
      ...List.generate(_aRows, (i) {
        final bool has = i < report.candidatesA.length;
        return dataRow(i, has ? report.candidatesA[i] : null, dateFormat);
      }),
    ];

    final pw.Widget table = pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: columnWidths,
      children: rows,
    );

    // ── Calculate vertical offsets for the overlay cells ──
    // Section B: starts after header row
    final double bDataTop = _headerH;
    final double bSectionHeight = _bRows * _rowH;

    // Section A: starts after B header + B rows + separator + A header
    final double aDataTop = _headerH + bSectionHeight + _separatorH + _headerH;
    final double aSectionHeight = _aRows * _rowH;

    // الصنف column: it's the 4th column from left (index 3).
    // Left offset = sum of widths of columns 0,1,2
    const double colLeft = 40 + 56 + 62;

    return pw.Stack(
      children: [
        table,
        // B section merged cell overlay
        pw.Positioned(
          left: colLeft,
          top: bDataTop,
          child: pw.Container(
            width: 30,
            height: bSectionHeight,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(width: 0.5),
            ),
            child: pw.Center(
              child: pw.Text(
                'B',
                style: categoryStyle,
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
        ),
        // A section merged cell overlay
        pw.Positioned(
          left: colLeft,
          top: aDataTop,
          child: pw.Container(
            width: 30,
            height: aSectionHeight,
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(width: 0.5),
            ),
            child: pw.Center(
              child: pw.Text(
                'A',
                style: categoryStyle,
                textAlign: pw.TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _tc(String text, pw.TextStyle style, double h) {
    return pw.Container(
      height: h,
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(horizontal: 2),
      child: pw.Text(
        text,
        style: style,
        textDirection: pw.TextDirection.rtl,
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildFooterTable(
    ReportModel report,
    pw.TextStyle cellStyle,
    pw.TextStyle cellBoldStyle,
  ) {
    final types = ['قانون المرور', 'مناورات', 'سياقة'];
    int totalExamined = 0;

    final dataRows = types.map((type) {
      final int examined = report.countByExamType(type);
      totalExamined += examined;
      return pw.TableRow(children: [
        _tc('', cellStyle, 18),
        _tc(examined > 0 ? '$examined' : '', cellStyle, 18),
        _tc(type, cellStyle, 18),
      ]);
    }).toList();

    dataRows.add(pw.TableRow(
      decoration: const pw.BoxDecoration(color: _headerColor),
      children: [
        _tc('', cellBoldStyle, 18),
        _tc(totalExamined > 0 ? '$totalExamined' : '', cellBoldStyle, 18),
        _tc('المجموع', cellBoldStyle, 18),
      ],
    ));

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _headerColor),
          children: [
            _tc('عدد المترشحين الناجحين', cellBoldStyle, 18),
            _tc('عدد المترشحين الممتحنين', cellBoldStyle, 18),
            _tc('طبيعة الإمتحان', cellBoldStyle, 18),
          ],
        ),
        ...dataRows,
      ],
    );
  }
}