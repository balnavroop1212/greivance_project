import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatelessWidget {
  final String userId;
  const HistoryScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Complaint History', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.blue.shade800,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue.shade800,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'In Progress'),
              Tab(text: 'Resolved'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildComplaintList(context, null),
            _buildComplaintList(context, 'Pending'),
            _buildComplaintList(context, 'In Progress'),
            _buildComplaintList(context, 'Resolved'),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintList(BuildContext context, String? filterStatus) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Query query = FirebaseFirestore.instance
        .collection('grievances')
        .where('userId', isEqualTo: userId);

    if (filterStatus != null) {
      query = query.where('status', isEqualTo: filterStatus);
    }

    query = query.orderBy('timestamp', descending: true);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No ${filterStatus ?? ""} complaints found',
                  style: TextStyle(fontSize: 18, color: isDarkMode ? Colors.white60 : Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final complaints = snapshot.data!.docs;

        return ListView.builder(
          itemCount: complaints.length,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemBuilder: (context, index) {
            final data = complaints[index].data() as Map<String, dynamic>;
            final status = data['status'] ?? 'Pending';
            final category = data['category'] ?? 'General';
            final timestamp = data['timestamp'] as Timestamp?;
            final dateStr = timestamp != null
                ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
                : 'N/A';

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.blue.withValues(alpha: 0.1) : Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIconForCategory(category), color: isDarkMode ? Colors.blue.shade300 : Colors.blue.shade800),
                ),
                title: Text(
                  category,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text("Date: $dateStr", style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey[600], fontSize: 13)),
                    const SizedBox(height: 8),
                    _buildStatusChip(status),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                onTap: () {
                  _showComplaintDetails(context, data, dateStr);
                },
              ),
            );
          },
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Electricity': return Icons.flash_on;
      case 'Plumber': return Icons.plumbing;
      case 'Dispensary': return Icons.local_hospital;
      case 'Food': return Icons.restaurant;
      case 'Internet': return Icons.wifi;
      default: return Icons.description;
    }
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
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data['category'] ?? 'Complaint Detail',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(data['status'] ?? 'Pending'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Filed on: $date',
              style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.grey[600], fontSize: 14),
            ),
            const Divider(height: 40),
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  data['description'] ?? 'No description provided.',
                  style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white70 : Colors.grey[800], height: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Close', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
