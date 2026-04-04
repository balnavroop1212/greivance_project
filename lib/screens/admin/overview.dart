import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

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
        body: const TabBarView(
          children: [
            _NoComplaintsPlaceholder(status: 'Total'),
            _NoComplaintsPlaceholder(status: 'Pending'),
            _NoComplaintsPlaceholder(status: 'Resolved'),
          ],
        ),
      ),
    );
  }
}

class _NoComplaintsPlaceholder extends StatelessWidget {
  final String status;
  const _NoComplaintsPlaceholder({required this.status});

  @override
  Widget build(BuildContext context) {
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
            'No $status complaints found',
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
}
