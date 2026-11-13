import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/pecox_models.dart';
import '../services/pecox_api_client.dart';
import '../services/token_storage.dart';

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

final apiBaseUrlProvider = StateProvider<String>((ref) => kDefaultApiBaseUrl);

final tokenStorageProvider = Provider<TokenStorage>((ref) => SecureTokenStorage());

final pecoxApiProvider = Provider<PecoxApiGateway>((ref) {
  final baseUrl = ref.watch(apiBaseUrlProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return DioPecoxApiGateway(baseUrl: baseUrl, tokenStorage: tokenStorage);
});

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService();
});

class AppState {
  const AppState({
    required this.user,
    required this.isAuthenticated,
    required this.history,
    required this.selectedGuideMaterial,
    required this.accessibility,
    this.modelInfo,
    this.backendGuides = const [],
    this.authBusy = false,
    this.authError,
    this.historyLoading = false,
    this.historyError,
    this.capturedImagePath,
    this.invalidImageFlag = false,
    this.lastPrediction,
    this.analysisBusy = false,
    this.analysisFailure,
    this.analysisErrorMessage,
    this.saveBusy = false,
    this.saveErrorMessage,
    this.cameraDeniedSim = false,
    this.offlineSim = false,
  });

  final UserProfile user;
  final bool isAuthenticated;
  final List<ClassificationRecord> history;
  final MaterialKey selectedGuideMaterial;
  final AccessibilitySettings accessibility;
  final ModelInfoModel? modelInfo;
  final List<ApiGuideDto> backendGuides;
  final bool authBusy;
  final String? authError;
  final bool historyLoading;
  final String? historyError;
  final String? capturedImagePath;
  final bool invalidImageFlag;
  final PredictionResultModel? lastPrediction;
  final bool analysisBusy;
  final ApiFailure? analysisFailure;
  final String? analysisErrorMessage;
  final bool saveBusy;
  final String? saveErrorMessage;
  final bool cameraDeniedSim;
  final bool offlineSim;

  factory AppState.initial() {
    return const AppState(
      user: UserProfile(
        name: 'Visitante',
        email: 'Sin sesión iniciada',
        initials: 'PV',
        badge: 'Acceso sin cuenta',
        isGuest: true,
      ),
      isAuthenticated: false,
      history: [],
      selectedGuideMaterial: MaterialKey.plastic,
      accessibility: AccessibilitySettings(),
    );
  }

