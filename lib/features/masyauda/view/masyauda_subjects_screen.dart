import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../notes/view/pdf_viewer_screen.dart';

class MasyaudaSubjectsScreen extends StatefulWidget {
  const MasyaudaSubjectsScreen({super.key});

  @override
  State<MasyaudaSubjectsScreen> createState() => _MasyaudaSubjectsScreenState();
}

class _MasyaudaTopic {
  final String id;
  final String name;
  final bool isPremium;
  final List<_MasyaudaPdf> pdfs;
  const _MasyaudaTopic({
    required this.id,
    required this.name,
    required this.isPremium,
    required this.pdfs,
  });
}

class _MasyaudaPdf {
  final String id;
  final String name;
  final String downloadUrl;
  final int pageCount;
  final bool isPremium;
  const _MasyaudaPdf({
    required this.id,
    required this.name,
    required this.downloadUrl,
    required this.pageCount,
    required this.isPremium,
  });
}

class _MasyaudaSubjectsScreenState extends State<MasyaudaSubjectsScreen> {
  final Map<String, bool> _expanded = {};

  // Static sample data based on the syllabus image
  final List<_MasyaudaTopic> _topics = const [
    _MasyaudaTopic(
      id: 'masyauda_dewani',
      name: 'देवानी मुद्दाको लिखतको मस्यौदा',
      isPremium: false,
      pdfs: [
        _MasyaudaPdf(
          id: 'dewani_firadpatra',
          name: 'फिरादपत्र',
          downloadUrl: '',
          pageCount: 8,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'dewani_pratiuttarpatra',
          name: 'प्रतिउत्तरपत्र',
          downloadUrl: '',
          pageCount: 6,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'dewani_antarkalin',
          name: 'अन्तरकालीन आदेश उपरको निवेदन',
          downloadUrl: '',
          pageCount: 5,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'dewani_bahas',
          name: 'बहस नोट',
          downloadUrl: '',
          pageCount: 4,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'dewani_punaravedan',
          name: 'पुनरावेदन',
          downloadUrl: '',
          pageCount: 7,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'dewani_dopa',
          name: 'दो.पा. र पुनरावलोकनको निवेदन',
          downloadUrl: '',
          pageCount: 6,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'dewani_vigo',
          name: 'विगो भराउने, चलन चलाउने र अंश छुट्याइ पाऊँ भन्ने निवेदन',
          downloadUrl: '',
          pageCount: 9,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'dewani_adhikrit',
          name: 'अधिकृत वारिसनामा',
          downloadUrl: '',
          pageCount: 3,
          isPremium: false,
        ),
      ],
    ),
    _MasyaudaTopic(
      id: 'masyauda_faujdaari',
      name: 'फौजदारी मुद्दाको मस्यौदा लेखन',
      isPremium: false,
      pdfs: [
        _MasyaudaPdf(
          id: 'faujdaari_thunchek',
          name: 'थुनछेक आदेश उपरको निवेदन',
          downloadUrl: '',
          pageCount: 5,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'faujdaari_bahas',
          name: 'बहस नोट',
          downloadUrl: '',
          pageCount: 4,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'faujdaari_sajaypurba',
          name: 'सजायपूर्वको प्रतिवेदन',
          downloadUrl: '',
          pageCount: 6,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'faujdaari_punaravedan',
          name: 'पुनरावेदनपत्र',
          downloadUrl: '',
          pageCount: 7,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'faujdaari_dopa',
          name: 'दो. पा. र पुनरावलोकनको निवेदन',
          downloadUrl: '',
          pageCount: 6,
          isPremium: false,
        ),
      ],
    ),
    _MasyaudaTopic(
      id: 'masyauda_rit',
      name: 'रिटसम्बन्धी लिखतको मस्यौदा लेखन',
      isPremium: false,
      pdfs: [
        _MasyaudaPdf(
          id: 'rit_writ_petition',
          name:
              'रिट निवेदन (उत्प्रेषण, परमादेश, प्रतिषेध, बन्दी प्रत्यक्षीकरण, अधिकारपृच्छा, निषेधाज्ञा र संविधानको धारा १३३(१) बमोजिमको निवेदन)',
          downloadUrl: '',
          pageCount: 12,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'rit_darpith',
          name: 'रिट निवेदन दरपीठ उपरको निवेदन',
          downloadUrl: '',
          pageCount: 5,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'rit_antrim',
          name: 'अन्तरिम आदेश उपरको उपचार',
          downloadUrl: '',
          pageCount: 4,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'rit_likhit_jawaf',
          name: 'लिखित जवाफ',
          downloadUrl: '',
          pageCount: 6,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'rit_uchcha_dopa',
          name: 'उच्च अदालतको आदेश उपर दो.पा. को निवेदन',
          downloadUrl: '',
          pageCount: 7,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'rit_punarawalokan',
          name: 'पुनरावलोकनको निवेदन',
          downloadUrl: '',
          pageCount: 5,
          isPremium: false,
        ),
      ],
    ),
    _MasyaudaTopic(
      id: 'masyauda_anuwaad',
      name: 'कानूनी अंग्रेजी नेपाली अनुबाद',
      isPremium: false,
      pdfs: [
        _MasyaudaPdf(
          id: 'anuwaad_nepali_english',
          name: 'कानूनी नेपालीबाट अंग्रेजीमा अनुवाद',
          downloadUrl: '',
          pageCount: 3,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'anuwaad_english_nepali',
          name: 'कानूनी अंग्रेजीबाट नेपालीमा अनुवाद',
          downloadUrl: '',
          pageCount: 3,
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
          'मस्यौदा लेखन',
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
    _MasyaudaTopic topic,
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
    _MasyaudaPdf pdf,
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

// The dedicated Masyauda PDF viewer is no longer needed; using PdfViewerScreen
