import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:convert';
import 'dart:async';
import '../../../core/services/pdf_cache_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final String topicName;
  final String pdfId;
  final String pdfUrl;
  final String pdfName;

  const PdfViewerScreen({
    super.key,
    required this.topicName,
    required this.pdfId,
    required this.pdfUrl,
    required this.pdfName,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;
  PdfViewerController? pdfController;
  int currentPage = 0;
  int totalPages = 0;
  bool isSavedLocally = false;
  bool isPreviewMode = true;
  bool _controlsVisible = true; // Show initially
  Timer? _controlsTimer;
  static const String _dummyPdfUrl =
      'https://www.nrb.org.np/contents/uploads/2021/07/%E0%A5%AC.-%E0%A4%B5%E0%A4%BF%E0%A4%A8%E0%A4%BF%E0%A4%AE%E0%A5%87%E0%A4%AF-%E0%A4%85%E0%A4%A7%E0%A4%BF%E0%A4%95%E0%A4%BE%E0%A4%B0%E0%A4%AA%E0%A4%A4%E0%A5%8D%E0%A4%B0-%E0%A4%90%E0%A4%A8-%E0%A5%A8%E0%A5%A6%E0%A5%A9%E0%A5%AA.pdf';

  @override
  void initState() {
    super.initState();
    pdfController = PdfViewerController();
    _loadPdf();
    // Hide controls after 2 seconds initially
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }

  Future<File> _getLocalFile() async {
    final dir = await getApplicationSupportDirectory();
    final fileName = '${_sanitizeFileName(widget.pdfId)}.pdf';
    return File('${dir.path}/$fileName');
  }

  Future<File> _getMetaFile() async {
    final dir = await getApplicationSupportDirectory();
    final fileName = '${_sanitizeFileName(widget.pdfId)}.meta.json';
    return File('${dir.path}/$fileName');
  }

  Future<Map<String, String>> _readMeta() async {
    try {
      final metaFile = await _getMetaFile();
      if (await metaFile.exists()) {
        final content = await metaFile.readAsString();
        final decoded = json.decode(content);
        return {
          'etag': decoded['etag'] ?? '',
          'lastModified': decoded['lastModified'] ?? '',
          'contentLength': decoded['contentLength']?.toString() ?? '',
        };
      }
    } catch (_) {}
    return {'etag': '', 'lastModified': '', 'contentLength': ''};
  }

  Future<void> _writeMeta(http.BaseResponse response) async {
    final metaFile = await _getMetaFile();
    final map = {
      'etag': response.headers['etag'] ?? '',
      'lastModified': response.headers['last-modified'] ?? '',
      'contentLength': response.headers['content-length'] ?? '',
    };
    await metaFile.writeAsString(json.encode(map), flush: true);
  }

  Future<http.Response?> _tryHead(String url) async {
    try {
      final head = await http.head(Uri.parse(url));
      // Some servers may not support HEAD properly; treat 200 as success
      if (head.statusCode >= 200 && head.statusCode < 400) {
        // Convert to Response-like for uniform header handling
        return http.Response('', head.statusCode, headers: head.headers);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _downloadAndSave(File file) async {
    final String url = (widget.pdfUrl).trim().isNotEmpty
        ? widget.pdfUrl
        : _dummyPdfUrl;
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('डाउनलोड त्रुटि (${response.statusCode})');
    }
    await file.writeAsBytes(response.bodyBytes, flush: true);
    await _writeMeta(response);
  }

  Future<void> _saveCurrentToPermanent() async {
    if (isSavedLocally) return;

    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final String url = (widget.pdfUrl).trim().isNotEmpty
          ? widget.pdfUrl
          : _dummyPdfUrl;

      // Downloading PDF for offline use

      // Try to download from URL first
      try {
        final cachedPath = await PdfCacheService.downloadAndCachePdf(url);

        if (cachedPath != null) {
          setState(() {
            localPath = cachedPath;
            isSavedLocally = true;
            isPreviewMode = false;
            isLoading = false;
          });
          // PDF downloaded and cached successfully

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('लोकरूपमा सुरक्षित गरियो।')),
            );
          }
          return;
        }
      } catch (e) {
        // Error downloading from URL, falling back to dummy PDF
      }

      // If URL download fails, generate and save dummy PDF
      final appDir = await getApplicationDocumentsDirectory();
      final permanentFile = File(
        '${appDir.path}/${widget.pdfId}_permanent.pdf',
      );
      await _generateAndSaveDummyPdf(permanentFile);

      setState(() {
        localPath = permanentFile.path;
        isSavedLocally = true;
        isPreviewMode = false;
        isLoading = false;
      });

      // Dummy PDF saved permanently

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('लोकरूपमा सुरक्षित गरियो।')),
        );
      }
    } catch (e) {
      // Error in save operation
      setState(() {
        errorMessage = 'PDF सेभ गर्न सकिएन: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _generateAndSaveDummyPdf(File file) async {
    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                widget.pdfName.isNotEmpty ? widget.pdfName : widget.topicName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'विषय: ${widget.topicName}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'PDF ID: ${widget.pdfId}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'यो एक नमुना PDF हो। वास्तविक PDF लोड गर्न सकिएन।',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'सामग्री:',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                '• यो PDF फाइलको नमुना हो\n• वास्तविक सामग्री यहाँ हुनेछ\n• यो केवल प्रदर्शनका लागि हो',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 30),
              pw.Text(
                'तयार गरिएको मिति: ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
    final bytes = await doc.save();
    await file.writeAsBytes(bytes, flush: true);
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final String url = (widget.pdfUrl).trim().isNotEmpty
          ? widget.pdfUrl
          : _dummyPdfUrl;

      // Loading PDF

      // First, try to get cached file
      final cachedPath = await PdfCacheService.getCachedFilePath(url);
      if (cachedPath != null) {
        // Using cached PDF
        setState(() {
          localPath = cachedPath;
          isSavedLocally = true;
          isPreviewMode = false;
          isLoading = false;
        });
        return;
      }

      // If no valid cache, preview first (stream from URL)
      // No valid cache found, previewing PDF
      await _previewPdf(url);
    } catch (e) {
      // Error loading PDF
      setState(() {
        errorMessage = 'PDF लोड गर्न सकिएन: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _previewPdf(String url) async {
    try {
      // Create a temporary file for preview
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/preview_${widget.pdfId}.pdf');

      // Try to download from URL first
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          await tempFile.writeAsBytes(response.bodyBytes);

          setState(() {
            localPath = tempFile.path;
            isSavedLocally = false;
            isPreviewMode = true;
            isLoading = false;
          });

          // PDF preview loaded from URL
          return;
        } else {
          // URL returned error, falling back to dummy PDF
        }
      } catch (e) {
        // Error downloading from URL, falling back to dummy PDF
      }

      // If URL fails, generate dummy PDF
      await _generateAndSaveDummyPdf(tempFile);

      setState(() {
        localPath = tempFile.path;
        isSavedLocally = false;
        isPreviewMode = true;
        isLoading = false;
      });

      // Dummy PDF generated for preview
    } catch (e) {
      // Error in preview
      setState(() {
        errorMessage = 'PDF प्रिव्यू गर्न सकिएन: $e';
        isLoading = false;
      });
    }
  }

  void _showControlsTemporarily() {
    setState(() {
      _controlsVisible = true;
    });
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _controlsVisible = false;
      });
    });
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    super.dispose();
  }

  Future<void> _downloadForPreview(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('डाउनलोड त्रुटि (${response.statusCode})');
      }

      // Save to temp file for preview
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/preview_${widget.pdfId}.pdf');
      await tempFile.writeAsBytes(response.bodyBytes, flush: true);

      setState(() {
        localPath = tempFile.path;
        isSavedLocally = false; // Not saved to permanent location yet
        isLoading = false;
      });
    } catch (_) {
      // Network failed; generate a small dummy PDF instead
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/preview_${widget.pdfId}.pdf');
      await _generateAndSaveDummyPdf(tempFile);
      setState(() {
        localPath = tempFile.path;
        isSavedLocally = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      floatingActionButton: null,
      body: _buildBody(context),
      bottomNavigationBar: null,
      extendBodyBehindAppBar: true,
      extendBody: true,
      resizeToAvoidBottomInset: false, // Prevent unnecessary rebuilds
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                _loadPdf();
              },
              child: const Text('पुनः प्रयास गर्नुहोस्'),
            ),
          ],
        ),
      );
    }
    if (localPath == null) {
      return const Center(child: Text('PDF फेला परेन'));
    }

    return Stack(
      children: [
        GestureDetector(
          onLongPressStart: (details) {
            // Prevent long press from showing copy menu
            // This blocks the context menu but allows other interactions
          },
          onLongPress: () {
            // Consume the long press event to prevent copy menu
          },
          child: SfPdfViewer.file(
            File(localPath!),
            controller: pdfController,
            onDocumentLoaded: (PdfDocumentLoadedDetails details) {
              setState(() {
                totalPages = details.document.pages.count;
              });
            },
            onPageChanged: (PdfPageChangedDetails details) {
              setState(() {
                currentPage = details.newPageNumber - 1;
              });
            },
            onTap: (PdfGestureDetails details) {
              if (_controlsVisible) {
                // If controls are visible, hide them immediately
                _controlsTimer?.cancel();
                setState(() {
                  _controlsVisible = false;
                });
              } else {
                // If controls are hidden, show them
                _showControlsTemporarily();
              }
            },
            enableDoubleTapZooming: true,
            enableTextSelection: false, // Allow text selection for highlighting
            canShowScrollHead: false, // Disable for smoother scrolling
            canShowScrollStatus: false,
            canShowPasswordDialog: false, // Disable for performance
            canShowPaginationDialog: false, // Disable for performance
            interactionMode:
                PdfInteractionMode.selection, // Allow text interaction
            scrollDirection: PdfScrollDirection.vertical,
            pageLayoutMode: PdfPageLayoutMode.continuous,
            enableDocumentLinkAnnotation: false, // Disable for performance
            maxZoomLevel: 3.0, // Limit zoom for better performance
          ),
        ),
        if (_controlsVisible)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      color: Colors.black,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ((widget.pdfName.isNotEmpty
                                    ? widget.pdfName
                                    : widget.topicName) +
                                ' (Notes)')
                            .trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: isSavedLocally
                          ? null
                          : _saveCurrentToPermanent,
                      color: Colors.black,
                      tooltip: isSavedLocally
                          ? 'पहिले नै डाउनलोड गरिएको'
                          : isPreviewMode
                          ? 'डाउनलोड गर्नुहोस्'
                          : 'डाउनलोड गर्नुहोस्',
                      icon: const Icon(Icons.download_for_offline_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_controlsVisible)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (totalPages > 0)
                      Row(
                        children: [
                          const SizedBox(width: 48),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${currentPage + 1} / $totalPages',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: FloatingActionButton(
                              onPressed: () async {
                                if (pdfController != null) {
                                  pdfController!.jumpToPage(1);
                                }
                              },
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.35,
                              ),
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.arrow_upward, size: 12),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/bastugat-subjects');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'यस विषयको वस्तुगत प्रश्नोत्तर',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
