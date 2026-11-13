import 'package:flutter/material.dart';

enum MaterialKey {
  plastic,
  glass,
  metal,
  cardboard,
  paper,
  other,
}

String materialKeyToApi(MaterialKey key) => key.name;

MaterialKey materialKeyFromApi(String raw) {
  return MaterialKey.values.firstWhere(
    (item) => item.name == raw.trim().toLowerCase(),
    orElse: () => MaterialKey.other,
  );
}

enum PredictionStatus {
  identified,
  lowConfidence,
  unknown,
}

PredictionStatus predictionStatusFromApi(String raw) {
  return switch (raw) {
    'identified' => PredictionStatus.identified,
    'low_confidence' => PredictionStatus.lowConfidence,
    _ => PredictionStatus.unknown,
  };
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

  MaterialDefinition copyWith({String? label, String? description}) {
    return MaterialDefinition(
      key: key,
      label: label ?? this.label,
      icon: icon,
      bgColor: bgColor,
      fgColor: fgColor,
      description: description ?? this.description,
      examples: examples,
      steps: steps,
      warning: warning,
    );
  }
}

class MaterialAlternative {
  const MaterialAlternative({required this.key, required this.confidence});
  final MaterialKey key;
  final int confidence;
}

class PredictionResultModel {
  const PredictionResultModel({
    required this.predictionId,
    required this.material,
    required this.confidence,
    required this.alternatives,
    required this.modelVersion,
    required this.architecture,
    required this.status,
    required this.inferenceMs,
  });

  final String predictionId;
  final MaterialKey material;
  final double confidence;
  final List<MaterialAlternative> alternatives;
  final String modelVersion;
  final String architecture;
  final PredictionStatus status;
  final double inferenceMs;

  int get confidencePercent => (confidence * 100).round().clamp(0, 100);
}

class ModelInfoModel {
  const ModelInfoModel({
    required this.status,
    required this.activeVersion,
    required this.architecture,
    required this.note,
    this.identifiedThreshold,
    this.lowConfidenceThreshold,
  });

  final String status;
  final String? activeVersion;
  final String? architecture;
  final double? identifiedThreshold;
  final double? lowConfidenceThreshold;
  final String note;

  bool get isReady => status == 'ready';
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
    this.createdAtUtc,
    this.modelVersion,
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
  final DateTime? createdAtUtc;
  final String? modelVersion;
  final String? imagePath;
  final String? notes;

  ClassificationRecord copyWith({
    String? title,
    MaterialKey? confirmedMaterial,
    ClassificationStatus? status,
    String? notes,
  }) {
    return ClassificationRecord(
      id: id,
      title: title ?? this.title,
      predictedMaterial: predictedMaterial,
      confirmedMaterial: confirmedMaterial ?? this.confirmedMaterial,
      confidence: confidence,
      status: status ?? this.status,
      dateGroup: dateGroup,
      timestampLabel: timestampLabel,
      createdAtUtc: createdAtUtc,
      modelVersion: modelVersion,
      imagePath: imagePath,
      notes: notes ?? this.notes,
    );
  }
}

class UserProfile {
  const UserProfile({
    this.id,
    required this.name,
    required this.email,
    required this.initials,
    required this.badge,
    required this.isGuest,
    this.role = 'user',
  });

