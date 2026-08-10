import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/founder/models/mock_data.dart';

/// Bottom-sheet dialog for adding a new VDR document.
/// Returns a [VdrDocument] when the user taps Confirm, or null on cancel.
class AddDocumentDialog extends StatefulWidget {
  const AddDocumentDialog({super.key});

  @override
  State<AddDocumentDialog> createState() => _AddDocumentDialogState();
}

class _AddDocumentDialogState extends State<AddDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  String _selectedCategory = 'Financial';
  String? _pickedFilePath;
  String? _pickedFileName;
  double _pickedFileSizeMB = 0.0;
  bool _isPicking = false;

  static const List<String> _categories = [
    'Financial',
    'Legal',
    'Technical',
    'Corporate',
    'Other',
  ];

  static const Map<String, String> _allowedExtensions = {
    'pdf': 'pdf',
    'xlsx': 'xlsx',
    'xls': 'xlsx',
    'docx': 'docx',
    'doc': 'docx',
    'pptx': 'pptx',
    'ppt': 'pptx',
  };

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _isPicking = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions.keys.toList(),
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final sizeBytes = await file.length();
        setState(() {
          _pickedFilePath = file.path;
          _pickedFileName = result.files.single.name;
          _pickedFileSizeMB = sizeBytes / (1024 * 1024);
        });
        // Auto-fill document name from file name (without extension)
        if (_nameController.text.trim().isEmpty) {
          final nameWithoutExt = result.files.single.name.replaceAll(RegExp(r'\.[^.]+$'), '');
          _nameController.text = nameWithoutExt;
        }
      }
    } finally {
      setState(() => _isPicking = false);
    }
  }

  String _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    return _allowedExtensions[ext] ?? 'pdf';
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a file first.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final doc = VdrDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedCategory,
      fileType: _getFileType(_pickedFileName!),
      sizeMB: double.parse(_pickedFileSizeMB.toStringAsFixed(2)),
      uploadedAt: DateTime.now(),
      isLocked: true,
      viewCount: 0,
      filePath: _pickedFilePath,
    );

    Navigator.of(context).pop(doc);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppDimensions.xl,
        right: AppDimensions.xl,
        top: AppDimensions.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppDimensions.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLightBlue,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(Icons.upload_file, color: AppColors.primaryBlue, size: 22),
                ),
                const SizedBox(width: AppDimensions.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Document', style: AppTextStyles.heading3),
                    Text(
                      'Upload to your Virtual Data Room',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.xl),

            // Document Name
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                labelText: 'Document Name',
                hintText: 'e.g., Q2 Financial Report',
                prefixIcon: const Icon(Icons.description_outlined, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                ),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Document name is required' : null,
            ),
            const SizedBox(height: AppDimensions.base),

            // Category Dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(Icons.folder_outlined, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                ),
              ),
              items: _categories.map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat, style: AppTextStyles.bodyMedium),
              )).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val ?? _selectedCategory),
            ),
            const SizedBox(height: AppDimensions.base),

            // File Picker
            GestureDetector(
              onTap: _isPicking ? null : _pickFile,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.base),
                decoration: BoxDecoration(
                  color: _pickedFilePath != null
                      ? AppColors.successGreen.withAlpha(15)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: _pickedFilePath != null
                        ? AppColors.successGreen
                        : AppColors.borderLight,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _pickedFilePath != null ? Icons.check_circle : Icons.attach_file,
                      color: _pickedFilePath != null ? AppColors.successGreen : AppColors.textTertiary,
                      size: 20,
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: _isPicking
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pickedFileName ?? 'Tap to pick a file',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: _pickedFilePath != null
                                        ? AppColors.textPrimary
                                        : AppColors.textTertiary,
                                    fontWeight: _pickedFilePath != null
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (_pickedFileSizeMB > 0)
                                  Text(
                                    '${_pickedFileSizeMB.toStringAsFixed(2)} MB',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    if (_pickedFilePath != null)
                      GestureDetector(
                        onTap: () => setState(() {
                          _pickedFilePath = null;
                          _pickedFileName = null;
                          _pickedFileSizeMB = 0.0;
                        }),
                        child: const Icon(Icons.close, color: AppColors.textTertiary, size: 18),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                      side: const BorderSide(color: AppColors.borderMedium),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                    ),
                    child: Text('Cancel', style: AppTextStyles.bodyMedium),
                  ),
                ),
                const SizedBox(width: AppDimensions.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _confirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.textOnDark,
                      padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                    ),
                    child: Text(
                      'Add Document',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
