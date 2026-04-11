import 'package:flutter/material.dart';
import 'package:permis_app/core/theme/app_theme.dart';
import 'package:permis_app/features/session/data/models/candidate_model.dart';
import 'package:intl/intl.dart';

class CandidateCard extends StatelessWidget {
  final CandidateModel candidate;
  final int index;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CandidateCard({
    super.key,
    required this.candidate,
    required this.index,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy/MM/dd');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Number badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}'.padLeft(2, '0'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name
                Expanded(
                  child: Text(
                    candidate.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Actions
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  color: AppTheme.primaryGreen,
                  onPressed: onEdit,
                  tooltip: 'تعديل',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppTheme.accentRed,
                  onPressed: onDelete,
                  tooltip: 'حذف',
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            // Details row
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                if (candidate.registrationNumber.isNotEmpty)
                  _infoChip(
                    Icons.tag,
                    'رقم التسجيل: ${candidate.registrationNumber}',
                  ),
                _infoChip(
                  Icons.calendar_today,
                  'تاريخ الميلاد: ${dateFormat.format(candidate.dateOfBirth)}',
                ),
                _infoChip(
                  Icons.assignment,
                  candidate.examType,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryGreen),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
