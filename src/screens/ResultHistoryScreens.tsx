import { useEffect, useState } from "react";
import { Icon, OfflineBanner, StateCard, TopBar } from "../components/Icons";
import { DEMO_PREDICTIONS, getMaterialByKey, MATERIALS } from "../data/materials";
import type {
  ClassificationRecord,
  MaterialKey,
  ResultVariant,
  Screen,
} from "../types/pecox";

function CorrectionSheet({
  originalMaterial,
  value,
  onSelect,
  onUndo,
  onClose,
}: {
  originalMaterial: MaterialKey;
  value: MaterialKey;
  onSelect: (value: MaterialKey) => void;
  onUndo: () => void;
  onClose: () => void;
}) {
  const isModified = value !== originalMaterial;
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
        <p>
          Tu corrección se guarda en un campo separado de la sugerencia original y no reentrena el
          modelo de inmediato.
        </p>
        <div className="correction-grid">
          {MATERIALS.map((item) => (
            <button
              key={item.key}
              className={value === item.key ? "selected" : ""}
              onClick={() => onSelect(item.key)}
            >
              <span className={`tone-${item.tone}`}>{item.icon}</span>
              <b>{item.label}</b>
              <small className="correction-example">{item.examples[0].split("(")[0].trim()}</small>
              {value === item.key && (
                <i>
                  <Icon name="check" size={13} />
                </i>
              )}
            </button>
          ))}
        </div>
        <div className="sheet-actions">
          {isModified && (
            <button type="button" className="secondary-button undo-btn" onClick={onUndo}>
              <Icon name="undo" size={16} /> Deshacer corrección
            </button>
          )}
          <button type="button" className="primary-button" onClick={onClose}>
            Confirmar material ({getMaterialByKey(value).label})
          </button>
        </div>
      </div>
    </div>
  );
}

export function ResultScreen({
  photo,
  variant,
  onChangeVariant,
  onSaveRecord,
  navigate,
}: {
  photo: string;
  variant: ResultVariant;
  onChangeVariant: (next: ResultVariant) => void;
  onSaveRecord: (record: ClassificationRecord) => void;
  navigate: (screen: Screen) => void;
}) {
  const payload = variant === "error" ? DEMO_PREDICTIONS.identified : DEMO_PREDICTIONS[variant];
  const [correctionOpen, setCorrectionOpen] = useState(false);
  const [confirmedMaterial, setConfirmedMaterial] = useState<MaterialKey>(payload.material);
  const [savedNotice, setSavedNotice] = useState(false);

  useEffect(() => {
    setConfirmedMaterial(payload.material);
    setSavedNotice(false);
  }, [payload.material, variant]);

  const activeMaterial = getMaterialByKey(confirmedMaterial);
  const isCorrected = confirmedMaterial !== payload.material;

  if (variant === "error") {
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
        <div className="preview-error-wrap">
          <StateCard
            icon="alert"
            tone="error"
            title="Error al procesar la imagen"
            description="El servicio de inferencia devolvió un error controlado. No se mostrará una categoría inventada."
            primaryLabel="Reintentar análisis"
            onPrimary={() => navigate("analyzing")}
            secondaryLabel="Elegir material manualmente"
            onSecondary={() => onChangeVariant("low-confidence")}
          />
        </div>
      </div>
    );
  }

  const handleSave = () => {
    const newRecord: ClassificationRecord = {
      id: `cls-${Date.now()}`,
      title: isCorrected ? `${activeMaterial.label} (corregido)` : payload.title,
      predictedMaterial: payload.material,
      confirmedMaterial,
      confidence: payload.confidence,
      status: isCorrected ? "corrected" : "confirmed",
      dateGroup: "HOY",
      timestampLabel: "Ahora mismo",
      imageUrl: photo,
      notes: isCorrected
        ? `Predicción demo: ${getMaterialByKey(payload.material).label} → Confirmado: ${activeMaterial.label}`
        : "Guardado en sesión de demostración.",
    };
    onSaveRecord(newRecord);
    setSavedNotice(true);
    navigate("history");
  };

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

      <div className="variant-strip" role="group" aria-label="Variantes de resultado demo">
        {(
          [
            { id: "identified", label: "Identificado" },
            { id: "low-confidence", label: "Baja confianza" },
            { id: "unknown", label: "Desconocido" },
            { id: "error", label: "Error" },
          ] as { id: ResultVariant; label: string }[]
        ).map((item) => (
          <button
            key={item.id}
            type="button"
            className={variant === item.id ? "active" : ""}
            onClick={() => onChangeVariant(item.id)}
          >
            {item.label}
          </button>
        ))}
      </div>

      <div className="result-photo">
        <img src={photo} alt="Objeto analizado" />
        <span className="demo-label">RESULTADO DEMO · {payload.modelVersion}</span>
      </div>

      <section className="result-card">
        <div className="result-heading">
          <span className={`material-symbol tone-${activeMaterial.tone}`}>{activeMaterial.icon}</span>
          <div>
            <span>{isCorrected ? "MATERIAL CORREGIDO" : "MATERIAL SUGERIDO"}</span>
            <h1>{activeMaterial.label}</h1>
            <small>
              <Icon name={isCorrected ? "edit" : "check"} size={13} />{" "}
              {isCorrected
                ? `Corregido (original: ${getMaterialByKey(payload.material).label})`
                : variant === "low-confidence"
                  ? "Confianza baja · Revisa antes de guardar"
                  : variant === "unknown"
                    ? "Material incierto"
                    : "Sugerencia del prototipo"}
            </small>
          </div>
          <div className={`score ${variant !== "identified" ? "score--warn" : ""}`}>
            <strong>
              {payload.confidence ?? "--"}
              <sup>%</sup>
            </strong>
            <span>
              Confianza
              <br />
              del modelo
            </span>
          </div>
        </div>

        <div className={`honesty-banner ${variant !== "identified" ? "honesty-banner--warn" : ""}`}>
          <Icon name={variant === "identified" ? "info" : "alert"} size={18} />
          <span>
            <b>{payload.headline}</b>
            {payload.explanation}
          </span>
        </div>

        <div className="separation-guide">
          <div className="guide-icon">
            <Icon name="book" />
          </div>
          <div>
            <span>CÓMO PREPARARLO ({activeMaterial.label.toUpperCase()})</span>
            <h3>{activeMaterial.steps[0].title}</h3>
            <p>
              {activeMaterial.steps[0].detail} {activeMaterial.warning}
            </p>
          </div>
        </div>

        <div className="alternatives">
          <span>Otras sugerencias del ejemplo</span>
          {payload.alternatives.map((alt) => {
            const altMat = getMaterialByKey(alt.key);
            return (
              <div key={alt.key}>
                <b>
                  {altMat.label} <i style={{ width: `${Math.max(alt.confidence, 6)}%` }} />
                </b>
                <small>{alt.confidence}%</small>
              </div>
            );
          })}
        </div>

        <button className="primary-button" onClick={handleSave}>
          <Icon name={savedNotice ? "check" : "history"} size={18} />{" "}
          {savedNotice ? "Guardado en historial" : "Guardar clasificación"}
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
          originalMaterial={payload.material}
          value={confirmedMaterial}
          onSelect={setConfirmedMaterial}
          onUndo={() => setConfirmedMaterial(payload.material)}
          onClose={() => setCorrectionOpen(false)}
        />
      )}
    </div>
  );
}

