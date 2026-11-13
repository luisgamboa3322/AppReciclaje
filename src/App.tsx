import { useEffect, useRef, useState, type ChangeEvent, type ReactNode } from "react";

type Screen =
  | "home"
  | "scan"
  | "preview"
  | "analyzing"
  | "result"
  | "history"
  | "guide"
  | "profile";

type IconName =
  | "home"
  | "scan"
  | "history"
  | "user"
  | "bell"
  | "arrow"
  | "sparkles"
  | "camera"
  | "image"
  | "close"
  | "flash"
  | "info"
  | "check"
  | "edit"
  | "book"
  | "chevron"
  | "settings"
  | "shield"
  | "eye"
  | "logout"
  | "leaf"
  | "search";

const PHOTO =
  "https://images.unsplash.com/photo-1616118132534-381148898bb4?crop=entropy&cs=tinysrgb&fit=crop&fm=jpg&q=85&w=1080";

const iconPaths: Record<IconName, ReactNode> = {
  home: (
    <>
      <path d="m3 10 9-7 9 7" />
      <path d="M5 9v11h14V9M9 20v-7h6v7" />
    </>
  ),
  scan: (
    <>
      <path d="M4 8V5a1 1 0 0 1 1-1h3M16 4h3a1 1 0 0 1 1 1v3M20 16v3a1 1 0 0 1-1 1h-3M8 20H5a1 1 0 0 1-1-1v-3" />
      <circle cx="12" cy="12" r="3" />
    </>
  ),
  history: (
    <>
      <path d="M3 12a9 9 0 1 0 3-6.7L3 8" />
      <path d="M3 3v5h5M12 7v5l3 2" />
    </>
  ),
  user: (
    <>
      <circle cx="12" cy="8" r="4" />
      <path d="M4 21a8 8 0 0 1 16 0" />
    </>
  ),
  bell: (
    <>
      <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4" />
    </>
  ),
  arrow: (
    <>
      <path d="M5 12h14M14 7l5 5-5 5" />
    </>
  ),
  sparkles: (
    <>
      <path d="m12 3 1.3 3.7L17 8l-3.7 1.3L12 13l-1.3-3.7L7 8l3.7-1.3L12 3ZM5 14l.8 2.2L8 17l-2.2.8L5 20l-.8-2.2L2 17l2.2-.8L5 14ZM19 14l.8 2.2L22 17l-2.2.8L19 20l-.8-2.2L16 17l2.2-.8L19 14Z" />
    </>
  ),
  camera: (
    <>
      <path d="M4 7h3l2-3h6l2 3h3v13H4z" />
      <circle cx="12" cy="13" r="4" />
    </>
  ),
  image: (
    <>
      <rect x="3" y="4" width="18" height="16" rx="2" />
      <circle cx="8.5" cy="9" r="1.5" />
      <path d="m21 15-5-5L5 20" />
    </>
  ),
  close: <path d="m6 6 12 12M18 6 6 18" />,
  flash: <path d="m13 2-7 12h6l-1 8 7-12h-6z" />,
  info: (
    <>
      <circle cx="12" cy="12" r="9" />
      <path d="M12 11v6M12 7h.01" />
    </>
  ),
  check: <path d="m5 12 4 4L19 6" />,
  edit: (
    <>
      <path d="M13.5 6.5 17.5 10.5M4 20l4.5-1 10-10a2.8 2.8 0 0 0-4-4l-10 10z" />
    </>
  ),
  book: (
    <>
      <path d="M4 5a3 3 0 0 1 3-2h5v17H7a3 3 0 0 0-3 2zM20 5a3 3 0 0 0-3-2h-5v17h5a3 3 0 0 1 3 2z" />
    </>
  ),
  chevron: <path d="m9 18 6-6-6-6" />,
  settings: (
    <>
      <circle cx="12" cy="12" r="3" />
      <path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1-2.8 2.8-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.6v.2h-4V21a1.7 1.7 0 0 0-1-1.6 1.7 1.7 0 0 0-1.9.3l-.1.1L4.2 17l.1-.1a1.7 1.7 0 0 0 .3-1.9A1.7 1.7 0 0 0 3 14H2.8v-4H3a1.7 1.7 0 0 0 1.6-1 1.7 1.7 0 0 0-.3-1.9L4.2 7 7 4.2l.1.1A1.7 1.7 0 0 0 9 4.6 1.7 1.7 0 0 0 10 3V2.8h4V3a1.7 1.7 0 0 0 1 1.6 1.7 1.7 0 0 0 1.9-.3l.1-.1L19.8 7l-.1.1a1.7 1.7 0 0 0-.3 1.9 1.7 1.7 0 0 0 1.6 1h.2v4H21a1.7 1.7 0 0 0-1.6 1Z" />
    </>
  ),
  shield: <path d="M12 22s8-3 8-10V5l-8-3-8 3v7c0 7 8 10 8 10Z" />,
  eye: (
    <>
      <path d="M2 12s3.5-6 10-6 10 6 10 6-3.5 6-10 6S2 12 2 12Z" />
      <circle cx="12" cy="12" r="2.5" />
    </>
  ),
  logout: (
    <>
      <path d="M10 17l5-5-5-5M15 12H3M15 4h5v16h-5" />
    </>
  ),
  leaf: (
    <>
      <path d="M20 3C11 3 5 7 5 13c0 3 2 5 5 5 6 0 10-6 10-15Z" />
      <path d="M4 21c2-6 6-9 12-12" />
    </>
  ),
  search: (
    <>
      <circle cx="10.5" cy="10.5" r="6.5" />
      <path d="m16 16 5 5" />
    </>
  ),
};

