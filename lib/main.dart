import 'package:agrotech_hacakaton/auth_wrapper.dart';
import 'package:agrotech_hacakaton/screens/auth/login_screen.dart';
import 'package:agrotech_hacakaton/screens/auth/register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/batches/batches_screen.dart';
import 'screens/graph/grow_chart_screen.dart' as graph;
import 'screens/settings/settings_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // StreamProvider для отслеживания состояния пользователя Firebase
        StreamProvider<User?>(
          create:
              (_) =>
                  FirebaseAuth.instance
                      .authStateChanges(), // Поток изменений состояния пользователя
          initialData:
              null, // Начальные данные, если пользователь не авторизован
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Инициализация уведомлений
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          locale: themeProvider.locale,
          routes: {
            '/login': (context) => LoginScreen(),
            '/register': (context) => RegisterScreen(),
            '/home': (context) => const MainNavigation(),
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AuthWrapper(),
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
    SettingsScreen(),
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
