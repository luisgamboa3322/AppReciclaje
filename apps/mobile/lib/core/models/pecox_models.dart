import 'package:flutter/material.dart';

enum MaterialKey {
  plastic,
  glass,
  metal,
  cardboard,
  paper,
  other,
}

enum ResultVariant {
  identified,
  lowConfidence,
  unknown,
  error,
}

enum ClassificationStatus {
  confirmed,
  corrected,
}

class MaterialStep {
  const MaterialStep({required this.title, required this.detail});
  final String title;
  final String detail;
}

class MaterialDefinition {
  const MaterialDefinition({
    required this.key,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.fgColor,
    required this.description,
    required this.examples,
    required this.steps,
    required this.warning,
  });

  final MaterialKey key;
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color fgColor;
  final String description;
  final List<String> examples;
  final List<MaterialStep> steps;
  final String warning;
}

class MaterialAlternative {
  const MaterialAlternative({required this.key, required this.confidence});
  final MaterialKey key;
  final int confidence;
}

class ClassificationRecord {
  const ClassificationRecord({
    required this.id,
    required this.title,
    required this.predictedMaterial,
    required this.confirmedMaterial,
    required this.confidence,
    required this.status,
    required this.dateGroup,
    required this.timestampLabel,
    this.imagePath,
    this.notes,
  });

  final String id;
  final String title;
  final MaterialKey predictedMaterial;
  final MaterialKey confirmedMaterial;
  final int? confidence;
  final ClassificationStatus status;
  final String dateGroup;
  final String timestampLabel;
  final String? imagePath;
  final String? notes;
}

class DemoPrediction {
  const DemoPrediction({
    required this.title,
    required this.material,
    required this.confidence,
    required this.alternatives,
    required this.modelVersion,
    required this.headline,
    required this.explanation,
  });

