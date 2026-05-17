import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'AdminTheme.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<dynamic> _allComplaints = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final data = await _apiService.getAllComplaints();
    if (mounted) {
      setState(() {
        _allComplaints = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminTheme = Provider.of<AdminThemeProvider>(context);
    final isDarkMode = adminTheme.themeMode == ThemeMode.dark;
    const Color primaryPurple = Color(0xFF5C59E8);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFFBFBFF),
        appBar: AppBar(
          backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDarkMode ? Colors.white : Colors.black87, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Complaints Overview',
            style: TextStyle(
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: primaryPurple,
            labelColor: primaryPurple,
            unselectedLabelColor: isDarkMode ? Colors.white38 : Colors.grey.shade400,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorWeight: 3,
            dividerColor: Colors.transparent,
            isScrollable: false, // Set to false to distribute evenly
            tabAlignment: TabAlignment.fill, // Ensures tabs fill the width
            tabs: const [
              Tab(text: 'Total'),
              Tab(text: 'Pending'),
              Tab(text: 'Progress'), // Shortened to fit better
              Tab(text: 'Resolved'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryPurple))
            : TabBarView(
                children: [
                  _buildStatusList(null),
                  _buildStatusList('Pending'),
                  _buildStatusList('In Progress'),
                  _buildStatusList('Resolved'),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusList(String? status) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final filtered = status == null
        ? _allComplaints
        : _allComplaints.where((c) => c['status'] == status).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              'No ${status ?? "total"} complaints found',
              style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white38 : Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final data = filtered[index] as Map<String, dynamic>;
        final currentStatus = data['status'] ?? 'Pending';
        final category = data['category'] ?? 'General';
        final description = data['description'] ?? '';
        final dateStr = data['createdAt'] != null 
            ? DateFormat('dd MMM yyyy').format(DateTime.parse(data['createdAt']))
            : 'N/A';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.03),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            onTap: () {
              _showComplaintDetails(context, data, dateStr);
            },
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getCategoryColor(category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getIconForCategory(category), color: _getCategoryColor(category), size: 24),
            ),
            title: Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A)
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black45, fontSize: 13),
              ),
            ),
            trailing: _buildStatusChip(currentStatus, isSmall: true),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status, {bool isSmall = false}) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = const Color(0xFFDA8D00); break;
      case 'resolved': color = Colors.green; break;
      case 'in progress': color = const Color(0xFF5C59E8); break;
      default: color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 12, vertical: isSmall ? 6 : 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: isSmall ? 14 : 16, color: color),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(color: color, fontSize: isSmall ? 11 : 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Electricity': return Icons.bolt_rounded;
      case 'Plumber': return Icons.plumbing_rounded;
      case 'Dispensary': return Icons.add_box_rounded;
      case 'Food': return Icons.restaurant_rounded;
      case 'Labs': return Icons.laptop_mac_rounded;
      case 'Internet': return Icons.wifi_rounded;
      default: return Icons.description_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Electricity': return const Color(0xFF5C59E8);
      case 'Plumber': return const Color(0xFF2E66E7);
      case 'Dispensary': return const Color(0xFF5C59E8);
      case 'Food': return const Color(0xFFDA8D00);
      case 'Labs': return const Color(0xFF5C59E8);
      default: return const Color(0xFF50C878);
    }
  }

  void _showComplaintDetails(BuildContext context, Map<String, dynamic> data, String date) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const Color primaryPurple = Color(0xFF5C59E8);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFFBFBFF),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF262626) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.02), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: Text(data['subCategory'] ?? data['category'] ?? 'Complaint Detail', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A)))),
                              const SizedBox(width: 12),
                              _buildStatusChip(data['status'] ?? 'Pending'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Filed on: $date', style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black38, fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildDetailSection('Category', data['category'] ?? 'General', isDarkMode),
                    const SizedBox(height: 16),
                    _buildDetailSection('Description', data['description'] ?? 'No description provided.', isDarkMode, isExpanded: true),
                    const SizedBox(height: 16),
                    if (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty) ...[
                      Padding(padding: const EdgeInsets.only(left: 4.0, bottom: 12.0), child: Text('Attachment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.black87))),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxHeight: 300),
                          decoration: BoxDecoration(color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100),
                          child: Image.network(
                            data['imageUrl'],
                            width: double.infinity,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator()),
                            errorBuilder: (context, error, stackTrace) => Container(height: 150, width: double.infinity, color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100, child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: const Text('Close', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, bool isDarkMode, {bool isExpanded = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF262626) : Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.02), blurRadius: 15, offset: const Offset(0, 8))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDarkMode ? Colors.white38 : Colors.black38)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: isExpanded ? FontWeight.normal : FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A), height: 1.5)),
        ],
      ),
    );
  }
}
