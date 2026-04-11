import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:permis_app/core/theme/app_theme.dart';
import 'package:permis_app/core/router/app_router.dart';
import 'package:permis_app/features/pdf/presentation/cubits/pdf_cubit.dart';
import 'package:permis_app/features/session/presentation/cubits/report_cubit.dart';
import 'package:permis_app/features/session/presentation/cubits/session_history_cubit.dart';
import 'package:printing/printing.dart';

class SessionDrawer extends StatelessWidget {
  const SessionDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Refresh sessions when drawer opens
    context.read<SessionHistoryCubit>().loadSessions();

    return Drawer(
      child: Column(
        children: [
          // Drawer header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.history, color: Colors.white, size: 36),
                SizedBox(height: 12),
                Text(
                  'سجل التقارير',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'عرض و إعادة طباعة التقارير السابقة',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          // Session list
          Expanded(
            child: BlocBuilder<SessionHistoryCubit, SessionHistoryState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'لا توجد تقارير محفوظة',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final session = state.sessions[index];
                    final dateFormat = DateFormat('yyyy/MM/dd');

                    return Card(
                      margin: EdgeInsets.zero,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        title: Text(
                          'تقرير ${session.wilaya}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${dateFormat.format(session.createdAt)} — ${session.totalCandidates} مترشح',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.print,
                                  color: AppTheme.primaryGreen, size: 20),
                              tooltip: 'طباعة',
                              onPressed: () async {
                                Navigator.of(context).pop(); // close drawer
                                final pdfCubit = context.read<PdfCubit>();
                                await pdfCubit.viewExistingPdf(session);
                                if (context.mounted) {
                                  final pdfState = pdfCubit.state;
                                  if (pdfState is PdfSuccess) {
                                    await Printing.layoutPdf(
                                      onLayout: (_) async => pdfState.bytes,
                                    );
                                  }
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppTheme.accentRed, size: 20),
                              tooltip: 'حذف',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('حذف التقرير'),
                                    content: const Text(
                                        'هل أنت متأكد من حذف هذا التقرير؟'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context
                                              .read<SessionHistoryCubit>()
                                              .deleteSession(session.id);
                                          Navigator.of(ctx).pop();
                                        },
                                        child: const Text(
                                          'حذف',
                                          style:
                                              TextStyle(color: AppTheme.accentRed),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // New Session Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<ReportCubit>().reset();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.candidates,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text(
                    'إنشاء امتحان جديد',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
