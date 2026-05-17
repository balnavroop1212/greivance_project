import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'AdminTheme.dart';

class AdminSuggestionsPage extends StatefulWidget {
  const AdminSuggestionsPage({super.key});

  @override
  State<AdminSuggestionsPage> createState() => _AdminSuggestionsPageState();
}

class _AdminSuggestionsPageState extends State<AdminSuggestionsPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _fetchSuggestions();
  }

  Future<void> _fetchSuggestions() async {
    final data = await _apiService.getAllSuggestions();
    if (mounted) {
      setState(() {
        _suggestions = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminTheme = Provider.of<AdminThemeProvider>(context);
    final isDarkMode = adminTheme.themeMode == ThemeMode.dark;
    
    const Color primaryPurple = Color(0xFF5C59E8);
    final Color bgColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FE);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDarkMode ? Colors.white : const Color(0xFF2D2D2D);
    final Color subTextColor = isDarkMode ? Colors.white54 : const Color(0xFF8E8E8E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 42,
                height: 42,
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
                  Icons.arrow_back_ios_new_rounded, 
                  color: isDarkMode ? Colors.white70 : Colors.black87, 
                  size: 18
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'User Suggestions',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryPurple))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // 1. Sleek Header Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User Feedback\nReview',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: primaryPurple,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'View and manage all user\nsuggestions here.',
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
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: primaryPurple.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Icon(Icons.mark_chat_read_outlined, size: 55, color: primaryPurple.withValues(alpha: 0.2)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Recent Submissions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_suggestions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Column(
                          children: [
                            Icon(Icons.lightbulb_outline, size: 80, color: Colors.grey.withValues(alpha: 0.2)),
                            const SizedBox(height: 16),
                            Text(
                              "No suggestions yet",
                              style: TextStyle(fontSize: 16, color: subTextColor),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestions.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        var data = _suggestions[index] as Map<String, dynamic>;
                        String id = data['_id'] ?? '';
                        String userId = data['userId'] ?? 'Unknown User';
                        String feedback = data['feedback'] ?? 'No feedback provided';
                        
                        String formattedDate = 'Just now';
                        if (data['timestamp'] != null) {
                          formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(data['timestamp']));
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: primaryPurple.withValues(alpha: 0.08),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.person_rounded, size: 18, color: primaryPurple),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          "User: $userId",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline_rounded, color: Colors.red.withValues(alpha: 0.7), size: 22),
                                      onPressed: () => _showDeleteDialog(context, id),
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.0),
                                  child: Divider(height: 1),
                                ),
                                Text(
                                  feedback,
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    color: isDarkMode ? Colors.white70 : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: subTextColor.withValues(alpha: 0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          "Delete Suggestion?", 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          )
        ),
        content: Text(
          "This action cannot be undone and will remove the feedback from the database.",
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final success = await _apiService.deleteSuggestion(id);
              if (mounted) {
                Navigator.pop(context);
                if (success) {
                  _fetchSuggestions();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Suggestion deleted successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to delete suggestion')),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
