import type {
  ClassificationRecord,
  MaterialAlternative,
  MaterialKey,
  ResultVariant,
} from "../types/pecox";

export const DEMO_PHOTO =
  "https://images.unsplash.com/photo-1616118132534-381148898bb4?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=85&w=1080";

export interface MaterialGuideStep {
  title: string;
  detail: string;
}

export interface MaterialDefinition {
  key: MaterialKey;
  label: string;
  icon: string;
  tone: "mint" | "blue" | "gray" | "sand" | "lilac" | "peach";
  accentColor: string;
  description: string;
  examples: string[];
  steps: MaterialGuideStep[];
  warning: string;
}

export const MATERIALS: MaterialDefinition[] = [
  {
    key: "plastic",
    label: "Plástico",
    icon: "♳",
    tone: "mint",
    accentColor: "#12C994",
    description:
      "Envases rígidos como botellas PET y recipientes de limpieza o alimentos. No todos los polímeros son aceptados por todos los programas.",
    examples: [
      "Botellas de agua y bebidas (PET 1)",
      "Envases de detergente o champú (HDPE 2)",
      "Tapas plásticas limpias",
    ],
    steps: [
      {
        title: "Vacía el contenido",
        detail: "Asegúrate de no dejar líquidos o restos de alimentos en el envase.",
      },
      {
        title: "Enjuaga ligeramente",
        detail: "Un enjuague breve evita malos olores y contaminación de otros materiales.",
      },
      {
        title: "Aplasta y coloca la tapa",
        detail: "Reduce el volumen para facilitar el almacenamiento y transporte.",
      },
    ],
    warning:
      "Plásticos flexibles, films sucios o unicel suelen requerir puntos de acopio específicos.",
  },
  {
    key: "glass",
    label: "Vidrio",
    icon: "◒",
    tone: "blue",
    accentColor: "#4C8EAC",
    description:
      "Botellas y frascos de vidrio transparente o de color. Es reciclable múltiples veces si no se mezcla con cerámica ni cristales especiales.",
    examples: [
      "Botellas de jugos, salsas o bebidas",
      "Frascos de conservas y mermeladas",
      "Envases cosméticos de vidrio sin dosificador",
    ],
    steps: [
      {
        title: "Retira tapas y corchos",
        detail: "Separa las tapas metálicas o plásticas según su propio material.",
      },
      {
        title: "Enjuaga residuos espesos",
        detail: "Quita restos de salsas o aceites para mantener limpio el lote.",
      },
      {
        title: "Manipula sin romper",
        detail: "Deposítalo entero cuando sea posible para evitar riesgos al recolectar.",
      },
    ],
    warning:
      "No mezcles espejos, focos, vidrio templado, pyrex ni cerámica con envases de vidrio.",
  },
  {
    key: "metal",
    label: "Metal",
    icon: "⌁",
    tone: "gray",
    accentColor: "#6F7D77",
    description:
      "Latas de aluminio y acero o hojalata de uso doméstico. Se recuperan con alta eficiencia cuando están libres de residuos orgánicos.",
    examples: [
      "Latas de bebidas de aluminio",
      "Conservas metálicas y tapas rosca",
      "Bandejas de aluminio limpias",
    ],
    steps: [
      {
        title: "Escurre líquidos o aceite",
        detail: "Vacía por completo latas de conservas y bebidas.",
      },
      {
        title: "Enjuaga y seca",
        detail: "Evita restos de comida adheridos en el borde interior.",
      },
      {
        title: "Cuida los bordes cortantes",
        detail: "Si abriste una conserva, dobla la tapa hacia adentro con precaución.",
      },
    ],
    warning:
      "Aerosoles presurizados, latas de pintura o pilas requieren manejo especial y no van al contenedor común.",
  },
  {
    key: "cardboard",
    label: "Cartón",
    icon: "□",
    tone: "sand",
    accentColor: "#A5782B",
    description:
      "Cajas corrugadas y empaques de cartón seco. La humedad y la grasa reducen significativamente su valor de recuperación.",
    examples: [
      "Cajas de paquetería y envíos",
      "Empaques de cereales o calzado",
      "Tubos de cartón limpios",
    ],
    steps: [
      {
        title: "Retira cintas y plásticos",
        detail: "Quita burbujas, rellenos de espuma o cintas gruesas cuando sea fácil.",
      },
      {
        title: "Verifica que esté seco",
        detail: "El cartón mojado o impregnado con aceite de pizza no debe mezclarse.",
      },
      {
        title: "Desarma y aplana",
        detail: "Dobla las cajas para ahorrar espacio en tu hogar y en la recolección.",
      },
    ],
    warning:
      "Cartón manchado con comida o grasa debe ir a residuos orgánicos o no aprovechables según tu municipio.",
  },
  {
    key: "paper",
    label: "Papel",
    icon: "≋",
    tone: "lilac",
    accentColor: "#826CB2",
    description:
      "Hojas de oficina, cuadernos, periódicos y folletos limpios. Conviene mantenerlos agrupados, secos y sin plastificados.",
    examples: [
      "Hojas impresas y cuadernos sin espiral",
      "Periódicos, revistas y sobres sin ventana plástica",
      "Bolsas de papel kraft limpias",
    ],
    steps: [
      {
        title: "Separa grapas grandes o espirales",
        detail: "Retira anillados plásticos o metálicos gruesos de cuadernos.",
      },
      {
        title: "Mantén las hojas secas",
        detail: "Almacena el papel lejos de envases con líquidos.",
      },
      {
        title: "Agrupa sin arrugar en exceso",
        detail: "Apilarlo plano facilita la clasificación en planta.",
      },
    ],
    warning:
      "Servilletas usadas, papel higiénico, tickets térmicos y papel carbón no son reciclables en papel común.",
  },
  {
    key: "other",
    label: "Otros",
    icon: "＋",
    tone: "peach",
    accentColor: "#BB7357",
    description:
      "Residuos compuestos, multicapa, electrónicos, textiles u objetos que no pertenecen a las cinco categorías principales.",
    examples: [
      "Envases multicapa / Tetra Pak (según programa local)",
      "Baterías, cables y pequeños electrónicos",
      "Residuos orgánicos o sanitarios",
    ],
    steps: [
      {
        title: "Identifica si es residuo especial",
        detail: "Pilas, focos y electrónicos nunca deben mezclarse con reciclables comunes.",
      },
      {
        title: "Consulta puntos de acopio",
        detail: "Algunos municipios aceptan envases multicapa en puntos diferenciados.",
      },
      {
        title: "Corrige si el objeto es mixto",
        detail: "Usa la corrección manual si predominaba otro material reciclable.",
      },
    ],
    warning:
      "Esta categoría agrupa objetos heterogéneos: revisa la normativa local antes de desecharlos.",
  },
];

