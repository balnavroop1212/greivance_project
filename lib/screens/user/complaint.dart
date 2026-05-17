import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import 'UserTheme.dart';

class ComplaintScreen extends StatefulWidget {
  final String userId;
  const ComplaintScreen({super.key, required this.userId});

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final ApiService _apiService = ApiService();
  String? selectedCategoryName;
  String? selectedSubCategory;
  bool _isSubmitting = false;
  bool _isPickingImage = false;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, dynamic>> categories = [
    {'name': 'Electricity', 'icon': Icons.bolt_rounded},
    {'name': 'Plumber', 'icon': Icons.plumbing_rounded},
    {'name': 'Dispensary', 'icon': Icons.add_box_rounded},
    {'name': 'Food', 'icon': Icons.restaurant_rounded},
    {'name': 'Labs', 'icon': Icons.laptop_mac_rounded},
    {'name': 'Others', 'icon': Icons.more_horiz_rounded},
  ];

  final Map<String, List<String>> subCategoriesMap = {
    'Electricity': [
      'Power outrage in classroom', 'Faulty switch/socket', 'Tube light not working',
      'Fan not working', 'AC not working', 'Short circuit problem', 'Loose wiring',
      'Generator backup issue', 'Corridor lights not working',
    ],
    'Plumber': [
      'Water leakage in washroom', 'Tap not working', 'Flush not working',
      'Blocked drainage', 'Low water pressure', 'No water supply', 'Broken wash basin',
      'Pipe burst', 'Water tank overflow'
    ],
    'Dispensary': [
      'Medicine not available', 'Doctor not present', 'First-aid kit empty',
      'Long waiting time', 'Staff misbehaviour', 'Expired medicines',
      'Emergency response delay', 'Cleanliness issue',
    ],
    'Food': [
      'Poor food quality', 'Food hygiene issue', 'Stale food served',
      'High pricing', 'Limited menu options', 'uncertain utensils',
      'Water quality issue', 'Delay in serving', 'Staff behaviour issue'
    ],
    'Labs': [
      'Computers not working', 'Software not installed', 'Internet not working',
      'Projector not working', 'Lab equipment damaged', 'Insufficient equipment',
      'Safety equipment missing', 'AC/fan not working in lab', 'Seating arrangement issue'
    ],
    'Others': ['General Inquiry', 'Infrastructure Issue', 'Security Concern', 'Other'],
  };

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _handleLostData();
    _descriptionController.addListener(() => _saveDraft());
  }

  Future<void> _handleLostData() async {
    if (Platform.isAndroid) {
      try {
        final LostDataResponse response = await _picker.retrieveLostData();
        if (response.isEmpty || response.file == null) return;
        setState(() { _image = File(response.file!.path); });
        _saveDraft();
      } catch (e) { debugPrint('Error: $e'); }
    }
  }

  Future<void> _saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_desc', _descriptionController.text);
    if (selectedCategoryName != null) await prefs.setString('draft_cat', selectedCategoryName!);
    if (selectedSubCategory != null) await prefs.setString('draft_subcat', selectedSubCategory!);
    if (_image != null) await prefs.setString('draft_image', _image!.path);
    await prefs.setBool('is_filing_complaint', true);
  }

  Future<void> _loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('is_filing_complaint') ?? false)) return;
    setState(() {
      _descriptionController.text = prefs.getString('draft_desc') ?? '';
      selectedCategoryName = prefs.getString('draft_cat');
      selectedSubCategory = prefs.getString('draft_subcat');
      String? img = prefs.getString('draft_image');
      if (img != null) _image = File(img);
    });
  }

  Future<void> _clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_desc');
    await prefs.remove('draft_cat');
    await prefs.remove('draft_subcat');
    await prefs.remove('draft_image');
    await prefs.setBool('is_filing_complaint', false);
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source, maxWidth: 800, maxHeight: 800, imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() { _image = File(pickedFile.path); });
        _saveDraft();
      }
    } catch (e) { debugPrint('Error picking image: $e'); }
    finally { if (mounted) setState(() => _isPickingImage = false); }
  }

  Future<void> _submitGrievance() async {
    final messenger = ScaffoldMessenger.of(context);
    if (selectedCategoryName == null) {
      messenger.showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('Please enter a description')));
      return;
    }
    setState(() { _isSubmitting = true; });
    try {
      final error = await _apiService.postComplaint(
        userId: widget.userId,
        category: selectedCategoryName!,
        subCategory: selectedSubCategory ?? "General",
        description: _descriptionController.text.trim(),
        imageFile: _image,
      );
      if (error == null) {
        await _clearDraft();
        if (mounted) {
          messenger.showSnackBar(const SnackBar(content: Text('Complaint submitted successfully!'), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      } else {
        if (mounted) messenger.showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) messenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() { _isSubmitting = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<UserThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    
    const Color primaryPurple = Color(0xFF5C59E8);
    const Color backgroundLight = Color(0xFFF8F9FE);
    const Color textColor = Color(0xFF2D2D6A);
    const Color subTextColor = Color(0xFF8E8E8E);
    
    final Color bgColor = isDarkMode ? const Color(0xFF121212) : backgroundLight;
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) { if (didPop) _clearDraft(); },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 70,
          centerTitle: false,
          leadingWidth: 70,
          leading: Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
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
            'File Complaint',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Illustration
              Container(
                width: double.infinity,
                height: 180,
                child: Image.asset(
                  'images/college2.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(height: 180),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Horizontal Categories
                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          bool isSelected = selectedCategoryName == category['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedCategoryName = category['name'];
                                selectedSubCategory = null;
                              });
                              _saveDraft();
                            },
                            child: Container(
                              width: 85,
                              margin: const EdgeInsets.only(right: 15, bottom: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryPurple : cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.06),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                                border: Border.all(
                                  color: isSelected ? primaryPurple : Colors.black.withValues(alpha: 0.02),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    category['icon'],
                                    color: isSelected ? Colors.white : primaryPurple,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    category['name'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    if (selectedCategoryName != null && subCategoriesMap.containsKey(selectedCategoryName)) ...[
                      const SizedBox(height: 25),
                      Text(
                        'Select Sub-Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: subCategoriesMap[selectedCategoryName!]!.map((sub) {
                          final isSelected = selectedSubCategory == sub;
                          return GestureDetector(
                            onTap: () {
                              setState(() => selectedSubCategory = sub);
                              _saveDraft();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryPurple : (isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade50),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? primaryPurple : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(sub, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : (isDarkMode ? Colors.white70 : Colors.grey.shade700))),
                                  if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 18),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 32),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode ? Colors.grey.shade800 : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
                        decoration: InputDecoration(
                          hintText: 'Describe your issue in detail...',
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white30 : Colors.black26, 
                            fontSize: 15
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                    Text(
                      'Attachments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildAttachCard(
                            context,
                            icon: Icons.camera_alt_rounded,
                            label: 'Camera',
                            onTap: () => _pickImage(ImageSource.camera),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAttachCard(
                            context,
                            icon: Icons.image_rounded,
                            label: 'Gallery',
                            onTap: () => _pickImage(ImageSource.gallery),
                          ),
                        ),
                      ],
                    ),

                    if (_image != null) ...[
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.file(_image!, height: 160, width: double.infinity, fit: BoxFit.cover),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: GestureDetector(
                                onTap: () => setState(() { _image = null; }),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.black54,
                                  radius: 15,
                                  child: Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitGrievance,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E66E7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting 
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Submit Complaint',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const Color primaryPurple = Color(0xFF5C59E8);
    final Color cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
          border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryPurple, size: 30),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
