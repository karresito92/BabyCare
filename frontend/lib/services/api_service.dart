import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_storage.dart';

class ApiService {
  static const String baseUrl = 'https://babycare-8hlu.onrender.com';
  final _authStorage = AuthStorage();

  // ==================== AUTH ENDPOINTS ====================

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error en registro: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _authStorage.saveToken(data['access_token']);
      return data;
    } else {
      throw Exception('Error en login: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await _authStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/auth/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener usuario: ${response.body}');
    }
  }

  Future<void> updateUserProfile({
    required String name,
    String? profilePicture,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/auth/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        if (profilePicture != null) 'profile_picture': profilePicture,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar perfil: ${response.body}');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al cambiar contraseña: ${response.body}');
    }
  }

  // Recuperar contraseña (enviar código por email)
  Future<void> forgotPassword({required String email}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar correo de recuperación');
    }
  }

  // NUEVO - Resetear contraseña con token
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Error al restablecer contraseña');
    }
  }

  Future<void> logout() async {
    await _authStorage.deleteToken();
  }

  // ==================== BABIES ENDPOINTS ====================

  Future<List<dynamic>> getBabies() async {
    final token = await _authStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/babies'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener bebés: ${response.body}');
    }
  }

  Future<List<dynamic>> getMyBabies() async {
    return await getBabies();
  }

  Future<Map<String, dynamic>> getBaby(int babyId) async {
    final token = await _authStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/babies/$babyId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener bebé: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> createBaby({
    required String name,
    required DateTime birthDate,
    String? photo,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/babies'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'birth_date': birthDate.toIso8601String().split('T')[0],
        if (photo != null) 'photo': photo,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al crear bebé: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> updateBaby({
    required int babyId,
    required String name,
    required DateTime birthDate,
    String? photo,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/babies/$babyId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'birth_date': birthDate.toIso8601String().split('T')[0],
        if (photo != null) 'photo': photo,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al actualizar bebé: ${response.body}');
    }
  }

  // ==================== ACTIVITIES ENDPOINTS ====================

  Future<List<dynamic>> getActivities({
    required int babyId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await _authStorage.getToken();

    var url = '$baseUrl/babies/$babyId/activities';

    if (startDate != null && endDate != null) {
      url +=
          '?start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener actividades: ${response.body}');
    }
  }

  Future<List<dynamic>> getBabyActivities({
    required int babyId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await getActivities(
      babyId: babyId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<Map<String, dynamic>> createActivity({
    required int babyId,
    required String type,
    required DateTime timestamp,
    required Map<String, dynamic> data,
    String? notes,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/babies/$babyId/activities'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'data': data,
        if (notes != null) 'notes': notes,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al crear actividad: ${response.body}');
    }
  }

  Future<void> updateActivity({
    required int babyId,
    required int activityId,
    required String type,
    required DateTime timestamp,
    required Map<String, dynamic> data,
    String? notes,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/babies/$babyId/activities/$activityId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'data': data,
        if (notes != null) 'notes': notes,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar actividad: ${response.body}');
    }
  }

  Future<void> deleteActivity({
    required int babyId,
    required int activityId,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/babies/$babyId/activities/$activityId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Error al eliminar actividad: ${response.body}');
    }
  }

  // ==================== STATISTICS ENDPOINTS ====================

  Future<Map<String, dynamic>> getStatistics({
    required int babyId,
    int days = 7,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/babies/$babyId/statistics?days=$days'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener estadísticas: ${response.body}');
    }
  }

  // ==================== INSIGHTS/ML ENDPOINTS ====================

  Future<Map<String, dynamic>> getInsights({
    required int babyId,
    int days = 14,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/babies/$babyId/insights?days=$days'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener insights: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getBabyInsights({
    required int babyId,
    int days = 14,
  }) async {
    return await getInsights(babyId: babyId, days: days);
  }

  // ==================== PDF ENDPOINTS ====================

  Future<List<int>> generatePDF({required int babyId, int days = 7}) async {
    final token = await _authStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/babies/$babyId/generate-pdf?days=$days'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Error al generar PDF: ${response.body}');
    }
  }

  // ==================== CAREGIVERS ENDPOINTS ====================

  Future<List<dynamic>> getBabyCaregivers({required int babyId}) async {
    final token = await _authStorage.getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/babies/$babyId/caregivers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al obtener cuidadores: ${response.body}');
    }
  }

  Future<void> addCaregiver({
    required int babyId,
    required String email,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/babies/$babyId/caregivers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al añadir cuidador: ${response.body}');
    }
  }

  Future<void> removeCaregiver({
    required int babyId,
    required int caregiverId,
  }) async {
    final token = await _authStorage.getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/babies/$babyId/caregivers/$caregiverId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar cuidador: ${response.body}');
    }
  }
}