function Icon({
  name,
  size = 22,
  strokeWidth = 1.8,
}: {
  name: IconName;
  size?: number;
  strokeWidth?: number;
}) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth={strokeWidth}
      strokeLinecap="round"
      strokeLinejoin="round"
      aria-hidden="true"
    >
      {iconPaths[name]}
    </svg>
  );
}

const materials = [
  { label: "Plástico", icon: "♳", tone: "mint" },
  { label: "Vidrio", icon: "◒", tone: "blue" },
  { label: "Metal", icon: "⌁", tone: "gray" },
  { label: "Cartón", icon: "□", tone: "sand" },
  { label: "Papel", icon: "≋", tone: "lilac" },
  { label: "Otros", icon: "＋", tone: "peach" },
];

function Brand({ light = false }: { light?: boolean }) {
  return (
    <div className={`brand ${light ? "brand--light" : ""}`} aria-label="PECOX Vision">
      <span className="brand-mark">
        <Icon name="leaf" size={19} strokeWidth={2.2} />
      </span>
      <span>
        PECOX<span>Vision</span>
      </span>
    </div>
  );
}

function TopBar({
  title,
  onBack,
  action,
}: {
  title: string;
  onBack: () => void;
  action?: ReactNode;
}) {
  return (
    <header className="topbar">
      <button className="icon-btn" onClick={onBack} aria-label="Volver">
        <span className="back-glyph">‹</span>
      </button>
      <h1>{title}</h1>
      <div className="topbar-action">{action}</div>
    </header>
  );
}

function BottomNav({ screen, navigate }: { screen: Screen; navigate: (screen: Screen) => void }) {
  const items: { target: Screen; label: string; icon: IconName }[] = [
    { target: "home", label: "Inicio", icon: "home" },
    { target: "scan", label: "Escanear", icon: "scan" },
    { target: "history", label: "Historial", icon: "history" },
    { target: "profile", label: "Perfil", icon: "user" },
  ];
  return (
    <nav className="bottom-nav" aria-label="Navegación principal">
      {items.map((item) => (
        <button
          key={item.target}
          className={screen === item.target ? "active" : ""}
          onClick={() => navigate(item.target)}
        >
          <span className={item.target === "scan" ? "scan-nav-icon" : ""}>
            <Icon name={item.icon} size={21} />
          </span>
          <small>{item.label}</small>
        </button>
      ))}
    </nav>
  );
}

