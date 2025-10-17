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

  // Static sample data similar to NotesSubjectsScreen
  final List<_MasyaudaTopic> _topics = const [
    _MasyaudaTopic(
      id: 'masyauda_rit',
      name: 'रिट',
      isPremium: false,
      pdfs: [
        _MasyaudaPdf(
          id: 'rit_habeas',
          name: 'हाबियस कर्पस नमूना',
          downloadUrl: '',
          pageCount: 4,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'rit_mandamus',
          name: 'म्यान्डामस नमूना',
          downloadUrl: '',
          pageCount: 5,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'rit_certiorari',
          name: 'सर्टियोरारी नमूना',
          downloadUrl: '',
          pageCount: 3,
          isPremium: false,
        ),
      ],
    ),
    _MasyaudaTopic(
      id: 'masyauda_dewani',
      name: 'देवानी',
      isPremium: true,
      pdfs: [
        _MasyaudaPdf(
          id: 'civil_inheritance',
          name: 'विरासत सम्बन्धी मस्यौदा',
          downloadUrl: '',
          pageCount: 6,
          isPremium: true,
        ),
        _MasyaudaPdf(
          id: 'civil_contract',
          name: 'करार उल्लंघन मस्यौदा',
          downloadUrl: '',
          pageCount: 7,
          isPremium: true,
        ),
        _MasyaudaPdf(
          id: 'civil_possession',
          name: 'कब्जा माग मस्यौदा',
          downloadUrl: '',
          pageCount: 5,
          isPremium: true,
        ),
      ],
    ),
    _MasyaudaTopic(
      id: 'masyauda_faujdaari',
      name: 'फौजदारी',
      isPremium: false,
      pdfs: [
        _MasyaudaPdf(
          id: 'criminal_bail',
          name: 'जमानत निवेदन नमूना',
          downloadUrl: '',
          pageCount: 4,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'criminal_appeal',
          name: 'अपिल निवेदन नमूना',
          downloadUrl: '',
          pageCount: 6,
          isPremium: false,
        ),
        _MasyaudaPdf(
          id: 'criminal_complaint',
          name: 'जिल्ला नापतौल उजुरी',
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
        title: const Text('मस्यौदा लेखन'),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: locked
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                locked ? Icons.lock_outline : Icons.lock_open_outlined,
                color: locked
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : Colors.green.withValues(alpha: 0.6),
                size: 14,
              ),
            ),
            title: Text(
              topic.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 14,
                  color: Colors.black54,
                ),
                const SizedBox(width: 4),
                Text(
                  '${topic.pdfs.length} PDFs',
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
              ],
            ),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.black54,
            ),
            onTap: () {
              setState(() {
                _expanded[topic.id] = !isExpanded;
              });
            },
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...topic.pdfs.map(
                    (pdf) => _buildPdfItem(context, topic.name, pdf, locked),
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
    return InkWell(
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
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.picture_as_pdf_outlined,
              color: Colors.red.shade600,
              size: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pdf.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pdf.pageCount} पृष्ठ',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              locked ? Icons.lock_outline : Icons.lock_open_outlined,
              size: 10,
              color: locked
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : Colors.green.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            IconButton(
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
              icon: const Icon(Icons.chrome_reader_mode_outlined, size: 16),
              color: Colors.black54,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'पढ्नुहोस्',
            ),
          ],
        ),
      ),
    );
  }
}

// The dedicated Masyauda PDF viewer is no longer needed; using PdfViewerScreen