export function HistoryScreen({
  history,
  offline,
  onRetryNetwork,
  onDeleteRecord,
  navigate,
}: {
  history: ClassificationRecord[];
  offline: boolean;
  onRetryNetwork: () => void;
  onDeleteRecord: (id: string) => void;
  navigate: (screen: Screen) => void;
}) {
  const [filter, setFilter] = useState<"all" | MaterialKey>("all");
  const [searchOpen, setSearchOpen] = useState(false);
  const [query, setQuery] = useState("");
  const [selectedRecord, setSelectedRecord] = useState<ClassificationRecord | null>(null);

  const filtered = history.filter((item) => {
    const matchesFilter = filter === "all" || item.confirmedMaterial === filter;
    const matLabel = getMaterialByKey(item.confirmedMaterial).label.toLowerCase();
    const matchesQuery =
      !query.trim() ||
      item.title.toLowerCase().includes(query.toLowerCase()) ||
      matLabel.includes(query.toLowerCase());
    return matchesFilter && matchesQuery;
  });

  const groups: ("HOY" | "ESTA SEMANA" | "ANTERIORES")[] = ["HOY", "ESTA SEMANA", "ANTERIORES"];
  const correctedCount = history.filter((item) => item.status === "corrected").length;

  return (
    <div className="page page-with-nav history-page">
      <header className="simple-header">
        <div>
          <span>TU ACTIVIDAD</span>
          <h1>Mi historial</h1>
        </div>
        <button
          className={`icon-btn ${searchOpen ? "icon-btn--active" : ""}`}
          aria-label={searchOpen ? "Cerrar búsqueda" : "Buscar en historial"}
          onClick={() => {
            setSearchOpen((prev) => !prev);
            if (searchOpen) setQuery("");
          }}
        >
          <Icon name={searchOpen ? "close" : "search"} />
        </button>
      </header>

      {offline && <OfflineBanner onRetry={onRetryNetwork} />}

      {searchOpen && (
        <div className="history-search-bar">
          <Icon name="search" size={16} />
          <input
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Buscar por objeto o material..."
            aria-label="Buscar clasificaciones"
          />
        </div>
      )}

      <div className="summary-banner">
        <div>
          <span>Clasificaciones</span>
          <strong>{history.length}</strong>
        </div>
        <i />
        <div>
          <span>Corregidas</span>
          <strong>{correctedCount}</strong>
        </div>
        <span className="summary-art">♻</span>
      </div>

      <div className="filter-row" role="tablist" aria-label="Filtrar por material">
        <button
          type="button"
          className={filter === "all" ? "active" : ""}
          onClick={() => setFilter("all")}
        >
          Todos
        </button>
        {MATERIALS.map((mat) => (
          <button
            key={mat.key}
            type="button"
            className={filter === mat.key ? "active" : ""}
            onClick={() => setFilter(mat.key)}
          >
            {mat.label}
          </button>
        ))}
      </div>

      {history.length === 0 ? (
        <StateCard
          icon="history"
          title="Aún no tienes clasificaciones"
          description="Captura o selecciona una fotografía para empezar a construir tu registro de separación."
          primaryLabel="Escanear mi primer residuo"
          onPrimary={() => navigate("scan")}
          secondaryLabel="Explorar guía de materiales"
          onSecondary={() => navigate("guide")}
        />
      ) : filtered.length === 0 ? (
        <StateCard
          icon="search"
          title="Sin coincidencias"
          description="No encontramos registros con los filtros actuales."
          primaryLabel="Limpiar filtros"
          onPrimary={() => {
            setFilter("all");
            setQuery("");
          }}
        />
      ) : (
        groups.map((group) => {
          const items = filtered.filter((item) => item.dateGroup === group);
          if (items.length === 0) return null;
          return (
            <div key={group}>
              <span className="date-label">{group}</span>
              <div className="history-list">
                {items.map((item) => {
                  const mat = getMaterialByKey(item.confirmedMaterial);
                  return (
                    <button
                      key={item.id}
                      className="history-item"
                      onClick={() => setSelectedRecord(item)}
                    >
                      {item.imageUrl ? (
                        <img src={item.imageUrl} alt={item.title} />
                      ) : (
                        <span className={`fake-thumb tone-${mat.tone}`}>{mat.icon}</span>
                      )}
                      <span>
                        <b>{item.title}</b>
                        <small>
                          {item.timestampLabel} ·{" "}
                          {item.status === "corrected" ? "Corregido" : "Confirmado"}
                        </small>
                        <i>
                          <Icon name={item.status === "corrected" ? "edit" : "check"} size={11} />{" "}
                          {mat.label}
                        </i>
                      </span>
                      {item.confidence !== null && (
                        <span className="confidence-pill">{item.confidence}%</span>
                      )}
                      <Icon name="chevron" size={18} />
                    </button>
                  );
                })}
              </div>
            </div>
          );
        })
      )}

      {selectedRecord && (
        <div
          className="sheet-backdrop"
          role="presentation"
          onMouseDown={() => setSelectedRecord(null)}
        >
          <div
            className="correction-sheet detail-sheet"
            role="dialog"
            aria-modal="true"
            aria-labelledby="detail-title"
            onMouseDown={(e) => e.stopPropagation()}
          >
            <div className="sheet-handle" />
            <div className="sheet-title">
              <div>
                <span>DETALLE DE REGISTRO</span>
                <h2 id="detail-title">{selectedRecord.title}</h2>
              </div>
              <button onClick={() => setSelectedRecord(null)} aria-label="Cerrar detalle">
                <Icon name="close" />
              </button>
            </div>
            <div className="detail-meta-grid">
              <div>
                <small>Predicción original</small>
                <b>{getMaterialByKey(selectedRecord.predictedMaterial).label}</b>
              </div>
              <div>
                <small>Material confirmado</small>
                <b>{getMaterialByKey(selectedRecord.confirmedMaterial).label}</b>
              </div>
              <div>
                <small>Confianza demo</small>
                <b>{selectedRecord.confidence !== null ? `${selectedRecord.confidence}%` : "--"}</b>
              </div>
              <div>
                <small>Fecha</small>
                <b>{selectedRecord.timestampLabel}</b>
              </div>
            </div>
            {selectedRecord.notes && <p className="detail-notes">{selectedRecord.notes}</p>}
            <button
              type="button"
              className="logout-button"
              onClick={() => {
                onDeleteRecord(selectedRecord.id);
                setSelectedRecord(null);
              }}
            >
              <Icon name="trash" size={17} /> Eliminar de mi historial
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
