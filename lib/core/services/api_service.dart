import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/api_response_models.dart';

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

  // Educational Platform APIs

  // Get subjects with access control
  static Future<List<SubjectListResponse>> getSubjectsWithAccess({
    String? category,
    int limit = 50,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{'limit': limit.toString()};
      if (category != null) {
        queryParams['category'] = category;
      }

      final uri = Uri.parse(
        '$baseUrl/api/v1/education/subjects',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      print('Get subjects response status: ${response.statusCode}');
      print('Get subjects response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => SubjectListResponse.fromJson(item)).toList();
      } else {
        print('Get subjects failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get subjects error: $e');
      return [];
    }
  }

  // Get specific subject with questions
  static Future<SubjectResponse?> getSubject(String subjectId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/education/subjects/$subjectId'),
        headers: headers,
      );

      print('Get subject response status: ${response.statusCode}');
      print('Get subject response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SubjectResponse.fromJson(data);
      } else {
        print('Get subject failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Get subject error: $e');
      return null;
    }
  }

  // Get exams with access control
  static Future<List<ExamListResponse>> getExamsWithAccess({
    String? category,
    int limit = 50,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{'limit': limit.toString()};
      if (category != null) {
        queryParams['category'] = category;
      }

      final uri = Uri.parse(
        '$baseUrl/api/v1/education/exams',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      print('Get exams response status: ${response.statusCode}');
      print('Get exams response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ExamListResponse.fromJson(item)).toList();
      } else {
        print('Get exams failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get exams error: $e');
      return [];
    }
  }

  // Get specific exam with questions
  static Future<ExamResponse?> getExam(String examId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/education/exams/$examId'),
        headers: headers,
      );

      print('Get exam response status: ${response.statusCode}');
      print('Get exam response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ExamResponse.fromJson(data);
      } else {
        print('Get exam failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Get exam error: $e');
      return null;
    }
  }

  // Get notes with access control
  static Future<List<NotesResponse>> getNotesWithAccess({
    bool premiumOnly = false,
    bool freeOnly = false,
    int limit = 50,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'premium_only': premiumOnly.toString(),
        'free_only': freeOnly.toString(),
      };

      final uri = Uri.parse(
        '$baseUrl/api/v1/education/notes',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      print('Get notes response status: ${response.statusCode}');
      print('Get notes response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => NotesResponse.fromJson(item)).toList();
      } else {
        print('Get notes failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get notes error: $e');
      return [];
    }
  }

  // Get drafting (Masyauda Lekhan) with access control
  static Future<List<DraftingResponse>> getDrafting({
    String? category,
    int limit = 100,
  }) async {
    try {
      final headers = await _getHeaders();
      final queryParams = <String, String>{'limit': limit.toString()};
      if (category != null) {
        queryParams['category'] = category;
      }

      final uri = Uri.parse(
        '$baseUrl/api/v1/education/drafting',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers);

      print('Get drafting response status: ${response.statusCode}');
      print('Get drafting response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => DraftingResponse.fromJson(item)).toList();
      } else {
        print('Get drafting failed: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Get drafting error: $e');
      return [];
    }
  }

  // Get specific drafting by ID
  static Future<DraftingResponse?> getDraftingById(String draftingId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/education/drafting/$draftingId'),
        headers: headers,
      );

      print('Get drafting by ID response status: ${response.statusCode}');
      print('Get drafting by ID response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DraftingResponse.fromJson(data);
      } else {
        print(
          'Get drafting by ID failed: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Get drafting by ID error: $e');
      return null;
    }
  }

  // Search drafting
  static Future<List<DraftingResponse>> searchDrafting({
    required String query,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/api/v1/education/drafting/search',
      ).replace(queryParameters: {'query': query, 'limit': limit.toString()});

      final response = await http.get(uri, headers: headers);

      print('Search drafting response status: ${response.statusCode}');
      print('Search drafting response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => DraftingResponse.fromJson(item)).toList();
      } else {
        print(
          'Search drafting failed: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Search drafting error: $e');
      return [];
    }
  }

  // Get all upcoming exam najirs (Quiz of the Day)
  static Future<List<UpcomingExamNajirsResponse>> getUpcomingExamNajirs({
    int limit = 100,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/api/v1/education/upcoming-exam-najirs',
      ).replace(queryParameters: {'limit': limit.toString()});

      final response = await http.get(uri, headers: headers);

      print('Get upcoming exam najirs response status: ${response.statusCode}');
      print('Get upcoming exam najirs response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => UpcomingExamNajirsResponse.fromJson(item))
            .toList();
      } else {
        print(
          'Get upcoming exam najirs failed: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Get upcoming exam najirs error: $e');
      return [];
    }
  }

  // Get specific upcoming exam najir by ID
  static Future<UpcomingExamNajirsResponse?> getUpcomingExamNajir(
    String najirId,
  ) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/api/v1/education/upcoming-exam-najirs/$najirId',
      );

      final response = await http.get(uri, headers: headers);

      print('Get upcoming exam najir response status: ${response.statusCode}');
      print('Get upcoming exam najir response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UpcomingExamNajirsResponse.fromJson(data);
      } else {
        print(
          'Get upcoming exam najir failed: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Get upcoming exam najir error: $e');
      return null;
    }
  }

  // Search upcoming exam najirs
  static Future<List<UpcomingExamNajirsResponse>> searchUpcomingExamNajirs({
    required String query,
    int limit = 20,
  }) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl/api/v1/education/upcoming-exam-najirs/search',
      ).replace(queryParameters: {'query': query, 'limit': limit.toString()});

      final response = await http.get(uri, headers: headers);

      print(
        'Search upcoming exam najirs response status: ${response.statusCode}',
      );
      print('Search upcoming exam najirs response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => UpcomingExamNajirsResponse.fromJson(item))
            .toList();
      } else {
        print(
          'Search upcoming exam najirs failed: ${response.statusCode} - ${response.body}',
        );
        return [];
      }
    } catch (e) {
      print('Search upcoming exam najirs error: $e');
      return [];
    }
  }
}
