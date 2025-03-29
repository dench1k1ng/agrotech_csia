import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final _storage = FlutterSecureStorage();

  // Сохранить токен
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Получить токен
  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Удалить токен
  static Future<void> removeToken() async {
    await _storage.delete(key: 'jwt_token');
  }
}
