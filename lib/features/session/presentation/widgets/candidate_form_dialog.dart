import 'package:flutter/material.dart';
import 'package:permis_app/core/constants/app_constants.dart';
import 'package:permis_app/core/theme/app_theme.dart';
import 'package:permis_app/features/session/data/models/candidate_model.dart';
import 'package:intl/intl.dart';

class CandidateFormDialog extends StatefulWidget {
  final String category;
  final CandidateModel? existingCandidate;

  const CandidateFormDialog({
    super.key,
    required this.category,
    this.existingCandidate,
  });

  @override
  State<CandidateFormDialog> createState() => _CandidateFormDialogState();
}

class _CandidateFormDialogState extends State<CandidateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _regController;
  late TextEditingController _nameController;
  DateTime? _dateOfBirth;
  String? _examType;
  final _dateFormat = DateFormat('yyyy/MM/dd');

  @override
  void initState() {
    super.initState();
    _regController = TextEditingController(
      text: widget.existingCandidate?.registrationNumber ?? '',
    );
    _nameController = TextEditingController(
      text: widget.existingCandidate?.fullName ?? '',
    );
    _dateOfBirth = widget.existingCandidate?.dateOfBirth;
    _examType = widget.existingCandidate?.examType;
  }

  @override
  void dispose() {
    _regController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار تاريخ الميلاد')),
      );
      return;
    }
    if (_examType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار طبيعة الإمتحان')),
      );
      return;
    }

    final candidate = CandidateModel(
      registrationNumber: _regController.text.trim(),
      fullName: _nameController.text.trim(),
      dateOfBirth: _dateOfBirth!,
      examType: _examType!,
      category: widget.category,
    );

    Navigator.of(context).pop(candidate);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCandidate != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isEditing ? 'تعديل مترشح' : 'إضافة مترشح',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Registration number
                TextFormField(
                  controller: _regController,
                  decoration: const InputDecoration(
                    labelText: 'رقم التسجيل',
                    prefixIcon: Icon(Icons.tag),
                  ),
                ),
                const SizedBox(height: 16),

                // Full name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اللقب و الإسم *',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'هذا الحقل مطلوب';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date of birth
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الميلاد *',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _dateOfBirth != null
                          ? _dateFormat.format(_dateOfBirth!)
                          : 'اختر التاريخ',
                      style: TextStyle(
                        color: _dateOfBirth != null
                            ? AppTheme.textDark
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Exam type dropdown
                DropdownButtonFormField<String>(
                  value: _examType,
                  decoration: const InputDecoration(
                    labelText: 'طبيعة الإمتحان *',
                    prefixIcon: Icon(Icons.assignment),
                  ),
                  items: AppConstants.examTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) => setState(() => _examType = value),
                  validator: (v) {
                    if (v == null) return 'هذا الحقل مطلوب';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('إلغاء'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        child: Text(isEditing ? 'تحديث' : 'إضافة'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