function Home({ navigate }: { navigate: (screen: Screen) => void }) {
  return (
    <div className="page page-with-nav home-page">
      <header className="home-header">
        <div>
          <Brand />
          <p>
            Hola, Sofía <span aria-hidden="true">·</span> Cada clasificación cuenta
          </p>
        </div>
        <button
          className="avatar-btn"
          aria-label="Abrir perfil"
          onClick={() => navigate("profile")}
        >
          SM
          <span className="online-dot" />
        </button>
      </header>

      <section className="hero-card" aria-labelledby="hero-title">
        <div className="hero-copy">
          <span className="eyebrow">
            <Icon name="sparkles" size={14} /> Reconocimiento inteligente
          </span>
          <h1 id="hero-title">¿Qué vamos a reciclar hoy?</h1>
          <p>Identifica el material y aprende a separarlo correctamente.</p>
          <button className="light-button" onClick={() => navigate("scan")}>
            Escanear ahora <Icon name="arrow" size={18} />
          </button>
        </div>
        <div className="hero-visual" aria-hidden="true">
          <div className="recycle-ring">♻</div>
          <div className="hero-bottle">
            <span className="bottle-cap" />
            <span className="bottle-body">
              <i>PECOX</i>
            </span>
          </div>
          <span className="orbit-dot dot-one" />
          <span className="orbit-dot dot-two" />
        </div>
      </section>

      <section className="stats-row" aria-label="Resumen de actividad">
        <div className="stat-card primary-stat">
          <span>Objetos clasificados</span>
          <strong>24</strong>
          <small>
            <b>+6</b> esta semana
          </small>
        </div>
        <div className="stat-card">
          <span>Materiales</span>
          <strong>
            5<small>/6</small>
          </strong>
          <div className="mini-materials" aria-label="Cinco tipos identificados">
            {["#12C994", "#7EB7D3", "#9CA7A2", "#D0A45C", "#A794D4"].map((c) => (
              <i key={c} style={{ background: c }} />
            ))}
          </div>
        </div>
      </section>

      <section className="section-block">
        <div className="section-heading">
          <div>
            <span className="section-kicker">EXPLORA</span>
            <h2>Guía de materiales</h2>
          </div>
          <button onClick={() => navigate("guide")}>
            Ver guía <Icon name="chevron" size={16} />
          </button>
        </div>
        <div className="material-grid">
          {materials.map((material) => (
            <button
              className={`material-card tone-${material.tone}`}
              key={material.label}
              onClick={() => navigate("guide")}
            >
              <span>{material.icon}</span>
              <b>{material.label}</b>
            </button>
          ))}
        </div>
      </section>

      <section className="section-block recent-section">
        <div className="section-heading">
          <div>
            <span className="section-kicker">TU ACTIVIDAD</span>
            <h2>Clasificaciones recientes</h2>
          </div>
          <button onClick={() => navigate("history")}>
            Ver todo <Icon name="chevron" size={16} />
          </button>
        </div>
        <button className="recent-item" onClick={() => navigate("history")}>
          <img src={PHOTO} alt="Botella transparente sobre una mesa" />
          <span>
            <b>Botella de plástico</b>
            <small>Hoy, 10:32 · Confirmado</small>
          </span>
          <span className="confidence-pill">86%</span>
          <Icon name="chevron" size={18} />
        </button>
      </section>
    </div>
  );
}

