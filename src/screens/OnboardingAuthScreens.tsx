import { useEffect, useState, type FormEvent } from "react";
import { Brand, Icon } from "../components/Icons";
import type { AuthSimulationError, Screen } from "../types/pecox";

export function SplashScreen({
  hasError,
  onRetry,
  onFinish,
}: {
  hasError: boolean;
  onRetry: () => void;
  onFinish: () => void;
}) {
  useEffect(() => {
    if (hasError) return;
    const timer = window.setTimeout(onFinish, 1800);
    return () => window.clearTimeout(timer);
  }, [hasError, onFinish]);

  return (
    <div className="splash-page">
      <div className="splash-glow" aria-hidden="true" />
      <div className="splash-center">
        <div className="splash-mark">
          <Icon name="leaf" size={38} strokeWidth={2.1} />
        </div>
        <h1>
          PECOX <span>Vision</span>
        </h1>
        <p className="splash-slogan">Reconoce. Aprende. Recicla.</p>
      </div>

      <div className="splash-footer">
        {hasError ? (
          <div className="splash-error" role="alert">
            <p>No se pudo verificar la sesión inicial.</p>
            <div className="splash-error-actions">
              <button type="button" className="light-button" onClick={onRetry}>
                <Icon name="refresh" size={16} /> Reintentar
              </button>
              <button type="button" className="splash-link-btn" onClick={onFinish}>
                Continuar sin sesión
              </button>
            </div>
          </div>
        ) : (
          <>
            <div className="splash-dots" aria-label="Iniciando aplicación">
              <i />
              <i />
              <i />
            </div>
            <button type="button" className="splash-link-btn" onClick={onFinish}>
              Continuar ahora
            </button>
          </>
        )}
      </div>
    </div>
  );
}

const ONBOARDING_SLIDES = [
  {
    kicker: "PASO 1 DE 3 · RECONOCIMIENTO",
    title: "Reconoce tus residuos",
    description:
      "Toma o selecciona una fotografía para recibir una sugerencia de material con nivel de confianza.",
  },
  {
    kicker: "PASO 2 DE 3 · APRENDIZAJE",
    title: "Aprende a clasificarlos",
    description:
      "Descubre cómo vaciar, limpiar y separar plástico, vidrio, metal, cartón, papel y otros.",
  },
  {
    kicker: "PASO 3 DE 3 · SEGUIMIENTO",
    title: "Consulta tu progreso",
    description:
      "Guarda tus clasificaciones confirmadas y revisa tu actividad en un historial ordenado.",
  },
];

