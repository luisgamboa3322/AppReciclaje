import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pecox_vision/core/models/pecox_models.dart';
import 'package:pecox_vision/core/services/pecox_api_client.dart';
import 'package:pecox_vision/core/services/token_storage.dart';
import 'package:pecox_vision/core/state/app_state.dart';
import 'package:pecox_vision/main.dart';

// Valid 1x1 transparent PNG
const _kSamplePngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+X2ZkAAAAASUVORK5CYII=';

File _createTempSampleImage() {
  final dir = Directory.systemTemp.createTempSync('pecox_test_');
  final file = File('${dir.path}/bottle.png');
  file.writeAsBytesSync(base64Decode(_kSamplePngBase64));
  return file;
}

class _FakeImagePickerService extends ImagePickerService {
  _FakeImagePickerService(this.outcome, {this.path});
  final PickImageOutcome outcome;
  final String? path;

  @override
  Future<PickImageResult> pick(ImageSource source) async {
    return PickImageResult(outcome: outcome, path: path);
  }
}

class _FakePecoxApiGateway implements PecoxApiGateway {
  _FakePecoxApiGateway({
    this.modelUnavailable = false,
    List<ApiClassificationDto>? initialRecords,
  }) : records = List<ApiClassificationDto>.from(initialRecords ?? const []);

  bool modelUnavailable;
  final List<ApiClassificationDto> records;

  final _user = const ApiUserDto(
    id: 'user-1',
    name: 'Sofía Martínez',
    email: 'sofia@ejemplo.com',
    role: 'user',
  );

  @override
  Future<AuthSessionDto> login({
    required String email,
    required String password,
  }) async {
    return AuthSessionDto(
      accessToken: 'fake-access-token',
      refreshToken: 'fake-refresh-token',
      user: _user,
    );
  }

