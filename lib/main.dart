import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/login_page.dart';
import 'screens/user/home_page.dart';
import 'screens/admin/admin_home_page.dart';
import 'theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('user_id');
  final String? userName = prefs.getString('user_name');
  final String? userRole = prefs.getString('user_role');
  
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
      ],
      child: MyApp(
        initialHome: initialHome,
        userRole: userRole,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialHome;
  final String? userRole;
  const MyApp({super.key, required this.initialHome, this.userRole});

  @override
  Widget build(BuildContext context) {
    // Role based theme selection
    ThemeMode currentThemeMode;
    if (userRole == 'admin') {
      currentThemeMode = Provider.of<AdminThemeProvider>(context).themeMode;
    } else {
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
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: initialHome,
    );
  }
}
