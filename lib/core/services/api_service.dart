import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../models/api_response_models.dart';

class ApiService {
  static const String baseUrl = 'https://bkd.pdfy.cloud';

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
      final url = '$baseUrl$endpoint';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
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
      final url = '$baseUrl$endpoint';
      final body = json.encode(data);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
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
        return null;
      }
    } catch (e) {
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
      return false;
    }
  }

  // Update Firebase user profile
  static Future<Map<String, dynamic>?> updateFirebaseUserProfile(
    Map<String, dynamic> updateData,
  ) async {
    try {
      final headers = await _getHeaders();

      final response = await http.put(
        Uri.parse('$baseUrl/api/v1/firebase/profile'),
        headers: headers,
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return result;
      } else {
        return null;
      }
    } catch (e) {
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
        return null;
      }
    } catch (e) {
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

  // Submit exam result to the proper API endpoint
  static Future<ExamResultResponse?> submitExamResult(
    String examId,
    ExamResultCreate result,
  ) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/education/exams/$examId/submit'),
        headers: headers,
        body: json.encode(result.toJson()),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return ExamResultResponse.fromJson(result);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get my exam result for a specific exam
  static Future<ExamResultResponse?> getMyExamResult(String examId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/education/exams/$examId/my-result'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return ExamResultResponse.fromJson(result);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get exam with all results
  static Future<Map<String, dynamic>?> getExamWithResults(String examId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/education/exams/$examId/results'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get my exam history
  static Future<List<ExamResultResponse>> getMyExamHistory({
    int limit = 50,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/education/my-exam-history?limit=$limit'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ExamResultResponse.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
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

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => SubjectListResponse.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SubjectResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Get subject questions with pagination (for practice)
  static Future<QuestionListResponse?> getSubjectQuestions(
    String subjectId, {
    int startIndex = 0,
    int endIndex = 100,
    String sortOrder = 'oldest',
  }) async {
    try {
      final headers = await _getHeaders();
      final url =
          Uri.parse(
            '$baseUrl/api/v1/education/subjects/$subjectId/questions',
          ).replace(
            queryParameters: {
              'start_index': startIndex.toString(),
              'end_index': endIndex.toString(),
              'sort_order': sortOrder,
            },
          );

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return QuestionListResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => ExamListResponse.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ExamResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => NotesResponse.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => DraftingResponse.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DraftingResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => DraftingResponse.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => UpcomingExamNajirsResponse.fromJson(item))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UpcomingExamNajirsResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => UpcomingExamNajirsResponse.fromJson(item))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
