import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6BA3E8).withValues(alpha: 0.05),
              const Color(0xFF5B93D8).withValues(alpha: 0.1),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      style: IconButton.styleFrom(
                        foregroundColor: const Color(0xFF6BA3E8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Política de Privacidad',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fecha de actualización
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6BA3E8).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Última actualización: Enero 2025',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF6BA3E8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Introducción
                        Text(
                          'En BabyCare, nos tomamos muy en serio la privacidad de tus datos y los de tu bebé. Esta Política de Privacidad explica cómo recopilamos, usamos, protegemos y compartimos tu información personal.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                            height: 1.7,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Contenido de política
                        _buildSection(
                          '1. Información que Recopilamos',
                          'Recopilamos diferentes tipos de información para proporcionarte nuestros servicios:\n\n'
                          '**Información de cuenta:**\n'
                          '• Nombre completo\n'
                          '• Dirección de correo electrónico\n'
                          '• Contraseña (encriptada con Argon2)\n\n'
                          '**Información del bebé:**\n'
                          '• Nombre del bebé\n'
                          '• Fecha de nacimiento\n'
                          '• Fotografías (opcional)\n'
                          '• Registros de actividades (alimentación, sueño, cambios de pañal, salud)\n\n'
                          '**Información de uso:**\n'
                          '• Datos de interacción con la aplicación\n'
                          '• Preferencias de configuración\n'
                          '• Información del dispositivo (modelo, sistema operativo)',
                        ),

                        _buildSection(
                          '2. Cómo Usamos tu Información',
                          'Utilizamos tu información personal para:\n\n'
                          '• Proporcionar y mantener nuestros servicios\n'
                          '• Crear y gestionar tu cuenta\n'
                          '• Permitir el registro y seguimiento de actividades del bebé\n'
                          '• Generar estadísticas e insights personalizados\n'
                          '• Mejorar la experiencia del usuario\n'
                          '• Enviar notificaciones importantes sobre el servicio\n'
                          '• Responder a tus consultas y proporcionar soporte técnico\n'
                          '• Cumplir con obligaciones legales',
                        ),

                        _buildSection(
                          '3. Base Legal para el Procesamiento',
                          'Procesamos tu información personal basándonos en:\n\n'
                          '• **Consentimiento:** Has aceptado que procesemos tu información\n'
                          '• **Contrato:** Necesario para proporcionar los servicios que solicitaste\n'
                          '• **Interés legítimo:** Para mejorar nuestros servicios y seguridad\n'
                          '• **Obligación legal:** Cuando sea requerido por ley',
                        ),

                        _buildSection(
                          '4. Compartir tu Información',
                          'BabyCare NO vende tu información personal a terceros.\n\n'
                          'Compartimos información solo en estas circunstancias:\n\n'
                          '**Con cuidadores autorizados:**\n'
                          '• Cuando invites a otros cuidadores a acceder a la información del bebé\n'
                          '• Los cuidadores solo verán información del bebé específico\n\n'
                          '**Proveedores de servicios:**\n'
                          '• Servicios de hosting (Render, Supabase)\n'
                          '• Servicio de email (SendGrid)\n'
                          '• Estos proveedores tienen obligaciones contractuales de proteger tus datos\n\n'
                          '**Requisitos legales:**\n'
                          '• Cuando sea requerido por ley\n'
                          '• Para proteger nuestros derechos legales\n'
                          '• En caso de emergencia que afecte la seguridad',
                        ),

                        _buildSection(
                          '5. Seguridad de los Datos',
                          'Implementamos medidas de seguridad robustas:\n\n'
                          '• **Encriptación:** Todas las contraseñas se cifran con Argon2\n'
                          '• **Conexiones seguras:** Usamos HTTPS para todas las comunicaciones\n'
                          '• **Acceso limitado:** Solo personal autorizado puede acceder a datos sensibles\n'
                          '• **Auditorías regulares:** Revisamos y actualizamos nuestras prácticas de seguridad\n'
                          '• **Copias de seguridad:** Realizamos backups regulares para prevenir pérdida de datos\n\n'
                          'Sin embargo, ningún sistema es 100% seguro. Te recomendamos usar contraseñas fuertes y únicas.',
                        ),

                        _buildSection(
                          '6. Almacenamiento y Retención de Datos',
                          '**Ubicación del almacenamiento:**\n'
                          'Tus datos se almacenan en servidores seguros proporcionados por Supabase y Render.\n\n'
                          '**Tiempo de retención:**\n'
                          '• Mantenemos tu información mientras tu cuenta esté activa\n'
                          '• Puedes solicitar la eliminación de tu cuenta en cualquier momento\n'
                          '• Tras la eliminación, conservamos algunos datos durante 30 días para permitir recuperación\n'
                          '• Después de 30 días, eliminamos permanentemente todos tus datos\n'
                          '• Algunos datos pueden conservarse más tiempo si es requerido por ley',
                        ),

                        _buildSection(
                          '7. Tus Derechos',
                          'Tienes los siguientes derechos sobre tu información personal:\n\n'
                          '**Derecho de acceso:** Puedes solicitar una copia de tus datos\n\n'
                          '**Derecho de rectificación:** Puedes corregir información inexacta\n\n'
                          '**Derecho de eliminación:** Puedes solicitar que eliminemos tus datos\n\n'
                          '**Derecho de portabilidad:** Puedes exportar tus datos en formato PDF\n\n'
                          '**Derecho de oposición:** Puedes oponerte a ciertos procesamientos\n\n'
                          '**Derecho de limitación:** Puedes solicitar que limitemos el procesamiento\n\n'
                          'Para ejercer estos derechos, contacta con nosotros en babycaretfg@gmail.com',
                        ),

                        _buildSection(
                          '8. Privacidad de Menores',
                          'BabyCare está diseñado para ser usado por adultos (mayores de 18 años) responsables del cuidado de bebés.\n\n'
                          '• No recopilamos intencionalmente información de menores de 18 años\n'
                          '• La información del bebé es proporcionada por los padres/cuidadores\n'
                          '• Los padres/cuidadores son responsables de la veracidad de la información\n'
                          '• Si descubrimos que hemos recopilado datos de un menor sin autorización, los eliminaremos',
                        ),

                        _buildSection(
                          '9. Cookies y Tecnologías Similares',
                          'Utilizamos tecnologías de almacenamiento local para:\n\n'
                          '• Mantener tu sesión iniciada\n'
                          '• Recordar tus preferencias\n'
                          '• Mejorar el rendimiento de la aplicación\n\n'
                          'Puedes controlar el almacenamiento local en la configuración de tu dispositivo.',
                        ),

                        _buildSection(
                          '10. Transferencias Internacionales',
                          'Tus datos pueden ser transferidos y procesados en países distintos al tuyo. Nos aseguramos de que:\n\n'
                          '• Existan garantías adecuadas de protección\n'
                          '• Se cumplan las regulaciones de protección de datos aplicables\n'
                          '• Los proveedores cumplan con estándares internacionales',
                        ),

                        _buildSection(
                          '11. Cambios a esta Política',
                          'Podemos actualizar esta Política de Privacidad periódicamente para reflejar:\n\n'
                          '• Cambios en nuestras prácticas\n'
                          '• Nuevas regulaciones legales\n'
                          '• Mejoras en nuestros servicios\n\n'
                          'Te notificaremos sobre cambios significativos mediante:\n'
                          '• Email a tu dirección registrada\n'
                          '• Notificación en la aplicación\n'
                          '• Actualización de la fecha en la parte superior\n\n'
                          'Te recomendamos revisar esta política periódicamente.',
                        ),

                        _buildSection(
                          '12. Cumplimiento Legal',
                          'BabyCare cumple con:\n\n'
                          '• Reglamento General de Protección de Datos (GDPR) - Unión Europea\n'
                          '• Ley Orgánica de Protección de Datos (LOPD) - España\n'
                          '• Otras regulaciones de privacidad aplicables\n\n'
                          'Nos comprometemos a mantener el cumplimiento con las leyes de protección de datos vigentes.',
                        ),

                        _buildSection(
                          '13. Contacto',
                          'Para preguntas sobre esta Política de Privacidad o sobre cómo manejamos tus datos:\n\n'
                          '**Email:** babycaretfg@gmail.com\n\n'
                          'Responderemos a todas las consultas en un plazo máximo de 48 horas.\n\n'
                          'Si no estás satisfecho con nuestra respuesta, tienes derecho a presentar una queja ante la Agencia Española de Protección de Datos (AEPD).',
                        ),

                        const SizedBox(height: 32),

                        // Disclaimer final
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                color: Colors.green.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Tu privacidad es nuestra prioridad. Nos comprometemos a proteger tus datos y los de tu bebé con los más altos estándares de seguridad.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green.shade900,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.7,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}