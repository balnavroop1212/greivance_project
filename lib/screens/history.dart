import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint History')),
      body: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.only(top: 8),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(Icons.description, color: Colors.blue.shade800),
                ),
                title: Text('Complaint #${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Status: Under Review'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          );
        },
      ),
    );
  }
}
