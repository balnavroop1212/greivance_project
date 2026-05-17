import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../auth/login_page.dart';
import 'AdminTheme.dart';
import '../../session_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  final String userName;
  final String adminId;

  const AdminProfileScreen({
    super.key, 
    this.userName = 'Admin', 
    this.adminId = '1111111'
  });

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: 'admin@resolve.com');
    _phoneController = TextEditingController(text: '+91 98765 43210');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      Provider.of<SessionProvider>(context, listen: false).setRole(null);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminTheme = Provider.of<AdminThemeProvider>(context);
    final isDarkMode = adminTheme.themeMode == ThemeMode.dark;
    const Color primaryPurple = Color(0xFF5C59E8);
    const Color textColor = Color(0xFF2D2D6A);
    const Color bgColor = Color(0xFFFBFBFF);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Admin Profile',
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF2D2D2D),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit_outlined, 
              color: primaryPurple,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
              if (!_isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated')),
                );
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // 1. Profile Info Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Image
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: primaryPurple.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: Color(0xFFDEDEFF),
                        child: Icon(Icons.person_rounded, size: 60, color: primaryPurple),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Administrator',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              'OFFICIAL INFORMATION',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white38 : Colors.blueGrey,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoTile(Icons.person_outline_rounded, "Name", _nameController, isDarkMode),
            _buildInfoTile(Icons.alternate_email_rounded, "Official Email", _emailController, isDarkMode),
            _buildInfoTile(Icons.phone_android_rounded, "Phone Number", _phoneController, isDarkMode),
            _buildReadOnlyTile(Icons.badge_outlined, "Employee ID", widget.adminId, isDarkMode),

            const SizedBox(height: 32),
            Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white38 : Colors.blueGrey,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 16),

            // Dark Mode Toggle
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.wb_sunny_outlined, color: primaryPurple, size: 20),
                ),
                value: isDarkMode,
                activeColor: primaryPurple,
                onChanged: (bool value) {
                  adminTheme.toggleTheme(value);
                },
              ),
            ),

            const SizedBox(height: 40),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.red.withValues(alpha: 0.1) : const Color(0xFFFFF0F0),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, TextEditingController controller, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF5C59E8).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF5C59E8), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
                TextField(
                  controller: controller,
                  enabled: _isEditing,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.only(top: 4)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyTile(IconData icon, String label, String value, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF5C59E8).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF5C59E8), size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                value, 
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black87)
              ),
            ],
          ),
        ],
      ),
    );
  }
}