  final String? id;
  final String name;
  final String email;
  final String initials;
  final String badge;
  final bool isGuest;
  final String role;

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? initials,
    String? badge,
    bool? isGuest,
    String? role,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      initials: initials ?? this.initials,
      badge: badge ?? this.badge,
      isGuest: isGuest ?? this.isGuest,
      role: role ?? this.role,
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
        'Verifica la aceptación local para plásticos flexibles, films o unicel (poliestireno expandido).',
  ),
  MaterialDefinition(
    key: MaterialKey.glass,
    label: 'Vidrio',
    icon: Icons.wine_bar_outlined,
    bgColor: Color(0xFFE7F3FF),
    fgColor: Color(0xFF1F74BF),
    description:
        'Botellas y frascos de vidrio pueden reciclarse múltiples veces si se separan sin cerámica ni espejos.',
    examples: [
      'Botellas de bebidas y jugos',
      'Frascos de mermelada o conservas',
      'Envases de vidrio transparente o ámbar',
    ],
    steps: [
      MaterialStep(
        title: 'Retira tapas y corchos',
        detail: 'Separa las tapas metálicas o plásticas según su material.',
      ),
      MaterialStep(
        title: 'Enjuaga residuos espesos',
        detail: 'Evita restos de salsas o aceites adheridos.',
      ),
      MaterialStep(
        title: 'Deposita sin romper',
        detail: 'Manipula con cuidado para prevenir accidentes en la recolección.',
      ),
    ],
    warning:
        'No mezcles focos, espejos, cristalería de ventana ni cerámica con envases de vidrio.',
  ),
  MaterialDefinition(
    key: MaterialKey.metal,
    label: 'Metal',
    icon: Icons.inventory_2_outlined,
    bgColor: Color(0xFFEBF0EE),
    fgColor: Color(0xFF3E5950),
    description:
        'Latas de aluminio y hojalata conservan alto valor de recuperación cuando están limpias y vacías.',
    examples: [
      'Latas de aluminio de bebidas',
      'Conservas y enlatados de hojalata',
      'Tapas metálicas de frascos',
    ],
    steps: [
      MaterialStep(
        title: 'Escurre líquidos o aceite',
        detail: 'Vacía completamente el contenido del envase.',
      ),
      MaterialStep(
        title: 'Enjuaga y seca',
        detail: 'Reduce olores durante el acopio en casa.',
      ),
      MaterialStep(
        title: 'Cuida los bordes cortantes',
        detail: 'Dobla tapas hacia adentro si representan riesgo.',
      ),
    ],
    warning:
        'No incluyas aerosoles presurizados ni latas con restos de pintura o solventes en el reciclaje doméstico.',
  ),
  MaterialDefinition(
    key: MaterialKey.cardboard,
    label: 'Cartón',
    icon: Icons.all_inbox_outlined,
    bgColor: Color(0xFFFBF3E4),
    fgColor: Color(0xFF9E6A1C),
    description:
        'Cajas corrugadas y empaques limpios que mantienen sus fibras secas y sin contaminación por grasas.',
    examples: [
      'Cajas de paquetería y envíos',
      'Empaques de cereales o calzado',
      'Tubos de cartón limpios',
    ],
    steps: [
      MaterialStep(
        title: 'Retira cintas y etiquetas gruesas',
        detail: 'Quita plásticos de embalaje y relleno externo.',
      ),
      MaterialStep(
        title: 'Verifica que esté seco',
        detail: 'La humedad y la grasa degradan la fibra reciclable.',
      ),
      MaterialStep(
        title: 'Aplana las cajas',
        detail: 'Ahorra espacio y facilita el transporte.',
      ),
    ],
    warning:
        'Las partes manchadas de grasa o comida (por ejemplo, base de cajas de pizza) deben descartarse aparte.',
  ),
  MaterialDefinition(
    key: MaterialKey.paper,
    label: 'Papel',
    icon: Icons.description_outlined,
    bgColor: Color(0xFFEFF8E3),
    fgColor: Color(0xFF4F7D18),
    description:
        'Hojas impresas, cuadernos, sobres y folletos sin plastificado ni humedad excesiva.',
    examples: [
      'Hojas de oficina y apuntes',
      'Periódicos, revistas y folletos',
      'Bolsas de papel limpias',
    ],
    steps: [
      MaterialStep(
        title: 'Retira espirales o grapas grandes',
        detail: 'Separa anillas plásticas o metálicas de cuadernos.',
      ),
      MaterialStep(
        title: 'Mantén las hojas secas',
        detail: 'No mezcles papel mojado o sucio con restos orgánicos.',
      ),
      MaterialStep(
        title: 'Agrúpalas planas',
        detail: 'Evita arrugar en exceso para preservar la fibra.',
      ),
    ],
    warning:
        'No son reciclables servilletas usadas, papel higiénico, recibos térmicos ni papel carbón.',
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
