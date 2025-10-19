import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/premium/premium_bloc.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/api_response_models.dart';
import '../../notes/view/pdf_viewer_screen.dart';

class QuizSubjectsScreen extends StatefulWidget {
  const QuizSubjectsScreen({super.key});

  @override
  State<QuizSubjectsScreen> createState() => _QuizSubjectsScreenState();
}

class _QuizSubjectsScreenState extends State<QuizSubjectsScreen> {
  final Map<String, bool> _expanded = {};
  List<UpcomingExamNajirsResponse> _najirs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNajirs();
  }

  Future<void> _loadNajirs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final najirs = await ApiService.getUpcomingExamNajirs();

      setState(() {
        _najirs = najirs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          '३४औ अधिवक्ता तहको परीक्षाका लागि तोकिएका नजिरहरु',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: AppColors.background,
      body: BlocBuilder<PremiumBloc, PremiumState>(
        builder: (context, premiumState) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (_error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'डेटा लोड गर्न असफल भयो',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadNajirs,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('पुनः प्रयास गर्नुहोस्'),
                  ),
                ],
              ),
            );
          }

          if (_najirs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'कुनै नजिर उपलब्ध छैन',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'हालका लागि कुनै नजिर उपलब्ध छैन।',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          // Flatten all items from all najirs into a single list
          final allItems = <MapEntry<int, NotesResponse>>[];
          for (int i = 0; i < _najirs.length; i++) {
            final najir = _najirs[i];
            for (int j = 0; j < najir.items.length; j++) {
              allItems.add(MapEntry(i, najir.items[j]));
            }
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: allItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = allItems[index];
              final item = entry.value;
              return _buildExpandableNotesItem(context, index, item);
            },
          );
        },
      ),
    );
  }

  // Unused method - replaced by _buildExpandableNotesItem
  /*
  Widget _buildNotesItem(
    BuildContext context,
    String najirTitle,
    NotesResponse notes,
    bool topicLocked,
  ) {
    final bool hasAccess = notes.hasAccess(!topicLocked);

    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            // Main notes item header
            InkWell(
              onTap: () {
                if (!hasAccess) {
                  _showUpgradeDialog(context, notes.name);
                  return;
                }
                // Navigate to PDF viewer for the first PDF in the notes
                if (notes.pdfs.isNotEmpty) {
                  final firstPdf = notes.pdfs.first;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PdfViewerScreen(
                        topicName: najirTitle,
                        pdfId: firstPdf.id,
                        pdfUrl: firstPdf.downloadUrl,
                        pdfName: firstPdf.name,
                      ),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: !hasAccess ? Colors.grey.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: !hasAccess
                        ? Colors.grey.shade300
                        : AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // PDF icon
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: !hasAccess
                            ? Colors.grey.shade200
                            : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf_outlined,
                        color: !hasAccess
                            ? Colors.grey.shade600
                            : Colors.red.shade600,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notes.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: !hasAccess
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${notes.pdfCount} PDFs',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: notes.isPremium
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  notes.isPremium ? 'प्रीमियम' : 'निःशुल्क',
                                  style: TextStyle(
                                    color: notes.isPremium
                                        ? AppColors.primary
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action button
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: !hasAccess
                            ? Colors.grey.shade200
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        onPressed: () {
                          if (!hasAccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'यो PDF प्रीमियम मात्रका लागि हो।',
                                ),
                              ),
                            );
                            return;
                          }
                          // Navigate to PDF viewer for the first PDF in the notes
                          if (notes.pdfs.isNotEmpty) {
                            final firstPdf = notes.pdfs.first;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PdfViewerScreen(
                                  topicName: najirTitle,
                                  pdfId: firstPdf.id,
                                  pdfUrl: firstPdf.downloadUrl,
                                  pdfName: firstPdf.name,
                                ),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          !hasAccess
                              ? Icons.lock_outline
                              : Icons.visibility_outlined,
                          size: 16,
                          color: !hasAccess
                              ? Colors.grey.shade600
                              : AppColors.primary,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        tooltip: !hasAccess ? 'लक गरिएको' : 'पढ्नुहोस्',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // PDF list within the notes item
            if (notes.pdfs.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: Column(
                  children: notes.pdfs
                      .map(
                        (pdf) =>
                            _buildPdfItem(context, najirTitle, pdf),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      );
  }
  */

  Widget _buildExpandableNotesItem(
    BuildContext context,
    int index,
    NotesResponse notes,
  ) {
    // Use the is_locked field directly from API instead of checking premium status
    final bool isLocked = notes.isLocked;
    final String itemKey = '${notes.id}_$index';
    final bool isItemExpanded = _expanded[itemKey] ?? false;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isLocked
              ? Colors.grey.shade300
              : AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header section
          InkWell(
            onTap: () {
              // Always allow expansion - don't check hasAccess here
              setState(() {
                _expanded[itemKey] = !isItemExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Folder icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? Colors.grey.shade100
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock : Icons.quiz_outlined,
                      color: isLocked
                          ? Colors.grey.shade600
                          : AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notes.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isLocked
                                ? Colors.grey.shade600
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${notes.pdfCount} PDFs',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: notes.isPremium
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                notes.isPremium ? 'प्रीमियम' : 'निःशुल्क',
                                style: TextStyle(
                                  color: notes.isPremium
                                      ? AppColors.primary
                                      : Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Expand button
                  Icon(
                    isItemExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded PDF list
          if (isItemExpanded && notes.pdfs.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  Container(height: 1, color: Colors.grey.shade200),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: notes.pdfs
                          .map((pdf) => _buildPdfItem(context, notes.name, pdf))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPdfItem(
    BuildContext context,
    String topicName,
    PDFResponse pdf,
  ) {
    // Use the is_locked field directly from API instead of checking premium status
    final bool locked = pdf.isLocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          if (locked) {
            _showUpgradeDialog(context, pdf.name);
            return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(
                topicName: topicName,
                pdfId: pdf.id,
                pdfUrl: pdf.downloadUrl,
                pdfName: pdf.name,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: locked ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: locked
                  ? Colors.grey.shade200
                  : AppColors.primary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // PDF icon
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: locked ? Colors.grey.shade200 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.picture_as_pdf_outlined,
                  color: locked ? Colors.grey.shade600 : Colors.red.shade600,
                  size: 12,
                ),
              ),
              const SizedBox(width: 8),

              // Content
              Expanded(
                child: Text(
                  pdf.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: locked ? Colors.grey.shade600 : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Action button
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: locked
                      ? Colors.grey.shade200
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  onPressed: () {
                    if (locked) {
                      _showUpgradeDialog(context, pdf.name);
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          topicName: topicName,
                          pdfId: pdf.id,
                          pdfUrl: pdf.downloadUrl,
                          pdfName: pdf.name,
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    locked ? Icons.lock_outline : Icons.visibility_outlined,
                    size: 12,
                    color: locked ? Colors.grey.shade600 : AppColors.primary,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: locked ? 'लक गरिएको' : 'पढ्नुहोस्',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context, String itemName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Lock icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.lock_outline,
                size: 32,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'प्रीमियम अपग्रेड आवश्यक',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              '$itemName पहुँच गर्न प्रीमियम सदस्यता आवश्यक छ।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Upgrade button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('प्रीमियम अपग्रेड सुविधा जल्दै आउँदैछ!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'प्रीमियम अपग्रेड गर्नुहोस्',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'रद्द गर्नुहोस्',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