function Scanner({
  navigate,
  onPhoto,
}: {
  navigate: (screen: Screen) => void;
  onPhoto: (url: string) => void;
}) {
  const inputRef = useRef<HTMLInputElement>(null);
  const choosePhoto = (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) onPhoto(URL.createObjectURL(file));
  };
  return (
    <div className="scanner-page">
      <img src={PHOTO} alt="Vista de cámara de una botella de plástico" className="scanner-bg" />
      <div className="scanner-overlay" />
      <header className="scanner-header">
        <button onClick={() => navigate("home")} aria-label="Cerrar escáner">
          <Icon name="close" />
        </button>
        <span>Escáner inteligente</span>
        <button aria-label="Activar flash">
          <Icon name="flash" />
        </button>
      </header>
      <div className="scanner-intro">
        <span>
          <Icon name="sparkles" size={14} /> Vista de prototipo
        </span>
        <h1>Coloca el residuo dentro del encuadre</h1>
        <p>Usa buena luz y un fondo despejado.</p>
      </div>
      <div className="viewfinder" aria-hidden="true">
        <i className="corner tl" />
        <i className="corner tr" />
        <i className="corner bl" />
        <i className="corner br" />
        <span className="scan-line" />
      </div>
      <div className="scanner-help">
        <Icon name="info" size={15} /> La imagen solo se usa durante el análisis
      </div>
      <div className="camera-controls">
        <button
          className="gallery-button"
          onClick={() => inputRef.current?.click()}
          aria-label="Elegir de la galería"
        >
          <Icon name="image" />
        </button>
        <button className="shutter" onClick={() => onPhoto(PHOTO)} aria-label="Tomar fotografía">
          <span />
        </button>
        <button className="guide-button" onClick={() => navigate("guide")} aria-label="Abrir guía">
          <Icon name="book" />
        </button>
      </div>
      <input
        ref={inputRef}
        className="sr-only"
        type="file"
        accept="image/*"
        onChange={choosePhoto}
      />
    </div>
  );
}

function Preview({ photo, navigate }: { photo: string; navigate: (screen: Screen) => void }) {
  return (
    <div className="page preview-page">
      <TopBar title="Revisar fotografía" onBack={() => navigate("scan")} />
      <div className="photo-frame">
        <img src={photo} alt="Fotografía seleccionada para analizar" />
        <span>
          <Icon name="check" size={14} /> Imagen lista
        </span>
      </div>
      <div className="preview-content">
        <h2>¿La imagen se ve clara?</h2>
        <p>Asegúrate de que el objeto esté completo, enfocado y con buena iluminación.</p>
        <div className="privacy-note">
          <Icon name="shield" size={21} />
          <span>
            <b>Tu privacidad importa</b>
            <small>No conservaremos esta fotografía de forma permanente.</small>
          </span>
        </div>
        <button className="primary-button" onClick={() => navigate("analyzing")}>
          <Icon name="sparkles" size={18} /> Analizar material
        </button>
        <button className="secondary-button" onClick={() => navigate("scan")}>
          Tomar otra foto
        </button>
      </div>
    </div>
  );
}

function Analyzing({ photo, navigate }: { photo: string; navigate: (screen: Screen) => void }) {
  useEffect(() => {
    const timer = window.setTimeout(() => navigate("result"), 1900);
    return () => window.clearTimeout(timer);
  }, [navigate]);
  return (
    <div className="analyzing-page">
      <Brand />
      <div className="analyze-visual">
        <img src={photo} alt="" />
        <span className="pulse-ring ring-one" />
        <span className="pulse-ring ring-two" />
        <span className="analyze-badge">
          <Icon name="sparkles" size={19} />
        </span>
      </div>
      <h1>Analizando el material</h1>
      <p>
        El prototipo está preparando una vista de resultado. No se está ejecutando un modelo real.
      </p>
      <div className="loading-dots" aria-label="Cargando">
        <i />
        <i />
        <i />
      </div>
      <button onClick={() => navigate("preview")}>Cancelar</button>
    </div>
  );
}

