from pydantic import BaseModel, field_serializer
from datetime import date, datetime
from typing import Optional

class BabyCreate(BaseModel):
    name: str
    birth_date: date
    photo: Optional[str] = None

class BabyResponse(BaseModel):
    id: int
    name: str
    birth_date: date
    photo: Optional[str] = None
    created_at: datetime
    updated_at: datetime

    @field_serializer('created_at', 'updated_at')
    def serialize_datetime(self, dt: datetime, _info):
        return dt.isoformat()

    class Config:
        from_attributes = True