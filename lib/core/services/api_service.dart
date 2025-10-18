import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class ApiService {
  static const String baseUrl = 'https://bkd.pdfy.cloud';

  // Get headers with ID token for authenticated requests
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getIdToken();
    if (token == null) {
      print('Warning: No ID token available for API request');
    } else {
      print('ID token available: ${token.substring(0, 20)}...');
    }
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

  // Update Firebase user profile
  static Future<Map<String, dynamic>?> updateFirebaseUserProfile(
    Map<String, dynamic> updateData,
  ) async {
    try {
      final headers = await _getHeaders();
      print('Updating Firebase user profile with data: $updateData');
      print('Headers: $headers');

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/firebase/profile'),
        headers: headers,
        body: json.encode(updateData),
      );

      print('Profile update response status: ${response.statusCode}');
      print('Profile update response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('Profile update successful: $result');
        return result;
      } else {
        print(
          'Profile update failed: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Profile update error: $e');
      return null;
    }
  }

  // Firebase user endpoint
  static Future<Map<String, dynamic>?> getFirebaseUser() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/firebase/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // User is already logged in elsewhere
        throw Exception('User already logged in on another device');
      } else {
        print('Firebase user request failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Firebase user request error: $e');
      rethrow;
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
