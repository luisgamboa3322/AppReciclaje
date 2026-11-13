import { useState, type FormEvent } from "react";
import { Icon, StateCard, TopBar } from "../components/Icons";
import {
  DEMO_FUTURE_MACHINES,
  DEMO_WEEKLY_ACTIVITY,
  getMaterialByKey,
  MATERIALS,
} from "../data/materials";
import type {
  AccessibilitySettings,
  ClassificationRecord,
  MaterialKey,
  Screen,
  UserProfile,
} from "../types/pecox";

export function StatsScreen({
  history,
  navigate,
}: {
  history: ClassificationRecord[];
  navigate: (screen: Screen) => void;
}) {
  const [period, setPeriod] = useState<"7d" | "30d" | "all">("7d");
  const maxBar = Math.max(...DEMO_WEEKLY_ACTIVITY.map((d) => d.count), 1);

  const countsByMaterial = MATERIALS.map((mat) => ({
    ...mat,
    count: history.filter((item) => item.confirmedMaterial === mat.key).length,
  })).sort((a, b) => b.count - a.count);

  const topMaterial = countsByMaterial[0];
  const totalCount = history.length;

  return (
    <div className="page stats-page">
      <TopBar title="Estadísticas" onBack={() => navigate("home")} />

      <div className="stats-body">
        <div className="honesty-banner">
          <Icon name="info" size={18} />
          <span>
            <b>Vista V2 · Datos de demostración</b> Los totales reflejan tu sesión actual del
            prototipo. No se muestran cifras inventadas de CO₂ evitado ni dinero ahorrado.
          </span>
        </div>

        <div className="period-pills" role="group" aria-label="Periodo de tiempo">
          {(
            [
              { id: "7d", label: "7 días" },
              { id: "30d", label: "30 días" },
              { id: "all", label: "Todo" },
            ] as const
          ).map((item) => (
            <button
              key={item.id}
              type="button"
              className={period === item.id ? "active" : ""}
              onClick={() => setPeriod(item.id)}
            >
              {item.label}
            </button>
          ))}
        </div>

        <div className="stats-kpi-grid">
          <div className="stats-kpi-card stats-kpi-card--main">
            <span>Total clasificaciones</span>
            <strong>{totalCount}</strong>
            <small>Registros en esta sesión ({period})</small>
          </div>
          <div className="stats-kpi-card">
            <span>Más frecuente</span>
            <strong>{totalCount > 0 ? topMaterial.label : "--"}</strong>
            <small>
              {totalCount > 0 ? `${topMaterial.count} registro(s)` : "Sin registros"}
            </small>
          </div>
        </div>

        <section className="chart-card">
          <div className="chart-head">
            <div>
              <span className="section-kicker">EVOLUCIÓN SEMANAL (DEMO)</span>
              <h2>Actividad reciente</h2>
            </div>
            <span className="demo-pill">DEMO</span>
          </div>
          <div className="bar-chart" aria-label="Gráfica semanal de demostración">
            {DEMO_WEEKLY_ACTIVITY.map((item) => (
              <div key={item.day} className="bar-col">
                <span className="bar-value">{item.count}</span>
                <div className="bar-track">
                  <div
                    className="bar-fill"
                    style={{ height: `${Math.round((item.count / maxBar) * 100)}%` }}
                  />
                </div>
                <small>{item.day}</small>
              </div>
            ))}
          </div>
        </section>

        <section className="chart-card">
          <div className="chart-head">
            <div>
              <span className="section-kicker">DISTRIBUCIÓN</span>
              <h2>Por material confirmado</h2>
            </div>
          </div>
          {totalCount === 0 ? (
            <StateCard
              icon="chart"
              title="Sin datos para graficar"
              description="Guarda una clasificación para ver la distribución por material."
              primaryLabel="Ir al escáner"
              onPrimary={() => navigate("scan")}
            />
          ) : (
            <div className="distribution-list">
              {countsByMaterial.map((mat) => {
                const pct = totalCount > 0 ? Math.round((mat.count / totalCount) * 100) : 0;
                return (
                  <div key={mat.key} className="dist-row">
                    <div className="dist-label">
                      <span>{mat.label}</span>
                      <b>
                        {mat.count} ({pct}%)
                      </b>
                    </div>
                    <div className="dist-track">
                      <div
                        className="dist-fill"
                        style={{
                          width: `${Math.max(pct, mat.count > 0 ? 8 : 0)}%`,
                          background: mat.accentColor,
                        }}
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </section>
      </div>
    </div>
  );
}

export function GuideScreen({
  selectedKey,
  onSelectKey,
  onBack,
}: {
  selectedKey: MaterialKey;
  onSelectKey: (key: MaterialKey) => void;
  onBack: () => void;
}) {
  const active = getMaterialByKey(selectedKey);

  return (
    <div className="page guide-page">
      <TopBar title="Guía de materiales" onBack={onBack} />
      <div className="guide-intro">
        <span className="section-kicker">APRENDE A SEPARAR · SIN CÁMARA</span>
        <h1>Cada material tiene su lugar</h1>
        <p>
          Consulta ejemplos, preparación y advertencias por categoría. Las reglas pueden variar
          según tu municipio.
        </p>
      </div>

      <div className="guide-materials" role="tablist" aria-label="Categorías de materiales">
        {MATERIALS.map((item) => (
          <button
            key={item.key}
            type="button"
            role="tab"
            aria-selected={selectedKey === item.key}
            className={selectedKey === item.key ? "active" : ""}
            onClick={() => onSelectKey(item.key)}
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
          <p className="guide-description">{active.description}</p>

          <div className="guide-examples">
            <span className="section-kicker">EJEMPLOS COMUNES</span>
            <ul>
              {active.examples.map((example) => (
                <li key={example}>{example}</li>
              ))}
            </ul>
          </div>

          <span className="section-kicker">ANTES DE RECICLAR</span>
          <h3>Prepáralo en tres pasos</h3>
          <ol className="guide-steps">
            {active.steps.map((step, index) => (
              <li key={step.title}>
                <b>{index + 1}</b>
                <span>
                  <strong>{step.title}</strong>
                  <small>{step.detail}</small>
                </span>
              </li>
            ))}
          </ol>

          <div className="local-note">
            <Icon name="info" size={18} />
            <span>
              <b>Advertencia y reglas locales</b>
              <small>{active.warning}</small>
            </span>
          </div>
        </div>
      </article>
    </div>
  );
}

type ProfileSheet = "none" | "edit" | "accessibility" | "privacy";

export function ProfileScreen({
  user,
  historyCount,
  a11y,
  onUpdateUser,
  onUpdateA11y,
  onClearHistory,
  onLogout,
  navigate,
}: {
  user: UserProfile;
  historyCount: number;
  a11y: AccessibilitySettings;
  onUpdateUser: (name: string, email: string) => void;
  onUpdateA11y: (next: AccessibilitySettings) => void;
  onClearHistory: () => void;
  onLogout: () => void;
  navigate: (screen: Screen) => void;
}) {
  const [sheet, setSheet] = useState<ProfileSheet>("none");
  const [editName, setEditName] = useState(user.name);
  const [editEmail, setEditEmail] = useState(user.email);
  const [clearedMsg, setClearedMsg] = useState(false);

  const handleSaveProfile = (event: FormEvent) => {
    event.preventDefault();
    if (!editName.trim() || !editEmail.includes("@")) return;
    onUpdateUser(editName.trim(), editEmail.trim());
    setSheet("none");
  };

  return (
    <div className="page page-with-nav profile-page">
      <header className="simple-header">
        <div>
          <span>TU CUENTA</span>
          <h1>Perfil</h1>
        </div>
      </header>

      <div className="profile-card">
        <div className="large-avatar">{user.initials}</div>
        <div>
          <h2>{user.name}</h2>
          <p>{user.email}</p>
          <span>{user.badge}</span>
        </div>
        <button
          aria-label="Editar perfil"
          onClick={() => {
            setEditName(user.name);
            setEditEmail(user.email);
            setSheet("edit");
          }}
        >
          <Icon name="edit" size={18} />
        </button>
      </div>

      <div className="profile-impact">
        <span>
          <Icon name="leaf" size={19} />
        </span>
        <div>
          <b>{historyCount} clasificaciones en sesión</b>
          <small>Datos demostrativos locales · Sin backend conectado</small>
        </div>
      </div>

      <section className="settings-section">
        <span className="date-label">AJUSTES Y EXPLORACIÓN</span>
        <div className="settings-list">
          <button
            onClick={() => {
              setEditName(user.name);
              setEditEmail(user.email);
              setSheet("edit");
            }}
          >
            <span>
              <Icon name="user" />
            </span>
            <div>
              <b>Datos personales</b>
              <small>Nombre, correo e iniciales</small>
            </div>
            <Icon name="chevron" size={18} />
          </button>

          <button onClick={() => setSheet("accessibility")}>
            <span>
              <Icon name="eye" />
            </span>
            <div>
              <b>Accesibilidad</b>
              <small>
                {a11y.largeText ? "Texto grande activo" : "Texto estándar"} ·{" "}
                {a11y.reduceMotion ? "Movimiento reducido" : "Animaciones normales"}
              </small>
            </div>
            <Icon name="chevron" size={18} />
          </button>

          <button
            onClick={() => {
              setClearedMsg(false);
              setSheet("privacy");
            }}
          >
            <span>
              <Icon name="shield" />
            </span>
            <div>
              <b>Privacidad y datos</b>
              <small>Retención temporal y borrado de historial</small>
            </div>
            <Icon name="chevron" size={18} />
          </button>

          <button onClick={() => navigate("stats")}>
            <span>
              <Icon name="chart" />
            </span>
            <div>
              <b>Estadísticas personales (V2 Demo)</b>
              <small>Gráficas semanales y distribución</small>
            </div>
            <Icon name="chevron" size={18} />
          </button>

          <button onClick={() => navigate("future")}>
            <span>
              <Icon name="cpu" />
            </span>
            <div>
              <b>Conceptos futuros (V3)</b>
              <small>Recompensas verificadas y máquinas IoT</small>
            </div>
            <Icon name="chevron" size={18} />
          </button>
        </div>
      </section>

      <button className="logout-button" onClick={onLogout}>
        <Icon name="logout" size={18} />{" "}
        {user.isGuest ? "Ir a iniciar sesión" : "Cerrar sesión"}
      </button>

      <p className="version">PECOX Vision · Prototipo completo (14 pantallas)</p>

      {sheet !== "none" && (
        <div className="sheet-backdrop" role="presentation" onMouseDown={() => setSheet("none")}>
          <div
            className="correction-sheet"
            role="dialog"
            aria-modal="true"
            onMouseDown={(e) => e.stopPropagation()}
          >
            <div className="sheet-handle" />
            <div className="sheet-title">
              <div>
                <span>CONFIGURACIÓN</span>
                <h2>
                  {sheet === "edit" && "Editar datos personales"}
                  {sheet === "accessibility" && "Accesibilidad"}
                  {sheet === "privacy" && "Privacidad y datos"}
                </h2>
              </div>
              <button onClick={() => setSheet("none")} aria-label="Cerrar">
                <Icon name="close" />
              </button>
            </div>

            {sheet === "edit" && (
              <form className="sheet-form" onSubmit={handleSaveProfile}>
                <label className="input-field">
                  <span>Nombre</span>
                  <input
                    type="text"
                    value={editName}
                    onChange={(e) => setEditName(e.target.value)}
                    required
                  />
                </label>
                <label className="input-field">
                  <span>Correo electrónico</span>
                  <input
                    type="email"
                    value={editEmail}
                    onChange={(e) => setEditEmail(e.target.value)}
                    required
                  />
                </label>
                <button type="submit" className="primary-button">
                  Guardar cambios
                </button>
              </form>
            )}

            {sheet === "accessibility" && (
              <div className="a11y-toggles">
                <label className="toggle-row">
                  <div>
                    <b>Texto grande</b>
                    <small>Aumenta la escala tipográfica para mejorar la lectura</small>
                  </div>
                  <input
                    type="checkbox"
                    checked={a11y.largeText}
                    onChange={(e) => onUpdateA11y({ ...a11y, largeText: e.target.checked })}
                  />
                </label>
                <label className="toggle-row">
                  <div>
                    <b>Reducir movimiento</b>
                    <small>Desactiva pulsos y transiciones animadas</small>
                  </div>
                  <input
                    type="checkbox"
                    checked={a11y.reduceMotion}
                    onChange={(e) => onUpdateA11y({ ...a11y, reduceMotion: e.target.checked })}
                  />
                </label>
                <button
                  type="button"
                  className="primary-button"
                  onClick={() => setSheet("none")}
                >
                  Listo
                </button>
              </div>
            )}

            {sheet === "privacy" && (
              <div className="privacy-sheet-body">
                <p>
                  Las imágenes enviadas para análisis se procesarán de forma temporal y no se
                  conservarán indefinidamente por defecto.
                </p>
                {clearedMsg ? (
                  <div className="auth-alert auth-alert--success">
                    <Icon name="check" size={18} />
                    <span>Historial de demostración eliminado.</span>
                  </div>
                ) : (
                  <button
                    type="button"
                    className="logout-button"
                    onClick={() => {
                      onClearHistory();
                      setClearedMsg(true);
                    }}
                  >
                    <Icon name="trash" size={17} /> Borrar historial de demostración ({historyCount})
                  </button>
                )}
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

export function FutureConceptsScreen({ navigate }: { navigate: (screen: Screen) => void }) {
  const [tab, setTab] = useState<"rewards" | "machines">("rewards");

  return (
    <div className="page future-page">
      <TopBar title="Conceptos futuros · V3" onBack={() => navigate("home")} />

      <div className="future-body">
        <div className="future-banner">
          <Icon name="lock" size={18} />
          <div>
            <b>CONCEPTO FUTURO (V3) · NO IMPLEMENTADO EN MVP</b>
            <small>
              Estas pantallas ilustran la ampliación posterior con máquinas físicas e IoT. Los
              valores mostrados no son telemetría ni saldos reales.
            </small>
          </div>
        </div>

        <div className="auth-tabs" role="tablist" aria-label="Conceptos futuros V3">
          <button
            type="button"
            role="tab"
            aria-selected={tab === "rewards"}
            className={tab === "rewards" ? "active" : ""}
            onClick={() => setTab("rewards")}
          >
            A. Recompensas
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={tab === "machines"}
            className={tab === "machines" ? "active" : ""}
            onClick={() => setTab("machines")}
          >
            B. Máquinas IoT
          </button>
        </div>

        {tab === "rewards" ? (
          <div className="future-stack">
            <div className="future-hero-card">
              <span className="demo-tag">CONCEPTO FUTURO</span>
              <small>Puntos por depósitos verificados</small>
              <strong>0 pts</strong>
              <p>
                Regla central: los escaneos por cámara NO otorgan puntos. Las recompensas
                dependerán exclusivamente de depósitos confirmados por sensores en máquina.
              </p>
            </div>

            <div className="future-card">
              <div className="future-card-head">
                <Icon name="gift" size={18} />
                <h3>Elegibilidad y canjes (Ilustrativo)</h3>
              </div>
              <ul className="future-list">
                <li>
                  <span>1. Escaneo de QR en máquina autorizada</span>
                  <small>Pendiente V3</small>
                </li>
                <li>
                  <span>2. Validación de depósito por sensor físico</span>
                  <small>Pendiente V3</small>
                </li>
                <li>
                  <span>3. Historial de canjes e incentivos locales</span>
                  <small>Concepto futuro</small>
                </li>
              </ul>
            </div>
          </div>
        ) : (
          <div className="future-stack">
            <div className="future-card">
              <div className="future-card-head">
                <Icon name="cpu" size={18} />
                <h3>Máquinas inteligentes (Ejemplo ilustrativo)</h3>
              </div>
              <p className="future-subnote">
                Las ubicaciones, niveles de llenado y estados son ejemplos de diseño, no telemetría
                conectada.
              </p>
              <div className="machine-list">
                {DEMO_FUTURE_MACHINES.map((machine) => (
                  <div key={machine.id} className="machine-item">
                    <div className="machine-top">
                      <b>{machine.name}</b>
                      <span className="demo-tag">{machine.status}</span>
                    </div>
                    <div className="machine-fill">
                      <span>Nivel de llenado ilustrativo</span>
                      <b>{machine.fillLevel}%</b>
                    </div>
                    <div className="dist-track">
                      <div
                        className="dist-fill"
                        style={{
                          width: `${machine.fillLevel}%`,
                          background: machine.fillLevel > 85 ? "#C83D42" : "#12C994",
                        }}
                      />
                    </div>
                    <small className="machine-meta">
                      Acepta: {machine.accepted.join(" · ")} — {machine.alert}
                    </small>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
