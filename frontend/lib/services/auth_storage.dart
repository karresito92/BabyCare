import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  // Guardar token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Obtener token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Eliminar token (logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Verificar si hay token
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}