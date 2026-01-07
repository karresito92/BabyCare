import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'terms_screen.dart';
import 'privacy_policy_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  String? _errorMessage;

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      setState(() {
        _errorMessage = 'Debes aceptar los términos y condiciones y la política de privacidad';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Las contraseñas no coinciden';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Cuenta creada exitosamente. Por favor inicia sesión.',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Error al crear la cuenta. El email podría estar en uso.';
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
                    child: Form(
                      key: _formKey,
                      child: Column(
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

                          // Logo animado
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(28),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6BA3E8)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 25,
                                        offset: const Offset(0, 12),
                                        spreadRadius: -5,
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'images/logo.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Título con gradiente
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF6BA3E8), Color(0xFF5B93D8)],
                            ).createShader(bounds),
                            child: const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1.0,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            'Únete a la familia BabyCare',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Card del formulario
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Registro',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                    letterSpacing: -0.5,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Text(
                                  'Completa tus datos para crear una cuenta',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Campo Nombre
                                _AnimatedTextField(
                                  controller: _nameController,
                                  label: 'Nombre completo',
                                  hintText: 'María González',
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu nombre';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

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

                                const SizedBox(height: 20),

                                // Campo Contraseña
                                _AnimatedTextField(
                                  controller: _passwordController,
                                  label: 'Contraseña',
                                  hintText: 'Mínimo 8 caracteres',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: _obscurePassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Por favor ingresa tu contraseña';
                                    }
                                    if (value.length < 8) {
                                      return 'Mínimo 8 caracteres';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Campo Confirmar Contraseña
                                _AnimatedTextField(
                                  controller: _confirmPasswordController,
                                  label: 'Confirmar contraseña',
                                  hintText: 'Repite tu contraseña',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                  obscureText: _obscureConfirmPassword,
                                  onToggleVisibility: () {
                                    setState(() {
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword;
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

                                // Checkbox términos y política - NUEVO con InkWell para área clickeable
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _acceptedTerms = !_acceptedTerms;
                                      if (_acceptedTerms) {
                                        _errorMessage = null;
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: _acceptedTerms,
                                            onChanged: (value) {
                                              setState(() {
                                                _acceptedTerms = value ?? false;
                                                if (_acceptedTerms) {
                                                  _errorMessage = null;
                                                }
                                              });
                                            },
                                            activeColor: const Color(0xFF6BA3E8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Wrap(
                                            children: [
                                              Text(
                                                'Acepto los ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const TermsScreen(),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  'Términos de servicio',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF6BA3E8),
                                                    fontWeight: FontWeight.w700,
                                                    decoration:
                                                        TextDecoration.underline,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                ' y la ',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const PrivacyPolicyScreen(),
                                                    ),
                                                  );
                                                },
                                                child: const Text(
                                                  'Política de privacidad',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF6BA3E8),
                                                    fontWeight: FontWeight.w700,
                                                    decoration:
                                                        TextDecoration.underline,
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

                                const SizedBox(height: 24),

                                // Mensaje de error
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: _errorMessage != null ? null : 0,
                                  child: _errorMessage != null
                                      ? Container(
                                          padding: const EdgeInsets.all(14),
                                          margin:
                                              const EdgeInsets.only(bottom: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius:
                                                BorderRadius.circular(12),
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

                                // Botón Crear cuenta
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6BA3E8),
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          Colors.grey.shade300,
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
                                            'Crear cuenta',
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
                          ),

                          const SizedBox(height: 32),

                          // Link a login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿Ya tienes una cuenta? ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
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
                      ),
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
}

// Widget personalizado para campos de texto animados
class _AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleVisibility;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleVisibility,
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
              obscureText: widget.isPassword && widget.obscureText,
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
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          widget.obscureText
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _isFocused
                              ? const Color(0xFF6BA3E8)
                              : Colors.grey.shade400,
                          size: 22,
                        ),
                        onPressed: widget.onToggleVisibility,
                      )
                    : null,
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
                fillColor:
                    _isFocused ? Colors.white : const Color(0xFFFAFAFA),
              ),
              validator: widget.validator,
            ),
          ),
        ),
      ],
    );
  }
}