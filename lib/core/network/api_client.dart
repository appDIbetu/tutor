import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final Duration timeout;

  const ApiClient({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
    this.timeout = const Duration(seconds: 15),
  });

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse(baseUrl).replace(
      path: Uri.parse(baseUrl).path + path,
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
  }

  Future<dynamic> getJson(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final res = await http
        .get(
          _uri(path, query),
          headers: {...defaultHeaders, if (headers != null) ...headers},
        )
        .timeout(timeout);
    _throwIfNotOk(res);
    return _decode(res);
  }

  Future<dynamic> postJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final res = await http
        .post(
          _uri(path),
          headers: {...defaultHeaders, if (headers != null) ...headers},
          body: jsonEncode(body ?? {}),
        )
        .timeout(timeout);
    _throwIfNotOk(res);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    if (res.body.isEmpty) return null;
    return jsonDecode(res.body);
  }

  void _throwIfNotOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        'HTTP ${res.statusCode}: ${res.reasonPhrase}',
        res.statusCode,
        res.body,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? responseBody;
  ApiException(this.message, this.statusCode, [this.responseBody]);
  @override
  String toString() => 'ApiException($statusCode): $message';
}
