from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.material_guide import MaterialGuide
from app.models.model_version import ModelVersion

DEFAULT_GUIDES: list[tuple[str, str, str]] = [
    (
        "plastic",
        "Plástico",
        "Vacía el contenido, enjuaga ligeramente y aplasta el envase. "
        "Verifica aceptación local para plásticos flexibles.",
    ),
    (
        "glass",
        "Vidrio",
        "Retira tapas y corchos, enjuaga residuos espesos y deposita sin romper. "
        "No mezcles espejos ni cerámica.",
    ),
    (
        "metal",
        "Metal",
        "Escurre líquidos o aceite, enjuaga y seca. Maneja con cuidado bordes cortantes. "
        "No incluyas aerosoles presurizados.",
    ),
    (
        "cardboard",
        "Cartón",
        "Retira cintas gruesas, verifica que esté seco y aplana las cajas. "
        "Cartón manchado de grasa no es reciclable.",
    ),
    (
        "paper",
        "Papel",
        "Retira espirales o grapas grandes, mantén las hojas secas y agrúpalas planas. "
        "Evita servilletas o tickets térmicos.",
    ),
    (
        "other",
        "Otros",
        "Identifica si es residuo especial (pilas, electrónicos) y consulta puntos "
        "de acopio diferenciados en tu localidad.",
    ),
]


class GuideRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def list_all(self) -> list[MaterialGuide]:
        guides = list(self.db.scalars(select(MaterialGuide).order_by(MaterialGuide.title)).all())
        if not guides:
            for key, title, instructions in DEFAULT_GUIDES:
                self.db.add(
                    MaterialGuide(
                        material_key=key,
                        title=title,
                        instructions=instructions,
                    )
                )
            self.db.commit()
            guides = list(
                self.db.scalars(select(MaterialGuide).order_by(MaterialGuide.title)).all()
            )
        return guides


class ModelVersionRepository:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_active(self) -> ModelVersion | None:
        stmt = select(ModelVersion).where(ModelVersion.is_active.is_(True))
        return self.db.scalar(stmt)
