import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_page.dart';
import '../theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userId;

  const ProfileScreen({super.key, required this.userName, required this.userId});

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Stack(
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: Icon(Icons.person, size: 80, color: Colors.blue.shade800),
                ),
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800,
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Text(
              userName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Roll No: $userId',
                style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white70 : Colors.grey.shade700, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 40),
            
            // Theme Toggle ListTile
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 0,
                color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode, color: Colors.blue.shade800),
                  value: isDarkMode,
                  onChanged: (bool value) {
                    themeProvider.toggleTheme(value);
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red, width: 2),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  minimumSize: const Size.fromHeight(55),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded),
                    SizedBox(width: 10),
                    Text('Logout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
