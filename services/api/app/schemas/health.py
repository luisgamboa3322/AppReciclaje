from pydantic import BaseModel


class HealthResponse(BaseModel):
    status: str
    database: str
    environment: str


class ModelInfoResponse(BaseModel):
    status: str
    active_version: str | None
    architecture: str | None
    note: str
