import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _emailSent = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔵 Enviando petición a: https://babycare-8hlu.onrender.com/auth/forgot-password');
      print('🔵 Email: ${_emailController.text.trim()}');
      
      await _apiService.forgotPassword(email: _emailController.text.trim());
      
      print('✅ Petición exitosa');
      
      setState(() {
        _emailSent = true;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        _errorMessage = 'Error al enviar el correo. Verifica tu email e intenta de nuevo.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 440),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Botón volver
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF6BA3E8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Ícono animado
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.8, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6BA3E8),
                                      Color(0xFF5B93D8)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6BA3E8)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12),
                                      spreadRadius: -5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _emailSent
                                      ? Icons.check_circle_outline
                                      : Icons.lock_reset,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Título
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF6BA3E8), Color(0xFF5B93D8)],
                          ).createShader(bounds),
                          child: Text(
                            _emailSent
                                ? '¡Correo enviado!'
                                : '¿Olvidaste tu contraseña?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1.0,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Text(
                          _emailSent
                              ? 'Te hemos enviado un correo con instrucciones para restablecer tu contraseña.'
                              : 'Ingresa tu correo electrónico y te enviaremos instrucciones para restablecer tu contraseña.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 48),

                        // Card del formulario o mensaje de éxito
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: _emailSent
                              ? _buildSuccessContent()
                              : _buildFormContent(),
                        ),

                        if (!_emailSent) ...[
                          const SizedBox(height: 24),

                          // Link volver al login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿Recordaste tu contraseña? ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Inicia sesión',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF6BA3E8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo Email
          _AnimatedTextField(
            controller: _emailController,
            label: 'Correo electrónico',
            hintText: 'tu@email.com',
            icon: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              if (!value.contains('@')) {
                return 'Email inválido';
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Mensaje de error
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _errorMessage != null ? null : 0,
            child: _errorMessage != null
                ? Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Botón Enviar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BA3E8),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Enviar instrucciones',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      children: [
        // Icono de éxito
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 40,
            color: Colors.green.shade600,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Revisa tu bandeja de entrada',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          _emailController.text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6BA3E8),
          ),
        ),

        const SizedBox(height: 32),

        // Botón para ir a resetear contraseña
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ResetPasswordScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6BA3E8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Tengo el código, restablecer ahora',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Botón volver al login
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6BA3E8),
            side: const BorderSide(color: Color(0xFF6BA3E8), width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: const Text(
            'Volver al inicio de sesión',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Botón reenviar
        TextButton(
          onPressed: () {
            setState(() {
              _emailSent = false;
              _emailController.clear();
            });
          },
          child: const Text(
            '¿No recibiste el correo? Reenviar',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6BA3E8),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget personalizado para campos de texto animados
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.validator,
    this.keyboardType,
  });

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 10),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color:
                            const Color(0xFF6BA3E8).withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  widget.icon,
                  color: _isFocused
                      ? const Color(0xFF6BA3E8)
                      : Colors.grey.shade400,
                  size: 22,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF6BA3E8),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                filled: true,
                fillColor: _isFocused ? Colors.white : const Color(0xFFFAFAFA),
              ),
              validator: widget.validator,
            ),
          ),
        ),
      ],
    );
  }
}