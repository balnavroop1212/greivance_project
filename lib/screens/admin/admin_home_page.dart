import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  final String userName;
  final String userId;

  const AdminHomePage({super.key, this.userName = 'Admin', this.userId = '1111111'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: isDarkMode ? Colors.blue.shade900 : Colors.blue.shade100,
            child: Icon(Icons.person, color: isDarkMode ? Colors.blue.shade200 : Colors.blue.shade800),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Admin Summary Tab
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Session,',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'ID: $userId',
                            style: const TextStyle(color: Colors.white70, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              _buildTab(
                context,
                title: 'Overview',
                subtitle: 'View complaint statistics',
                icon: Icons.dashboard_rounded,
                onTap: () {
                  // TODO: Navigate to Overview Screen
                },
              ),
              const SizedBox(height: 20),
              _buildTab(
                context,
                title: 'Worker Management',
                subtitle: 'Manage staff and assignments',
                icon: Icons.engineering_rounded,
                onTap: () {
                  // TODO: Navigate to Worker Management Screen
                },
              ),
              const SizedBox(height: 20),
              _buildTab(
                context,
                title: 'Suggestions',
                subtitle: 'View user feedback',
                icon: Icons.lightbulb_outline_rounded,
                onTap: () {
                  // TODO: Navigate to Admin Suggestions Screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context,
      {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade800),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white60 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: isDarkMode ? Colors.white30 : Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
