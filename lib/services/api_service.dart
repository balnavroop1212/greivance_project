import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ApiService {
  static const String baseUrl = "https://backend-server-c513.onrender.com/api";

  // --- AUTHENTICATION ---

  Future<Map<String, dynamic>?> login(String rollNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "rollNumber": rollNumber,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("❌ Login Connection Error: $e");
      return null;
    }
  }

  Future<bool> signup(String name, String rollNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "name": name,
          "rollNumber": rollNumber,
          "password": password,
        }),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("❌ Signup Connection Error: $e");
      return false;
    }
  }

  // --- COMPLAINTS ---

  Future<String?> postComplaint({
    required String userId,
    required String category,
    required String subCategory,
    required String description,
    File? imageFile,
  }) async {
    try {
      if (kIsWeb) {
        final response = await http.post(
          Uri.parse('$baseUrl/add-complaint'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "userId": userId,
            "category": category,
            "subCategory": subCategory,
            "description": description,
            "status": "Pending",
          }),
        );
        return response.statusCode == 201 ? null : "Error: ${response.body}";
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/add-complaint'));
      request.headers.addAll({"Accept": "application/json"});
      
      request.fields['userId'] = userId;
      request.fields['category'] = category;
      request.fields['subCategory'] = subCategory;
      request.fields['description'] = description;
      request.fields['status'] = "Pending";

      if (imageFile != null) {
        if (!await imageFile.exists()) return "Error: Image file not found.";
        request.files.add(await http.MultipartFile.fromPath(
          'image', 
          imageFile.path,
          filename: basename(imageFile.path),
        ));
      }

      print("📤 Uploading complaint to $baseUrl...");
      var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      var response = await http.Response.fromStream(streamedResponse);

      print("📡 postComplaint Status: ${response.statusCode}");
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return null; // Success
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return errorData['message'] ?? "Server Error: ${response.statusCode}";
        } catch (e) {
          return "Server Error (${response.statusCode}): ${response.body}";
        }
      }
    } on SocketException {
      return "Network error. Please check your internet.";
    } catch (e) {
      return "Failed: $e";
    }
  }

  Future<List<dynamic>> getComplaints(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/complaints/$userId'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAllComplaints() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/all-complaints'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAllSuggestions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/admin/all-suggestions'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> deleteSuggestion(String suggestionId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/admin/delete-suggestion/$suggestionId'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> postSuggestion(String userId, String feedback) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add-suggestion'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "feedback": feedback,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
