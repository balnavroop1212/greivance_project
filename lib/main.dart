import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_page.dart';
import 'screens/user/home_page.dart';
import 'screens/admin/admin_home_page.dart';
import 'screens/user/UserTheme.dart';
import 'screens/admin/AdminTheme.dart';
import 'session_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('user_id');
  final String? userName = prefs.getString('user_name');
  final String? userRole = prefs.getString('user_role');
  
  final sessionProvider = SessionProvider();
  sessionProvider.setRole(userRole);

  Widget initialHome;
  if (userId != null && userName != null) {
    if (userRole == 'admin') {
      initialHome = const AdminHomePage();
    } else {
      initialHome = HomePage(userId: userId, userName: userName);
    }
  } else {
    initialHome = const LoginPage();
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserThemeProvider()),
        ChangeNotifierProvider(create: (_) => AdminThemeProvider()),
        ChangeNotifierProvider.value(value: sessionProvider),
      ],
      child: MyApp(
        initialHome: initialHome,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialHome;
  const MyApp({super.key, required this.initialHome});

  @override
  Widget build(BuildContext context) {
    final currentRole = Provider.of<SessionProvider>(context).currentRole;
    
    ThemeMode currentThemeMode = ThemeMode.light;
    
    if (currentRole == 'admin') {
      currentThemeMode = Provider.of<AdminThemeProvider>(context).themeMode;
    } else if (currentRole == 'user') {
      currentThemeMode = Provider.of<UserThemeProvider>(context).themeMode;
    }

    return MaterialApp(
      title: 'Resolve Desk',
      debugShowCheckedModeBanner: false,
      themeMode: currentThemeMode,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue.shade800,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue.shade300,
          surface: const Color(0xFF1E1E1E),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: initialHome,
    );
  }
}
