from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from ..database import get_db
from ..models.user import User
from ..models.activity import Activity
from ..models.user_baby import UserBaby
from ..schemas.activity import ActivityCreate, ActivityResponse
from ..core.security import get_current_user

router = APIRouter(tags=["activities"])

@router.post("/babies/{baby_id}/activities", response_model=ActivityResponse, status_code=status.HTTP_201_CREATED)
async def create_activity(
    baby_id: int,
    activity: ActivityCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new activity for a baby"""
    # Check if user has access to this baby
    user_baby = db.query(UserBaby).filter(
        UserBaby.user_id == current_user.id,
        UserBaby.baby_id == baby_id
    ).first()

    if not user_baby:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have access to this baby"
        )

    db_activity = Activity(
        baby_id=baby_id,
        user_id=current_user.id,
        type=activity.type,
        timestamp=activity.timestamp,
        data=activity.data,
        notes=activity.notes
    )

    db.add(db_activity)
    db.commit()
    db.refresh(db_activity)

    return db_activity

@router.get("/babies/{baby_id}/activities", response_model=List[ActivityResponse])
async def get_baby_activities(
    baby_id: int,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None,
    activity_type: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all activities for a baby with optional filters"""
    # Check if user has access
    user_baby = db.query(UserBaby).filter(
        UserBaby.user_id == current_user.id,
        UserBaby.baby_id == baby_id
    ).first()

    if not user_baby:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have access to this baby"
        )

    query = db.query(Activity).filter(Activity.baby_id == baby_id)

    if start_date:
        query = query.filter(Activity.timestamp >= start_date)
    if end_date:
        query = query.filter(Activity.timestamp <= end_date)
    if activity_type:
        query = query.filter(Activity.type == activity_type)

    activities = query.order_by(Activity.timestamp.desc()).all()

    return activities

@router.get("/babies/{baby_id}/activities/{activity_id}", response_model=ActivityResponse)
async def get_activity(
    baby_id: int,
    activity_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific activity"""
    user_baby = db.query(UserBaby).filter(
        UserBaby.user_id == current_user.id,
        UserBaby.baby_id == baby_id
    ).first()

    if not user_baby:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have access to this baby"
        )

    activity = db.query(Activity).filter(
        Activity.id == activity_id,
        Activity.baby_id == baby_id
    ).first()

    if not activity:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Activity not found"
        )

    return activity

@router.put("/babies/{baby_id}/activities/{activity_id}", response_model=ActivityResponse)
async def update_activity(
    baby_id: int,
    activity_id: int,
    activity_update: ActivityCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update an activity"""
    user_baby = db.query(UserBaby).filter(
        UserBaby.user_id == current_user.id,
        UserBaby.baby_id == baby_id
    ).first()

    if not user_baby:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have access to this baby"
        )

    activity = db.query(Activity).filter(
        Activity.id == activity_id,
        Activity.baby_id == baby_id
    ).first()

    if not activity:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Activity not found"
        )

    activity.type = activity_update.type
    activity.timestamp = activity_update.timestamp
    activity.data = activity_update.data
    activity.notes = activity_update.notes

    db.commit()
    db.refresh(activity)

    return activity

@router.delete("/babies/{baby_id}/activities/{activity_id}", status_code=status.HTTP_204_NO_CONTENT)      
async def delete_activity(
    baby_id: int,
    activity_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete an activity"""
    user_baby = db.query(UserBaby).filter(
        UserBaby.user_id == current_user.id,
        UserBaby.baby_id == baby_id
    ).first()

    if not user_baby:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have access to this baby"
        )

    activity = db.query(Activity).filter(
        Activity.id == activity_id,
        Activity.baby_id == baby_id
    ).first()

    if not activity:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Activity not found"
        )

    db.delete(activity)
    db.commit()

    return None