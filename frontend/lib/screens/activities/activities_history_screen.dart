import 'package:flutter/material.dart';
import '../../models/activity.dart';
import '../../services/api_service.dart';
import 'feeding_form_screen.dart';
import 'sleep_form_screen.dart';
import 'diaper_form_screen.dart';
import 'health_form_screen.dart';

class ActivitiesHistoryScreen extends StatefulWidget {
  final int babyId;

  const ActivitiesHistoryScreen({super.key, required this.babyId});

  @override
  State<ActivitiesHistoryScreen> createState() =>
      _ActivitiesHistoryScreenState();
}

class _ActivitiesHistoryScreenState extends State<ActivitiesHistoryScreen> {
  final _apiService = ApiService();
  List<Activity> _activities = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

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
      final activitiesData = await _apiService.getActivities(
        babyId: widget.babyId,
      );

      setState(() {
        _activities = activitiesData
            .map((json) => Activity.fromJson(json))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      });
    } catch (e) {
      print('Error loading activities: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar actividades: ${e.toString()}'),
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

  Future<void> _editActivity(Activity activity) async {
    Widget? editScreen;

    // Navegar a la pantalla de edición correspondiente
    switch (activity.type) {
      case 'feeding':
        editScreen = FeedingFormScreen(
          babyId: widget.babyId,
          activityToEdit: activity,
        );
        break;
      case 'sleep':
        editScreen = SleepFormScreen(
          babyId: widget.babyId,
          activityToEdit: activity,
        );
        break;
      case 'diaper':
        editScreen = DiaperFormScreen(
          babyId: widget.babyId,
          activityToEdit: activity,
        );
        break;
      case 'medical':
        editScreen = HealthFormScreen(
          babyId: widget.babyId,
          activityToEdit: activity,
        );
        break;
    }

    if (editScreen != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => editScreen!),
      );

      if (result == true) {
        _loadActivities();
      }
    }
  }

  Future<void> _deleteActivity(Activity activity) async {
    try {
      await _apiService.deleteActivity(
        babyId: widget.babyId,
        activityId: activity.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actividad eliminada'),
            backgroundColor: Colors.green,
          ),
        );
      }
      _loadActivities();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<Activity> get _filteredActivities {
    if (_selectedFilter == 'all') {
      return _activities;
    }
    return _activities.where((a) => a.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Historial de Actividades'),
        backgroundColor: const Color(0xFF6BA3E8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Todas', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Alimentación', 'feeding'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Sueño', 'sleep'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pañal', 'diaper'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Médico', 'medical'),
                ],
              ),
            ),
          ),

          // Activities list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6BA3E8),
                    ),
                  )
                : _filteredActivities.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay actividades registradas',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        color: const Color(0xFF6BA3E8),
                        onRefresh: _loadActivities,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredActivities.length,
                          itemBuilder: (context, index) {
                            return _buildActivityCard(
                                _filteredActivities[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF6BA3E8).withOpacity(0.2),
      checkmarkColor: const Color(0xFF6BA3E8),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF6BA3E8) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF6BA3E8) : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    IconData icon;
    Color iconColor;
    Color iconBgColor;
    String title;
    String subtitle;

    switch (activity.type) {
      case 'feeding':
        icon = Icons.restaurant;
        iconColor = const Color(0xFF4CAF50);
        iconBgColor = const Color(0xFF4CAF50).withOpacity(0.1);
        title = 'Alimentación';
        final quantity = activity.data?['quantity_ml'];
        subtitle = quantity != null ? '$quantity ml' : 'Sin cantidad';
        break;
      case 'sleep':
        icon = Icons.bed;
        iconColor = const Color(0xFF9C27B0);
        iconBgColor = const Color(0xFF9C27B0).withOpacity(0.1);
        title = 'Sueño';
        final duration = activity.data?['duration_hours'];
        subtitle = duration != null ? '$duration horas' : 'Sin duración';
        break;
      case 'diaper':
        icon = Icons.child_care;
        iconColor = const Color(0xFFFFA726);
        iconBgColor = const Color(0xFFFFA726).withOpacity(0.1);
        title = 'Cambio de pañal';
        final type = activity.data?['diaper_type'] ?? 'normal';
        subtitle = type == 'wet'
            ? 'Mojado'
            : type == 'dirty'
                ? 'Sucio'
                : type == 'both'
                    ? 'Mojado y sucio'
                    : 'Normal';
        break;
      case 'medical':
        icon = Icons.medical_services;
        iconColor = const Color(0xFFF44336);
        iconBgColor = const Color(0xFFF44336).withOpacity(0.1);
        title = 'Consulta médica';
        subtitle = activity.data?['reason'] ?? 'Sin motivo especificado';
        break;
      default:
        icon = Icons.help_outline;
        iconColor = Colors.grey;
        iconBgColor = Colors.grey.withOpacity(0.1);
        title = 'Actividad';
        subtitle = 'Sin descripción';
    }

    return Dismissible(
      key: Key(activity.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Eliminar actividad'),
              content: const Text('¿Estás seguro de eliminar esta actividad?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        _deleteActivity(activity);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: GestureDetector(
        onTap: () => _editActivity(activity),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(activity.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.edit,
              color: Color(0xFF6BA3E8),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Justo ahora';
    }
  }
}