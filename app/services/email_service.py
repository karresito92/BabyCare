import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.utils import formataddr
import os
from dotenv import load_dotenv

# Cargar variables de entorno
load_dotenv()

# Configuración de email desde variables de entorno
SMTP_HOST = os.getenv("SMTP_HOST")
SMTP_PORT = int(os.getenv("SMTP_PORT", 587))
SMTP_USER = os.getenv("SMTP_USER")
SMTP_PASSWORD = os.getenv("SMTP_PASSWORD")
SMTP_FROM = os.getenv("SMTP_FROM")
SMTP_FROM_NAME = os.getenv("SMTP_FROM_NAME", "BabyCare")


def send_reset_password_email(email: str, token: str, user_name: str = None):
    """
    Envía un email con el código para restablecer la contraseña
    """
    # Crear mensaje
    message = MIMEMultipart("alternative")
    message["From"] = formataddr((SMTP_FROM_NAME, SMTP_FROM))
    message["To"] = email
    message["Subject"] = "Recupera tu contraseña - BabyCare"
    
    # Versión texto plano
    text_body = f"""
Hola{' ' + user_name if user_name else ''},

Has solicitado restablecer tu contraseña en BabyCare.

Tu código de recuperación es:

{token}

Copia este código e ingrésalo en la aplicación para restablecer tu contraseña.

Este código expirará en 1 hora.

Si no solicitaste esto, puedes ignorar este correo de forma segura.

Saludos,
El equipo de BabyCare
    """
    
    # Versión HTML (más bonita)
    html_body = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
    <div style="max-width: 600px; margin: 0 auto; padding: 40px 20px;">
        <!-- Logo y header -->
        <div style="text-align: center; margin-bottom: 40px;">
            <div style="width: 80px; height: 80px; background: linear-gradient(135deg, #6BA3E8 0%, #5B93D8 100%); border-radius: 20px; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center;">
                <span style="font-size: 40px;">👶</span>
            </div>
            <h1 style="margin: 0; color: #6BA3E8; font-size: 28px; font-weight: 800;">BabyCare</h1>
        </div>
        
        <!-- Contenido principal -->
        <div style="background: white; border-radius: 16px; padding: 40px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">
            <h2 style="margin: 0 0 20px; color: #1A1A1A; font-size: 24px; font-weight: 700;">
                Recupera tu contraseña
            </h2>
            
            <p style="margin: 0 0 20px; color: #666; font-size: 16px; line-height: 1.6;">
                Hola{' ' + user_name if user_name else ''},
            </p>
            
            <p style="margin: 0 0 30px; color: #666; font-size: 16px; line-height: 1.6;">
                Has solicitado restablecer tu contraseña en BabyCare. Copia el siguiente código e ingrésalo en la aplicación:
            </p>
            
            <!-- Código de recuperación -->
            <div style="text-align: center; margin: 40px 0;">
                <div style="display: inline-block; padding: 20px 40px; background: #f5f5f5; border: 2px dashed #6BA3E8; border-radius: 12px;">
                    <p style="margin: 0; font-size: 24px; font-weight: 700; color: #6BA3E8; letter-spacing: 2px; font-family: monospace;">
                        {token}
                    </p>
                </div>
            </div>
            
            <p style="margin: 30px 0 0; color: #999; font-size: 14px; line-height: 1.6;">
                Este código expirará en <strong>1 hora</strong> por razones de seguridad.
            </p>
            
            <p style="margin: 20px 0 0; color: #999; font-size: 14px; line-height: 1.6;">
                Si no solicitaste restablecer tu contraseña, puedes ignorar este correo de forma segura.
            </p>
        </div>
        
        <!-- Footer -->
        <div style="text-align: center; margin-top: 40px; color: #999; font-size: 13px;">
            <p style="margin: 0 0 10px;">
                © 2025 BabyCare. Todos los derechos reservados.
            </p>
            <p style="margin: 0;">
                Cuidado infantil inteligente
            </p>
        </div>
    </div>
</body>
</html>
    """
    
    # Adjuntar ambas versiones
    part1 = MIMEText(text_body, "plain", "utf-8")
    part2 = MIMEText(html_body, "html", "utf-8")
    message.attach(part1)
    message.attach(part2)
    
    # Enviar email
    try:
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
            server.starttls()  # Seguridad TLS
            server.login(SMTP_USER, SMTP_PASSWORD)
            server.send_message(message)
        return True
    except Exception as e:
        print(f"Error al enviar email: {str(e)}")
        raise Exception(f"Error al enviar email: {str(e)}")


def send_password_changed_confirmation(email: str, user_name: str = None):
    """
    Envía un email de confirmación cuando la contraseña fue cambiada exitosamente
    """
    message = MIMEMultipart("alternative")
    message["From"] = formataddr((SMTP_FROM_NAME, SMTP_FROM))
    message["To"] = email
    message["Subject"] = "Tu contraseña ha sido cambiada - BabyCare"
    
    text_body = f"""
Hola{' ' + user_name if user_name else ''},

Tu contraseña de BabyCare ha sido cambiada exitosamente.

Si no realizaste este cambio, por favor contacta con nuestro soporte inmediatamente.

Saludos,
El equipo de BabyCare
    """
    
    html_body = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
    <div style="max-width: 600px; margin: 0 auto; padding: 40px 20px;">
        <div style="text-align: center; margin-bottom: 40px;">
            <div style="width: 80px; height: 80px; background: linear-gradient(135deg, #4CAF50 0%, #45a049 100%); border-radius: 20px; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center;">
                <span style="font-size: 40px;">✓</span>
            </div>
            <h1 style="margin: 0; color: #4CAF50; font-size: 28px; font-weight: 800;">Contraseña actualizada</h1>
        </div>
        
        <div style="background: white; border-radius: 16px; padding: 40px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);">
            <p style="margin: 0 0 20px; color: #666; font-size: 16px; line-height: 1.6;">
                Hola{' ' + user_name if user_name else ''},
            </p>
            
            <p style="margin: 0 0 20px; color: #666; font-size: 16px; line-height: 1.6;">
                Tu contraseña de BabyCare ha sido cambiada exitosamente.
            </p>
            
            <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 16px; margin: 20px 0; border-radius: 4px;">
                <p style="margin: 0; color: #856404; font-size: 14px;">
                    <strong>⚠️ Nota de seguridad:</strong> Si no realizaste este cambio, por favor contacta con nuestro soporte inmediatamente.
                </p>
            </div>
        </div>
        
        <div style="text-align: center; margin-top: 40px; color: #999; font-size: 13px;">
            <p style="margin: 0;">© 2025 BabyCare. Todos los derechos reservados.</p>
        </div>
    </div>
</body>
</html>
    """
    
    part1 = MIMEText(text_body, "plain", "utf-8")
    part2 = MIMEText(html_body, "html", "utf-8")
    message.attach(part1)
    message.attach(part2)
    
    try:
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
            server.starttls()
            server.login(SMTP_USER, SMTP_PASSWORD)
            server.send_message(message)
        return True
    except Exception as e:
        print(f"Error al enviar email: {str(e)}")
        raise Exception(f"Error al enviar email: {str(e)}")