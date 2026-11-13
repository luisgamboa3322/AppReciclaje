import { useCallback, useState } from "react";
import { BottomNav, Brand } from "./components/Icons";
import { DEMO_PHOTO, INITIAL_HISTORY } from "./data/materials";
import { AnalyzingScreen, HomeScreen, PreviewScreen, ScannerScreen } from "./screens/CoreScreens";
import {
  FutureConceptsScreen,
  GuideScreen,
  ProfileScreen,
  StatsScreen,
} from "./screens/GuideStatsProfileScreens";
import { AuthScreen, OnboardingScreen, SplashScreen } from "./screens/OnboardingAuthScreens";
import { HistoryScreen, ResultScreen } from "./screens/ResultHistoryScreens";
import type {
  AccessibilitySettings,
  ClassificationRecord,
  MaterialKey,
  PrototypeSimulationFlags,
  ResultVariant,
  Screen,
  UserProfile,
} from "./types/pecox";

const SCREEN_DIRECTORY: { id: Screen; code: string; label: string }[] = [
  { id: "splash", code: "UI-01", label: "Splash" },
  { id: "onboarding", code: "UI-02", label: "Onboarding" },
  { id: "auth", code: "UI-03", label: "Login / Registro" },
  { id: "home", code: "UI-04", label: "Inicio" },
  { id: "scan", code: "UI-05", label: "Escáner" },
  { id: "preview", code: "UI-06", label: "Previsualización" },
  { id: "analyzing", code: "UI-07", label: "Analizando" },
  { id: "result", code: "UI-08/09", label: "Resultado y Corrección" },
  { id: "history", code: "UI-10", label: "Historial" },
  { id: "stats", code: "UI-11", label: "Estadísticas (V2)" },
  { id: "guide", code: "UI-12", label: "Guía de materiales" },
  { id: "profile", code: "UI-13", label: "Perfil y ajustes" },
  { id: "future", code: "UI-14", label: "Conceptos V3" },
];

const DEFAULT_USER: UserProfile = {
  name: "Sofía Martínez",
  email: "sofia@ejemplo.com",
  initials: "SM",
  badge: "Exploradora consciente",
  isGuest: false,
};

function computeInitials(name: string): string {
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return "PV";
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
  return `${parts[0][0]}${parts[1][0]}`.toUpperCase();
}

