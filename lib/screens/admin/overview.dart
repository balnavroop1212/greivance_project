import 'package:flutter/material.dart';
import '../../services/api_service.dart';

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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complaints Overview', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: TabBar(
            indicatorColor: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade800,
            labelColor: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade800,
            unselectedLabelColor: isDarkMode ? Colors.white70 : Colors.grey,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Total'),
              Tab(text: 'Pending'),
              Tab(text: 'Resolved'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildStatusList(null),
                  _buildStatusList('Pending'),
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
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${status ?? "total"} complaints found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final data = filtered[index] as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          child: ListTile(
            onTap: () => _showComplaintDetails(context, data, "N/A"),
            title: Text(data['category'] ?? 'General', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(data['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: _buildStatusChip(data['status'] ?? 'Pending'),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'resolved':
        color = Colors.green;
        break;
      case 'in progress':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showComplaintDetails(BuildContext context, Map<String, dynamic> data, String date) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(data['category'] ?? 'Complaint Detail', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                _buildStatusChip(data['status'] ?? 'Pending'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Status Info', style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey[600], fontSize: 14)),
            const Divider(height: 40),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(data['description'] ?? 'No description provided.', style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.grey[800], height: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Close', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ),
          ],
        ),
      ),
    );
  }
}