function CorrectionSheet({
  value,
  onSelect,
  onClose,
}: {
  value: string;
  onSelect: (value: string) => void;
  onClose: () => void;
}) {
  return (
    <div className="sheet-backdrop" role="presentation" onMouseDown={onClose}>
      <div
        className="correction-sheet"
        role="dialog"
        aria-modal="true"
        aria-labelledby="correction-title"
        onMouseDown={(e) => e.stopPropagation()}
      >
        <div className="sheet-handle" />
        <div className="sheet-title">
          <div>
            <span>AJUSTAR RESULTADO</span>
            <h2 id="correction-title">¿Qué material es?</h2>
          </div>
          <button onClick={onClose} aria-label="Cerrar">
            <Icon name="close" />
          </button>
        </div>
        <p>Tu corrección se guarda separada de la sugerencia original.</p>
        <div className="correction-grid">
          {materials.map((item) => (
            <button
              key={item.label}
              className={value === item.label ? "selected" : ""}
              onClick={() => onSelect(item.label)}
            >
              <span className={`tone-${item.tone}`}>{item.icon}</span>
              <b>{item.label}</b>
              {value === item.label && (
                <i>
                  <Icon name="check" size={13} />
                </i>
              )}
            </button>
          ))}
        </div>
        <button className="primary-button" onClick={onClose}>
          Confirmar material
        </button>
      </div>
    </div>
  );
}

function Result({
  photo,
  navigate,
  saved,
  setSaved,
}: {
  photo: string;
  navigate: (screen: Screen) => void;
  saved: boolean;
  setSaved: (saved: boolean) => void;
}) {
  const [correctionOpen, setCorrectionOpen] = useState(false);
  const [material, setMaterial] = useState("Plástico");
  return (
    <div className="page result-page">
      <TopBar
        title="Resultado"
        onBack={() => navigate("preview")}
        action={
          <button className="icon-btn" onClick={() => navigate("scan")} aria-label="Cerrar">
            <Icon name="close" />
          </button>
        }
      />
      <div className="result-photo">
        <img src={photo} alt="Botella analizada" />
        <span className="demo-label">RESULTADO DEMO</span>
      </div>
      <section className="result-card">
        <div className="result-heading">
          <span className="material-symbol">♳</span>
          <div>
            <span>MATERIAL SUGERIDO</span>
            <h1>{material}</h1>
            <small>
              <Icon name="check" size={13} />{" "}
              {material === "Plástico" ? "Sugerencia del prototipo" : "Corregido manualmente"}
            </small>
          </div>
          <div className="score">
            <strong>
              86<sup>%</sup>
            </strong>
            <span>
              Confianza
              <br />
              del modelo
            </span>
          </div>
        </div>
        <div className="honesty-banner">
          <Icon name="info" size={18} />
          <span>
            <b>Vista de demostración</b> Este resultado ilustra la interfaz; no proviene de un
            modelo ML conectado.
          </span>
        </div>
        <div className="separation-guide">
          <div className="guide-icon">
            <Icon name="book" />
          </div>
          <div>
            <span>CÓMO PREPARARLO</span>
            <h3>Vacía, enjuaga y aplasta</h3>
            <p>
              Retira el contenido, enjuaga el envase y reduce su volumen. Consulta siempre las
              reglas de reciclaje de tu localidad.
            </p>
          </div>
        </div>
        <div className="alternatives">
          <span>Otras sugerencias</span>
          <div>
            <b>
              Vidrio <i style={{ width: "8%" }} />
            </b>
            <small>8%</small>
          </div>
          <div>
            <b>
              Otros <i style={{ width: "4%" }} />
            </b>
            <small>4%</small>
          </div>
        </div>
        <button
          className="primary-button"
          onClick={() => {
            setSaved(true);
            navigate("history");
          }}
        >
          <Icon name={saved ? "check" : "history"} size={18} />{" "}
          {saved ? "Guardado en historial" : "Guardar clasificación"}
        </button>
        <button className="secondary-button" onClick={() => setCorrectionOpen(true)}>
          <Icon name="edit" size={18} /> Corregir material
        </button>
        <button className="text-button" onClick={() => navigate("scan")}>
          Escanear otro objeto
        </button>
      </section>
      {correctionOpen && (
        <CorrectionSheet
          value={material}
          onSelect={setMaterial}
          onClose={() => setCorrectionOpen(false)}
        />
      )}
    </div>
  );
}

