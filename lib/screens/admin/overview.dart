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
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${status ?? ""} complaints found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.withValues(alpha: 0.7),
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
            title: Text(data['category'] ?? 'General', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(data['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text(data['status'] ?? 'Pending', style: TextStyle(color: _getStatusColor(data['status']))),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'resolved': return Colors.green;
      case 'in progress': return Colors.blue;
      default: return Colors.grey;
    }
  }
}
