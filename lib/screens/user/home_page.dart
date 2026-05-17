import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'complaint.dart';
import 'history.dart';
import 'profile.dart';
import 'suggestions_page.dart';
import 'UserTheme.dart';

class HomePage extends StatelessWidget {
  final String userName;
  final String userId;

  const HomePage({super.key, this.userName = 'User', this.userId = ''});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<UserThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    const Color primaryPurple = Color(0xFF5C59E8);
    const Color backgroundLight = Color(0xFFFBFBFF);
    const Color activeGreen = Color(0xFF50C878);
    
    final Color bgColor = isDarkMode ? const Color(0xFF121212) : backgroundLight;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    final Color subTextColor = isDarkMode ? Colors.white54 : const Color(0xFF8E8E8E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        centerTitle: true,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userName: userName, userId: userId),
                  ),
                );
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    )
                  ],
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 0.5),
                ),
                child: Icon(
                  Icons.person_outline_rounded, 
                  color: isDarkMode ? Colors.white70 : Colors.black87, 
                  size: 24
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Home',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: textColor,
                      size: 26,
                    ),
                    Positioned(
                      right: 12,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryPurple,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDarkMode ? const Color(0xFF121212) : Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // 1. Welcome Section - Anchor building to the far right using Expanded text area
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Here's an overview of your\ncomplaint system",
                        style: TextStyle(
                          fontSize: 14,
                          color: subTextColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset(
                  'images/college.png',
                  width: 145, // Fixed width prevents floating
                  height: 145,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(width: 100),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 2. Session Info Card - Fixed Alignment
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.shield_rounded, size: 30, color: primaryPurple),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complaining Session',
                          style: TextStyle(
                            fontSize: 13,
                            color: subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryPurple.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Roll No: $userId',
                            style: const TextStyle(
                              fontSize: 11,
                              color: primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(radius: 4, backgroundColor: activeGreen),
                          const SizedBox(width: 8),
                          Text(
                            'Active Session',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white70 : const Color(0xFF8A8A99),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Logged in securely',
                        style: TextStyle(
                          fontSize: 11,
                          color: subTextColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),

            // 3. Quick Actions Title
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),

            // 3 Action Cards - Fixed spacing and text overflow
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'File a Complaint',
                    subtitle: 'Submit grievance',
                    icon: Icons.grid_view_rounded,
                    accentColor: const Color(0xFF5C59E8),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ComplaintScreen(userId: userId)));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'Complaint History',
                    subtitle: 'Track status',
                    icon: Icons.groups_rounded,
                    accentColor: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryScreen(userId: userId)));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    context,
                    title: 'Suggestions',
                    subtitle: 'Provide feedback',
                    icon: Icons.lightbulb_outline_rounded,
                    accentColor: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SuggestionsPage(userId: userId)));
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // 4. Bottom Banner Section - Consistent sleek design
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 0, 0),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1A2F) : const Color(0xFFF2F1FF),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.school_rounded, color: primaryPurple, size: 28),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Together, let\'s build a better system.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'images/student.png',
                      height: 180, 
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomRight,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      required Color accentColor,
      required VoidCallback onTap}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220, 
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF2D2D2D),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? Colors.white54 : const Color(0xFF8E8E8E),
                height: 1.4,
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
