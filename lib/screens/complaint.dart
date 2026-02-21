import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintScreen extends StatefulWidget {
  final String phone;
  const ComplaintScreen({super.key, required this.phone});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String? selectedCategory;
  bool _isSubmitting = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Electricity', 'icon': Icons.flash_on},
    {'name': 'Plumber', 'icon': Icons.plumbing},
    {'name': 'Dispensary', 'icon': Icons.local_hospital},
    {'name': 'Food', 'icon': Icons.restaurant},
    {'name': 'Internet', 'icon': Icons.wifi},
    {'name': 'Others', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _handleLostData();
    
    // Save description draft as user types
    _descriptionController.addListener(() {
      _saveDraft();
    });
  }

  // Retrieve image if app was killed while camera was open
  Future<void> _handleLostData() async {
    if (Platform.isAndroid) {
      final LostDataResponse response = await _picker.retrieveLostData();
      if (response.isEmpty) return;
      if (response.file != null) {
        setState(() {
          _image = File(response.file!.path);
        });
      }
    }
  }

  // Save current progress to SharedPreferences
  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_desc', _descriptionController.text);
    if (selectedCategory != null) {
      await prefs.setString('draft_cat', selectedCategory!);
    }
    await prefs.setBool('is_filing_complaint', true);
  }

  // Load saved progress
  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _descriptionController.text = prefs.getString('draft_desc') ?? '';
      selectedCategory = prefs.getString('draft_cat');
    });
  }

  // Clear draft after successful submission
  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_desc');
    await prefs.remove('draft_cat');
    await prefs.remove('is_filing_complaint');
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Set flag that we are intentionally leaving the app for camera
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_filing_complaint', true);
      
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _submitGrievance() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a description')));
      return;
    }

    setState(() { _isSubmitting = true; });

    try {
      String? imageUrl;
      if (_image != null) {
        String fileName = 'complaint_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference ref = FirebaseStorage.instance.ref().child('complaints').child(fileName);
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('grievances').add({
        'category': selectedCategory,
        'description': _descriptionController.text.trim(),
        'userId': widget.phone,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl, 
      });

      await _clearDraft(); // Clear progress on success

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grievance submitted successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) { setState(() { _isSubmitting = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Complaint'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await _clearDraft(); // Clear if user manually goes back
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedCategory == categories[index]['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = categories[index]['name'];
                        });
                        _saveDraft();
                      },
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.shade800 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? Colors.blue.shade800 : Colors.grey.shade300),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(categories[index]['icon'], color: isSelected ? Colors.white : Colors.blue.shade800),
                            const SizedBox(height: 8),
                            Text(categories[index]['name'], style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade700)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe your issue in detail...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Attachments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAttachmentButton(icon: Icons.camera_alt_outlined, label: 'Camera', onTap: () => _pickImage(ImageSource.camera)),
                  const SizedBox(width: 16),
                  _buildAttachmentButton(icon: Icons.photo_outlined, label: 'Gallery', onTap: () => _pickImage(ImageSource.gallery)),
                ],
              ),
              if (_image != null) ...[
                const SizedBox(height: 16),
                Stack(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(image: FileImage(_image!), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => setState(() { _image = null; }),
                        child: const CircleAvatar(backgroundColor: Colors.black54, child: Icon(Icons.close, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitGrievance,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(55)),
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Complaint', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade100)),
          child: Column(children: [Icon(icon, color: Colors.blue.shade800), const SizedBox(height: 8), Text(label, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold))]),
        ),
      ),
    );
  }
}
