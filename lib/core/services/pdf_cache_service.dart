import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class PdfCacheService {
  static const String _cacheDirName = 'pdf_cache';
  static const String _metadataDirName = 'pdf_metadata';

  // Get app-only directory for PDFs
  static Future<Directory> _getAppDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${appDir.path}/$_cacheDirName');
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir;
  }

  // Get metadata directory
  static Future<Directory> _getMetadataDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final metadataDir = Directory('${appDir.path}/$_metadataDirName');
    if (!await metadataDir.exists()) {
      await metadataDir.create(recursive: true);
    }
    return metadataDir;
  }

  // Generate cache key from URL
  static String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Get cached file path
  static Future<String?> _getCachedFilePath(String url) async {
    final cacheKey = _generateCacheKey(url);
    final cacheDir = await _getAppDocumentsDirectory();
    final file = File('${cacheDir.path}/$cacheKey.pdf');
    return await file.exists() ? file.path : null;
  }

  // Get metadata file path
  static Future<String> _getMetadataFilePath(String url) async {
    final cacheKey = _generateCacheKey(url);
    final metadataDir = await _getMetadataDirectory();
    return '${metadataDir.path}/$cacheKey.json';
  }

  // PDF metadata model
  static Map<String, dynamic> _createMetadata({
    required String url,
    required String etag,
    required String lastModified,
    required DateTime cachedAt,
    required int fileSize,
  }) {
    return {
      'url': url,
      'etag': etag,
      'lastModified': lastModified,
      'cachedAt': cachedAt.toIso8601String(),
      'fileSize': fileSize,
    };
  }

  // Check if file is cached and valid
  static Future<bool> isCachedAndValid(String url) async {
    try {
      final cachedPath = await _getCachedFilePath(url);
      if (cachedPath == null) return false;

      final metadataPath = await _getMetadataFilePath(url);
      final metadataFile = File(metadataPath);
      if (!await metadataFile.exists()) return false;

      // Check if cached file still exists
      final cachedFile = File(cachedPath);
      if (!await cachedFile.exists()) return false;

      // Validate with server
      return await _validateCache(url, metadataPath);
    } catch (e) {
      // Error checking cache validity
      return false;
    }
  }

  // Validate cache with server
  static Future<bool> _validateCache(String url, String metadataPath) async {
    try {
      final metadataFile = File(metadataPath);
      final metadataContent = await metadataFile.readAsString();
      final metadata = jsonDecode(metadataContent) as Map<String, dynamic>;

      final etag = metadata['etag'] as String?;
      final lastModified = metadata['lastModified'] as String?;

      // Make HEAD request to check if file has been modified
      final response = await http.head(
        Uri.parse(url),
        headers: {
          if (etag != null) 'If-None-Match': etag,
          if (lastModified != null) 'If-Modified-Since': lastModified,
        },
      );

      // If 304 Not Modified, cache is still valid
      return response.statusCode == 304;
    } catch (e) {
      // Error validating cache
      return false;
    }
  }

  // Get cached file path if available and valid
  static Future<String?> getCachedFilePath(String url) async {
    if (await isCachedAndValid(url)) {
      return await _getCachedFilePath(url);
    }
    return null;
  }

  // Download and cache PDF
  static Future<String?> downloadAndCachePdf(String url) async {
    try {
      // Starting download

      // First, make a HEAD request to get metadata
      final headResponse = await http.head(Uri.parse(url));
      if (headResponse.statusCode != 200) {
        // HEAD request failed
        return null;
      }

      final etag = headResponse.headers['etag'];
      final lastModified = headResponse.headers['last-modified'];

      // Check if we already have a valid cached version
      if (await isCachedAndValid(url)) {
        // Valid cached version found
        return await _getCachedFilePath(url);
      }

      // Download the file
      // Downloading PDF
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        // Download failed
        return null;
      }

      // Save to app-only directory
      final cacheKey = _generateCacheKey(url);
      final cacheDir = await _getAppDocumentsDirectory();
      final file = File('${cacheDir.path}/$cacheKey.pdf');

      await file.writeAsBytes(response.bodyBytes);

      // Save metadata
      final metadata = _createMetadata(
        url: url,
        etag: etag ?? '',
        lastModified: lastModified ?? '',
        cachedAt: DateTime.now(),
        fileSize: response.bodyBytes.length,
      );

      final metadataPath = await _getMetadataFilePath(url);
      final metadataFile = File(metadataPath);
      await metadataFile.writeAsString(jsonEncode(metadata));

      // PDF cached successfully
      return file.path;
    } catch (e) {
      // Error downloading and caching PDF
      return null;
    }
  }

  // Preview PDF (stream from URL without caching)
  static Future<http.Response?> previewPdf(String url) async {
    try {
      // Previewing PDF
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // PDF preview successful
        return response;
      } else {
        // PDF preview failed
        return null;
      }
    } catch (e) {
      // Error previewing PDF
      return null;
    }
  }

  // Download PDF for offline use (permanent cache)
  static Future<bool> downloadForOffline(String url) async {
    try {
      final cachedPath = await downloadAndCachePdf(url);
      return cachedPath != null;
    } catch (e) {
      // Error downloading for offline
      return false;
    }
  }

  // Check if PDF is downloaded for offline use
  static Future<bool> isDownloadedForOffline(String url) async {
    return await isCachedAndValid(url);
  }

  // Clear cache for specific URL
  static Future<void> clearCache(String url) async {
    try {
      final cacheKey = _generateCacheKey(url);
      final cacheDir = await _getAppDocumentsDirectory();
      final metadataDir = await _getMetadataDirectory();

      // Remove cached file
      final cachedFile = File('${cacheDir.path}/$cacheKey.pdf');
      if (await cachedFile.exists()) {
        await cachedFile.delete();
      }

      // Remove metadata
      final metadataFile = File('${metadataDir.path}/$cacheKey.json');
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }

      // Cache cleared
    } catch (e) {
      // Error clearing cache
    }
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final cacheDir = await _getAppDocumentsDirectory();
      final metadataDir = await _getMetadataDirectory();

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      if (await metadataDir.exists()) {
        await metadataDir.delete(recursive: true);
      }

      // All cache cleared
    } catch (e) {
      // Error clearing all cache
    }
  }

  // Get cache size
  static Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getAppDocumentsDirectory();
      int totalSize = 0;

      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return totalSize;
    } catch (e) {
      // Error getting cache size
      return 0;
    }
  }

  // Get cache info
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final cacheDir = await _getAppDocumentsDirectory();
      final metadataDir = await _getMetadataDirectory();

      int fileCount = 0;
      int totalSize = 0;

      if (await cacheDir.exists()) {
        await for (final entity in cacheDir.list()) {
          if (entity is File) {
            fileCount++;
            totalSize += await entity.length();
          }
        }
      }

      return {
        'fileCount': fileCount,
        'totalSize': totalSize,
        'cacheDirectory': cacheDir.path,
        'metadataDirectory': metadataDir.path,
      };
    } catch (e) {
      // Error getting cache info
      return {
        'fileCount': 0,
        'totalSize': 0,
        'cacheDirectory': '',
        'metadataDirectory': '',
      };
    }
  }
}