export function OnboardingScreen({ onDone }: { onDone: () => void }) {
  const [step, setStep] = useState(0);
  const current = ONBOARDING_SLIDES[step];
  const isLast = step === ONBOARDING_SLIDES.length - 1;

  return (
    <div className="page onboarding-page">
      <header className="onboarding-header">
        <Brand />
        <button type="button" className="skip-btn" onClick={onDone}>
          Omitir
        </button>
      </header>

      <div className="onboarding-stage">
        {step === 0 && (
          <div className="onboarding-art art-scan" aria-hidden="true">
            <div className="art-frame">
              <i className="corner tl" />
              <i className="corner tr" />
              <i className="corner bl" />
              <i className="corner br" />
              <div className="art-bottle-silhouette">
                <span />
                <div />
              </div>
            </div>
            <span className="art-pill">
              <Icon name="sparkles" size={14} /> Vista previa de encuadre
            </span>
          </div>
        )}

        {step === 1 && (
          <div className="onboarding-art art-materials" aria-hidden="true">
            <div className="art-chip-grid">
              <div className="tone-mint">
                <span>♳</span>
                <b>Plástico</b>
              </div>
              <div className="tone-blue">
                <span>◒</span>
                <b>Vidrio</b>
              </div>
              <div className="tone-gray">
                <span>⌁</span>
                <b>Metal</b>
              </div>
              <div className="tone-sand">
                <span>□</span>
                <b>Cartón</b>
              </div>
              <div className="tone-lilac">
                <span>≋</span>
                <b>Papel</b>
              </div>
              <div className="tone-peach">
                <span>＋</span>
                <b>Otros</b>
              </div>
            </div>
          </div>
        )}

        {step === 2 && (
          <div className="onboarding-art art-progress" aria-hidden="true">
            <span className="demo-tag">GRÁFICA DEMO</span>
            <div className="art-chart-bars">
              {[42, 68, 55, 88, 72, 95, 64].map((height, idx) => (
                <div key={idx} className="art-bar-col">
                  <span style={{ height: `${height}%` }} />
                </div>
              ))}
            </div>
            <div className="art-chart-caption">
              <b>Actividad ilustrativa</b>
              <small>Los datos reales se cargarán desde tu historial</small>
            </div>
          </div>
        )}
      </div>

      <div className="onboarding-copy">
        <span className="section-kicker">{current.kicker}</span>
        <h1>{current.title}</h1>
        <p>{current.description}</p>
      </div>

      <div className="onboarding-controls">
        <div className="progress-dots" role="tablist" aria-label="Progreso de introducción">
          {ONBOARDING_SLIDES.map((slide, idx) => (
            <button
              key={slide.title}
              type="button"
              className={idx === step ? "active" : ""}
              aria-label={`Ir al paso ${idx + 1}`}
              onClick={() => setStep(idx)}
            />
          ))}
        </div>

        <button
          type="button"
          className="primary-button"
          onClick={() => (isLast ? onDone() : setStep((prev) => prev + 1))}
        >
          {isLast ? "Empezar" : "Continuar"} <Icon name="arrow" size={18} />
        </button>
      </div>
    </div>
  );
}

type AuthMode = "login" | "register" | "recover";

