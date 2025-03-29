import 'package:agrotech_hacakaton/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    final authService = AuthService();
    final success = await authService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Переход на главный экран
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _errorMessage = 'Ошибка при входе. Проверьте логин и пароль.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Вход'), backgroundColor: Colors.green[700]),
      body: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Логотип или иконка
            Icon(Icons.eco, size: 120, color: Colors.green[700]),
            SizedBox(height: 40),

            // Поле ввода электронной почты с иконкой
            _buildTextField(
              controller: _emailController,
              label: 'Электронная почта',
              icon: Icons.email,
              obscureText: false,
            ),

            SizedBox(height: 20),

            // Поле ввода пароля с иконкой
            _buildTextField(
              controller: _passwordController,
              label: 'Пароль',
              icon: Icons.lock,
              obscureText: true,
            ),

            SizedBox(height: 30),

            // Кнопка входа
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Войти', style: TextStyle(fontSize: 18)),
                ),

            // Сообщение об ошибке
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Метод для создания текстовых полей с иконками
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green[700]!),
        ),
      ),
      obscureText: obscureText,
    );
  }
}
