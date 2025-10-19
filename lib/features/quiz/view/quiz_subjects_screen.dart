import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/premium/premium_bloc.dart';
import '../../../core/helpers/premium_access_helper.dart';
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
          final userHasPremium = premiumState is PremiumActive;

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
              final najirIndex = entry.key;
              final item = entry.value;
              return _buildExpandableNotesItem(
                context,
                index,
                item,
                !_najirs[najirIndex].hasAccess(userHasPremium),
              );
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

    return PremiumAccessHelper.wrapWithAccessControl(
      context,
      item: notes,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            // Main notes item header
            InkWell(
              onTap: () {
                if (!hasAccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('यो PDF प्रीमियम मात्रका लागि हो।'),
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
                            _buildPdfItem(context, najirTitle, pdf, !hasAccess),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
  */

  Widget _buildExpandableNotesItem(
    BuildContext context,
    int index,
    NotesResponse notes,
    bool topicLocked,
  ) {
    final bool hasAccess = notes.hasAccess(!topicLocked);
    final String itemKey = '${notes.id}_$index';
    final bool isItemExpanded = _expanded[itemKey] ?? false;

    return PremiumAccessHelper.wrapWithAccessControl(
      context,
      item: notes,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: !hasAccess
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
                        color: !hasAccess
                            ? Colors.grey.shade100
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        !hasAccess ? Icons.lock : Icons.quiz_outlined,
                        color: !hasAccess
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
                              color: !hasAccess
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
                            .map(
                              (pdf) => _buildPdfItem(
                                context,
                                notes.name,
                                pdf,
                                !hasAccess,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfItem(
    BuildContext context,
    String topicName,
    PDFResponse pdf,
    bool topicLocked,
  ) {
    final bool hasAccess = pdf.hasAccess(!topicLocked);

    return PremiumAccessHelper.wrapWithAccessControl(
      context,
      item: pdf,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: InkWell(
          onTap: () {
            if (!hasAccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('यो PDF प्रीमियम मात्रका लागि हो।'),
                ),
              );
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
              color: !hasAccess ? Colors.grey.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: !hasAccess
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
                    color: !hasAccess
                        ? Colors.grey.shade200
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    Icons.picture_as_pdf_outlined,
                    color: !hasAccess
                        ? Colors.grey.shade600
                        : Colors.red.shade600,
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
                      color: !hasAccess ? Colors.grey.shade600 : Colors.black87,
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
                    color: !hasAccess
                        ? Colors.grey.shade200
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (!hasAccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('यो PDF प्रीमियम मात्रका लागि हो।'),
                          ),
                        );
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
                      !hasAccess
                          ? Icons.lock_outline
                          : Icons.visibility_outlined,
                      size: 12,
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
      ),
    );
  }
}