  final String title;
  final MaterialKey material;
  final int? confidence;
  final List<MaterialAlternative> alternatives;
  final String modelVersion;
  final String headline;
  final String explanation;
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.initials,
    required this.badge,
    required this.isGuest,
  });

  final String name;
  final String email;
  final String initials;
  final String badge;
  final bool isGuest;

  UserProfile copyWith({
    String? name,
    String? email,
    String? initials,
    String? badge,
    bool? isGuest,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      initials: initials ?? this.initials,
      badge: badge ?? this.badge,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

class AccessibilitySettings {
  const AccessibilitySettings({
    this.largeText = false,
    this.reduceMotion = false,
  });

  final bool largeText;
  final bool reduceMotion;

  AccessibilitySettings copyWith({bool? largeText, bool? reduceMotion}) {
    return AccessibilitySettings(
      largeText: largeText ?? this.largeText,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

const List<MaterialDefinition> kMaterials = [
  MaterialDefinition(
    key: MaterialKey.plastic,
    label: 'Plástico',
    icon: Icons.local_drink_outlined,
    bgColor: Color(0xFFE1F7EE),
    fgColor: Color(0xFF078963),
    description:
        'Envases rígidos como botellas PET y recipientes de limpieza o alimentos. No todos los polímeros son aceptados en todos los programas.',
    examples: [
      'Botellas de agua y bebidas (PET 1)',
      'Envases de detergente o champú (HDPE 2)',
      'Tapas plásticas limpias',
    ],
    steps: [
      MaterialStep(
        title: 'Vacía el contenido',
        detail: 'Asegúrate de no dejar líquidos o restos de alimentos.',
      ),
      MaterialStep(
        title: 'Enjuaga ligeramente',
        detail: 'Un enjuague breve evita malos olores y contaminación.',
      ),
      MaterialStep(
        title: 'Aplasta y coloca la tapa',
        detail: 'Reduce el volumen para facilitar el almacenamiento.',
      ),
    ],
    warning:
        'Plásticos flexibles, films sucios o unicel suelen requerir puntos de acopio específicos.',
  ),
  MaterialDefinition(
    key: MaterialKey.glass,
    label: 'Vidrio',
    icon: Icons.wine_bar_outlined,
    bgColor: Color(0xFFE4F2F8),
    fgColor: Color(0xFF3E7B96),
    description:
        'Botellas y frascos de vidrio transparente o de color. Reciclable múltiples veces si no se mezcla con cerámica ni cristales especiales.',
    examples: [
      'Botellas de jugos, salsas o bebidas',
      'Frascos de conservas y mermeladas',
      'Envases cosméticos sin dosificador',
    ],
    steps: [
      MaterialStep(
        title: 'Retira tapas y corchos',
        detail: 'Separa las tapas metálicas o plásticas según su material.',
      ),
      MaterialStep(
        title: 'Enjuaga residuos espesos',
        detail: 'Quita restos de salsas o aceites del interior.',
      ),
      MaterialStep(
        title: 'Manipula sin romper',
        detail: 'Deposítalo entero para evitar riesgos al recolectar.',
      ),
    ],
    warning:
        'No mezcles espejos, focos, vidrio templado, pyrex ni cerámica con envases de vidrio.',
  ),
  MaterialDefinition(
    key: MaterialKey.metal,
    label: 'Metal',
    icon: Icons.recycling_outlined,
    bgColor: Color(0xFFEDF0EE),
    fgColor: Color(0xFF5A6862),
    description:
        'Latas de aluminio y acero o hojalata de uso doméstico. Se recuperan con alta eficiencia cuando están limpias.',
    examples: [
      'Latas de bebidas de aluminio',
      'Conservas metálicas y tapas rosca',
      'Bandejas de aluminio limpias',
    ],
    steps: [
      MaterialStep(
        title: 'Escurre líquidos o aceite',
        detail: 'Vacía por completo latas de conservas y bebidas.',
      ),
      MaterialStep(
        title: 'Enjuaga y seca',
        detail: 'Evita restos adheridos en el borde interior.',
      ),
      MaterialStep(
        title: 'Cuida los bordes cortantes',
        detail: 'Dobla la tapa hacia adentro con precaución.',
      ),
    ],
    warning:
        'Aerosoles presurizados, latas de pintura o pilas requieren manejo especial.',
  ),
  MaterialDefinition(
    key: MaterialKey.cardboard,
    label: 'Cartón',
    icon: Icons.inventory_2_outlined,
    bgColor: Color(0xFFF8EFDD),
    fgColor: Color(0xFF91671E),
    description:
        'Cajas corrugadas y empaques de cartón seco. La humedad y la grasa reducen su recuperación.',
    examples: [
      'Cajas de paquetería y envíos',
      'Empaques de cereales o calzado',
      'Tubos de cartón limpios',
    ],
    steps: [
      MaterialStep(
        title: 'Retira cintas y plásticos',
        detail: 'Quita rellenos de espuma o cintas gruesas.',
      ),
      MaterialStep(
        title: 'Verifica que esté seco',
        detail: 'El cartón manchado con aceite no debe mezclarse.',
      ),
      MaterialStep(
        title: 'Desarma y aplana',
        detail: 'Dobla las cajas para ahorrar espacio.',
      ),
    ],
    warning:
        'Cartón impregnado con comida o grasa debe ir a no aprovechables u orgánicos según normativa local.',
  ),
  MaterialDefinition(
    key: MaterialKey.paper,
    label: 'Papel',
    icon: Icons.description_outlined,
    bgColor: Color(0xFFF0EBF8),
    fgColor: Color(0xFF6B5698),
    description:
        'Hojas de oficina, cuadernos, periódicos y folletos limpios. Conviene mantenerlos secos y sin plastificados.',
    examples: [
      'Hojas impresas y cuadernos sin espiral',
      'Periódicos, revistas y sobres sin ventana',
      'Bolsas de papel kraft limpias',
    ],
    steps: [
      MaterialStep(
        title: 'Separa grapas o espirales',
        detail: 'Retira anillados metálicos o plásticos gruesos.',
      ),
      MaterialStep(
        title: 'Mantén las hojas secas',
        detail: 'Almacena lejos de envases con líquidos.',
      ),
      MaterialStep(
        title: 'Agrupa plano',
        detail: 'Evita arrugarlo en exceso para facilitar la clasificación.',
      ),
    ],
    warning:
        'Servilletas usadas, papel higiénico, tickets térmicos y papel carbón no van en papel reciclable.',
  ),
  MaterialDefinition(
    key: MaterialKey.other,
    label: 'Otros',
    icon: Icons.category_outlined,
    bgColor: Color(0xFFFAECE6),
    fgColor: Color(0xFFA05D42),
    description:
        'Residuos compuestos, multicapa, electrónicos, textiles u objetos que no pertenecen a las cinco categorías principales.',
    examples: [
      'Envases multicapa / Tetra Pak (según programa)',
      'Baterías, cables y pequeños electrónicos',
      'Residuos orgánicos o sanitarios',
    ],
    steps: [
      MaterialStep(
        title: 'Identifica si es residuo especial',
        detail: 'Pilas y electrónicos nunca deben ir con reciclables comunes.',
      ),
      MaterialStep(
        title: 'Consulta puntos de acopio',
        detail: 'Revisa si tu municipio recibe multicapa por separado.',
      ),
      MaterialStep(
        title: 'Corrige si es mixto',
        detail: 'Usa la corrección manual si predominaba otro material.',
      ),
    ],
    warning:
        'Categoría heterogénea: verifica siempre las reglas de recolección de tu localidad.',
  ),
];

MaterialDefinition materialByKey(MaterialKey key) {
  return kMaterials.firstWhere((item) => item.key == key, orElse: () => kMaterials.first);
}

const List<ClassificationRecord> kInitialDemoHistory = [
  ClassificationRecord(
    id: 'cls-101',
    title: 'Botella de plástico PET',
    predictedMaterial: MaterialKey.plastic,
    confirmedMaterial: MaterialKey.plastic,
    confidence: 86,
    status: ClassificationStatus.confirmed,
    dateGroup: 'HOY',
    timestampLabel: 'Hoy, 10:32',
    notes: 'Ejemplo ilustrativo inicial del prototipo.',
  ),
  ClassificationRecord(
    id: 'cls-102',
    title: 'Frasco de conservas',
    predictedMaterial: MaterialKey.glass,
    confirmedMaterial: MaterialKey.glass,
    confidence: 92,
    status: ClassificationStatus.confirmed,
    dateGroup: 'HOY',
    timestampLabel: 'Ayer, 18:05',
    notes: 'Ejemplo ilustrativo de vidrio transparente.',
  ),
  ClassificationRecord(
    id: 'cls-103',
    title: 'Lata de bebida',
    predictedMaterial: MaterialKey.plastic,
    confirmedMaterial: MaterialKey.metal,
    confidence: 58,
    status: ClassificationStatus.corrected,
    dateGroup: 'ESTA SEMANA',
    timestampLabel: 'Lun, 12:41',
    notes: 'Ejemplo de corrección manual preservando predicción original.',
  ),
  ClassificationRecord(
    id: 'cls-104',
    title: 'Caja de paquetería',
    predictedMaterial: MaterialKey.cardboard,
    confirmedMaterial: MaterialKey.cardboard,
    confidence: 89,
    status: ClassificationStatus.confirmed,
    dateGroup: 'ESTA SEMANA',
    timestampLabel: 'Dom, 16:15',
  ),
];

const Map<ResultVariant, DemoPrediction> kDemoPredictions = {
  ResultVariant.identified: DemoPrediction(
    title: 'Botella de plástico',
    material: MaterialKey.plastic,
    confidence: 86,
    alternatives: [
      MaterialAlternative(key: MaterialKey.glass, confidence: 8),
      MaterialAlternative(key: MaterialKey.other, confidence: 4),
    ],
    modelVersion: 'demo-ui-v0',
    headline: 'Vista de demostración · Modelo ML aún no conectado',
    explanation:
        'Esta pantalla ilustra el contrato esperado. La inferencia real con PyTorch se conectará en las Fases 3 y 4.',
  ),
  ResultVariant.lowConfidence: DemoPrediction(
    title: 'Objeto reflejante',
    material: MaterialKey.metal,
    confidence: 48,
    alternatives: [
      MaterialAlternative(key: MaterialKey.glass, confidence: 31),
      MaterialAlternative(key: MaterialKey.plastic, confidence: 15),
    ],
    modelVersion: 'demo-ui-v0',
    headline: 'Confianza baja · Revisa o corrige manualmente',
    explanation:
        'Cuando el puntaje esté por debajo del umbral de validación, la app solicita confirmación manual antes de guardar.',
  ),
  ResultVariant.unknown: DemoPrediction(
    title: 'Objeto no reconocido',
    material: MaterialKey.other,
    confidence: 29,
    alternatives: [
      MaterialAlternative(key: MaterialKey.cardboard, confidence: 18),
      MaterialAlternative(key: MaterialKey.plastic, confidence: 14),
    ],
    modelVersion: 'demo-ui-v0',
    headline: 'Material incierto o fuera de categoría',
    explanation:
        'La fotografía podría estar borrosa o contener varios residuos mezclados. Puedes elegir el material manualmente.',
  ),
};

const List<(String day, int count)> kDemoWeeklyActivity = [
  ('Lun', 3),
  ('Mar', 5),
  ('Mié', 2),
  ('Jue', 6),
  ('Vie', 4),
  ('Sáb', 3),
  ('Dom', 1),
];
