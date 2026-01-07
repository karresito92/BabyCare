import 'package:flutter/material.dart';
import 'dart:convert';
// ignore: deprecated_member_use
import 'dart:html' as html;
import '../../services/auth_storage.dart';
import '../../services/api_service.dart';
import '../../models/baby.dart';
import '../../models/activity.dart';
import '../activities/feeding_form_screen.dart';
import '../activities/sleep_form_screen.dart';
import '../activities/diaper_form_screen.dart';
import '../activities/health_form_screen.dart';
import '../babies/add_baby_screen.dart';
import '../babies/baby_profile_screen.dart';
import '../insights/insights_screen.dart';
import '../activities/activities_history_screen.dart';
import '../statistics/statistics_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  final int _selectedIndex = 0;

  Baby? _selectedBaby;
  List<Baby> _babies = [];
  List<Activity> _todayActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar bebés
      final babiesData = await _apiService.getMyBabies();
      _babies = babiesData.map((json) => Baby.fromJson(json)).toList();

      if (_babies.isNotEmpty) {
        _selectedBaby = _babies.first;

        // Cargar actividades de hoy
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final endOfDay = DateTime(
          today.year,
          today.month,
          today.day,
          23,
          59,
          59,
        );

        final activitiesData = await _apiService.getBabyActivities(
          babyId: _selectedBaby!.id,
          startDate: startOfDay,
          endDate: endOfDay,
        );

        _todayActivities = activitiesData
            .map((json) => Activity.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Calcular resumen del día
  int _getFeedingCount() {
    return _todayActivities.where((a) => a.type == 'feeding').length;
  }

  double _getSleepHours() {
    final sleepActivities = _todayActivities.where((a) => a.type == 'sleep');
    double total = 0;
    for (var activity in sleepActivities) {
      total += (activity.data?['duration_hours'] ?? 0).toDouble();
    }
    return total;
  }

  int _getDiaperChanges() {
    return _todayActivities.where((a) => a.type == 'diaper').length;
  }

  Activity? _getLastActivity(String type) {
    final activities = _todayActivities.where((a) => a.type == type).toList();
    if (activities.isEmpty) return null;
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return activities.first;
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        // Ya estamos en Home
        break;
      case 1:
        // Navegar a Insights
        if (_selectedBaby != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InsightsScreen(babyId: _selectedBaby!.id),
            ),
          );
        }
        break;
      case 2:
        // Navegar a Historial de actividades
        if (_selectedBaby != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ActivitiesHistoryScreen(babyId: _selectedBaby!.id),
            ),
          ).then((_) {
            // Al volver del historial, recargar datos
            _loadData();
          });
        }
        break;
      case 3:
        // Navegar a Estadísticas
        if (_selectedBaby != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StatisticsScreen(babyId: _selectedBaby!.id),
            ),
          );
        }
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  Future<void> _logout() async {
    final authStorage = AuthStorage();
    await authStorage.deleteToken();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _generatePdfReport() async {
    if (_selectedBaby == null) return;

    // Mostrar diálogo de selección de período con diseño mejorado
    final period = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Generar Informe PDF',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecciona el período del informe:',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            _buildPeriodOption(context, 7, 'Última semana (7 días)'),
            const SizedBox(height: 12),
            _buildPeriodOption(context, 30, 'Último mes (30 días)'),
            const SizedBox(height: 12),
            _buildPeriodOption(context, 90, 'Últimos 3 meses (90 días)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (period == null) return;

    // Mostrar loading
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Generando informe PDF...'),
            ],
          ),
          backgroundColor: const Color(0xFF6BA3E8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    try {
      // Obtener token
      final token = await AuthStorage().getToken();
      
      // Construir URL del PDF con token
      final url = '${ApiService.baseUrl}/babies/${_selectedBaby!.id}/report?days=$period&token=$token';
      
      // Abrir PDF en nueva pestaña
      // ignore: avoid_web_libraries_in_flutter
      html.window.open(url, '_blank');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Abriendo informe PDF...'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Widget _buildPeriodOption(BuildContext context, int days, String text) {
    return InkWell(
      onTap: () => Navigator.pop(context, days),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF6BA3E8),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToActivityForm(Widget screen) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    // Si se guardó una actividad, recargar datos
    if (result == true) {
      _loadData();
    }
  }

  Future<void> _addBaby() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddBabyScreen()),
    );

    if (result == true) {
      _loadData();
    }
  }

  Widget _buildBabyAvatar() {
    if (_selectedBaby?.photo != null && _selectedBaby!.photo!.isNotEmpty) {
      try {
        final imageData = _selectedBaby!.photo!.split(',').last;
        return Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: MemoryImage(base64Decode(imageData)),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        );
      } catch (e) {
        print('Error loading baby avatar: $e');
      }
    }
    
    // Avatar por defecto
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.child_care,
        color: Colors.white,
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF6BA3E8)),
          ),
        ),
      );
    }

    // Si no hay bebés, mostrar pantalla para añadir
    if (_babies.isEmpty) {
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
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icono animado
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF6BA3E8).withValues(alpha: 0.2),
                                  const Color(0xFF5B93D8).withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6BA3E8).withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.child_care,
                              size: 60,
                              color: Color(0xFF6BA3E8),
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
                        '¡Bienvenido a BabyCare!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Para empezar, añade tu primer bebé',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Botón añadir bebé
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _addBaby,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6BA3E8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Añadir bebé',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botón cerrar sesión
                    TextButton(
                      onPressed: _logout,
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6BA3E8),
                      ),
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

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
              // Header con información del bebé (diseño mejorado)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6BA3E8), Color(0xFF5B93D8)],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6BA3E8).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Row(
                    children: [
                      // Avatar y nombre del bebé (clickeable)
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BabyProfileScreen(babyId: _selectedBaby!.id),
                              ),
                            ).then((_) => _loadData());
                          },
                          child: Row(
                            children: [
                              // Avatar del bebé
                              _buildBabyAvatar(),
                              const SizedBox(width: 16),
                              // Información del bebé
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedBaby!.name,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.cake_outlined,
                                          color: Colors.white.withValues(alpha: 0.9),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _selectedBaby!.getAgeFormatted(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white.withValues(alpha: 0.9),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Icono visual de que es clickeable
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white.withValues(alpha: 0.7),
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón generar PDF
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _generatePdfReport,
                          icon: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          tooltip: 'Generar informe PDF',
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón de logout
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _logout,
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          tooltip: 'Cerrar sesión',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido scrollable
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFF6BA3E8),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título "Resumen de hoy"
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFF6BA3E8), Color(0xFF5B93D8)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Resumen de hoy',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Grid 2x2 del resumen (diseño mejorado)
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.4,
                          children: [
                            _buildSummaryCard(
                              icon: Icons.restaurant_rounded,
                              iconColor: const Color(0xFF6BA3E8),
                              iconBgColor: const Color(0xFF6BA3E8).withValues(alpha: 0.12),
                              title: 'Alimentación',
                              value: '${_getFeedingCount()} veces',
                            ),
                            _buildSummaryCard(
                              icon: Icons.bedtime_rounded,
                              iconColor: const Color(0xFF9C27B0),
                              iconBgColor: const Color(0xFF9C27B0).withValues(alpha: 0.12),
                              title: 'Sueño',
                              value: '${_getSleepHours().toStringAsFixed(1)} hrs',
                            ),
                            _buildSummaryCard(
                              icon: Icons.baby_changing_station_rounded,
                              iconColor: const Color(0xFF4CAF50),
                              iconBgColor: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                              title: 'Pañales',
                              value: '${_getDiaperChanges()} cambios',
                            ),
                            _buildSummaryCard(
                              icon: Icons.calendar_today_rounded,
                              iconColor: const Color(0xFFFF5252),
                              iconBgColor: const Color(0xFFFF5252).withValues(alpha: 0.12),
                              title: 'Total',
                              value: '${_todayActivities.length} registros',
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Título "Acciones rápidas"
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Color(0xFF6BA3E8), Color(0xFF5B93D8)],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Acciones rápidas',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Grid 2x2 de acciones rápidas (diseño mejorado)
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 1.1,
                          children: [
                            _buildQuickActionCard(
                              icon: Icons.restaurant_rounded,
                              iconColor: const Color(0xFF6BA3E8),
                              iconBgColor: const Color(0xFF6BA3E8).withValues(alpha: 0.12),
                              title: 'Alimentación',
                              subtitle:
                                  _getLastActivity('feeding')?.getTimeAgo() ??
                                  'Sin registros',
                              onTap: () => _navigateToActivityForm(
                                FeedingFormScreen(babyId: _selectedBaby!.id),
                              ),
                            ),
                            _buildQuickActionCard(
                              icon: Icons.bedtime_rounded,
                              iconColor: const Color(0xFF9C27B0),
                              iconBgColor: const Color(0xFF9C27B0).withValues(alpha: 0.12),
                              title: 'Sueño',
                              subtitle:
                                  _getLastActivity('sleep')?.getTimeAgo() ??
                                  'Sin registros',
                              onTap: () => _navigateToActivityForm(
                                SleepFormScreen(babyId: _selectedBaby!.id),
                              ),
                            ),
                            _buildQuickActionCard(
                              icon: Icons.baby_changing_station_rounded,
                              iconColor: const Color(0xFF4CAF50),
                              iconBgColor: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                              title: 'Pañal',
                              subtitle:
                                  _getLastActivity('diaper')?.getTimeAgo() ??
                                  'Sin registros',
                              onTap: () => _navigateToActivityForm(
                                DiaperFormScreen(babyId: _selectedBaby!.id),
                              ),
                            ),
                            _buildQuickActionCard(
                              icon: Icons.favorite_rounded,
                              iconColor: const Color(0xFFFF5252),
                              iconBgColor: const Color(0xFFFF5252).withValues(alpha: 0.12),
                              title: 'Salud',
                              subtitle:
                                  _getLastActivity('health')?.getTimeAgo() ??
                                  'Sin registros',
                              onTap: () => _navigateToActivityForm(
                                HealthFormScreen(babyId: _selectedBaby!.id),
                              ),
                            ),
                          ],
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

      // Bottom Navigation (diseño mejorado)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color(0xFF6BA3E8),
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.lightbulb_outline_rounded),
                activeIcon: Icon(Icons.lightbulb_rounded),
                label: 'Insights',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined),
                activeIcon: Icon(Icons.list_alt_rounded),
                label: 'Actividad',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart_rounded),
                label: 'Estadísticas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}