import { useEffect, useRef, useState, type ChangeEvent } from "react";
import { Brand, Icon, OfflineBanner, StateCard, TopBar } from "../components/Icons";
import { DEMO_PHOTO, getMaterialByKey, MATERIALS } from "../data/materials";
import type {
  ClassificationRecord,
  MaterialKey,
  PrototypeSimulationFlags,
  Screen,
  UserProfile,
} from "../types/pecox";

export function HomeScreen({
  user,
  history,
  offline,
  onRetryNetwork,
  onOpenGuideMaterial,
  navigate,
}: {
  user: UserProfile;
  history: ClassificationRecord[];
  offline: boolean;
  onRetryNetwork: () => void;
  onOpenGuideMaterial: (key: MaterialKey) => void;
  navigate: (screen: Screen) => void;
}) {
  const uniqueMaterials = new Set(history.map((item) => item.confirmedMaterial));
  const latest = history[0];
  const latestMaterial = latest ? getMaterialByKey(latest.confirmedMaterial) : null;
  const firstName = user.isGuest ? "Visitante" : user.name.split(" ")[0] || "Usuario";

  return (
    <div className="page page-with-nav home-page">
      <header className="home-header">
        <div>
          <Brand />
          <p>
            Hola, {firstName} <span aria-hidden="true">·</span> Cada clasificación cuenta
          </p>
        </div>
        <button
          className="avatar-btn"
          aria-label="Abrir perfil"
          onClick={() => navigate("profile")}
        >
          {user.initials}
          <span className="online-dot" />
        </button>
      </header>

      {offline && <OfflineBanner onRetry={onRetryNetwork} />}

      <section className="hero-card" aria-labelledby="hero-title">
        <div className="hero-copy">
          <span className="eyebrow">
            <Icon name="sparkles" size={13} /> Reconocimiento inteligente
          </span>
          <h1 id="hero-title">¿Qué vamos a reciclar hoy?</h1>
          <p>Identifica el material por fotografía y aprende a separarlo correctamente.</p>
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
        <button className="stat-card primary-stat stat-card-btn" onClick={() => navigate("stats")}>
          <span>Objetos clasificados</span>
          <strong>{history.length}</strong>
          <small>
            <b>Demo local</b> · Ver estadísticas
          </small>
        </button>
        <button className="stat-card stat-card-btn" onClick={() => navigate("stats")}>
          <span>Materiales</span>
          <strong>
            {uniqueMaterials.size}
            <small>/6</small>
          </strong>
          <div className="mini-materials" aria-label={`${uniqueMaterials.size} tipos identificados`}>
            {MATERIALS.filter((m) => uniqueMaterials.has(m.key)).map((m) => (
              <i key={m.key} style={{ background: m.accentColor }} />
            ))}
            {uniqueMaterials.size === 0 && <small className="empty-mini">Sin registros aún</small>}
          </div>
        </button>
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
          {MATERIALS.map((material) => (
            <button
              className={`material-card tone-${material.tone}`}
              key={material.key}
              onClick={() => onOpenGuideMaterial(material.key)}
            >
              <span>{material.icon}</span>
              <b>{material.label}</b>
            </button>
          ))}
        </div>
      </section>

      <section className="section-block">
        <div className="section-heading">
          <div>
            <span className="section-kicker">TU ACTIVIDAD</span>
            <h2>Clasificaciones recientes</h2>
          </div>
          <button onClick={() => navigate("history")}>
            Ver todo <Icon name="chevron" size={16} />
          </button>
        </div>
        {latest && latestMaterial ? (
          <button className="recent-item" onClick={() => navigate("history")}>
            {latest.imageUrl ? (
              <img src={latest.imageUrl} alt={latest.title} />
            ) : (
              <span className={`fake-thumb tone-${latestMaterial.tone}`}>{latestMaterial.icon}</span>
            )}
            <span>
              <b>{latest.title}</b>
              <small>
                {latest.timestampLabel} · {latest.status === "corrected" ? "Corregido" : "Confirmado"} (
                {latestMaterial.label})
              </small>
            </span>
            {latest.confidence !== null && (
              <span className="confidence-pill">{latest.confidence}%</span>
            )}
            <Icon name="chevron" size={18} />
          </button>
        ) : (
          <div className="inline-empty-card">
            <p>Aún no has guardado clasificaciones.</p>
            <button type="button" className="text-action-btn" onClick={() => navigate("scan")}>
              Escanear mi primer residuo
            </button>
          </div>
        )}
      </section>

      <section className="section-block home-extras">
        <button className="extra-tile" onClick={() => navigate("stats")}>
          <span className="extra-icon tone-mint">
            <Icon name="chart" size={18} />
          </span>
          <div>
            <b>Estadísticas y actividad</b>
            <small>Gráficas demostrativas por material</small>
          </div>
          <Icon name="chevron" size={17} />
        </button>

        <button className="extra-tile" onClick={() => navigate("future")}>
          <span className="extra-icon tone-sand">
            <Icon name="cpu" size={18} />
          </span>
          <div>
            <b>Conceptos futuros (V3)</b>
            <small>Máquinas inteligentes y depósitos verificados</small>
          </div>
          <Icon name="chevron" size={17} />
        </button>

        <div className="eco-tip-card">
          <Icon name="info" size={18} />
          <div>
            <b>Consejo verificable</b>
            <small>
              Enjuagar y secar brevemente los envases evita contaminar papel o cartón en el mismo
              punto de acopio.
            </small>
          </div>
        </div>
      </section>
    </div>
  );
}

