import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permis_app/core/constants/app_constants.dart';
import 'package:permis_app/core/theme/app_theme.dart';
import 'package:permis_app/core/router/app_router.dart';
import 'package:permis_app/features/session/data/models/candidate_model.dart';
import 'package:permis_app/features/session/presentation/cubits/report_cubit.dart';
import 'package:permis_app/features/session/presentation/widgets/candidate_card.dart';
import 'package:permis_app/features/session/presentation/widgets/candidate_form_dialog.dart';
import 'package:permis_app/features/session/presentation/widgets/session_drawer.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addCandidate(String category) async {
    final cubit = context.read<ReportCubit>();
    final state = cubit.state;
    final currentCount =
        category == 'B' ? state.candidatesB.length : state.candidatesA.length;
    final max =
        category == 'B' ? AppConstants.maxCandidatesB : AppConstants.maxCandidatesA;

    if (currentCount >= max) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم بلوغ الحد الأقصى ($max) لصنف $category'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
      return;
    }

    final result = await showDialog<CandidateModel>(
      context: context,
      builder: (_) => CandidateFormDialog(category: category),
    );

    if (result != null) {
      if (category == 'B') {
        cubit.addCandidateB(result);
      } else {
        cubit.addCandidateA(result);
      }
    }
  }

  Future<void> _editCandidate(String category, int index,
      CandidateModel existing) async {
    final result = await showDialog<CandidateModel>(
      context: context,
      builder: (_) => CandidateFormDialog(
        category: category,
        existingCandidate: existing,
      ),
    );

    if (result != null) {
      final cubit = context.read<ReportCubit>();
      if (category == 'B') {
        cubit.updateCandidateB(index, result);
      } else {
        cubit.updateCandidateA(index, result);
      }
    }
  }

  void _deleteCandidate(String category, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف المترشح'),
        content: const Text('هل أنت متأكد من حذف هذا المترشح؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              final cubit = context.read<ReportCubit>();
              if (category == 'B') {
                cubit.removeCandidateB(index);
              } else {
                cubit.removeCandidateA(index);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('حذف', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  // PDF generation moved to HeaderScreen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المترشحون'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'صنف B', icon: Icon(Icons.directions_car, size: 18)),
            Tab(text: 'صنف A', icon: Icon(Icons.two_wheeler, size: 18)),
          ],
        ),
      ),
      drawer: const SessionDrawer(),
      body: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCandidatesList(
                category: 'B',
                candidates: state.candidatesB,
                max: AppConstants.maxCandidatesB,
              ),
              _buildCandidatesList(
                category: 'A',
                candidates: state.candidatesA,
                max: AppConstants.maxCandidatesA,
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<ReportCubit, ReportState>(
        builder: (context, state) {
          final hasCandidates = state.totalCandidates > 0;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Add candidate FAB
                FloatingActionButton.extended(
                  heroTag: 'add',
                  onPressed: () {
                    final category = _tabController.index == 0 ? 'B' : 'A';
                    _addCandidate(category);
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('إضافة مترشح'),
                ),
                // Next FAB
                FloatingActionButton.extended(
                  heroTag: 'next',
                  onPressed: hasCandidates
                      ? () {
                          Navigator.pushNamed(context, AppRouter.header);
                        }
                      : null,
                  backgroundColor:
                      hasCandidates ? AppTheme.primaryGreen : Colors.grey.shade400,
                  elevation: hasCandidates ? 6 : 0,
                  icon: const Icon(Icons.arrow_back), // Arrow acts as forward in RTL
                  label: const Text('التالي'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildCandidatesList({
    required String category,
    required List<CandidateModel> candidates,
    required int max,
  }) {
    if (candidates.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'لا يوجد مترشحون في صنف $category',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على + لإضافة مترشح',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Counter bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: AppTheme.primaryGreen.withValues(alpha: 0.05),
          child: Text(
            'صنف $category — ${candidates.length} / $max مترشح',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 120),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              return CandidateCard(
                candidate: candidates[index],
                index: index,
                onEdit: () =>
                    _editCandidate(category, index, candidates[index]),
                onDelete: () => _deleteCandidate(category, index),
              );
            },
          ),
        ),
      ],
    );
  }
}
