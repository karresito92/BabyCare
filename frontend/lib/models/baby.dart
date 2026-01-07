import 'package:intl/intl.dart';

class Baby {
  final int id;
  final String name;
  final DateTime birthDate;
  final String? photo;
  final String createdAt;
  final String updatedAt;

  Baby({
    required this.id,
    required this.name,
    required this.birthDate,
    this.photo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Baby.fromJson(Map<String, dynamic> json) {
    return Baby(
      id: json['id'],
      name: json['name'],
      birthDate: DateTime.parse(json['birth_date']),
      photo: json['photo'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate.toIso8601String().split('T')[0],
      'photo': photo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  String getAgeFormatted() {
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    final days = (difference.inDays % 30);

    if (years > 0) {
      if (months > 0) {
        return '$years año${years > 1 ? 's' : ''} y $months mes${months > 1 ? 'es' : ''}';
      }
      return '$years año${years > 1 ? 's' : ''}';
    } else if (months > 0) {
      return '$months mes${months > 1 ? 'es' : ''}';
    } else {
      return '$days día${days > 1 ? 's' : ''}';
    }
  }

  String getFormattedBirthDate() {
    return DateFormat('dd/MM/yyyy').format(birthDate);
  }

  String getFormattedCreatedAt() {
    try {
      final date = DateTime.parse(createdAt);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return createdAt;
    }
  }
}