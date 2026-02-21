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
  String? selectedCategoryName;
  String? selectedSubCategory;
  bool _isSubmitting = false;
  bool _isPickingImage = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Electricity',
      'icon': Icons.flash_on,
      'subCategories': [
        'Power outrage in classroom',
        'Faulty switch/socket',
        'Tube light not working',
        'Fan not working',
        'AC not working',
        'Short circuit problem',
        'Loose wiring',
        'Generator backup issue',
        'Corridor lights not working',
      ]
    },
    {
      'name': 'Plumber',
      'icon': Icons.plumbing,
      'subCategories': [
        'Water leakage in washroom',
        'Tap not working',
        'Flush not working',
        'Blocked drainage',
        'Low water pressure',
        'No water supply',
        'Broken wash basin',
        'Pipe burst',
        'Water tank overflow'
      ]
    },
    {
      'name': 'Dispensary',
      'icon': Icons.local_hospital,
      'subCategories': [
        'Medicine not available',
        'Doctor not present',
        'First-aid kit empty',
        'Long waiting time',
        'Staff misbehaviour',
        'Expired medicines',
        'Emergency response delay',
        'Cleanlines issue',
      ]
    },
    {
      'name': 'Food',
      'icon': Icons.restaurant,
      'subCategories': [
        'Poor food quality',
        'Food hygiene issue',
        'Stale food served',
        'High pricing',
        'Limited menu options',
        'uncertain utensils',
        'Water quality issue',
        'Delay in serving',
        'Staff behaviour issue'
      ]
    },
    {
      'name': 'Labs',
      'icon': Icons.computer,
      'subCategories': [
        'Computers not working',
        'Software not installed',
        'Internet not working',
        'Projector not working',
        'Lab equipment damaged',
        'Insufficient equipment',
        'Safety equipment missing',
        'AC/fan not working in lab',
        'Seating arrangement issue'
      ]
    },
    {'name': 'Others', 'icon': Icons.more_horiz, 'subCategories': []},
  ];

  List<String> _currentSubCategories = [];

  Future<void> _submitGrievance() async {
    if (selectedCategoryName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }
    if (_currentSubCategories.isNotEmpty && selectedSubCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a sub-category')),
      );
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
        'category': selectedCategoryName,
        'subCategory': selectedSubCategory,
        'description': _descriptionController.text.trim(),
        'userId': widget.phone,
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl, 
      });

      await _clearDraft();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint submitted successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) { setState(() { _isSubmitting = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('File Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () async {
            await _clearDraft();
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    bool isSelected = selectedCategoryName == category['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategoryName = category['name'];
                          selectedSubCategory = null; // Reset sub-category
                          _currentSubCategories = List<String>.from(category['subCategories'] ?? []);
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
                          boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category['icon'],
                              color: isSelected ? Colors.white : Colors.blue.shade800,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category['name'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (_currentSubCategories.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text('Select Sub-Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _currentSubCategories.map((subCategory) {
                        final isSelected = selectedSubCategory == subCategory;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedSubCategory = subCategory;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12.0),
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.shade800 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.blue.shade800 : Colors.grey.shade300,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    subCategory,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: isSelected ? Colors.white : Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

              const SizedBox(height: 30),
              const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Describe your issue in detail...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.all(20),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Attachments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildAttachmentButton(
                    icon: Icons.camera_alt_rounded, 
                    label: 'Camera', 
                    onTap: () => _pickImage(ImageSource.camera),
                    isLoading: _isPickingImage,
                  ),
                  const SizedBox(width: 16),
                  _buildAttachmentButton(
                    icon: Icons.photo_library_rounded, 
                    label: 'Gallery', 
                    onTap: () => _pickImage(ImageSource.gallery),
                    isLoading: _isPickingImage,
                  ),
                ],
              ),
              if (_image != null) ...[
                const SizedBox(height: 20),
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                        image: DecorationImage(image: FileImage(_image!), fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => setState(() { _image = null; }),
                        child: const CircleAvatar(
                          backgroundColor: Colors.black54, 
                          radius: 18,
                          child: Icon(Icons.close, color: Colors.white, size: 20)
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitGrievance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                  ),
                  child: _isSubmitting 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Submit Complaint', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentButton({required IconData icon, required String label, required VoidCallback onTap, bool isLoading = false}) {
    return Expanded(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(15), 
            border: Border.all(color: Colors.blue.shade100),
            boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(icon, color: Colors.blue.shade800, size: 30),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
