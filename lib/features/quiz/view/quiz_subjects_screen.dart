import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../notes/view/pdf_viewer_screen.dart';

class QuizSubjectsScreen extends StatefulWidget {
  const QuizSubjectsScreen({super.key});

  @override
  State<QuizSubjectsScreen> createState() => _QuizSubjectsScreenState();
}

class _QuizTopic {
  final String id;
  final String name;
  final bool isPremium;
  final List<_QuizPdf> pdfs;
  const _QuizTopic({
    required this.id,
    required this.name,
    required this.isPremium,
    required this.pdfs,
  });
}

class _QuizPdf {
  final String id;
  final String name;
  final String downloadUrl;
  final int pageCount;
  final bool isPremium;
  const _QuizPdf({
    required this.id,
    required this.name,
    required this.downloadUrl,
    required this.pageCount,
    required this.isPremium,
  });
}

class _QuizSubjectsScreenState extends State<QuizSubjectsScreen> {
  final Map<String, bool> _expanded = {};

  // Static sample data based on the 3 topics (excluding अनुबाद)
  final List<_QuizTopic> _topics = const [
    _QuizTopic(
      id: 'quiz_dewani',
      name: 'देवानी मुद्दाको लिखतको मस्यौदा',
      isPremium: false,
      pdfs: [
        _QuizPdf(
          id: 'dewani_najir_1',
          name: 'नजिर 1',
          downloadUrl: '',
          pageCount: 8,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'dewani_najir_2',
          name: 'नजिर 2',
          downloadUrl: '',
          pageCount: 6,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'dewani_najir_3',
          name: 'नजिर 3',
          downloadUrl: '',
          pageCount: 5,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'dewani_najir_4',
          name: 'नजिर 4',
          downloadUrl: '',
          pageCount: 4,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'dewani_najir_5',
          name: 'नजिर 5',
          downloadUrl: '',
          pageCount: 7,
          isPremium: false,
        ),
      ],
    ),
    _QuizTopic(
      id: 'quiz_faujdaari',
      name: 'फौजदारी मुद्दाको मस्यौदा लेखन',
      isPremium: false,
      pdfs: [
        _QuizPdf(
          id: 'faujdaari_najir_1',
          name: 'नजिर 1',
          downloadUrl: '',
          pageCount: 5,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'faujdaari_najir_2',
          name: 'नजिर 2',
          downloadUrl: '',
          pageCount: 4,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'faujdaari_najir_3',
          name: 'नजिर 3',
          downloadUrl: '',
          pageCount: 6,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'faujdaari_najir_4',
          name: 'नजिर 4',
          downloadUrl: '',
          pageCount: 7,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'faujdaari_najir_5',
          name: 'नजिर 5',
          downloadUrl: '',
          pageCount: 6,
          isPremium: false,
        ),
      ],
    ),
    _QuizTopic(
      id: 'quiz_rit',
      name: 'रिटसम्बन्धी लिखतको मस्यौदा लेखन',
      isPremium: false,
      pdfs: [
        _QuizPdf(
          id: 'rit_najir_1',
          name: 'नजिर 1',
          downloadUrl: '',
          pageCount: 12,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'rit_najir_2',
          name: 'नजिर 2',
          downloadUrl: '',
          pageCount: 5,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'rit_najir_3',
          name: 'नजिर 3',
          downloadUrl: '',
          pageCount: 4,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'rit_najir_4',
          name: 'नजिर 4',
          downloadUrl: '',
          pageCount: 6,
          isPremium: false,
        ),
        _QuizPdf(
          id: 'rit_najir_5',
          name: 'नजिर 5',
          downloadUrl: '',
          pageCount: 7,
          isPremium: false,
        ),
      ],
    ),
  ];

  final bool _userHasPremium = false; // adapt from state when available

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
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _topics.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final topic = _topics[index];
          final isExpanded = _expanded[topic.id] ?? false;
          return _buildTopicCard(context, topic, isExpanded);
        },
      ),
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    _QuizTopic topic,
    bool isExpanded,
  ) {
    final bool locked = topic.isPremium && !_userHasPremium;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: locked
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
                _expanded[topic.id] = !isExpanded;
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
                      color: locked
                          ? Colors.grey.shade100
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      locked ? Icons.lock : Icons.folder_open,
                      color: locked ? Colors.grey.shade600 : AppColors.primary,
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
                          topic.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: locked
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
                              '${topic.pdfs.length} ${topic.pdfs.length == 1 ? 'PDF' : 'PDFs'}',
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
                                color: topic.isPremium
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                topic.isPremium ? 'प्रीमियम' : 'निःशुल्क',
                                style: TextStyle(
                                  color: topic.isPremium
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
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded PDF list
          if (isExpanded)
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
                      children: topic.pdfs
                          .map(
                            (pdf) =>
                                _buildPdfItem(context, topic.name, pdf, locked),
                          )
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
    _QuizPdf pdf,
    bool topicLocked,
  ) {
    final bool locked = (pdf.isPremium || topicLocked) && !_userHasPremium;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          if (locked) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('यो PDF प्रीमियम मात्रका लागि हो।')),
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: locked ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: locked
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
                  color: locked ? Colors.grey.shade200 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.picture_as_pdf_outlined,
                  color: locked ? Colors.grey.shade600 : Colors.red.shade600,
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
                      pdf.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: locked ? Colors.grey.shade600 : Colors.black87,
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
                          '${pdf.pageCount} पृष्ठ',
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
                            color: pdf.isPremium
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pdf.isPremium ? 'प्रीमियम' : 'निःशुल्क',
                            style: TextStyle(
                              color: pdf.isPremium
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
                  color: locked
                      ? Colors.grey.shade200
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  onPressed: () {
                    if (locked) {
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
                    locked ? Icons.lock_outline : Icons.visibility_outlined,
                    size: 16,
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
}
