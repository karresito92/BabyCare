from pydantic import BaseModel
from datetime import datetime
from typing import Optional, Dict, Any

class ActivityCreate(BaseModel):
    type: str
    timestamp: datetime
    data: Optional[Dict[str, Any]] = None
    notes: Optional[str] = None

class ActivityResponse(BaseModel):
    id: int
    baby_id: int
    user_id: Optional[int]
    type: str
    timestamp: datetime
    data: Optional[Dict[str, Any]]
    notes: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True