export function AuthScreen({
  offline,
  simulatedError,
  onClearSimError,
  onAuthSuccess,
  onGuestGuide,
  navigate,
}: {
  offline: boolean;
  simulatedError: AuthSimulationError;
  onClearSimError: () => void;
  onAuthSuccess: (name: string, email: string) => void;
  onGuestGuide: () => void;
  navigate: (screen: Screen) => void;
}) {
  const [mode, setMode] = useState<AuthMode>("login");
  const [name, setName] = useState("Sofía Martínez");
  const [email, setEmail] = useState("sofia@ejemplo.com");
  const [password, setPassword] = useState("pecox2026");
  const [showPass, setShowPass] = useState(false);
  const [loading, setLoading] = useState(false);
  const [fieldError, setFieldError] = useState<string | null>(null);
  const [recoverSent, setRecoverSent] = useState(false);

  const errorMessages: Record<Exclude<AuthSimulationError, "none">, string> = {
    "invalid-credentials": "Correo o contraseña incorrectos. Verifica tus datos.",
    "existing-user": "Ya existe una cuenta registrada con ese correo electrónico.",
    "session-expired": "Tu sesión expiró por seguridad. Inicia sesión nuevamente.",
  };

  const handleSubmit = (event: FormEvent) => {
    event.preventDefault();
    setFieldError(null);
    setRecoverSent(false);

    if (offline) {
      setFieldError("Sin conexión a internet. Conéctate para autenticarte o usa la guía sin cuenta.");
      return;
    }

    if (!email.trim() || !email.includes("@")) {
      setFieldError("Ingresa un correo electrónico válido.");
      return;
    }

    if (mode !== "recover" && password.trim().length < 6) {
      setFieldError("La contraseña debe tener al menos 6 caracteres.");
      return;
    }

    if (mode === "register" && name.trim().length < 2) {
      setFieldError("Ingresa tu nombre completo para crear tu cuenta.");
      return;
    }

    if (simulatedError !== "none") {
      setFieldError(errorMessages[simulatedError]);
      return;
    }

    setLoading(true);
    window.setTimeout(() => {
      setLoading(false);
      if (mode === "recover") {
        setRecoverSent(true);
        return;
      }
      onAuthSuccess(name.trim() || "Sofía Martínez", email.trim());
    }, 650);
  };

  const switchMode = (next: AuthMode) => {
    setMode(next);
    setFieldError(null);
    setRecoverSent(false);
    onClearSimError();
  };

  return (
    <div className="page auth-page">
      <div className="auth-hero">
        <Brand />
        <span className="demo-badge-inline">PROTOTIPO · AUTH DEMO</span>
      </div>

      <div className="auth-heading">
        <span className="section-kicker">
          {mode === "login" && "BIENVENIDO DE VUELTA"}
          {mode === "register" && "CREA TU CUENTA"}
          {mode === "recover" && "RECUPERAR ACCESO"}
        </span>
        <h1>
          {mode === "login" && "Inicia sesión en PECOX"}
          {mode === "register" && "Empieza a registrar tus residuos"}
          {mode === "recover" && "Restablece tu contraseña"}
        </h1>
        <p>
          {mode === "recover"
            ? "Te enviaremos instrucciones de recuperación cuando el backend esté conectado."
            : "Guarda tus clasificaciones verificadas y consulta tu historial desde cualquier lugar."}
        </p>
      </div>

      {mode !== "recover" && (
        <div className="auth-tabs" role="tablist" aria-label="Modo de acceso">
          <button
            type="button"
            role="tab"
            aria-selected={mode === "login"}
            className={mode === "login" ? "active" : ""}
            onClick={() => switchMode("login")}
          >
            Iniciar sesión
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={mode === "register"}
            className={mode === "register" ? "active" : ""}
            onClick={() => switchMode("register")}
          >
            Crear cuenta
          </button>
        </div>
      )}

      {(fieldError || simulatedError !== "none") && (
        <div className="auth-alert auth-alert--error" role="alert">
          <Icon name="alert" size={18} />
          <span>{fieldError ?? errorMessages[simulatedError as Exclude<AuthSimulationError, "none">]}</span>
        </div>
      )}

      {recoverSent && (
        <div className="auth-alert auth-alert--success" role="status">
          <Icon name="check" size={18} />
          <span>
            Simulación de envío completada para <b>{email}</b>. En producción se conectará a FastAPI.
          </span>
        </div>
      )}

      <form className="auth-form" onSubmit={handleSubmit} noValidate>
        {mode === "register" && (
          <label className="input-field">
            <span>Nombre completo</span>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Ej. Sofía Martínez"
              autoComplete="name"
            />
          </label>
        )}

        <label className="input-field">
          <span>Correo electrónico</span>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="nombre@ejemplo.com"
            autoComplete="email"
          />
        </label>

        {mode !== "recover" && (
          <label className="input-field">
            <span>Contraseña</span>
            <div className="password-wrap">
              <input
                type={showPass ? "text" : "password"}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Mínimo 6 caracteres"
                autoComplete={mode === "login" ? "current-password" : "new-password"}
              />
              <button
                type="button"
                className="eye-toggle"
                onClick={() => setShowPass((prev) => !prev)}
                aria-label={showPass ? "Ocultar contraseña" : "Mostrar contraseña"}
              >
                <Icon name={showPass ? "eyeOff" : "eye"} size={18} />
              </button>
            </div>
          </label>
        )}

        {mode === "login" && (
          <button
            type="button"
            className="forgot-link"
            onClick={() => switchMode("recover")}
          >
            ¿Olvidaste tu contraseña?
          </button>
        )}

        <button type="submit" className="primary-button" disabled={loading}>
          {loading
            ? "Procesando..."
            : mode === "login"
              ? "Entrar a PECOX Vision"
              : mode === "register"
                ? "Crear cuenta"
                : "Enviar enlace de recuperación"}
        </button>

        {mode === "recover" && (
          <button
            type="button"
            className="secondary-button"
            onClick={() => switchMode("login")}
          >
            Volver a iniciar sesión
          </button>
        )}
      </form>

      <div className="auth-guest-box">
        <button
          type="button"
          className="secondary-button"
          onClick={() => {
            onGuestGuide();
            navigate("guide");
          }}
        >
          <Icon name="book" size={18} /> Explorar guía de materiales sin cuenta
        </button>
        <small>
          El acceso como invitado permite consultar la guía de separación sin activar la cámara ni
          iniciar sesión.
        </small>
      </div>
    </div>
  );
}
