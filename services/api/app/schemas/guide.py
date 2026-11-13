from datetime import datetime

from pydantic import BaseModel, ConfigDict

from app.schemas.classification import MaterialKey


class MaterialGuideResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    material_key: MaterialKey
    title: str
    instructions: str
    updated_at: datetime
