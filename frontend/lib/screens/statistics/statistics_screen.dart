import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/api_service.dart';
import '../../models/activity.dart';

class StatisticsScreen extends StatefulWidget {
  final int babyId;
  
  const StatisticsScreen({
    super.key,
    required this.babyId,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final _apiService = ApiService();
  
  List<Activity> _activities = [];
  bool _isLoading = true;
  String _selectedPeriod = 'week'; // 'today', 'week', 'month'
  
  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      DateTime startDate;

      switch (_selectedPeriod) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      final data = await _apiService.getBabyActivities(
        babyId: widget.babyId,
        startDate: startDate,
        endDate: now,
      );

      _activities = data.map((json) => Activity.fromJson(json)).toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar estadísticas: ${e.toString()}'),
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

  // Calcular datos de alimentación por día
  Map<String, double> _getFeedingDataByDay() {
    final Map<String, double> data = {};
    final feedingActivities = _activities.where((a) => a.type == 'feeding');

    for (var activity in feedingActivities) {
      final dateKey = DateFormat('yyyy-MM-dd').format(activity.timestamp);
      final quantity = (activity.data?['quantity_ml'] ?? 0).toDouble();
      data[dateKey] = (data[dateKey] ?? 0) + quantity;
    }

    return data;
  }

  // Calcular datos de sueño por día
  Map<String, double> _getSleepDataByDay() {
    final Map<String, double> data = {};
    final sleepActivities = _activities.where((a) => a.type == 'sleep');

    for (var activity in sleepActivities) {
      final dateKey = DateFormat('yyyy-MM-dd').format(activity.timestamp);
      final duration = (activity.data?['duration_hours'] ?? 0).toDouble();
      data[dateKey] = (data[dateKey] ?? 0) + duration;
    }

    return data;
  }

  // Calcular promedio de alimentación
  double _getAverageFeedingPerDay() {
    final feedingData = _getFeedingDataByDay();
    if (feedingData.isEmpty) return 0;
    final total = feedingData.values.reduce((a, b) => a + b);
    return total / feedingData.length;
  }

  // Calcular promedio de sueño
  double _getAverageSleepPerDay() {
    final sleepData = _getSleepDataByDay();
    if (sleepData.isEmpty) return 0;
    final total = sleepData.values.reduce((a, b) => a + b);
    return total / sleepData.length;
  }

  // Calcular total de cambios de pañal
  int _getTotalDiaperChanges() {
    return _activities.where((a) => a.type == 'diaper').length;
  }

  // Calcular total de registros de salud
  int _getTotalHealthRecords() {
    return _activities.where((a) => a.type == 'health').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6BA3E8), Color(0xFF5B93D8)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estadísticas',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Análisis del cuidado de tu bebé',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Selector de período
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildPeriodButton('Hoy', 'today'),
                          _buildPeriodButton('Esta semana', 'week'),
                          _buildPeriodButton('Este mes', 'month'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6BA3E8),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadActivities,
                      color: const Color(0xFF6BA3E8),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tarjetas de resumen
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    icon: Icons.restaurant,
                                    color: const Color(0xFF6BA3E8),
                                    title: 'Promedio diario',
                                    value: '${_getAverageFeedingPerDay().toStringAsFixed(0)}ml',
                                    subtitle: 'Alimentación',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSummaryCard(
                                    icon: Icons.bedtime,
                                    color: const Color(0xFF9C27B0),
                                    title: 'Promedio diario',
                                    value: '${_getAverageSleepPerDay().toStringAsFixed(1)}h',
                                    subtitle: 'Sueño',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    icon: Icons.baby_changing_station,
                                    color: const Color(0xFF4CAF50),
                                    title: 'Total',
                                    value: '${_getTotalDiaperChanges()}',
                                    subtitle: 'Cambios de pañal',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSummaryCard(
                                    icon: Icons.favorite,
                                    color: const Color(0xFFFF5252),
                                    title: 'Total',
                                    value: '${_getTotalHealthRecords()}',
                                    subtitle: 'Registros de salud',
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Gráfica de alimentación
                            const Text(
                              'Alimentación por día',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildFeedingChart(),

                            const SizedBox(height: 32),

                            // Gráfica de sueño
                            const Text(
                              'Horas de sueño por día',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSleepChart(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = value;
            _loadActivities();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? const Color(0xFF6BA3E8) : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingChart() {
    final feedingData = _getFeedingDataByDay();
    
    if (feedingData.isEmpty) {
      return _buildEmptyChart('No hay datos de alimentación');
    }

    final sortedKeys = feedingData.keys.toList()..sort();
    final spots = <FlSpot>[];
    
    for (int i = 0; i < sortedKeys.length; i++) {
      spots.add(FlSpot(i.toDouble(), feedingData[sortedKeys[i]]!));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 200,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= sortedKeys.length) return const SizedBox();
                  final date = DateTime.parse(sortedKeys[value.toInt()]);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 200,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()}ml',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (sortedKeys.length - 1).toDouble(),
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF6BA3E8),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: const Color(0xFF6BA3E8),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF6BA3E8).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChart() {
    final sleepData = _getSleepDataByDay();
    
    if (sleepData.isEmpty) {
      return _buildEmptyChart('No hay datos de sueño');
    }

    final sortedKeys = sleepData.keys.toList()..sort();
    final bars = <BarChartGroupData>[];
    
    for (int i = 0; i < sortedKeys.length; i++) {
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: sleepData[sortedKeys[i]]!,
              color: const Color(0xFF9C27B0),
              width: 16,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 24,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= sortedKeys.length) return const SizedBox();
                  final date = DateTime.parse(sortedKeys[value.toInt()]);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('dd/MM').format(date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 4,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    '${value.toInt()}h',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: bars,
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}