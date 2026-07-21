import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/core/utils/responsive_utils.dart';
import 'package:navojit_tech/features/founder/providers/pitch_wizard_provider.dart';
import 'package:navojit_tech/features/founder/widgets/media_upload_zone.dart';

class MediaUploadScreen extends ConsumerStatefulWidget {
  const MediaUploadScreen({super.key});

  @override
  ConsumerState<MediaUploadScreen> createState() => _MediaUploadScreenState();
}

class _MediaUploadScreenState extends ConsumerState<MediaUploadScreen> {
  late TextEditingController _videoLinkController;

  @override
  void initState() {
    super.initState();
    _videoLinkController = TextEditingController();
    _videoLinkController.addListener(() {
      ref.read(mediaUploadProvider.notifier).setVideoUrl(_videoLinkController.text);
    });
  }

  @override
  void dispose() {
    _videoLinkController.dispose();
    super.dispose();
  }

  String? _validateVideoLink(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^(https?\:\/\/)?(www\.)?(youtube\.com|youtu\.be|vimeo\.com|loom\.com)\/.+$');
    if (!regex.hasMatch(value)) {
      return 'Please enter a valid YouTube, Vimeo, or Loom link';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mediaUploadProvider);
    final notifier = ref.read(mediaUploadProvider.notifier);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        title: const Text('Media & Documents'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidthWide),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: isDesktop
                ? _buildDesktopLayout(state, notifier)
                : _buildMobileLayout(state, notifier),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            border: Border(top: BorderSide(color: AppColors.borderLight)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidthWide),
            child: ElevatedButton(
              onPressed: () async {
                try {
                  final mediaState = ref.read(mediaUploadProvider);
                  final wizardNotifier = ref.read(pitchWizardProvider.notifier);
                  await wizardNotifier.submit(mediaState.videoUrl ?? '', mediaState.files);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pitch and Media uploaded successfully!'),
                        backgroundColor: AppColors.successGreen,
                      ),
                    );
                    context.go('/founder/vdr');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppColors.errorRed,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.surfaceWhite,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
              ),
              child: const Text('Save & Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoLinkCard(bool isDesktop) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(isDesktop ? AppDimensions.xxl : AppDimensions.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Icon(
              Icons.video_library,
              color: AppColors.textTertiary,
              size: 28,
            ),
          ),
          const SizedBox(height: AppDimensions.lg),
          Text(
            '60-Second Video',
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Paste YouTube, Vimeo, or Loom link',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.lg),
          TextFormField(
            controller: _videoLinkController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _validateVideoLink,
            decoration: InputDecoration(
              labelText: 'Pitch Video Link',
              hintText: 'Paste link here',
              prefixIcon: const Icon(Icons.link, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.surfaceWhite,
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
                borderSide: const BorderSide(color: AppColors.primaryBlue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(MediaUploadState state, MediaUploadNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Pitch Materials', style: AppTextStyles.heading2),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Provide your pitch deck and supporting materials to give investors the full picture.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppDimensions.xxl),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppDimensions.xl,
              mainAxisSpacing: AppDimensions.xl,
              childAspectRatio: 0.9,
            ),
            itemCount: state.files.length,
            itemBuilder: (context, index) {
              final file = state.files[index];
              if (file.name == '60-Second Video') {
                return _buildVideoLinkCard(true);
              }
              return MediaUploadZone(
                title: file.name,
                description: file.description,
                selectedFileName: file.selectedFileName,
                isUploaded: file.isUploaded,
                uploadProgress: file.uploadProgress,
                onTap: () async {
                  FilePickerResult? result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx'],
                  );

                  if (result != null && result.files.single.path != null) {
                    final File realFile = File(result.files.single.path!);
                    notifier.selectFile(file.id, result.files.single.name, realFile.path);
                    await notifier.simulateUpload(file.id);
                  }
                },
                onRemove: () => notifier.removeFile(file.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(MediaUploadState state, MediaUploadNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload Pitch Materials', style: AppTextStyles.heading2),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Provide your pitch deck and supporting materials to give investors the full picture.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppDimensions.xxl),
        Expanded(
          child: ListView.separated(
            itemCount: state.files.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.lg),
            itemBuilder: (context, index) {
              final file = state.files[index];
              if (file.name == '60-Second Video') {
                return _buildVideoLinkCard(false);
              }
              return MediaUploadZone(
                title: file.name,
                description: file.description,
                selectedFileName: file.selectedFileName,
                isUploaded: file.isUploaded,
                uploadProgress: file.uploadProgress,
                onTap: () async {
                  FilePickerResult? result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'doc', 'docx'],
                  );

                  if (result != null && result.files.single.path != null) {
                    final File realFile = File(result.files.single.path!);
                    notifier.selectFile(file.id, result.files.single.name, realFile.path);
                    await notifier.simulateUpload(file.id);
                  }
                },
                onRemove: () => notifier.removeFile(file.id),
              );
            },
          ),
        ),
      ],
    );
  }
}
