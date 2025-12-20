from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models.user import User
from ..models.baby import Baby
from ..models.user_baby import UserBaby
from ..core.security import get_current_user

router = APIRouter(prefix="/babies/{baby_id}/caregivers", tags=["caregivers"])

@router.get("")
async def get_baby_caregivers(
    baby_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all caregivers for a baby"""
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
    
    # Get all caregivers
    caregivers = db.query(UserBaby, User).join(
        User, UserBaby.user_id == User.id
    ).filter(
        UserBaby.baby_id == baby_id
    ).all()
    
    result = []
    for user_baby, user in caregivers:
        result.append({
            "id": user.id,
            "name": user.name,
            "email": user.email,
            "role": user_baby.role,
            "created_at": user_baby.created_at.isoformat()
        })
    
    return result

@router.post("", status_code=status.HTTP_201_CREATED)
async def add_caregiver(
    baby_id: int,
    caregiver_data: dict,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Add a new caregiver to a baby (only owner can do this)"""
    # Check if user is owner
    user_baby = db.query(UserBaby).filter(
        UserBaby.user_id == current_user.id,
        UserBaby.baby_id == baby_id,
        UserBaby.role == "owner"
    ).first()
    
    if not user_baby:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the owner can add caregivers"
        )
    
    # Find user by email
    caregiver_email = caregiver_data.get("email")
    role = caregiver_data.get("role", "caregiver")
    
    caregiver = db.query(User).filter(User.email == caregiver_email).first()
    
    if not caregiver:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User with this email not found"
        )
    
    # Check if already a caregiver
    existing = db.query(UserBaby).filter(
        UserBaby.user_id == caregiver.id,
        UserBaby.baby_id == baby_id
    ).first()
    
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="This user is already a caregiver for this baby"
        )
    
    # Add caregiver
    new_user_baby = UserBaby(
        user_id=caregiver.id,
        baby_id=baby_id,
        role=role
    )
    
    db.add(new_user_baby)
    db.commit()
    
    return {
        "id": caregiver.id,
        "name": caregiver.name,
        "email": caregiver.email,
        "role": role,
        "message": "Caregiver added successfully"
    }

@router.delete("/{caregiver_id}", status_code=status.HTTP_204_NO_CONTENT)
async def remove_caregiver(
    baby_id: int,
    caregiver_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Remove a caregiver from a baby (only owner can do this)"""
    # Check if user is owner
    user_baby = db.query(UserBaby).filter(
        UserBaby.user_id == current_user.id,
        UserBaby.baby_id == baby_id,
        UserBaby.role == "owner"
    ).first()
    
    if not user_baby:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the owner can remove caregivers"
        )
    
    # Cannot remove yourself
    if caregiver_id == current_user.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="You cannot remove yourself as a caregiver"
        )
    
    # Find and delete the caregiver relationship
    caregiver_relation = db.query(UserBaby).filter(
        UserBaby.user_id == caregiver_id,
        UserBaby.baby_id == baby_id
    ).first()
    
    if not caregiver_relation:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Caregiver not found"
        )
    
    db.delete(caregiver_relation)
    db.commit()
    
    return None