function History({ navigate, saved }: { navigate: (screen: Screen) => void; saved: boolean }) {
  return (
    <div className="page page-with-nav history-page">
      <header className="simple-header">
        <div>
          <span>TU ACTIVIDAD</span>
          <h1>Mi historial</h1>
        </div>
        <button className="icon-btn" aria-label="Buscar">
          <Icon name="search" />
        </button>
      </header>
      <div className="summary-banner">
        <div>
          <span>Clasificaciones</span>
          <strong>{saved ? "25" : "24"}</strong>
        </div>
        <i />
        <div>
          <span>Esta semana</span>
          <strong>{saved ? "+7" : "+6"}</strong>
        </div>
        <span className="summary-art">♻</span>
      </div>
      <div className="filter-row">
        <button className="active">Todos</button>
        <button>Plástico</button>
        <button>Vidrio</button>
        <button>Metal</button>
      </div>
      <span className="date-label">HOY</span>
      <div className="history-list">
        <button className="history-item" onClick={() => navigate("result")}>
          <img src={PHOTO} alt="Botella de plástico" />
          <span>
            <b>Botella de plástico</b>
            <small>10:32 · {saved ? "Guardado" : "Confirmado"}</small>
            <i>
              <Icon name="check" size={11} /> Plástico
            </i>
          </span>
          <span className="confidence-pill">86%</span>
          <Icon name="chevron" size={18} />
        </button>
        <button className="history-item">
          <span className="fake-thumb glass-thumb">◒</span>
          <span>
            <b>Frasco de vidrio</b>
            <small>Ayer, 18:05 · Confirmado</small>
            <i>
              <Icon name="check" size={11} /> Vidrio
            </i>
          </span>
          <span className="confidence-pill">92%</span>
          <Icon name="chevron" size={18} />
        </button>
      </div>
      <span className="date-label">ESTA SEMANA</span>
      <div className="history-list">
        <button className="history-item">
          <span className="fake-thumb metal-thumb">⌁</span>
          <span>
            <b>Lata de bebida</b>
            <small>Lun, 12:41 · Corregido</small>
            <i>
              <Icon name="edit" size={11} /> Metal
            </i>
          </span>
          <span className="confidence-pill">64%</span>
          <Icon name="chevron" size={18} />
        </button>
      </div>
    </div>
  );
}

function Guide({ navigate }: { navigate: (screen: Screen) => void }) {
  const [selected, setSelected] = useState("Plástico");
  const active = materials.find((item) => item.label === selected) ?? materials[0];
  return (
    <div className="page guide-page">
      <TopBar title="Guía de materiales" onBack={() => navigate("home")} />
      <div className="guide-intro">
        <span className="section-kicker">APRENDE A SEPARAR</span>
        <h1>Cada material tiene su lugar</h1>
        <p>
          Explora consejos prácticos antes de desechar. Las reglas pueden variar según tu localidad.
        </p>
      </div>
      <div className="guide-materials">
        {materials.map((item) => (
          <button
            key={item.label}
            className={selected === item.label ? "active" : ""}
            onClick={() => setSelected(item.label)}
          >
            <span className={`tone-${item.tone}`}>{item.icon}</span>
            <small>{item.label}</small>
          </button>
        ))}
      </div>
      <article className="guide-detail">
        <div className={`guide-hero tone-${active.tone}`}>
          <span>{active.icon}</span>
          <div>
            <small>MATERIAL</small>
            <h2>{active.label}</h2>
          </div>
        </div>
        <div className="guide-copy">
          <span className="section-kicker">ANTES DE RECICLAR</span>
          <h3>Prepáralo en tres pasos</h3>
          <ol>
            <li>
              <b>1</b>
              <span>
                <strong>Vacía el contenido</strong>
                <small>Evita que queden líquidos o restos de comida.</small>
              </span>
            </li>
            <li>
              <b>2</b>
              <span>
                <strong>Enjuaga ligeramente</strong>
                <small>No es necesario usar demasiada agua.</small>
              </span>
            </li>
            <li>
              <b>3</b>
              <span>
                <strong>Reduce su volumen</strong>
                <small>Aplasta el envase cuando sea posible.</small>
              </span>
            </li>
          </ol>
          <div className="local-note">
            <Icon name="info" size={18} />
            <span>
              <b>Comprueba las reglas locales</b>
              <small>
                Identificar un material no garantiza que sea aceptado en todos los programas.
              </small>
            </span>
          </div>
        </div>
      </article>
    </div>
  );
}

