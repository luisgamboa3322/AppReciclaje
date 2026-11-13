import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pecox_models.dart';

enum PickImageOutcome {
  picked,
  cancelled,
  cameraDenied,
  unavailableFallback,
}

class PickImageResult {
  const PickImageResult({required this.outcome, this.path});
  final PickImageOutcome outcome;
  final String? path;
}

class ImagePickerService {
  ImagePickerService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  Future<PickImageResult> pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (file == null) {
        return const PickImageResult(outcome: PickImageOutcome.cancelled);
      }
      return PickImageResult(outcome: PickImageOutcome.picked, path: file.path);
    } on PlatformException catch (e) {
      if (source == ImageSource.camera &&
          (e.code.contains('camera') || e.code.contains('permission'))) {
        return const PickImageResult(outcome: PickImageOutcome.cameraDenied);
      }
      return const PickImageResult(outcome: PickImageOutcome.unavailableFallback);
    } catch (_) {
      return const PickImageResult(outcome: PickImageOutcome.unavailableFallback);
    }
  }
}

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});

class AppState {
  const AppState({
    required this.user,
    required this.history,
    required this.selectedGuideMaterial,
    required this.accessibility,
    required this.resultVariant,
    this.capturedImagePath,
    this.invalidImageFlag = false,
    this.cameraDeniedSim = false,
    this.offlineSim = false,
  });

  final UserProfile user;
  final List<ClassificationRecord> history;
  final MaterialKey selectedGuideMaterial;
  final AccessibilitySettings accessibility;
  final ResultVariant resultVariant;
  final String? capturedImagePath;
  final bool invalidImageFlag;
  final bool cameraDeniedSim;
  final bool offlineSim;

  factory AppState.initial() {
    return const AppState(
      user: UserProfile(
        name: 'Sofía Martínez',
        email: 'sofia@ejemplo.com',
        initials: 'SM',
        badge: 'Exploradora consciente',
        isGuest: false,
      ),
      history: kInitialDemoHistory,
      selectedGuideMaterial: MaterialKey.plastic,
      accessibility: AccessibilitySettings(),
      resultVariant: ResultVariant.identified,
    );
  }

  AppState copyWith({
    UserProfile? user,
    List<ClassificationRecord>? history,
    MaterialKey? selectedGuideMaterial,
    AccessibilitySettings? accessibility,
    ResultVariant? resultVariant,
    String? capturedImagePath,
    bool clearCapturedImage = false,
    bool? invalidImageFlag,
    bool? cameraDeniedSim,
    bool? offlineSim,
  }) {
    return AppState(
      user: user ?? this.user,
      history: history ?? this.history,
      selectedGuideMaterial: selectedGuideMaterial ?? this.selectedGuideMaterial,
      accessibility: accessibility ?? this.accessibility,
      resultVariant: resultVariant ?? this.resultVariant,
      capturedImagePath:
          clearCapturedImage ? null : (capturedImagePath ?? this.capturedImagePath),
      invalidImageFlag: invalidImageFlag ?? this.invalidImageFlag,
      cameraDeniedSim: cameraDeniedSim ?? this.cameraDeniedSim,
      offlineSim: offlineSim ?? this.offlineSim,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState.initial());

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'PV';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  void loginUser(String name, String email) {
    final cleanName = name.trim().isEmpty ? 'Sofía Martínez' : name.trim();
    state = state.copyWith(
      user: UserProfile(
        name: cleanName,
        email: email.trim(),
        initials: _initialsFromName(cleanName),
        badge: 'Exploradora consciente',
        isGuest: false,
      ),
    );
  }

  void enterGuestMode() {
    state = state.copyWith(
      user: const UserProfile(
        name: 'Visitante',
        email: 'Modo invitado · Solo guía',
        initials: 'IN',
        badge: 'Acceso sin cuenta',
        isGuest: true,
      ),
    );
  }

  void updateProfile(String name, String email) {
    state = state.copyWith(
      user: state.user.copyWith(
        name: name.trim(),
        email: email.trim(),
        initials: _initialsFromName(name),
        isGuest: false,
      ),
    );
  }

  void selectGuideMaterial(MaterialKey key) {
    state = state.copyWith(selectedGuideMaterial: key);
  }

  void setCapturedPhoto(String? path, {bool invalid = false}) {
    state = state.copyWith(
      capturedImagePath: path,
      clearCapturedImage: path == null,
      invalidImageFlag: invalid,
    );
  }

  void clearInvalidImage() {
    state = state.copyWith(invalidImageFlag: false);
  }

  void setResultVariant(ResultVariant variant) {
    state = state.copyWith(resultVariant: variant);
  }

  void saveClassification(ClassificationRecord record) {
    state = state.copyWith(history: [record, ...state.history]);
  }

  void deleteClassification(String id) {
    state = state.copyWith(
      history: state.history.where((item) => item.id != id).toList(),
    );
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }

  void updateAccessibility({bool? largeText, bool? reduceMotion}) {
    state = state.copyWith(
      accessibility: state.accessibility.copyWith(
        largeText: largeText,
        reduceMotion: reduceMotion,
      ),
    );
  }

  void toggleCameraDenied([bool? value]) {
    state = state.copyWith(cameraDeniedSim: value ?? !state.cameraDeniedSim);
  }

  void toggleOffline([bool? value]) {
    state = state.copyWith(offlineSim: value ?? !state.offlineSim);
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});
