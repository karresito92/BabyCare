from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from ..database import get_db
from ..models.user import User
from ..models.user_baby import UserBaby
from ..core.security import get_current_user
from ..services.insights_service import InsightsService

router = APIRouter(prefix="/babies/{baby_id}/insights", tags=["insights"])

@router.get("")
async def get_baby_insights(
    baby_id: int,
    days: int = 14,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get insights and recommendations for a baby"""
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
    
    # Generate insights
    insights_service = InsightsService(db)
    insights = insights_service.generate_insights(baby_id, days)
    
    return insights