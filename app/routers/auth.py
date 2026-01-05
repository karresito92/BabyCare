from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta, datetime
import secrets
from ..database import get_db
from ..models.user import User
from ..schemas.user import (
    UserCreate, UserResponse, Token, UserUpdate, PasswordChange,
    ForgotPasswordRequest, ForgotPasswordResponse,
    ResetPasswordRequest, ResetPasswordResponse
)
from ..core.security import verify_password, get_password_hash, create_access_token, get_current_user
from ..core.config import settings
from ..services.email_service import send_reset_password_email, send_password_changed_confirmation

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user: UserCreate, db: Session = Depends(get_db)):
    """Register a new user"""
    # Check if email already exists
    existing_user = db.query(User).filter(User.email == user.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user
    hashed_password = get_password_hash(user.password)
    db_user = User(
        email=user.email,
        password_hash=hashed_password,
        name=user.name
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user


@router.post("/login", response_model=Token)
async def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    """Login user and return access token"""
    user = db.query(User).filter(User.email == form_data.username).first()
    
    if not user or not verify_password(form_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    
    return {"access_token": access_token, "token_type": "bearer"}


# Get current user profile
@router.get("/users/me", response_model=UserResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user)
):
    """Get current user profile"""
    return current_user


# Update current user profile
@router.put("/users/me", response_model=UserResponse)
async def update_current_user(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update current user profile"""
    # Update name if provided
    if user_update.name:
        current_user.name = user_update.name
    
    # Update profile picture if provided
    if user_update.profile_picture is not None:
        current_user.profile_picture = user_update.profile_picture
    
    # Update email if provided and not already taken
    if user_update.email and user_update.email != current_user.email:
        existing_user = db.query(User).filter(User.email == user_update.email).first()
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
        current_user.email = user_update.email
    
    db.commit()
    db.refresh(current_user)
    
    return current_user


# Change password
@router.put("/users/me/password")
async def change_password(
    password_change: PasswordChange,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Change user password"""
    # Verify current password
    if not verify_password(password_change.current_password, current_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Current password is incorrect"
        )
    
    # Update password
    current_user.password_hash = get_password_hash(password_change.new_password)
    db.commit()
    
    return {"message": "Password changed successfully"}


# ============================================
# NUEVOS ENDPOINTS PARA RECUPERAR CONTRASEÑA
# ============================================

@router.post("/forgot-password", response_model=ForgotPasswordResponse)
async def forgot_password(
    request: ForgotPasswordRequest,
    db: Session = Depends(get_db)
):
    """
    Endpoint para solicitar recuperación de contraseña.
    Genera un token y envía un email con el link de recuperación.
    """
    # 1. Buscar usuario por email
    user = db.query(User).filter(User.email == request.email).first()
    
    # Por seguridad, siempre devolver el mismo mensaje
    # (no revelar si el email existe o no)
    response_message = "Si el correo está registrado, recibirás instrucciones para restablecer tu contraseña."
    
    if not user:
        # Email no existe, pero devolvemos éxito por seguridad
        return ForgotPasswordResponse(message=response_message)
    
    # 2. Generar token seguro (32 bytes = 43 caracteres en base64url)
    reset_token = secrets.token_urlsafe(32)
    
    # 3. Establecer expiración (1 hora desde ahora)
    expiry_time = datetime.utcnow() + timedelta(hours=1)
    
    # 4. Guardar token y expiración en la base de datos
    user.reset_token = reset_token
    user.reset_token_expiry = expiry_time
    db.commit()
    
    # 5. Enviar email
    try:
        send_reset_password_email(
            email=user.email,
            token=reset_token,
            user_name=user.name
        )
    except Exception as e:
        # Log del error pero no exponer detalles al usuario
        print(f"Error enviando email: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al enviar el correo. Intenta nuevamente más tarde."
        )
    
    return ForgotPasswordResponse(message=response_message)


@router.post("/reset-password", response_model=ResetPasswordResponse)
async def reset_password(
    request: ResetPasswordRequest,
    db: Session = Depends(get_db)
):
    """
    Endpoint para restablecer la contraseña usando el token recibido por email.
    """
    # 1. Buscar usuario por token
    user = db.query(User).filter(User.reset_token == request.token).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token inválido o expirado"
        )
    
    # 2. Verificar que el token no haya expirado
    if not user.reset_token_expiry or user.reset_token_expiry < datetime.utcnow():
        # Limpiar token expirado
        user.reset_token = None
        user.reset_token_expiry = None
        db.commit()
        
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token expirado. Solicita un nuevo enlace de recuperación."
        )
    
    # 3. Validar nueva contraseña
    if len(request.new_password) < 8:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La contraseña debe tener al menos 8 caracteres"
        )
    
    # 4. Actualizar contraseña
    user.password_hash = get_password_hash(request.new_password)
    
    # 5. Limpiar token (ya fue usado)
    user.reset_token = None
    user.reset_token_expiry = None
    
    db.commit()
    
    # 6. Enviar email de confirmación
    try:
        send_password_changed_confirmation(
            email=user.email,
            user_name=user.name
        )
    except Exception as e:
        # Log pero no fallar la operación
        print(f"Error enviando email de confirmación: {str(e)}")
    
    return ResetPasswordResponse(message="Contraseña actualizada exitosamente")