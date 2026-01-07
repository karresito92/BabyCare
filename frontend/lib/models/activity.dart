class Activity {
  final int id;
  final int babyId;
  final int? userId;
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final String? notes;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.babyId,
    this.userId,
    required this.type,
    required this.timestamp,
    this.data,
    this.notes,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      babyId: json['baby_id'],
      userId: json['user_id'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      data: json['data'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Obtener el valor formateado según el tipo
  String getFormattedValue() {
    switch (type) {
      case 'feeding':
        final quantity = data?['quantity_ml'];
        return quantity != null ? '${quantity}ml' : 'N/A';
      case 'sleep':
        final duration = data?['duration_hours'];
        return duration != null ? '${duration}h' : 'N/A';
      case 'diaper':
        final diaperType = data?['type'] ?? 'N/A';
        final typeMap = {
          'wet': 'Mojado',
          'dirty': 'Sucio',
          'both': 'Ambos',
        };
        return typeMap[diaperType] ?? diaperType;
      case 'health':
        final medication = data?['medication'];
        final temperature = data?['temperature'];
        if (medication != null) return medication;
        if (temperature != null) return '$temperature°C';
        return 'N/A';
      default:
        return 'N/A';
    }
  }

  // Obtener tiempo transcurrido desde la actividad
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    // ✅ CORREGIDO: manejar valores negativos
    if (difference.isNegative) {
      return 'En el futuro';
    }

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inDays}d';
    }
  }
}