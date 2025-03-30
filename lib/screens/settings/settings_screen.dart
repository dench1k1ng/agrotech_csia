import 'package:agrotech_hacakaton/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // Функция выхода из аккаунта
    Future<void> _signOut(BuildContext context) async {
      try {
        await FirebaseAuth.instance.signOut();
        // После выхода перенаправляем пользователя на экран логина
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } catch (e) {
        // Обработка ошибок при выходе
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка при выходе: $e')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(value),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Change Language'),
              trailing: IconButton(
                icon: const Icon(Icons.language),
                onPressed: () => themeProvider.toggleLocale(),
              ),
            ),
            const SizedBox(height: 20),
            // Кнопка для выхода из аккаунта
            ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Красный цвет для кнопки выхода
                padding: EdgeInsets.symmetric(vertical: 14),
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Выход из аккаунта', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