  @override
  Future<AuthSessionDto> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return AuthSessionDto(
      accessToken: 'fake-access-token',
      refreshToken: 'fake-refresh-token',
      user: ApiUserDto(id: 'user-1', name: name, email: email, role: 'user'),
    );
  }

  @override
  Future<ApiUserDto> fetchMe() async => _user;

  @override
  Future<ModelInfoModel> fetchModelInfo() async {
    return ModelInfoModel(
      status: modelUnavailable ? 'not_trained_yet' : 'ready',
      activeVersion: modelUnavailable ? null : 'resnet18-trashnet-v1.0.0',
      architecture: modelUnavailable ? null : 'resnet18',
      identifiedThreshold: 0.50,
      lowConfidenceThreshold: 0.35,
      note: 'Fake test model metadata',
    );
  }

  @override
  Future<List<ApiGuideDto>> fetchGuides() async => const [];

  @override
  Future<PredictionResultModel> predictImage(String imagePath) async {
    if (modelUnavailable) {
      throw const ApiException(
        failure: ApiFailure.modelUnavailable,
        statusCode: 503,
        message: 'El modelo ML no está cargado en el servidor.',
      );
    }
    return const PredictionResultModel(
      predictionId: 'pred-1',
      material: MaterialKey.plastic,
      confidence: 0.89,
      alternatives: [
        MaterialAlternative(key: MaterialKey.glass, confidence: 7),
      ],
      modelVersion: 'resnet18-trashnet-v1.0.0',
      architecture: 'resnet18',
      status: PredictionStatus.identified,
      inferenceMs: 38.4,
    );
  }

  @override
  Future<List<ApiClassificationDto>> listClassifications({
    MaterialKey? material,
    int limit = 50,
    int offset = 0,
  }) async {
    return records;
  }

  @override
  Future<ApiClassificationDto> createClassification({
    required MaterialKey predictedMaterial,
    required double? confidence,
    required MaterialKey? confirmedMaterial,
    required String modelVersion,
  }) async {
    final created = ApiClassificationDto(
      id: 'cls-${records.length + 1}',
      predictedMaterial: predictedMaterial,
      confirmedMaterial: confirmedMaterial ?? predictedMaterial,
      confidence: confidence,
      modelVersion: modelVersion,
      createdAtUtc: DateTime.now().toUtc(),
    );
    records.insert(0, created);
    return created;
  }

  @override
  Future<ApiClassificationDto> updateClassification({
    required String id,
    required MaterialKey confirmedMaterial,
  }) async {
    final idx = records.indexWhere((e) => e.id == id);
    final old = records[idx];
    final updated = ApiClassificationDto(
      id: old.id,
      predictedMaterial: old.predictedMaterial,
      confirmedMaterial: confirmedMaterial,
      confidence: old.confidence,
      modelVersion: old.modelVersion,
      createdAtUtc: old.createdAtUtc,
    );
    records[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteClassification(String id) async {
    records.removeWhere((e) => e.id == id);
  }
}

void main() {
  testWidgets('Splash -> Onboarding -> Login via API -> Home works', (tester) async {
    final fakeApi = _FakePecoxApiGateway();
    final tokenStorage = MemoryTokenStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pecoxApiProvider.overrideWithValue(fakeApi),
          tokenStorageProvider.overrideWithValue(tokenStorage),
        ],
        child: const PecoxVisionApp(initialLocation: '/'),
      ),
    );

    expect(find.text('Reconoce. Aprende. Recicla.'), findsOneWidget);
    await tester.tap(find.text('Continuar ahora'));
    await tester.pumpAndSettle();

    expect(find.text('Reconoce tus residuos'), findsOneWidget);
    await tester.tap(find.text('Omitir'));
    await tester.pumpAndSettle();

    expect(find.text('Inicia sesión en PECOX'), findsOneWidget);
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'sofia@ejemplo.com');
    await tester.enterText(fields.at(1), 'pecox2026!');

    await tester.tap(find.text('Entrar a PECOX Vision'));
    await tester.pumpAndSettle();

    expect(find.text('¿Qué vamos a reciclar hoy?'), findsOneWidget);
    expect(await tokenStorage.readAccessToken(), 'fake-access-token');
  });

  testWidgets('Full predict -> manual correction -> save -> history persistence flow works',
      (tester) async {
    final sampleImg = _createTempSampleImage();
    addTearDown(() => sampleImg.parent.deleteSync(recursive: true));

    final fakeApi = _FakePecoxApiGateway();
    final tokenStorage = MemoryTokenStorage();
    await tokenStorage.saveTokens(
      accessToken: 'valid-access',
      refreshToken: 'valid-refresh',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pecoxApiProvider.overrideWithValue(fakeApi),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          imagePickerServiceProvider.overrideWithValue(
            _FakeImagePickerService(PickImageOutcome.picked, path: sampleImg.path),
          ),
        ],
        child: const PecoxVisionApp(initialLocation: '/auth'),
      ),
    );

    // Login quickly to enter authenticated session
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'sofia@ejemplo.com');
    await tester.enterText(fields.at(1), 'pecox2026!');
    await tester.tap(find.text('Entrar a PECOX Vision'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Escanear ahora'));
    await tester.pumpAndSettle();

    expect(find.text('Coloca el residuo dentro del encuadre'), findsOneWidget);
    await tester.tap(find.byKey(const Key('scanner-shutter')));
    await tester.pumpAndSettle();

    expect(find.text('¿La imagen se ve clara?'), findsOneWidget);
    await tester.ensureVisible(find.text('Analizar material'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analizar material'));
    await tester.pumpAndSettle();

    expect(find.text('Plástico'), findsWidgets);
    expect(find.text('89%'), findsOneWidget);

    await tester.ensureVisible(find.text('Corregir material'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Corregir material'));
    await tester.pumpAndSettle();
    expect(find.text('¿Qué material es?'), findsOneWidget);

    await tester.tap(find.text('Vidrio').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Confirmar (Vidrio)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar (Vidrio)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Corregido (original: Plástico)'), findsOneWidget);

    await tester.ensureVisible(find.text('Guardar clasificación'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guardar clasificación'));
    await tester.pumpAndSettle();

    expect(find.text('Mi historial'), findsOneWidget);
    expect(find.text('Vidrio (corregido)'), findsOneWidget);
    expect(fakeApi.records.length, 1);
    expect(fakeApi.records.first.predictedMaterial, MaterialKey.plastic);
    expect(fakeApi.records.first.confirmedMaterial, MaterialKey.glass);
  });

  testWidgets('Backend 503 model unavailable shows honest error card', (tester) async {
    final sampleImg = _createTempSampleImage();
    addTearDown(() => sampleImg.parent.deleteSync(recursive: true));

    final fakeApi = _FakePecoxApiGateway(modelUnavailable: true);
    final tokenStorage = MemoryTokenStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pecoxApiProvider.overrideWithValue(fakeApi),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          imagePickerServiceProvider.overrideWithValue(
            _FakeImagePickerService(PickImageOutcome.picked, path: sampleImg.path),
          ),
        ],
        child: const PecoxVisionApp(initialLocation: '/auth'),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'sofia@ejemplo.com');
    await tester.enterText(fields.at(1), 'pecox2026!');
    await tester.tap(find.text('Entrar a PECOX Vision'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Escanear ahora'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scanner-shutter')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Analizar material'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analizar material'));
    await tester.pumpAndSettle();

    expect(find.text('Modelo ML no disponible'), findsOneWidget);
    expect(find.text('Reintentar análisis'), findsOneWidget);
  });

  testWidgets('Guest can explore material guide without login and scanner prompts login',
      (tester) async {
    final fakeApi = _FakePecoxApiGateway();
    final tokenStorage = MemoryTokenStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pecoxApiProvider.overrideWithValue(fakeApi),
          tokenStorageProvider.overrideWithValue(tokenStorage),
        ],
        child: const PecoxVisionApp(initialLocation: '/auth'),
      ),
    );

    await tester.tap(find.text('Explorar guía de materiales sin cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Cada material tiene su lugar'), findsOneWidget);
    expect(find.text('Vacía el contenido'), findsOneWidget);

    await tester.tap(find.text('Vidrio'));
    await tester.pumpAndSettle();
    expect(find.text('Retira tapas y corchos'), findsOneWidget);
  });

  testWidgets('Camera denied shows gallery and guide fallback when authenticated',
      (tester) async {
    final fakeApi = _FakePecoxApiGateway();
    final tokenStorage = MemoryTokenStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pecoxApiProvider.overrideWithValue(fakeApi),
          tokenStorageProvider.overrideWithValue(tokenStorage),
          imagePickerServiceProvider.overrideWithValue(
            _FakeImagePickerService(PickImageOutcome.cameraDenied),
          ),
        ],
        child: const PecoxVisionApp(initialLocation: '/auth'),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'sofia@ejemplo.com');
    await tester.enterText(fields.at(1), 'pecox2026!');
    await tester.tap(find.text('Entrar a PECOX Vision'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Escanear ahora'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('scanner-shutter')));
    await tester.pumpAndSettle();

    expect(find.text('Cámara no disponible o denegada'), findsOneWidget);
    expect(find.text('Elegir imagen de la galería'), findsOneWidget);
    expect(find.text('Abrir guía de materiales'), findsOneWidget);
  });

  testWidgets('App launch with stored tokens restores session and loads history',
      (tester) async {
    final tokenStorage = MemoryTokenStorage();
    await tokenStorage.saveTokens(
      accessToken: 'stored-access',
      refreshToken: 'stored-refresh',
    );
    final fakeApi = _FakePecoxApiGateway(
      initialRecords: [
        ApiClassificationDto(
          id: 'cls-restored',
          predictedMaterial: MaterialKey.cardboard,
          confirmedMaterial: MaterialKey.cardboard,
          confidence: 0.91,
          modelVersion: 'resnet18-trashnet-v1.0.0',
          createdAtUtc: DateTime.now().toUtc(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pecoxApiProvider.overrideWithValue(fakeApi),
          tokenStorageProvider.overrideWithValue(tokenStorage),
        ],
        child: const PecoxVisionApp(initialLocation: '/'),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpAndSettle();

    expect(find.text('¿Qué vamos a reciclar hoy?'), findsOneWidget);
    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();

    expect(find.text('Cartón'), findsWidgets);
  });
}
