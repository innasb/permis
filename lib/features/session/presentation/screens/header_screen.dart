import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permis_app/features/pdf/presentation/cubits/pdf_cubit.dart';
import 'package:permis_app/features/pdf/presentation/screens/pdf_preview_screen.dart';
import 'package:intl/intl.dart';
import 'package:permis_app/core/constants/app_constants.dart';
import 'package:permis_app/core/theme/app_theme.dart';
import 'package:permis_app/features/session/presentation/cubits/report_cubit.dart';
import 'package:permis_app/features/session/presentation/widgets/session_drawer.dart';

class HeaderScreen extends StatefulWidget {
  const HeaderScreen({super.key});

  @override
  State<HeaderScreen> createState() => _HeaderScreenState();
}

class _HeaderScreenState extends State<HeaderScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _wilayaController;
  final _dateFormat = DateFormat('yyyy/MM/dd');
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<ReportCubit>();
    _wilayaController = TextEditingController(text: cubit.state.wilaya);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _wilayaController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isDeposit) async {
    final cubit = context.read<ReportCubit>();
    final initial = isDeposit
        ? cubit.state.depositDate ?? DateTime.now()
        : cubit.state.examDate ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      if (isDeposit) {
        cubit.updateDepositDate(picked);
      } else {
        cubit.updateExamDate(picked);
      }
    }
  }

  Future<void> _generatePdf() async {
    final reportState = context.read<ReportCubit>().state;

    // Validate
    if (!reportState.isHeaderValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء بيانات الامتحان أولاً (التاريخ و الولاية)'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    if (reportState.totalCandidates == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة مترشح واحد على الأقل'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final pdfCubit = context.read<PdfCubit>();
    await pdfCubit.generateFromState(reportState);

    if (!mounted) return;
    final pdfState = pdfCubit.state;
    if (pdfState is PdfSuccess) {
      if (mounted) {
        setState(() {
          _isSuccess = true;
        });
      }

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfPreviewScreen(
              pdfBytes: pdfState.bytes,
              title: 'معاينة التقرير',
            ),
          ),
        );
      }

      if (mounted) {
        setState(() {
          _isSuccess = false;
        });
      }
    } else if (pdfState is PdfError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${pdfState.message}'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بيانات الامتحان'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
            ),
          ),
        ),
      ),
      drawer: const SessionDrawer(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: BlocBuilder<ReportCubit, ReportState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Logo / Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.drive_eta, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'قائمة المترشحين لامتحان رخصة السياقة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Form Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'معلومات الامتحان',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const Divider(height: 24),

                          // Wilaya
                          TextFormField(
                            controller: _wilayaController,
                            decoration: const InputDecoration(
                              labelText: 'ولاية',
                              prefixIcon: Icon(Icons.location_city),
                            ),
                            onChanged: (v) =>
                                context.read<ReportCubit>().updateWilaya(v),
                          ),
                          const SizedBox(height: 16),

                          // Deposit date
                          _buildDateTile(
                            context: context,
                            label: 'تاريخ الإيداع',
                            icon: Icons.calendar_month,
                            date: state.depositDate,
                            onTap: () => _pickDate(context, true),
                          ),
                          const SizedBox(height: 12),

                          // Exam date
                          _buildDateTile(
                            context: context,
                            label: 'تاريخ الامتحان',
                            icon: Icons.event,
                            date: state.examDate,
                            onTap: () => _pickDate(context, false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Summary card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people, color: AppTheme.primaryGreen),
                              const SizedBox(width: 8),
                              const Text(
                                'المترشحون',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${state.totalCandidates} مترشح',
                                  style: const TextStyle(
                                    color: AppTheme.primaryGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              _categoryBadge(
                                  'B', state.candidatesB.length, AppConstants.maxCandidatesB),
                              const SizedBox(width: 16),
                              _categoryBadge(
                                  'A', state.candidatesA.length, AppConstants.maxCandidatesA),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Generate button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: BlocBuilder<PdfCubit, PdfState>(
                      builder: (context, pdfState) {
                        final isLoading = pdfState is PdfLoading;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isSuccess
                              ? Container(
                                  key: const ValueKey('success'),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.check,
                                        color: Colors.white, size: 30),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  key: const ValueKey('button'),
                                  onPressed: isLoading ? null : _generatePdf,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  ),
                                  icon: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2))
                                      : const Icon(Icons.picture_as_pdf),
                                  label: Text(
                                    isLoading
                                        ? 'جاري التوليد...'
                                        : 'توليد و معاينة PDF',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateTile({
    required BuildContext context,
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
        child: Text(
          date != null ? _dateFormat.format(date) : 'اختر التاريخ',
          style: TextStyle(
            color: date != null ? AppTheme.textDark : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _categoryBadge(String cat, int count, int max) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: cat == 'B'
              ? Colors.blue.withValues(alpha: 0.08)
              : Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cat == 'B'
                ? Colors.blue.withValues(alpha: 0.3)
                : Colors.orange.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              'صنف $cat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: cat == 'B' ? Colors.blue.shade700 : Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count / $max',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: cat == 'B' ? Colors.blue.shade700 : Colors.orange.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
