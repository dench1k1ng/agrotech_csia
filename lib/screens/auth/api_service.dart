import 'package:agrotech_hacakaton/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String _baseUrl =
      "http://your-backend-url/api"; // Замените на URL вашего сервера

  // Метод для получения защищенных данных
  Future<void> fetchProtectedData() async {
    final token = await AuthService().getToken();

    if (token == null) {
      // Если токен не найден, покажите сообщение или выполните выход
      print('User is not authenticated.');
      return;
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/protected-endpoint'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Обработка успешного ответа
      print('Получены данные: ${response.body}');
    } else {
      // Обработка ошибки
      print('Ошибка при запросе: ${response.statusCode}');
    }
  }
}
