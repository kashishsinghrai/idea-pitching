import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navojit_tech/features/founder/models/mock_data.dart';
import 'package:navojit_tech/features/founder/repositories/pitch_repository.dart';
import 'package:navojit_tech/features/investor/models/startup_deal.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════
// PITCH WIZARD STATE
// ═══════════════════════════════════════════════════════════════════

class PitchWizardState {
  final int currentStep;
  final int totalSteps;
  final Map<String, String> formData;
  final Map<String, String?> validationErrors;
  final bool isSubmitting;

  const PitchWizardState({
    this.currentStep = 0,
    this.totalSteps = 4,
    this.formData = const {},
    this.validationErrors = const {},
    this.isSubmitting = false,
  });

  PitchWizardState copyWith({
    int? currentStep,
    Map<String, String>? formData,
    Map<String, String?>? validationErrors,
    bool? isSubmitting,
  }) {
    return PitchWizardState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps,
      formData: formData ?? this.formData,
      validationErrors: validationErrors ?? this.validationErrors,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;
  double get progress => (currentStep + 1) / totalSteps;
}

final pitchRepositoryProvider = Provider((ref) => PitchRepository());

// A FutureProvider to fetch the logged-in founder's pitches
final myPitchesProvider = FutureProvider<List<StartupDeal>>((ref) async {
  final repository = ref.watch(pitchRepositoryProvider);
  final pitchesData = await repository.fetchMyPitches();
  return pitchesData.map((data) => StartupDeal.fromApi(Map<String, dynamic>.from(data as Map))).toList();
});

class PitchWizardNotifier extends StateNotifier<PitchWizardState> {
  final PitchRepository _pitchRepository;

  PitchWizardNotifier(this._pitchRepository) : super(const PitchWizardState());

  void updateField(String key, String value) {
    final updated = Map<String, String>.from(state.formData);
    updated[key] = value;
    // Clear validation error for this field
    final errors = Map<String, String?>.from(state.validationErrors);
    errors.remove(key);
    state = state.copyWith(formData: updated, validationErrors: errors);
  }

  bool validateCurrentStep() {
    final errors = <String, String?>{};
    switch (state.currentStep) {
      case 0: // Problem
        if (_isEmpty('problemTitle')) errors['problemTitle'] = 'Startup Name is required';
        if (_isEmpty('problemDescription')) errors['problemDescription'] = 'Industry is required';
        if (_isEmpty('targetAudience')) errors['targetAudience'] = 'Stage is required';
        break;
      case 1: // Solution
        if (_isEmpty('solutionOverview')) errors['solutionOverview'] = 'Tagline is required';
        if (_isEmpty('keyDifferentiators')) errors['keyDifferentiators'] = 'Description is required';
        break;
      case 2: // Market
        if (_isEmpty('marketSize')) errors['marketSize'] = 'Ask Amount is required';
        if (_isEmpty('tam')) errors['tam'] = 'Valuation is required';
        break;
      case 3: // Ask
        // Assuming validation was mapped similarly in wizard_step_form, 
        // we'll keep it general or adjust based on actual keys.
        break;
    }
    state = state.copyWith(validationErrors: errors);
    return errors.isEmpty;
  }

  bool _isEmpty(String key) {
    final value = state.formData[key];
    return value == null || value.trim().isEmpty;
  }