export function ScannerScreen({
  cameraDenied,
  onEnableCameraSim,
  navigate,
  onPhoto,
}: {
  cameraDenied: boolean;
  onEnableCameraSim: () => void;
  navigate: (screen: Screen) => void;
  onPhoto: (url: string, invalid?: boolean) => void;
}) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [flashOn, setFlashOn] = useState(false);

  const choosePhoto = (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (!file) return;
    const isTooBig = file.size > 10 * 1024 * 1024;
    const isInvalidType = !file.type.startsWith("image/");
    onPhoto(URL.createObjectURL(file), isTooBig || isInvalidType);
  };

  if (cameraDenied) {
    return (
      <div className="page scanner-denied-page">
        <TopBar title="Permiso de cámara" onBack={() => navigate("home")} />
        <div className="denied-wrap">
          <StateCard
            icon="camera"
            tone="warning"
            title="Cámara no disponible o denegada"
            description="PECOX necesita acceso a la cámara únicamente para capturar la foto que elijas analizar. Puedes seleccionar una imagen de tu galería o explorar la guía sin cámara."
            primaryLabel="Elegir imagen de la galería"
            onPrimary={() => inputRef.current?.click()}
            secondaryLabel="Abrir guía de materiales"
            onSecondary={() => navigate("guide")}
          />
          <button type="button" className="text-button" onClick={onEnableCameraSim}>
            Simular permiso concedido
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

  return (
    <div className="scanner-page">
      <img src={DEMO_PHOTO} alt="Vista de cámara de una botella de plástico" className="scanner-bg" />
      <div className={`scanner-overlay ${flashOn ? "flash-active" : ""}`} />

      <header className="scanner-header">
        <button onClick={() => navigate("home")} aria-label="Cerrar escáner">
          <Icon name="close" />
        </button>
        <span>Escáner inteligente</span>
        <button
          className={flashOn ? "flash-btn-on" : ""}
          onClick={() => setFlashOn((prev) => !prev)}
          aria-label={flashOn ? "Desactivar flash" : "Activar flash"}
          aria-pressed={flashOn}
        >
          <Icon name="flash" />
        </button>
      </header>

      <div className="scanner-intro">
        <span>
          <Icon name="sparkles" size={14} /> Vista de prototipo · Análisis por foto
        </span>
        <h1>Coloca el residuo dentro del encuadre</h1>
        <p>Usa buena luz y un fondo despejado. {flashOn ? "Flash activo." : ""}</p>
      </div>

      <div className="viewfinder" aria-hidden="true">
        <i className="corner tl" />
        <i className="corner tr" />
        <i className="corner bl" />
        <i className="corner br" />
        <span className="scan-line" />
      </div>

      <div className="scanner-help">
        <Icon name="info" size={15} /> Se envía solo la fotografía capturada al servidor
      </div>

      <div className="camera-controls">
        <button
          className="gallery-button"
          onClick={() => inputRef.current?.click()}
          aria-label="Elegir de la galería"
        >
          <Icon name="image" />
        </button>
        <button
          className="shutter"
          onClick={() => onPhoto(DEMO_PHOTO, false)}
          aria-label="Tomar fotografía"
        >
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

export function PreviewScreen({
  photo,
  invalidImage,
  onClearInvalidImage,
  navigate,
}: {
  photo: string;
  invalidImage: boolean;
  onClearInvalidImage: () => void;
  navigate: (screen: Screen) => void;
}) {
  return (
    <div className="page preview-page">
      <TopBar title="Revisar fotografía" onBack={() => navigate("scan")} />

      {invalidImage ? (
        <div className="preview-error-wrap">
          <StateCard
            icon="alert"
            tone="error"
            title="Imagen inválida o demasiado grande"
            description="El archivo seleccionado supera el límite permitido (10 MB) o tiene un formato no compatible. Prueba con una fotografía JPG o PNG clara."
            primaryLabel="Tomar o elegir otra foto"
            onPrimary={() => {
              onClearInvalidImage();
              navigate("scan");
            }}
            secondaryLabel="Cancelar y volver al inicio"
            onSecondary={() => {
              onClearInvalidImage();
              navigate("home");
            }}
          />
        </div>
      ) : (
        <>
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
        </>
      )}
    </div>
  );
}

export function AnalyzingScreen({
  photo,
  simFlags,
  onRetryFixed,
  navigate,
}: {
  photo: string;
  simFlags: PrototypeSimulationFlags;
  onRetryFixed: () => void;
  navigate: (screen: Screen) => void;
}) {
  const [failedMode, setFailedMode] = useState<"none" | "offline" | "timeout">("none");

  useEffect(() => {
    setFailedMode("none");
    if (simFlags.offline) {
      const timer = window.setTimeout(() => setFailedMode("offline"), 900);
      return () => window.clearTimeout(timer);
    }
    if (simFlags.mlUnavailable) {
      const timer = window.setTimeout(() => setFailedMode("timeout"), 1100);
      return () => window.clearTimeout(timer);
    }

    const timer = window.setTimeout(() => navigate("result"), 1700);
    return () => window.clearTimeout(timer);
  }, [navigate, simFlags.mlUnavailable, simFlags.offline]);

  if (failedMode !== "none") {
    return (
      <div className="page preview-page">
        <TopBar title="Analizando imagen" onBack={() => navigate("preview")} />
        <div className="preview-error-wrap">
          <StateCard
            icon={failedMode === "offline" ? "wifiOff" : "alert"}
            tone="error"
            title={
              failedMode === "offline"
                ? "Se perdió la conexión"
                : "Modelo ML no disponible temporalmente"
            }
            description={
              failedMode === "offline"
                ? "No fue posible enviar la fotografía. Verifica tu red y vuelve a intentarlo."
                : "El servicio de inferencia no respondió a tiempo. No generaremos una predicción falsa."
            }
            primaryLabel="Reintentar análisis"
            onPrimary={() => {
              onRetryFixed();
              setFailedMode("none");
            }}
            secondaryLabel="Volver a revisar foto"
            onSecondary={() => navigate("preview")}
          />
        </div>
      </div>
    );
  }

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
        El prototipo está preparando la vista de resultado. No se está ejecutando un modelo real
        ni mostrando porcentajes ficticios.
      </p>
      <div className="loading-dots" aria-label="Analizando sin porcentaje estimado">
        <i />
        <i />
        <i />
      </div>
      <button onClick={() => navigate("preview")}>Cancelar</button>
    </div>
  );
}
