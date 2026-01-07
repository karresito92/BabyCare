import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
                      'Términos y Condiciones',
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

                        // Contenido de términos
                        _buildSection(
                          '1. Aceptación de los Términos',
                          'Al acceder y utilizar BabyCare, aceptas estar sujeto a estos Términos y Condiciones de Uso. Si no estás de acuerdo con alguna parte de estos términos, no debes utilizar nuestra aplicación.',
                        ),

                        _buildSection(
                          '2. Descripción del Servicio',
                          'BabyCare es una aplicación móvil diseñada para ayudar a padres y cuidadores a llevar un registro del cuidado infantil, incluyendo alimentación, sueño, cambios de pañal y salud del bebé. El servicio se proporciona "tal cual" y puede ser modificado o discontinuado en cualquier momento.',
                        ),

                        _buildSection(
                          '3. Registro y Cuenta de Usuario',
                          'Para utilizar BabyCare, debes:\n\n'
                          '• Proporcionar información precisa y completa durante el registro\n'
                          '• Mantener la seguridad de tu contraseña\n'
                          '• Ser mayor de 18 años o tener el consentimiento de un tutor legal\n'
                          '• Notificarnos inmediatamente sobre cualquier uso no autorizado de tu cuenta\n\n'
                          'Eres responsable de todas las actividades que ocurran bajo tu cuenta.',
                        ),

                        _buildSection(
                          '4. Privacidad y Protección de Datos',
                          'La recopilación y uso de tu información personal se rige por nuestra Política de Privacidad. Al utilizar BabyCare, consientes la recopilación y uso de información de acuerdo con dicha política.\n\n'
                          'Nos comprometemos a:\n'
                          '• Proteger la información sensible de tu bebé\n'
                          '• No compartir datos personales con terceros sin tu consentimiento\n'
                          '• Cumplir con las regulaciones de protección de datos aplicables',
                        ),

                        _buildSection(
                          '5. Uso Apropiado',
                          'Te comprometes a:\n\n'
                          '• Utilizar la aplicación solo para fines legales y apropiados\n'
                          '• No intentar acceder sin autorización a otras cuentas\n'
                          '• No cargar contenido ofensivo, ilegal o inapropiado\n'
                          '• No interferir con el funcionamiento normal de la aplicación\n'
                          '• No usar la aplicación para spam o actividades maliciosas',
                        ),

                        _buildSection(
                          '6. Contenido del Usuario',
                          'Conservas todos los derechos sobre el contenido que subas a BabyCare (fotos, notas, registros). Sin embargo, nos otorgas una licencia limitada para almacenar y procesar este contenido con el fin de proporcionar el servicio.\n\n'
                          'Puedes eliminar tu contenido en cualquier momento desde la configuración de la aplicación.',
                        ),

                        _buildSection(
                          '7. Limitación de Responsabilidad',
                          'BabyCare es una herramienta de registro y organización. NO proporciona asesoramiento médico profesional.\n\n'
                          'Importante:\n'
                          '• No sustituimos la opinión de profesionales de la salud\n'
                          '• Las decisiones médicas deben consultarse con un pediatra\n'
                          '• No somos responsables por decisiones tomadas basadas únicamente en la información de la app\n'
                          '• En caso de emergencia médica, contacta inmediatamente con servicios de salud',
                        ),

                        _buildSection(
                          '8. Modificaciones del Servicio',
                          'Nos reservamos el derecho de:\n\n'
                          '• Modificar o discontinuar características de la aplicación\n'
                          '• Actualizar estos términos y condiciones\n'
                          '• Cambiar los planes de precios (si aplica)\n\n'
                          'Te notificaremos sobre cambios significativos con antelación razonable.',
                        ),

                        _buildSection(
                          '9. Terminación de Cuenta',
                          'Puedes cancelar tu cuenta en cualquier momento desde la configuración de la aplicación.\n\n'
                          'Nos reservamos el derecho de suspender o terminar cuentas que:\n'
                          '• Violen estos términos y condiciones\n'
                          '• Participen en actividades fraudulentas\n'
                          '• Abusen del servicio de manera que perjudique a otros usuarios',
                        ),

                        _buildSection(
                          '10. Propiedad Intelectual',
                          'Todo el contenido, características y funcionalidad de BabyCare (incluyendo pero no limitado a diseño, texto, gráficos, logos) son propiedad exclusiva de BabyCare y están protegidos por leyes de derechos de autor y propiedad intelectual.',
                        ),

                        _buildSection(
                          '11. Contacto',
                          'Para preguntas sobre estos términos y condiciones, puedes contactarnos a través de:\n\n'
                          'Email: babycaretfg@gmail.com\n'
                          'Nos esforzamos por responder a todas las consultas en un plazo de 48 horas.',
                        ),

                        const SizedBox(height: 32),

                        // Disclaimer final
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Al utilizar BabyCare, confirmas que has leído, entendido y aceptado estos Términos y Condiciones.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade900,
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