  void nextStep() {
    if (validateCurrentStep() && !state.isLastStep) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void prevStep() {
    if (!state.isFirstStep) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  Future<void> submit(String videoUrl, List<MediaFile> files) async {
    if (!validateCurrentStep()) throw Exception('Please fix the errors before submitting.');
    
    state = state.copyWith(isSubmitting: true);
    try {
      // Map UI formData to backend API schema
      final Map<String, dynamic> payload = {
        'startupName': state.formData['problemTitle'] ?? 'Unnamed Startup',
        'industry': state.formData['problemDescription'] ?? 'Unknown Industry',
        'stage': state.formData['targetAudience'] ?? 'Idea Stage',
        'tagline': state.formData['solutionOverview'] ?? '',
        'description': state.formData['keyDifferentiators'] ?? '',
        'askAmount': double.tryParse((state.formData['marketSize'] ?? '0').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
        'valuation': double.tryParse((state.formData['tam'] ?? '0').replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
        'videoUrl': videoUrl,
      };

      // Extract file paths from the MediaFile list
      for (final file in files) {
        if (file.name == 'Pitch Deck' && file.filePath != null) {
          payload['pitchDeck'] = file.filePath;
        } else if (file.name == 'Executive Summary' && file.filePath != null) {
          payload['executiveSummary'] = file.filePath;
        }
      }

      await _pitchRepository.createPitch(payload);
      state = state.copyWith(isSubmitting: false);
    } catch (e) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  void reset() {
    state = const PitchWizardState();
  }
}

final pitchWizardProvider = StateNotifierProvider<PitchWizardNotifier, PitchWizardState>((ref) {
  final repository = ref.watch(pitchRepositoryProvider);
  return PitchWizardNotifier(repository);
});

// ═══════════════════════════════════════════════════════════════════
// MEDIA UPLOAD STATE
// ═══════════════════════════════════════════════════════════════════

class MediaUploadState {
  final List<MediaFile> files;
  final String? videoUrl;

  const MediaUploadState({required this.files, this.videoUrl});

  MediaUploadState copyWith({
    List<MediaFile>? files,
    String? videoUrl,
  }) {
    return MediaUploadState(
      files: files ?? this.files,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}

class MediaUploadNotifier extends StateNotifier<MediaUploadState> {
  MediaUploadNotifier()
      : super(const MediaUploadState(files: [
          MediaFile(
            id: '1',
            name: 'Pitch Deck',
            type: 'pdf',
            description: 'Upload your pitch presentation (PDF format)',
            maxSizeMB: 50,
          ),
          MediaFile(
            id: '2',
            name: 'Executive Summary',
            type: 'doc',
            description: 'A concise overview of your business plan',
            maxSizeMB: 10,
          ),
          MediaFile(
            id: '3',
            name: '60-Second Video',
            type: 'video',
            description: 'Record a short elevator pitch video',
            maxSizeMB: 100,
          ),
        ]));

  void selectFile(String fileId, String fileName, String filePath) {
    final updated = state.files.map((f) {
      if (f.id == fileId) {
        return f.copyWith(
            selectedFileName: fileName, filePath: filePath, uploadProgress: 0.0);
      }
      return f;
    }).toList();
    state = state.copyWith(files: updated);
  }

  void setVideoUrl(String url) {
    state = state.copyWith(videoUrl: url);
  }

  void removeFile(String fileId) {
    final updated = state.files.map((f) {
      if (f.id == fileId) {
        return MediaFile(
          id: f.id,
          name: f.name,
          type: f.type,
          description: f.description,
          maxSizeMB: f.maxSizeMB,
        );
      }
      return f;
    }).toList();
    state = state.copyWith(files: updated);
  }

  Future<void> simulateUpload(String fileId) async {
    for (var i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      final updated = state.files.map((f) {
        if (f.id == fileId) {
          return f.copyWith(
            uploadProgress: i / 10,
            isUploaded: i == 10,
          );
        }
        return f;
      }).toList();
      if (mounted) state = state.copyWith(files: updated);
    }
  }
}

final mediaUploadProvider =
    StateNotifierProvider<MediaUploadNotifier, MediaUploadState>(
  (ref) => MediaUploadNotifier(),
);

// ═══════════════════════════════════════════════════════════════════
// VDR STATE
// ═══════════════════════════════════════════════════════════════════

class VdrState {
  final List<VdrDocument> documents;
  final String? selectedCategory; // null = 'All'
  final bool isLoading;

  const VdrState({
    required this.documents,
    this.selectedCategory,
    this.isLoading = false,
  });

  VdrState copyWith({
    List<VdrDocument>? documents,
    String? selectedCategory,
    bool? isLoading,
    bool clearCategory = false,
  }) {
    return VdrState(
      documents: documents ?? this.documents,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<VdrDocument> get filteredDocuments {
    if (selectedCategory == null || selectedCategory == 'All') {
      return documents;
    }
    return documents.where((d) => d.category == selectedCategory).toList();
  }

  List<String> get categories {
    final cats = documents.map((d) => d.category).toSet().toList();
    cats.sort();
    return ['All', ...cats];
  }
}

class VdrNotifier extends StateNotifier<VdrState> {
  static const _storageKey = 'vdr_documents';

  VdrNotifier() : super(const VdrState(documents: [], isLoading: true)) {
    _loadFromStorage();
  }

  // ── Persistence ──────────────────────────────────────────────────

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];
    final docs = jsonList.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
      return VdrDocument(
        id: map['id'] as String,
        name: map['name'] as String,
        category: map['category'] as String,
        fileType: map['fileType'] as String,
        sizeMB: (map['sizeMB'] as num).toDouble(),
        uploadedAt: DateTime.parse(map['uploadedAt'] as String),
        isLocked: map['isLocked'] as bool? ?? true,
        viewCount: map['viewCount'] as int? ?? 0,
        filePath: map['filePath'] as String?,
      );
    }).toList();
    if (mounted) {
      state = state.copyWith(documents: docs, isLoading: false);
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = state.documents.map((d) => jsonEncode({
      'id': d.id,
      'name': d.name,
      'category': d.category,
      'fileType': d.fileType,
      'sizeMB': d.sizeMB,
      'uploadedAt': d.uploadedAt.toIso8601String(),
      'isLocked': d.isLocked,
      'viewCount': d.viewCount,
      'filePath': d.filePath,
    })).toList();
    await prefs.setStringList(_storageKey, jsonList);
  }

  // ── Actions ───────────────────────────────────────────────────────

  void addDocument(VdrDocument doc) {
    final updated = [...state.documents, doc];
    state = state.copyWith(documents: updated);
    _saveToStorage();
  }

  void deleteDocument(String docId) {
    final updated = state.documents.where((d) => d.id != docId).toList();
    state = state.copyWith(documents: updated);
    _saveToStorage();
  }

  void toggleLock(String docId) {
    final updated = state.documents.map((d) {
      if (d.id == docId) return d.copyWith(isLocked: !d.isLocked);
      return d;
    }).toList();
    state = state.copyWith(documents: updated);
    _saveToStorage();
  }

  void incrementViewCount(String docId) {
    final updated = state.documents.map((d) {
      if (d.id == docId) return d.copyWith(viewCount: d.viewCount + 1);
      return d;
    }).toList();
    state = state.copyWith(documents: updated);
    _saveToStorage();
  }

  void setCategory(String? category) {
    if (category == null || category == 'All') {
      state = state.copyWith(clearCategory: true);
    } else {
      state = VdrState(
        documents: state.documents,
        selectedCategory: category,
        isLoading: state.isLoading,
      );
    }
  }
}

final vdrProvider = StateNotifierProvider<VdrNotifier, VdrState>(
  (ref) => VdrNotifier(),
);

