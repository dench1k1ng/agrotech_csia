import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _baseUrl =
      "http://your-backend-url/api"; // Замените на URL вашего сервера

  static final _storage = FlutterSecureStorage();

  // Сохранить токен
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt_token', value: token);
  }

  // Получить токен
  Future<String?> getToken() async {
    return await _storage.read(key: 'jwt_token');
  }

  // Удалить токен
  Future<void> removeToken() async {
    await _storage.delete(key: 'jwt_token');
  }

  // Проверить, аутентифицирован ли пользователь
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Метод для входа
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      body: json.encode({'email': email, 'password': password}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final token = body['token']; // Предполагаем, что сервер возвращает токен

      // Сохраняем токен в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      return true;
    } else {
      return false;
    }
  }

  // Метод для регистрации
  Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      body: json.encode({'email': email, 'password': password}),
      headers: {"Content-Type": "application/json"},
    );

    return response.statusCode == 200;
  }

  // Метод для выхода (удаление токена)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('jwt_token');
  }
}
