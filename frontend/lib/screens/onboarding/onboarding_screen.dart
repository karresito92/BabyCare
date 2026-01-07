import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: Icons.child_care,
      title: '¡Bienvenido a BabyCare!',
      description:
          'La app completa para el cuidado de tu bebé. Registra alimentación, sueño, cambios de pañal y más.',
      color: const Color(0xFF6BA3E8),
      useCustomLogo: true,
    ),
    OnboardingPage(
      image: Icons.insights,
      title: 'Insights inteligentes',
      description:
          'Obtén patrones y recomendaciones personalizadas basadas en Machine Learning para el cuidado de tu bebé.',
      color: const Color(0xFF9C27B0),
      useCustomLogo: false,
    ),
    OnboardingPage(
      image: Icons.bar_chart,
      title: 'Estadísticas y reportes',
      description:
          'Visualiza el progreso de tu bebé con gráficas detalladas y genera informes PDF para compartir con el pediatra.',
      color: const Color(0xFF4CAF50),
      useCustomLogo: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _fadeController.reset();
    _fadeController.forward();
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
              _pages[_currentPage].color.withValues(alpha: 0.05),
              _pages[_currentPage].color.withValues(alpha: 0.1),
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Botón Skip con estilo mejorado
              if (_currentPage < _pages.length - 1)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextButton(
                      onPressed: _completeOnboarding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Saltar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _pages[_currentPage].color,
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 64),

              // PageView con animación
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildPage(_pages[index]),
                    );
                  },
                ),
              ),

              // Indicadores de página mejorados
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildPageIndicator(index),
                  ),
                ),
              ),

              // Botón siguiente/comenzar con estilo del login
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage < _pages.length - 1
                              ? 'Siguiente'
                              : 'Comenzar',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage < _pages.length - 1
                              ? Icons.arrow_forward_rounded
                              : Icons.check_circle_outline_rounded,
                          size: 20,
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

  Widget _buildPage(OnboardingPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Logo/Ícono con animación y diseño mejorado
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: page.color.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                        spreadRadius: -5,
                      ),
                    ],
                  ),
                  child: page.useCustomLogo
                      ? Padding(
                          padding: const EdgeInsets.all(40),
                          child: Image.asset(
                            'images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        )
                      : Icon(
                          page.image,
                          size: 100,
                          color: page.color,
                        ),
                ),
              );
            },
          ),

          const SizedBox(height: 60),

          // Título con gradiente (igual que el login)
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                page.color,
                page.color.withValues(alpha: 0.8),
              ],
            ).createShader(bounds),
            child: Text(
              page.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Descripción en un card con glassmorphism
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Text(
              page.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: isActive ? 12 : 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? _pages[_currentPage].color
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: _pages[_currentPage].color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
    );
  }
}

class OnboardingPage {
  final IconData image;
  final String title;
  final String description;
  final Color color;
  final bool useCustomLogo;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
    this.useCustomLogo = false,
  });
}