import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pecox_vision/core/state/app_state.dart';
import 'package:pecox_vision/main.dart';

class _FakeImagePickerService extends ImagePickerService {
  _FakeImagePickerService(this.outcome);
  final PickImageOutcome outcome;

  @override
  Future<PickImageResult> pick(ImageSource source) async {
    return PickImageResult(outcome: outcome);
  }
}

void main() {
  testWidgets('Full onboarding, auth, and home navigation flow works', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PecoxVisionApp(initialLocation: '/')),
    );

    expect(find.text('Reconoce. Aprende. Recicla.'), findsOneWidget);
    await tester.tap(find.text('Continuar ahora'));
    await tester.pumpAndSettle();

    expect(find.text('Reconoce tus residuos'), findsOneWidget);
    await tester.tap(find.text('Omitir'));
    await tester.pumpAndSettle();

    expect(find.text('Inicia sesión en PECOX'), findsOneWidget);
    await tester.tap(find.text('Entrar a PECOX Vision'));
    await tester.pumpAndSettle();

    expect(find.text('¿Qué vamos a reciclar hoy?'), findsOneWidget);
  });

  testWidgets('Scanner -> Preview -> Analyzing -> Result -> Correction -> Save flow works',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          imagePickerServiceProvider.overrideWithValue(
            _FakeImagePickerService(PickImageOutcome.unavailableFallback),
          ),
        ],
        child: const PecoxVisionApp(initialLocation: '/home'),
      ),
    );

    await tester.tap(find.text('Escanear ahora'));
    await tester.pumpAndSettle();

    expect(find.text('Coloca el residuo dentro del encuadre'), findsOneWidget);

    await tester.tap(find.byKey(const Key('scanner-shutter')));
    await tester.pumpAndSettle();

    expect(find.text('¿La imagen se ve clara?'), findsOneWidget);
    await tester.ensureVisible(find.text('Analizar material'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analizar material'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Analizando el material'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('Plástico'), findsWidgets);

    // Open manual correction sheet and switch to Vidrio
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
  });

  testWidgets('Guest can explore material guide without login and switch categories',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PecoxVisionApp(initialLocation: '/auth')),
    );

    await tester.tap(find.text('Explorar guía de materiales sin cuenta'));
    await tester.pumpAndSettle();

    expect(find.text('Cada material tiene su lugar'), findsOneWidget);
    expect(find.text('Vacía el contenido'), findsOneWidget);

    await tester.tap(find.text('Vidrio'));
    await tester.pumpAndSettle();

    expect(find.text('Retira tapas y corchos'), findsOneWidget);
  });

  testWidgets('Clearing history in Profile shows empty state CTA in History',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: PecoxVisionApp(initialLocation: '/profile')),
    );

    await tester.tap(find.text('Privacidad y datos'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Historial'));
    await tester.pumpAndSettle();

    expect(find.text('Aún no tienes clasificaciones'), findsOneWidget);
    expect(find.text('Escanear mi primer residuo'), findsOneWidget);
  });

  testWidgets('Camera denied displays gallery and guide fallback actions',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          imagePickerServiceProvider.overrideWithValue(
            _FakeImagePickerService(PickImageOutcome.cameraDenied),
          ),
        ],
        child: const PecoxVisionApp(initialLocation: '/scanner'),
      ),
    );

    await tester.tap(find.byKey(const Key('scanner-shutter')));
    await tester.pumpAndSettle();

    expect(find.text('Cámara no disponible o denegada'), findsOneWidget);
    expect(find.text('Elegir imagen de la galería'), findsOneWidget);
    expect(find.text('Abrir guía de materiales'), findsOneWidget);
  });
}
