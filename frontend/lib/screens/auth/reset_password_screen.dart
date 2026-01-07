import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _passwordReset = false;

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
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.resetPassword(
        token: _tokenController.text.trim(),
        newPassword: _passwordController.text,
      );

      setState(() {
        _passwordReset = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
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
                        // Botón volver (solo si no se ha reseteado)
                        if (!_passwordReset)
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
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _passwordReset
                                        ? [
                                            const Color(0xFF4CAF50),
                                            const Color(0xFF45a049)
                                          ]
                                        : [
                                            const Color(0xFF6BA3E8),
                                            const Color(0xFF5B93D8)
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_passwordReset
                                              ? const Color(0xFF4CAF50)
                                              : const Color(0xFF6BA3E8))
                                          .withValues(alpha: 0.4),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12),
                                      spreadRadius: -5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  _passwordReset
                                      ? Icons.check_circle_outline
                                      : Icons.vpn_key,
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
                          shaderCallback: (bounds) => LinearGradient(
                            colors: _passwordReset
                                ? [
                                    const Color(0xFF4CAF50),
                                    const Color(0xFF45a049)
                                  ]
                                : [
                                    const Color(0xFF6BA3E8),
                                    const Color(0xFF5B93D8)
                                  ],
                          ).createShader(bounds),
                          child: Text(
                            _passwordReset
                                ? '¡Contraseña actualizada!'
                                : 'Restablecer contraseña',
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
                          _passwordReset
                              ? 'Tu contraseña ha sido actualizada exitosamente. Ya puedes iniciar sesión con tu nueva contraseña.'
                              : 'Ingresa el código que recibiste por email y tu nueva contraseña.',
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
                          child: _passwordReset
                              ? _buildSuccessContent()
                              : _buildFormContent(),
                        ),
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
          // Campo Código
          _AnimatedTextField(
            controller: _tokenController,
            label: 'Código de recuperación',
            hintText: 'Ingresa el código del email',
            icon: Icons.password,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el código';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Campo Nueva Contraseña
          _AnimatedPasswordField(
            controller: _passwordController,
            label: 'Nueva contraseña',
            hintText: 'Mínimo 8 caracteres',
            isVisible: _passwordVisible,
            onToggleVisibility: () {
              setState(() {
                _passwordVisible = !_passwordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu nueva contraseña';
              }
              if (value.length < 8) {
                return 'La contraseña debe tener al menos 8 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Campo Confirmar Contraseña
          _AnimatedPasswordField(
            controller: _confirmPasswordController,
            label: 'Confirmar contraseña',
            hintText: 'Repite tu nueva contraseña',
            isVisible: _confirmPasswordVisible,
            onToggleVisibility: () {
              setState(() {
                _confirmPasswordVisible = !_confirmPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
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

          // Botón Restablecer
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
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
                      'Restablecer contraseña',
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
            Icons.check_circle,
            size: 40,
            color: Colors.green.shade600,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          '¡Todo listo!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Tu contraseña ha sido actualizada correctamente',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 32),

        // Botón ir al login
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Ir a iniciar sesión',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
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

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.validator,
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

// Widget personalizado para campos de contraseña
class _AnimatedPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;

  const _AnimatedPasswordField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.isVisible,
    required this.onToggleVisibility,
    this.validator,
  });

  @override
  State<_AnimatedPasswordField> createState() => _AnimatedPasswordFieldState();
}

class _AnimatedPasswordFieldState extends State<_AnimatedPasswordField> {
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
              obscureText: !widget.isVisible,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: _isFocused
                      ? const Color(0xFF6BA3E8)
                      : Colors.grey.shade400,
                  size: 22,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    widget.isVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                  onPressed: widget.onToggleVisibility,
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