  AppState copyWith({
    UserProfile? user,
    bool? isAuthenticated,
    List<ClassificationRecord>? history,
    MaterialKey? selectedGuideMaterial,
    AccessibilitySettings? accessibility,
    ModelInfoModel? modelInfo,
    List<ApiGuideDto>? backendGuides,
    bool? authBusy,
    String? authError,
    bool clearAuthError = false,
    bool? historyLoading,
    String? historyError,
    bool clearHistoryError = false,
    String? capturedImagePath,
    bool clearCapturedImage = false,
    bool? invalidImageFlag,
    PredictionResultModel? lastPrediction,
    bool clearPrediction = false,
    bool? analysisBusy,
    ApiFailure? analysisFailure,
    String? analysisErrorMessage,
    bool clearAnalysisError = false,
    bool? saveBusy,
    String? saveErrorMessage,
    bool clearSaveError = false,
    bool? cameraDeniedSim,
    bool? offlineSim,
  }) {
    return AppState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      history: history ?? this.history,
      selectedGuideMaterial: selectedGuideMaterial ?? this.selectedGuideMaterial,
      accessibility: accessibility ?? this.accessibility,
      modelInfo: modelInfo ?? this.modelInfo,
      backendGuides: backendGuides ?? this.backendGuides,
      authBusy: authBusy ?? this.authBusy,
      authError: clearAuthError ? null : (authError ?? this.authError),
      historyLoading: historyLoading ?? this.historyLoading,
      historyError: clearHistoryError ? null : (historyError ?? this.historyError),
      capturedImagePath:
          clearCapturedImage ? null : (capturedImagePath ?? this.capturedImagePath),
      invalidImageFlag: invalidImageFlag ?? this.invalidImageFlag,
      lastPrediction: clearPrediction ? null : (lastPrediction ?? this.lastPrediction),
      analysisBusy: analysisBusy ?? this.analysisBusy,
      analysisFailure:
          clearAnalysisError ? null : (analysisFailure ?? this.analysisFailure),
      analysisErrorMessage: clearAnalysisError
          ? null
          : (analysisErrorMessage ?? this.analysisErrorMessage),
      saveBusy: saveBusy ?? this.saveBusy,
      saveErrorMessage:
          clearSaveError ? null : (saveErrorMessage ?? this.saveErrorMessage),
      cameraDeniedSim: cameraDeniedSim ?? this.cameraDeniedSim,
      offlineSim: offlineSim ?? this.offlineSim,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier(this._ref) : super(AppState.initial());

  final Ref _ref;

  PecoxApiGateway get _api => _ref.read(pecoxApiProvider);
  TokenStorage get _tokens => _ref.read(tokenStorageProvider);

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'PV';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  ClassificationRecord _dtoToRecord(ApiClassificationDto dto) {
    final local = dto.createdAtUtc.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdDay = DateTime(local.year, local.month, local.day);
    final diffDays = today.difference(createdDay).inDays;

    final String dateGroup;
    if (diffDays <= 0) {
      dateGroup = 'HOY';
    } else if (diffDays < 7) {
      dateGroup = 'ESTA SEMANA';
    } else {
      dateGroup = 'ANTERIOR';
    }

    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final dd = local.day.toString().padLeft(2, '0');
    final mo = local.month.toString().padLeft(2, '0');
    final timestampLabel =
        diffDays <= 0 ? 'Hoy, $hh:$mm' : '$dd/$mo/${local.year} $hh:$mm';

    final confirmedDef = materialByKey(dto.confirmedMaterial);
    final predictedDef = materialByKey(dto.predictedMaterial);
    final isCorrected = dto.predictedMaterial != dto.confirmedMaterial;

    return ClassificationRecord(
      id: dto.id,
      title: isCorrected ? '${confirmedDef.label} (corregido)' : confirmedDef.label,
      predictedMaterial: dto.predictedMaterial,
      confirmedMaterial: dto.confirmedMaterial,
      confidence: dto.confidence != null
          ? (dto.confidence! * 100).round().clamp(0, 100)
          : null,
      status: isCorrected
          ? ClassificationStatus.corrected
          : ClassificationStatus.confirmed,
      dateGroup: dateGroup,
      timestampLabel: timestampLabel,
      createdAtUtc: dto.createdAtUtc,
      modelVersion: dto.modelVersion,
      notes: isCorrected
          ? 'Sugerencia ML: ${predictedDef.label} → Confirmado: ${confirmedDef.label} (${dto.modelVersion})'
          : 'Clasificado con ${dto.modelVersion}.',
    );
  }

  UserProfile _userDtoToProfile(ApiUserDto dto) {
    return UserProfile(
      id: dto.id,
      name: dto.name,
      email: dto.email,
      initials: _initialsFromName(dto.name),
      badge: dto.role == 'admin' ? 'Administrador' : 'Cuenta verificada',
      isGuest: false,
      role: dto.role,
    );
  }

  Future<bool> restoreSession() async {
    try {
      await refreshPublicMetadata();
    } catch (_) {
      // Best-effort public metadata sync during splash.
    }

    final access = await _tokens.readAccessToken();
    final refresh = await _tokens.readRefreshToken();
    if ((access == null || access.isEmpty) && (refresh == null || refresh.isEmpty)) {
      return false;
    }

    try {
      final userDto = await _api.fetchMe();
      state = state.copyWith(
        user: _userDtoToProfile(userDto),
        isAuthenticated: true,
        clearAuthError: true,
      );
      await refreshHistory();
      return true;
    } on ApiException catch (e) {
      if (e.failure == ApiFailure.unauthorized) {
        await _tokens.clear();
        state = state.copyWith(isAuthenticated: false);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    if (state.offlineSim) {
      state = state.copyWith(
        authError: 'Sin conexión a internet. Puedes explorar la guía sin cuenta.',
      );
      return false;
    }
    state = state.copyWith(authBusy: true, clearAuthError: true);
    try {
      final session = await _api.login(email: email.trim(), password: password);
      await _tokens.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      state = state.copyWith(
        user: _userDtoToProfile(session.user),
        isAuthenticated: true,
        authBusy: false,
      );
      await Future.wait([
        refreshHistory(),
        refreshPublicMetadata(),
      ]);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(authBusy: false, authError: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        authBusy: false,
        authError: 'Ocurrió un error inesperado al iniciar sesión.',
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (state.offlineSim) {
      state = state.copyWith(
        authError: 'Sin conexión a internet. Puedes explorar la guía sin cuenta.',
      );
      return false;
    }
    state = state.copyWith(authBusy: true, clearAuthError: true);
    try {
      final session = await _api.register(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );
      await _tokens.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      state = state.copyWith(
        user: _userDtoToProfile(session.user),
        isAuthenticated: true,
        history: const [],
        authBusy: false,
      );
      await refreshPublicMetadata();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(authBusy: false, authError: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        authBusy: false,
        authError: 'Ocurrió un error inesperado al crear la cuenta.',
      );
      return false;
    }
  }

  Future<void> enterGuestMode() async {
    await _tokens.clear();
    state = state.copyWith(
      user: const UserProfile(
        name: 'Visitante',
        email: 'Modo invitado · Solo guía',
        initials: 'IN',
        badge: 'Acceso sin cuenta',
        isGuest: true,
      ),
      isAuthenticated: false,
      history: const [],
      clearAuthError: true,
      clearPrediction: true,
    );
  }

  Future<void> logout() async {
    await _tokens.clear();
    state = AppState.initial().copyWith(
      accessibility: state.accessibility,
      modelInfo: state.modelInfo,
      backendGuides: state.backendGuides,
    );
  }

  Future<void> refreshPublicMetadata() async {
    if (state.offlineSim) return;
    try {
      final results = await Future.wait([
        _api.fetchModelInfo(),
        _api.fetchGuides(),
      ]);
      state = state.copyWith(
        modelInfo: results[0] as ModelInfoModel,
        backendGuides: results[1] as List<ApiGuideDto>,
      );
    } catch (_) {
      // Public metadata stays optional if backend is unreachable.
    }
  }

  Future<void> refreshHistory() async {
    if (!state.isAuthenticated) return;
    if (state.offlineSim) {
      state = state.copyWith(
        historyError: 'Modo sin conexión activo.',
        historyLoading: false,
      );
      return;
    }
    state = state.copyWith(historyLoading: true, clearHistoryError: true);
    try {
      final items = await _api.listClassifications(limit: 100);
      state = state.copyWith(
        history: items.map(_dtoToRecord).toList(),
        historyLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(historyLoading: false, historyError: e.message);
    } catch (_) {
      state = state.copyWith(
        historyLoading: false,
        historyError: 'No pudimos actualizar tu historial.',
      );
    }
  }

  void updateProfileLocal(String name, String email) {
    state = state.copyWith(
      user: state.user.copyWith(
        name: name.trim(),
        email: email.trim(),
        initials: _initialsFromName(name),
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
      clearPrediction: true,
      clearAnalysisError: true,
    );
  }

  void clearInvalidImage() {
    state = state.copyWith(invalidImageFlag: false);
  }

  Future<bool> analyzeCapturedImage() async {
    final imagePath = state.capturedImagePath;
    if (state.offlineSim) {
      state = state.copyWith(
        analysisBusy: false,
        analysisFailure: ApiFailure.network,
        analysisErrorMessage:
            'No fue posible enviar la fotografía al servidor. No generaremos una predicción falsa.',
      );
      return false;
    }
    if (!state.isAuthenticated || state.user.isGuest) {
      state = state.copyWith(
        analysisBusy: false,
        analysisFailure: ApiFailure.unauthorized,
        analysisErrorMessage: 'Inicia sesión para analizar imágenes con el modelo IA.',
      );
      return false;
    }
    if (imagePath == null || imagePath.isEmpty) {
      state = state.copyWith(
        analysisBusy: false,
        analysisFailure: ApiFailure.invalidImage,
        analysisErrorMessage: 'No hay una fotografía seleccionada para analizar.',
      );
      return false;
    }

    state = state.copyWith(
      analysisBusy: true,
      clearAnalysisError: true,
      clearPrediction: true,
    );
    try {
      final prediction = await _api.predictImage(imagePath);
      state = state.copyWith(
        analysisBusy: false,
        lastPrediction: prediction,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        analysisBusy: false,
        analysisFailure: e.failure,
        analysisErrorMessage: e.message,
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        analysisBusy: false,
        analysisFailure: ApiFailure.serverError,
        analysisErrorMessage: 'Error inesperado al ejecutar la inferencia.',
      );
      return false;
    }
  }

  Future<bool> confirmAndSavePrediction({
    required MaterialKey confirmedMaterial,
  }) async {
    final prediction = state.lastPrediction;
    if (prediction == null) return false;
    if (state.offlineSim) {
      state = state.copyWith(
        saveErrorMessage: 'Sin conexión a internet. Reintenta al recuperar la red.',
      );
      return false;
    }

    state = state.copyWith(saveBusy: true, clearSaveError: true);
    try {
      final created = await _api.createClassification(
        predictedMaterial: prediction.material,
        confidence: prediction.confidence,
        confirmedMaterial: confirmedMaterial,
        modelVersion: prediction.modelVersion,
      );
      final record = _dtoToRecord(created).copyWith(
        notes: prediction.material != confirmedMaterial
            ? 'Sugerencia ML: ${materialByKey(prediction.material).label} → Confirmado: ${materialByKey(confirmedMaterial).label} (${prediction.modelVersion})'
            : 'Clasificado con ${prediction.modelVersion}.',
      );
      state = state.copyWith(
        saveBusy: false,
        history: [record, ...state.history],
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(saveBusy: false, saveErrorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        saveBusy: false,
        saveErrorMessage: 'No se pudo guardar la clasificación en el servidor.',
      );
      return false;
    }
  }

  Future<bool> correctSavedClassification(
    String id,
    MaterialKey confirmedMaterial,
  ) async {
    try {
      final updatedDto = await _api.updateClassification(
        id: id,
        confirmedMaterial: confirmedMaterial,
      );
      final updatedRecord = _dtoToRecord(updatedDto);
      state = state.copyWith(
        history: state.history
            .map((item) => item.id == id ? updatedRecord : item)
            .toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteClassification(String id) async {
    if (state.isAuthenticated) {
      try {
        await _api.deleteClassification(id);
      } catch (_) {
        return false;
      }
    }
    state = state.copyWith(
      history: state.history.where((item) => item.id != id).toList(),
    );
    return true;
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
  return AppStateNotifier(ref);
});
