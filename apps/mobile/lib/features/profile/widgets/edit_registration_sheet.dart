import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/ui.dart';
import '../models/profile_models.dart';

/// Cupertino Bottom Sheet: Edit Candidate Registration Details
class EditRegistrationSheet extends StatefulWidget {
  final ProfileCandidateRecord record;
  final ValueChanged<ProfileCandidateRecord> onSaveRecord;
  final ValueChanged<String> onShowToast;
  final String? initialFocusField;

  const EditRegistrationSheet({
    super.key,
    required this.record,
    required this.onSaveRecord,
    required this.onShowToast,
    this.initialFocusField,
  });

  static Future<void> show(
    BuildContext context, {
    required ProfileCandidateRecord record,
    required ValueChanged<ProfileCandidateRecord> onSaveRecord,
    required ValueChanged<String> onShowToast,
    String? initialFocusField,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => EditRegistrationSheet(
        record: record,
        onSaveRecord: onSaveRecord,
        onShowToast: onShowToast,
        initialFocusField: initialFocusField,
      ),
    );
  }

  @override
  State<EditRegistrationSheet> createState() => _EditRegistrationSheetState();
}

class _EditRegistrationSheetState extends State<EditRegistrationSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late String _gender;
  late String _grade;
  late String _stream;

  bool _isSaving = false;

  final List<String> _genderOptions = const ['Male', 'Female'];
  final List<String> _gradeOptions = const ['Grade 9', 'Grade 10', 'Grade 11', 'Grade 12'];
  final List<String> _streamOptions = const ['Natural Science', 'Social Science'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.record.name);
    _phoneCtrl = TextEditingController(text: widget.record.phone);
    _gender = widget.record.gender;
    _grade = widget.record.grade;
    _stream = widget.record.stream;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    final cleanName = _nameCtrl.text.trim().isEmpty ? 'Aymen Mubarek' : _nameCtrl.text.trim();
    final cleanPhone = _phoneCtrl.text.trim().isEmpty ? '+251 913 951 112' : _phoneCtrl.text.trim();

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 680));

    final updated = widget.record.copyWith(
      name: cleanName,
      phone: cleanPhone,
      gender: _gender,
      grade: _grade,
      stream: _stream,
    );

    widget.onSaveRecord(updated);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
      widget.onShowToast('Registration details updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    final accentSoftColor = isDark ? AppColors.accentSoftDark : AppColors.accentSoftLight;
    final subtextColor = isDark ? AppColors.darkSubtext : AppColors.lightSubtext;
    final lineColor = isDark ? AppColors.darkLine : AppColors.lightLine;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final sheetBg = isDark ? AppColors.darkRaised : AppColors.lightRaised;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: lineColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle & Header
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 8),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: lineColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CANDIDATE RECORD',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                              color: accentColor,
                            ),
                          ),
                          Text(
                            'Edit Registration Details',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      AcedexBounceable(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: surfaceColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: lineColor),
                          ),
                          alignment: Alignment.center,
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            color: theme.colorScheme.onSurface,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Full Name Input
                    Text(
                      'FULL NAME',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameCtrl,
                      autofocus: widget.initialFocusField == 'name',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: surfaceColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: lineColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: lineColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accentColor, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Phone Number Input
                    Text(
                      'PHONE NUMBER (+251)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      autofocus: widget.initialFocusField == 'phone',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: surfaceColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: lineColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: lineColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: accentColor, width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Gender Selector
                    Text(
                      'GENDER',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (final g in _genderOptions) ...[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: AcedexBounceable(
                                onTap: () => setState(() => _gender = g),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: _gender == g ? accentSoftColor : surfaceColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _gender == g ? accentColor : lineColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    g,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: _gender == g ? accentColor : subtextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Grade Level Selector
                    Text(
                      'GRADE LEVEL',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (final gr in _gradeOptions) ...[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2.5),
                              child: AcedexBounceable(
                                onTap: () => setState(() => _grade = gr),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: _grade == gr ? accentSoftColor : surfaceColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _grade == gr ? accentColor : lineColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    gr.replaceAll('Grade ', 'G'),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _grade == gr ? accentColor : subtextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Curriculum Stream Selector
                    Text(
                      'CURRICULUM STREAM',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        for (final st in _streamOptions) ...[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: AcedexBounceable(
                                onTap: () => setState(() => _stream = st),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9),
                                  decoration: BoxDecoration(
                                    color: _stream == st ? accentSoftColor : surfaceColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _stream == st ? accentColor : lineColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    st,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: _stream == st ? accentColor : subtextColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Save Changes Button
                    AcedexBounceable(
                      onTap: _isSaving ? null : _handleSave,
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8A2BA3).withValues(alpha: 0.38),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: _isSaving
                            ? const AcedexDotsLoader(color: Colors.white, dotSize: 5, gap: 4)
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
