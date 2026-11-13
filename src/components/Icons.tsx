import type { ReactNode } from "react";
import type { Screen } from "../types/pecox";

export type IconName =
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
  | "eyeOff"
  | "logout"
  | "leaf"
  | "search"
  | "chart"
  | "wifiOff"
  | "alert"
  | "trash"
  | "refresh"
  | "cpu"
  | "gift"
  | "undo"
  | "lock";

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
  bell: <path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4" />,
  arrow: <path d="M5 12h14M14 7l5 5-5 5" />,
  sparkles: (
    <path d="m12 3 1.3 3.7L17 8l-3.7 1.3L12 13l-1.3-3.7L7 8l3.7-1.3L12 3ZM5 14l.8 2.2L8 17l-2.2.8L5 20l-.8-2.2L2 17l2.2-.8L5 14ZM19 14l.8 2.2L22 17l-2.2.8L19 20l-.8-2.2L16 17l2.2-.8L19 14Z" />
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
  edit: <path d="M13.5 6.5 17.5 10.5M4 20l4.5-1 10-10a2.8 2.8 0 0 0-4-4l-10 10z" />,
  book: <path d="M4 5a3 3 0 0 1 3-2h5v17H7a3 3 0 0 0-3 2zM20 5a3 3 0 0 0-3-2h-5v17h5a3 3 0 0 1 3 2z" />,
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
  eyeOff: (
    <>
      <path d="M9.9 4.2A10.9 10.9 0 0 1 12 4c6.5 0 10 8 10 8a18.5 18.5 0 0 1-2.2 3.2M6.6 6.6A13.5 13.5 0 0 0 2 12s3.5 8 10 8a9.7 9.7 0 0 0 4.8-1.2" />
      <path d="m2 2 20 20" />
    </>
  ),
  logout: <path d="M10 17l5-5-5-5M15 12H3M15 4h5v16h-5" />,
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
  chart: (
    <>
      <path d="M4 20V10M10 20V4M16 20v-7M22 20H2" />
    </>
  ),
  wifiOff: (
    <>
      <path d="M2 2 22 22" />
      <path d="M8.5 16.5a5 5 0 0 1 7 0M5 13a10 10 0 0 1 5.2-2.7M16.5 10.8A10 10 0 0 1 19 13M12 20h.01" />
    </>
  ),
  alert: (
    <>
      <path d="m12 3 9 16H3z" />
      <path d="M12 9v4M12 16h.01" />
    </>
  ),
  trash: (
    <>
      <path d="M3 6h18M8 6V4h8v2M19 6l-1 14H6L5 6" />
      <path d="M10 11v6M14 11v6" />
    </>
  ),
  refresh: (
    <>
      <path d="M21 12a9 9 0 1 1-2.64-6.36" />
      <path d="M21 3v6h-6" />
    </>
  ),
  cpu: (
    <>
      <rect x="6" y="6" width="12" height="12" rx="2" />
      <path d="M9 2v4M15 2v4M9 18v4M15 18v4M2 9h4M2 15h4M18 9h4M18 15h4" />
    </>
  ),
  gift: (
    <>
      <rect x="3" y="8" width="18" height="4" rx="1" />
      <path d="M12 8v13M5 12v8a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-8" />
      <path d="M7.5 8a2.5 2.5 0 1 1 2.5-2.5V8M16.5 8A2.5 2.5 0 1 0 14 5.5V8" />
    </>
  ),
  undo: (
    <>
      <path d="M9 14 4 9l5-5" />
      <path d="M4 9h10.5a5.5 5.5 0 0 1 0 11H11" />
    </>
  ),
  lock: (
    <>
      <rect x="4" y="11" width="16" height="10" rx="2" />
      <path d="M8 11V7a4 4 0 0 1 8 0v4" />
    </>
  ),
};

export function Icon({
  name,
  size = 20,
  strokeWidth = 1.9,
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

export function Brand({ light = false }: { light?: boolean }) {
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

export function TopBar({
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

export function BottomNav({
  screen,
  navigate,
}: {
  screen: Screen;
  navigate: (screen: Screen) => void;
}) {
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
          aria-current={screen === item.target ? "page" : undefined}
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

export function OfflineBanner({ onRetry }: { onRetry?: () => void }) {
  return (
    <div className="offline-banner" role="status">
      <Icon name="wifiOff" size={16} />
      <span>Sin conexión a internet. Algunas funciones requieren red.</span>
      {onRetry && (
        <button type="button" onClick={onRetry}>
          Reintentar
        </button>
      )}
    </div>
  );
}

export function StateCard({
  icon,
  tone = "neutral",
  title,
  description,
  primaryLabel,
  onPrimary,
  secondaryLabel,
  onSecondary,
}: {
  icon: IconName;
  tone?: "neutral" | "warning" | "error";
  title: string;
  description: string;
  primaryLabel?: string;
  onPrimary?: () => void;
  secondaryLabel?: string;
  onSecondary?: () => void;
}) {
  return (
    <div className={`state-card state-card--${tone}`} role="status">
      <div className="state-card-icon">
        <Icon name={icon} size={24} />
      </div>
      <h2>{title}</h2>
      <p>{description}</p>
      {primaryLabel && onPrimary && (
        <button type="button" className="primary-button" onClick={onPrimary}>
          {primaryLabel}
        </button>
      )}
      {secondaryLabel && onSecondary && (
        <button type="button" className="secondary-button" onClick={onSecondary}>
          {secondaryLabel}
        </button>
      )}
    </div>
  );
}
