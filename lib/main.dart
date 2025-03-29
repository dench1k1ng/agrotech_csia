// main.dart
import 'package:agrotech_hacakaton/core/localization/l10n/app_localizations.dart';
import 'package:agrotech_hacakaton/screens/batches/batches_screen.dart';
import 'package:agrotech_hacakaton/screens/graph/grow_chart_screen.dart'
    as graph;
import 'package:agrotech_hacakaton/screens/journal/journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AgroTech App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: themeProvider.locale,
          supportedLocales: const [Locale('en'), Locale('ru')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const MainNavigation(),
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    BatchesScreen(),
    graph.GrowthChartScreen(
      measurements: [
        graph.GrowthMeasurement(date: DateTime(2023, 6, 10), height: 2.0),
        graph.GrowthMeasurement(date: DateTime(2023, 6, 13), height: 4.5),
        graph.GrowthMeasurement(date: DateTime(2023, 6, 15), height: 6.0),
      ],
    ),
    JournalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
