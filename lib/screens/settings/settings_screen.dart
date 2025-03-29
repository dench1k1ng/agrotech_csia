import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

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
          ],
        ),
      ),
    );
  }
}