export default function App() {
  const [screen, setScreen] = useState<Screen>("splash");
  const [previousScreen, setPreviousScreen] = useState<Screen>("home");
  const [photo, setPhoto] = useState(DEMO_PHOTO);
  const [history, setHistory] = useState<ClassificationRecord[]>(INITIAL_HISTORY);
  const [guideMaterial, setGuideMaterial] = useState<MaterialKey>("plastic");
  const [user, setUser] = useState<UserProfile>(DEFAULT_USER);
  const [a11y, setA11y] = useState<AccessibilitySettings>({
    largeText: false,
    reduceMotion: false,
  });
  const [sim, setSim] = useState<PrototypeSimulationFlags>({
    offline: false,
    cameraDenied: false,
    invalidImage: false,
    mlUnavailable: false,
    splashError: false,
    resultVariant: "identified",
    authError: "none",
  });

  const navigate = useCallback((next: Screen) => {
    setScreen((prev) => {
      if (prev !== next) setPreviousScreen(prev);
      return next;
    });
    window.scrollTo({ top: 0, behavior: "smooth" });
  }, []);

  const handlePhoto = (url: string, invalid = false) => {
    setPhoto(url);
    setSim((prev) => ({ ...prev, invalidImage: invalid }));
    navigate("preview");
  };

  const handleSaveRecord = (record: ClassificationRecord) => {
    setHistory((prev) => [record, ...prev]);
  };

  const handleDeleteRecord = (id: string) => {
    setHistory((prev) => prev.filter((item) => item.id !== id));
  };

  const handleAuthSuccess = (name: string, email: string) => {
    setUser({
      name,
      email,
      initials: computeInitials(name),
      badge: "Exploradora consciente",
      isGuest: false,
    });
    setSim((prev) => ({ ...prev, authError: "none" }));
    navigate("home");
  };

  const handleGuestGuide = () => {
    setUser({
      name: "Visitante",
      email: "Modo invitado · Solo guía",
      initials: "IN",
      badge: "Acceso sin cuenta",
      isGuest: true,
    });
  };

  const showBottomNav = (["home", "history", "profile"] as Screen[]).includes(screen);

  return (
    <main className="app-stage">
      <aside className="desktop-story">
        <Brand light />

        <div className="story-main">
          <span className="desktop-kicker">RECOGNIZE · LEARN · RECYCLE</span>
          <h1>
            Reciclar empieza
            <br />
            por <em>reconocer.</em>
          </h1>
          <p>
            Prototipo interactivo completo de <strong>PECOX Vision</strong> (UI-01 a UI-14) con
            estados transversales de accesibilidad, errores y flujo de clasificación honesto.
          </p>

          <div className="inspector-box" aria-label="Navegador del prototipo">
            <div className="inspector-section">
              <span className="inspector-label">PANTALLAS DEL BRIEF (14 VISTAS)</span>
              <div className="inspector-pills">
                {SCREEN_DIRECTORY.map((item) => (
                  <button
                    key={item.id}
                    type="button"
                    className={screen === item.id ? "active" : ""}
                    onClick={() => navigate(item.id)}
                  >
                    <b>{item.code}</b> {item.label}
                  </button>
                ))}
              </div>
            </div>

            <div className="inspector-section">
              <span className="inspector-label">ESTADOS TRANSVERSALES Y ERRORES</span>
              <div className="inspector-toggles">
                <button
                  type="button"
                  className={sim.offline ? "on" : ""}
                  onClick={() => setSim((p) => ({ ...p, offline: !p.offline }))}
                >
                  Sin conexión
                </button>
                <button
                  type="button"
                  className={sim.cameraDenied ? "on" : ""}
                  onClick={() => {
                    setSim((p) => ({ ...p, cameraDenied: !p.cameraDenied }));
                    navigate("scan");
                  }}
                >
                  Cámara denegada
                </button>
                <button
                  type="button"
                  className={sim.invalidImage ? "on" : ""}
                  onClick={() => {
                    setSim((p) => ({ ...p, invalidImage: !p.invalidImage }));
                    navigate("preview");
                  }}
                >
                  Imagen inválida
                </button>
                <button
                  type="button"
                  className={sim.mlUnavailable ? "on" : ""}
                  onClick={() => {
                    setSim((p) => ({ ...p, mlUnavailable: !p.mlUnavailable }));
                    navigate("analyzing");
                  }}
                >
                  Modelo ML caído
                </button>
                <button
                  type="button"
                  className={sim.splashError ? "on" : ""}
                  onClick={() => {
                    setSim((p) => ({ ...p, splashError: !p.splashError }));
                    navigate("splash");
                  }}
                >
                  Splash fallo
                </button>
                <button
                  type="button"
                  className={sim.authError === "session-expired" ? "on" : ""}
                  onClick={() => {
                    setSim((p) => ({
                      ...p,
                      authError:
                        p.authError === "session-expired" ? "none" : "session-expired",
                    }));
                    navigate("auth");
                  }}
                >
                  Sesión expirada
                </button>
                <button
                  type="button"
                  className={history.length === 0 ? "on" : ""}
                  onClick={() => {
                    setHistory((prev) => (prev.length === 0 ? INITIAL_HISTORY : []));
                    navigate("history");
                  }}
                >
                  {history.length === 0 ? "Restaurar historial" : "Historial vacío"}
                </button>
              </div>
            </div>

            <div className="inspector-section">
              <span className="inspector-label">VARIANTE DE RESULTADO (UI-08)</span>
              <div className="inspector-toggles">
                {(
                  [
                    { id: "identified", label: "Identificado (86%)" },
                    { id: "low-confidence", label: "Baja confianza (48%)" },
                    { id: "unknown", label: "Desconocido" },
                    { id: "error", label: "Error ML" },
                  ] as { id: ResultVariant; label: string }[]
                ).map((variant) => (
                  <button
                    key={variant.id}
                    type="button"
                    className={sim.resultVariant === variant.id ? "on" : ""}
                    onClick={() => {
                      setSim((p) => ({ ...p, resultVariant: variant.id }));
                      navigate("result");
                    }}
                  >
                    {variant.label}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        <small>Prototipo UI/UX · PECOX Vision 2026 · Inspiración Eco-Tech</small>
      </aside>

      <section
        className={`phone-shell ${a11y.largeText ? "large-text" : ""} ${a11y.reduceMotion ? "reduce-motion" : ""}`}
        aria-label="Prototipo móvil PECOX Vision"
      >
        {screen === "splash" && (
          <SplashScreen
            hasError={sim.splashError}
            onRetry={() => setSim((p) => ({ ...p, splashError: false }))}
            onFinish={() => navigate("onboarding")}
          />
        )}

        {screen === "onboarding" && <OnboardingScreen onDone={() => navigate("auth")} />}

        {screen === "auth" && (
          <AuthScreen
            offline={sim.offline}
            simulatedError={sim.authError}
            onClearSimError={() => setSim((p) => ({ ...p, authError: "none" }))}
            onAuthSuccess={handleAuthSuccess}
            onGuestGuide={handleGuestGuide}
            navigate={navigate}
          />
        )}

        {screen === "home" && (
          <HomeScreen
            user={user}
            history={history}
            offline={sim.offline}
            onRetryNetwork={() => setSim((p) => ({ ...p, offline: false }))}
            onOpenGuideMaterial={(key) => {
              setGuideMaterial(key);
              navigate("guide");
            }}
            navigate={navigate}
          />
        )}

        {screen === "scan" && (
          <ScannerScreen
            cameraDenied={sim.cameraDenied}
            onEnableCameraSim={() => setSim((p) => ({ ...p, cameraDenied: false }))}
            navigate={navigate}
            onPhoto={handlePhoto}
          />
        )}

        {screen === "preview" && (
          <PreviewScreen
            photo={photo}
            invalidImage={sim.invalidImage}
            onClearInvalidImage={() => setSim((p) => ({ ...p, invalidImage: false }))}
            navigate={navigate}
          />
        )}

        {screen === "analyzing" && (
          <AnalyzingScreen
            photo={photo}
            simFlags={sim}
            onRetryFixed={() =>
              setSim((p) => ({ ...p, offline: false, mlUnavailable: false }))
            }
            navigate={navigate}
          />
        )}

        {screen === "result" && (
          <ResultScreen
            photo={photo}
            variant={sim.resultVariant}
            onChangeVariant={(next) => setSim((p) => ({ ...p, resultVariant: next }))}
            onSaveRecord={handleSaveRecord}
            navigate={navigate}
          />
        )}

        {screen === "history" && (
          <HistoryScreen
            history={history}
            offline={sim.offline}
            onRetryNetwork={() => setSim((p) => ({ ...p, offline: false }))}
            onDeleteRecord={handleDeleteRecord}
            navigate={navigate}
          />
        )}

        {screen === "stats" && <StatsScreen history={history} navigate={navigate} />}

        {screen === "guide" && (
          <GuideScreen
            selectedKey={guideMaterial}
            onSelectKey={setGuideMaterial}
            onBack={() =>
              navigate(previousScreen === "auth" ? "auth" : user.isGuest ? "auth" : "home")
            }
          />
        )}

        {screen === "profile" && (
          <ProfileScreen
            user={user}
            historyCount={history.length}
            a11y={a11y}
            onUpdateUser={(name, email) =>
              setUser((prev) => ({
                ...prev,
                name,
                email,
                initials: computeInitials(name),
                isGuest: false,
              }))
            }
            onUpdateA11y={setA11y}
            onClearHistory={() => setHistory([])}
            onLogout={() => navigate("auth")}
            navigate={navigate}
          />
        )}

        {screen === "future" && <FutureConceptsScreen navigate={navigate} />}

        {showBottomNav && <BottomNav screen={screen} navigate={navigate} />}
      </section>
    </main>
  );
}
