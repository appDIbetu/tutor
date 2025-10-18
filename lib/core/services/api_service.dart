import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class ApiService {
  static const String baseUrl =
      'https://your-api-server.com/api'; // Replace with your actual API URL

  // Get headers with ID token for authenticated requests
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getIdToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Generic GET request with authentication
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('GET request failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('GET request error: $e');
      return null;
    }
  }

  // Generic POST request with authentication
  static Future<Map<String, dynamic>?> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        print('POST request failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('POST request error: $e');
      return null;
    }
  }

  // Generic PUT request with authentication
  static Future<Map<String, dynamic>?> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('PUT request failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('PUT request error: $e');
      return null;
    }
  }

  // Generic DELETE request with authentication
  static Future<bool> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('DELETE request error: $e');
      return false;
    }
  }

  // Example API methods for your app
  static Future<List<Map<String, dynamic>>?> getExams() async {
    final response = await get('/exams');
    return response?['exams']?.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>?> getSubjects() async {
    final response = await get('/subjects');
    return response?['subjects']?.cast<Map<String, dynamic>>();
  }

  static Future<List<Map<String, dynamic>>?> getNotes() async {
    final response = await get('/notes');
    return response?['notes']?.cast<Map<String, dynamic>>();
  }

  static Future<Map<String, dynamic>?> submitExamResult(
    Map<String, dynamic> result,
  ) async {
    return await post('/exam-results', result);
  }

  static Future<Map<String, dynamic>?> updateUserProfile(
    Map<String, dynamic> profile,
  ) async {
    return await put('/user/profile', profile);
  }
}
