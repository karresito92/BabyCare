import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class InsightsScreen extends StatefulWidget {
  final int babyId;

  const InsightsScreen({super.key, required this.babyId});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final _apiService = ApiService();

  Map<String, dynamic>? _insights;
  bool _isLoading = true;
  int _selectedDays = 14;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final insights = await _apiService.getBabyInsights(
        babyId: widget.babyId,
        days: _selectedDays,
      );

      setState(() {
        _insights = insights;
      });
    } catch (e) {
      print('Error loading insights: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar insights: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePeriod() async {
    final period = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Período de análisis'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Última semana (7 días)'),
              leading: Radio<int>(
                value: 7,
                groupValue: _selectedDays,
                onChanged: (value) => Navigator.pop(context, value),
                activeColor: const Color(0xFF6BA3E8),
              ),
              onTap: () => Navigator.pop(context, 7),
            ),
            ListTile(
              title: const Text('Últimas 2 semanas (14 días)'),
              leading: Radio<int>(
                value: 14,
                groupValue: _selectedDays,
                onChanged: (value) => Navigator.pop(context, value),
                activeColor: const Color(0xFF6BA3E8),
              ),
              onTap: () => Navigator.pop(context, 14),
            ),
            ListTile(
              title: const Text('Último mes (30 días)'),
              leading: Radio<int>(
                value: 30,
                groupValue: _selectedDays,
                onChanged: (value) => Navigator.pop(context, value),
                activeColor: const Color(0xFF6BA3E8),
              ),
              onTap: () => Navigator.pop(context, 30),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (period != null && period != _selectedDays) {
      setState(() {
        _selectedDays = period;
      });
      _loadInsights();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Insights y Recomendaciones'),
          backgroundColor: const Color(0xFF6BA3E8),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6BA3E8)),
        ),
      );
    }

    if (_insights == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Insights y Recomendaciones'),
          backgroundColor: const Color(0xFF6BA3E8),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Error al cargar insights'),
        ),
      );
    }

    final alerts = _insights!['alerts'] as List<dynamic>? ?? [];
    final insights = _insights!['insights'] as List<dynamic>? ?? [];
    final recommendations = _insights!['recommendations'] as List<dynamic>? ?? [];
    final mlInsights = _insights!['ml_insights'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Insights y Recomendaciones'),
        backgroundColor: const Color(0xFF6BA3E8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _changePeriod,
            icon: const Icon(Icons.date_range),
            tooltip: 'Cambiar período',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadInsights,
        color: const Color(0xFF6BA3E8),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Período actual
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6BA3E8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6BA3E8).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF6BA3E8)),
                    const SizedBox(width: 12),
                    Text(
                      'Análisis de los últimos $_selectedDays días',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ML Insights (NUEVO - Prioritario)
              if (mlInsights.isNotEmpty) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6BA3E8), Color(0xFF9C27B0)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Predicciones ML',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Inteligencia Artificial',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...mlInsights.map((insight) => _buildMLInsightCard(insight)),
                const SizedBox(height: 24),
              ],

              // Alertas
              if (alerts.isNotEmpty) ...[
                const Text(
                  '⚠️ Alertas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                ...alerts.map((alert) => _buildAlertCard(alert)),
                const SizedBox(height: 24),
              ],

              // Insights
              if (insights.isNotEmpty) ...[
                const Text(
                  '📊 Análisis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                ...insights.map((insight) => _buildInsightCard(insight)),
                const SizedBox(height: 24),
              ],

              // Recomendaciones
              if (recommendations.isNotEmpty) ...[
                const Text(
                  '💡 Recomendaciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 12),
                ...recommendations.map((rec) => _buildRecommendationCard(rec)),
              ],

              // Si no hay datos
              if (alerts.isEmpty && insights.isEmpty && recommendations.isEmpty && mlInsights.isEmpty) ...[
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Icon(
                        Icons.insights,
                        size: 80,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay suficientes datos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Registra más actividades para obtener\ninformación y recomendaciones personalizadas',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMLInsightCard(Map<String, dynamic> insight) {
    Color borderColor;
    Color bgColor;
    IconData icon;

    switch (insight['type']) {
      case 'ml_alert':
        borderColor = Colors.orange;
        bgColor = Colors.orange.shade50;
        icon = Icons.notifications_active;
        break;
      case 'ml_warning':
        borderColor = Colors.deepOrange;
        bgColor = Colors.deepOrange.shade50;
        icon = Icons.warning_amber_rounded;
        break;
      case 'ml_classification':
        borderColor = const Color(0xFF9C27B0);
        bgColor = const Color(0xFF9C27B0).withOpacity(0.1);
        icon = Icons.analytics;
        break;
      case 'ml_prediction':
        borderColor = const Color(0xFF6BA3E8);
        bgColor = const Color(0xFF6BA3E8).withOpacity(0.1);
        icon = Icons.query_stats;
        break;
      default:
        borderColor = const Color(0xFF6BA3E8);
        bgColor = const Color(0xFF6BA3E8).withOpacity(0.1);
        icon = Icons.smart_toy;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header con gradiente
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgColor, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: borderColor.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: borderColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight['message'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Datos técnicos del ML (si existen)
          if (insight['ml_data'] != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: _buildMLDataDetails(insight['ml_data']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMLDataDetails(Map<String, dynamic> mlData) {
    List<Widget> details = [];

    if (mlData['confidence'] != null) {
      details.add(_buildDetailRow(
        'Confianza',
        '${mlData['confidence']}%',
        Icons.verified,
      ));
    }

    if (mlData['score'] != null) {
      details.add(_buildDetailRow(
        'Puntuación',
        '${mlData['score']}/100',
        Icons.star,
      ));
    }

    if (mlData['avg_interval_hours'] != null) {
      details.add(_buildDetailRow(
        'Intervalo promedio',
        '${mlData['avg_interval_hours']} horas',
        Icons.schedule,
      ));
    }

    if (mlData['sleep_per_day_hours'] != null) {
      details.add(_buildDetailRow(
        'Sueño diario',
        '${mlData['sleep_per_day_hours']} horas',
        Icons.bedtime,
      ));
    }

    if (mlData['anomalies_detected'] != null) {
      details.add(_buildDetailRow(
        'Anomalías',
        '${mlData['anomalies_detected']} detectadas',
        Icons.warning_amber,
      ));
    }

    if (details.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              'Detalles del análisis ML:',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...details,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert['message'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(Map<String, dynamic> insight) {
    IconData icon;
    Color iconColor;

    switch (insight['icon']) {
      case 'restaurant':
        icon = Icons.restaurant;
        iconColor = const Color(0xFF6BA3E8);
        break;
      case 'bedtime':
        icon = Icons.bedtime;
        iconColor = const Color(0xFF9C27B0);
        break;
      case 'baby_changing_station':
        icon = Icons.baby_changing_station;
        iconColor = const Color(0xFF4CAF50);
        break;
      case 'trending_up':
        icon = Icons.trending_up;
        iconColor = Colors.green;
        break;
      case 'trending_down':
        icon = Icons.trending_down;
        iconColor = Colors.red;
        break;
      default:
        icon = Icons.info;
        iconColor = const Color(0xFF6BA3E8);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight['message'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6BA3E8).withOpacity(0.1),
            const Color(0xFF9C27B0).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6BA3E8).withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.lightbulb,
              color: Colors.amber.shade700,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation['message'] ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}