export function getMaterialByKey(key: MaterialKey): MaterialDefinition {
  return MATERIALS.find((item) => item.key === key) ?? MATERIALS[0];
}

export const INITIAL_HISTORY: ClassificationRecord[] = [
  {
    id: "cls-101",
    title: "Botella de plástico PET",
    predictedMaterial: "plastic",
    confirmedMaterial: "plastic",
    confidence: 86,
    status: "confirmed",
    dateGroup: "HOY",
    timestampLabel: "Hoy, 10:32",
    imageUrl: DEMO_PHOTO,
    notes: "Ejemplo ilustrativo inicial del prototipo.",
  },
  {
    id: "cls-102",
    title: "Frasco de conservas",
    predictedMaterial: "glass",
    confirmedMaterial: "glass",
    confidence: 92,
    status: "confirmed",
    dateGroup: "HOY",
    timestampLabel: "Ayer, 18:05",
    notes: "Ejemplo ilustrativo de vidrio transparente.",
  },
  {
    id: "cls-103",
    title: "Lata de bebida",
    predictedMaterial: "plastic",
    confirmedMaterial: "metal",
    confidence: 58,
    status: "corrected",
    dateGroup: "ESTA SEMANA",
    timestampLabel: "Lun, 12:41",
    notes: "Ejemplo de corrección manual preservando predicción original.",
  },
  {
    id: "cls-104",
    title: "Caja de paquetería",
    predictedMaterial: "cardboard",
    confirmedMaterial: "cardboard",
    confidence: 89,
    status: "confirmed",
    dateGroup: "ESTA SEMANA",
    timestampLabel: "Dom, 16:15",
  },
];

export interface DemoPredictionPayload {
  title: string;
  material: MaterialKey;
  confidence: number | null;
  alternatives: MaterialAlternative[];
  modelVersion: string;
  headline: string;
  explanation: string;
}

export const DEMO_PREDICTIONS: Record<Exclude<ResultVariant, "error">, DemoPredictionPayload> = {
  identified: {
    title: "Botella de plástico",
    material: "plastic",
    confidence: 86,
    alternatives: [
      { key: "glass", confidence: 8 },
      { key: "other", confidence: 4 },
    ],
    modelVersion: "demo-ui-v0",
    headline: "Material sugerido con confianza alta (Demo)",
    explanation:
      "Vista ilustrativa del contrato esperado. El modelo real de PyTorch se integrará en Fase 3.",
  },
  "low-confidence": {
    title: "Objeto reflejante",
    material: "metal",
    confidence: 48,
    alternatives: [
      { key: "glass", confidence: 31 },
      { key: "plastic", confidence: 15 },
    ],
    modelVersion: "demo-ui-v0",
    headline: "Confianza baja — confirma o corrige el material",
    explanation:
      "Cuando la puntuación está por debajo del umbral de validación, la app solicita revisión manual antes de guardar.",
  },
  unknown: {
    title: "Objeto no reconocido",
    material: "other",
    confidence: 29,
    alternatives: [
      { key: "cardboard", confidence: 18 },
      { key: "plastic", confidence: 14 },
    ],
    modelVersion: "demo-ui-v0",
    headline: "Material incierto o fuera de categoría",
    explanation:
      "La foto podría tener poca luz, varios objetos mezclados o un material no cubierto por el clasificador.",
  },
};

export const DEMO_WEEKLY_ACTIVITY = [
  { day: "Lun", count: 3 },
  { day: "Mar", count: 5 },
  { day: "Mié", count: 2 },
  { day: "Jue", count: 6 },
  { day: "Vie", count: 4 },
  { day: "Sáb", count: 3 },
  { day: "Dom", count: 1 },
];

export const DEMO_FUTURE_MACHINES = [
  {
    id: "pecox-m-01",
    name: "Módulo Campus Ingeniería (Ejemplo)",
    status: "En línea (simulado)",
    fillLevel: 68,
    accepted: ["Plástico", "Metal"],
    alert: "Sin alertas críticas",
  },
  {
    id: "pecox-m-02",
    name: "Módulo Biblioteca Central (Ejemplo)",
    status: "Mantenimiento requerido",
    fillLevel: 92,
    accepted: ["Papel", "Cartón"],
    alert: "Contenedor cercano al límite de llenado",
  },
];
