from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timedelta
from ..database import get_db
from ..models.user import User
from ..models.baby import Baby
from ..models.user_baby import UserBaby
from ..models.activity import Activity
from ..schemas.baby import BabyCreate, BabyResponse
from ..core.security import get_current_user
from ..services.pdf_generator import generate_pediatric_report

router = APIRouter(prefix="/babies", tags=["babies"])

@router.post("", response_model=BabyResponse, status_code=status.HTTP_201_CREATED)
async def create_baby(
    baby: BabyCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new baby"""
    db_baby = Baby(
        name=baby.name,
        birth_date=baby.birth_date,
        photo=baby.photo  # Ahora sí existe en BabyCreate
    )
    
    db.add(db_baby)
    db.commit()
    db.refresh(db_baby)
    
    # Associate baby with current user
    user_baby = UserBaby(
        user_id=current_user.id,
        baby_id=db_baby.id,
        role="owner"
    )
    db.add(user_baby)
    db.commit()
    
    return db_baby
@router.get("", response_model=List[BabyResponse])
async def get_my_babies(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get all babies associated with current user"""
    user_babies = db.query(UserBaby).filter(UserBaby.user_id == current_user.id).all()
    baby_ids = [ub.baby_id for ub in user_babies]
    babies = db.query(Baby).filter(Baby.id.in_(baby_ids)).all()
    
    return babies

@router.get("/{baby_id}", response_model=BabyResponse)
async def get_baby(
    baby_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get a specific baby"""
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
    
    baby = db.query(Baby).filter(Baby.id == baby_id).first()
    if not baby:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Baby not found"
        )
    
    return baby

@router.put("/{baby_id}", response_model=BabyResponse)
async def update_baby(
    baby_id: int,
    baby_update: BabyCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a baby's information"""
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
    
    baby = db.query(Baby).filter(Baby.id == baby_id).first()
    if not baby:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Baby not found"
        )
    
    baby.name = baby_update.name
    baby.birth_date = baby_update.birth_date
    if baby_update.photo:
        baby.photo = baby_update.photo
    
    db.commit()
    db.refresh(baby)
    
    return baby

@router.delete("/{baby_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_baby(
    baby_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete a baby"""
    user_baby = db.query(UserBaby).filter(
        UserBaby.user_id == current_user.id,
        UserBaby.baby_id == baby_id,
        UserBaby.role == "owner"
    ).first()
    
    if not user_baby:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only the owner can delete a baby"
        )
    
    baby = db.query(Baby).filter(Baby.id == baby_id).first()
    if not baby:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Baby not found"
        )
    
    db.delete(baby)
    db.commit()
    
    return None

@router.get("/{baby_id}/report")
async def generate_baby_report(
    baby_id: int,
    days: int = 30,
    token: str = None,  # Token opcional por URL
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Generate PDF report for baby"""
    # Check access
    user_baby = db.query(UserBaby).filter(
        UserBaby.user_id == current_user.id,
        UserBaby.baby_id == baby_id
    ).first()
    
    if not user_baby:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You don't have access to this baby"
        )
    
    # Get baby
    baby = db.query(Baby).filter(Baby.id == baby_id).first()
    if not baby:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Baby not found"
        )
    
    # Get activities
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days)
    
    activities = db.query(Activity).filter(
        Activity.baby_id == baby_id,
        Activity.timestamp >= start_date,
        Activity.timestamp <= end_date
    ).order_by(Activity.timestamp.desc()).all()
    
    # Generate PDF
    pdf_buffer = generate_pediatric_report(baby, activities, start_date, end_date)
    
    # Return PDF
    filename = f"informe_{baby.name}_{datetime.now().strftime('%Y%m%d')}.pdf"
    
    return StreamingResponse(
        pdf_buffer,
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename={filename}"}
    )
@router.put("/{baby_id}", response_model=BabyResponse)
async def update_baby(
    baby_id: int,
    baby: BabyCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update a baby"""
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
    
    # Get baby
    db_baby = db.query(Baby).filter(Baby.id == baby_id).first()
    if not db_baby:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Baby not found"
        )
    
    # Update baby
    db_baby.name = baby.name
    db_baby.birth_date = baby.birth_date
    if baby.photo is not None:
        db_baby.photo = baby.photo
    db_baby.updated_at = datetime.now(timezone.utc)
    
    db.commit()
    db.refresh(db_baby)
    
    return db_baby