function Profile({ navigate }: { navigate: (screen: Screen) => void }) {
  const rows: { icon: IconName; label: string; detail?: string }[] = [
    { icon: "user", label: "Datos personales", detail: "Nombre, email y avatar" },
    { icon: "eye", label: "Accesibilidad", detail: "Texto, contraste y movimiento" },
    { icon: "shield", label: "Privacidad y datos", detail: "Gestiona tu información" },
    { icon: "settings", label: "Preferencias", detail: "Notificaciones e idioma" },
  ];
  return (
    <div className="page page-with-nav profile-page">
      <header className="simple-header">
        <div>
          <span>TU CUENTA</span>
          <h1>Perfil</h1>
        </div>
      </header>
      <div className="profile-card">
        <div className="large-avatar">SM</div>
        <div>
          <h2>Sofía Martínez</h2>
          <p>sofia@ejemplo.com</p>
          <span>Exploradora consciente</span>
        </div>
        <button aria-label="Editar perfil">
          <Icon name="edit" size={18} />
        </button>
      </div>
      <div className="profile-impact">
        <span>
          <Icon name="leaf" size={19} />
        </span>
        <div>
          <b>24 clasificaciones</b>
          <small>Aprendiendo desde enero de 2026</small>
        </div>
      </div>
      <section className="settings-section">
        <span className="date-label">AJUSTES</span>
        <div className="settings-list">
          {rows.map((row) => (
            <button key={row.label}>
              <span>
                <Icon name={row.icon} />
              </span>
              <div>
                <b>{row.label}</b>
                <small>{row.detail}</small>
              </div>
              <Icon name="chevron" size={18} />
            </button>
          ))}
        </div>
      </section>
      <button className="logout-button">
        <Icon name="logout" size={18} /> Cerrar sesión
      </button>
      <p className="version">PECOX Vision · Prototipo 1.0</p>
    </div>
  );
}

export default function App() {
  const [screen, setScreen] = useState<Screen>("home");
  const [photo, setPhoto] = useState(PHOTO);
  const [saved, setSaved] = useState(false);

  const navigate = (next: Screen) => {
    setScreen(next);
    window.scrollTo({ top: 0, behavior: "smooth" });
  };
  const onPhoto = (url: string) => {
    setPhoto(url);
    navigate("preview");
  };

  return (
    <main className="app-stage">
      <aside className="desktop-story">
        <Brand light />
        <div>
          <span className="desktop-kicker">RECOGNIZE · LEARN · RECYCLE</span>
          <h1>
            Reciclar empieza
            <br />
            por <em>reconocer.</em>
          </h1>
          <p>
            Una experiencia móvil que ayuda a identificar materiales y aprender a separarlos con
            confianza.
          </p>
        </div>
        <small>Prototipo de producto · PECOX Vision 2026</small>
      </aside>
      <section className="phone-shell" aria-label="Prototipo móvil PECOX Vision">
        {screen === "home" && <Home navigate={navigate} />}
        {screen === "scan" && <Scanner navigate={navigate} onPhoto={onPhoto} />}
        {screen === "preview" && <Preview photo={photo} navigate={navigate} />}
        {screen === "analyzing" && <Analyzing photo={photo} navigate={navigate} />}
        {screen === "result" && (
          <Result photo={photo} navigate={navigate} saved={saved} setSaved={setSaved} />
        )}
        {screen === "history" && <History navigate={navigate} saved={saved} />}
        {screen === "guide" && <Guide navigate={navigate} />}
        {screen === "profile" && <Profile navigate={navigate} />}
        {(["home", "history", "profile"] as Screen[]).includes(screen) && (
          <BottomNav screen={screen} navigate={navigate} />
        )}
      </section>
    </main>
  );
}
