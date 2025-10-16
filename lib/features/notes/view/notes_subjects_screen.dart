import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/notes_service.dart';
import 'pdf_viewer_screen.dart';

class _NotesData {
  final List<NotesTopic> topics;
  final bool userHasPremium;
  const _NotesData(this.topics, this.userHasPremium);
}

class NotesSubjectsScreen extends StatefulWidget {
  const NotesSubjectsScreen({super.key});

  @override
  State<NotesSubjectsScreen> createState() => _NotesSubjectsScreenState();
}

class _NotesSubjectsScreenState extends State<NotesSubjectsScreen> {
  final Map<String, bool> _expandedTopics = {};
  Future<_NotesData>? _notesFuture;

  @override
  void initState() {
    super.initState();
    _notesFuture =
        Future.wait([
          NotesService.fetchNotesTopics(),
          NotesService.fetchUserPremium(),
        ]).then(
          (results) =>
              _NotesData(results[0] as List<NotesTopic>, results[1] as bool),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'वस्तुगत नोट्स',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<_NotesData>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final data = snapshot.data!;
          final topics = data.topics;
          final userHasPremium = data.userHasPremium;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: topics.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final topic = topics[index];
              final isExpanded = _expandedTopics[topic.id] ?? false;

              return _buildExpandableTopicCard(
                context,
                topic,
                isExpanded,
                userHasPremium,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildExpandableTopicCard(
    BuildContext context,
    NotesTopic topic,
    bool isExpanded,
    bool userHasPremium,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          // Unexpanded form - Topic header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: topic.isPremium
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                topic.isPremium && !userHasPremium
                    ? Icons.lock_outline
                    : Icons.lock_open_outlined,
                color: topic.isPremium && !userHasPremium
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
                  '${topic.pdfCount} ${topic.pdfCount == 1 ? 'PDF' : 'PDFs'}',
                  style: const TextStyle(color: Colors.black54, fontSize: 10),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: topic.isPremium
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    topic.isPremium ? 'प्रीमियम' : 'निःशुल्क',
                    style: TextStyle(
                      color: topic.isPremium
                          ? AppColors.primary.withValues(alpha: 0.7)
                          : Colors.green.withValues(alpha: 0.7),
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (topic.isPremium)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'रु. ${topic.price.toInt()}',
                      style: TextStyle(
                        color: AppColors.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                        fontSize: 9,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black54,
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _expandedTopics[topic.id] = !isExpanded;
              });
            },
          ),

          // Expanded form - PDF links
          if (isExpanded)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  ...topic.pdfs.map(
                    (pdf) =>
                        _buildPdfItem(context, pdf, userHasPremium, topic.name),
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
    NotesPdf pdf,
    bool userHasPremium,
    String topicName,
  ) {
    return InkWell(
      onTap: () {
        if (pdf.isPremium && !userHasPremium) {
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: pdf.isPremium
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pdf.isPremium ? 'प्रीमियम' : 'निःशुल्क',
                          style: TextStyle(
                            color: pdf.isPremium
                                ? AppColors.primary.withValues(alpha: 0.7)
                                : Colors.green.withValues(alpha: 0.7),
                            fontWeight: FontWeight.normal,
                            fontSize: 9,
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
              pdf.isPremium && !userHasPremium
                  ? Icons.lock_outline
                  : Icons.lock_open_outlined,
              size: 10,
              color: pdf.isPremium && !userHasPremium
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : Colors.green.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                if (pdf.isPremium && !userHasPremium) {
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

class NotesPdfViewerScreen extends StatelessWidget {
  final String subject;
  const NotesPdfViewerScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(subject, style: const TextStyle(color: Colors.white)),
      ),
      body: const Center(child: Text('यहाँ PDF दर्शक हुन्छ')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('साझा गर्नुहोस्'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('प्रिन्ट / सेभ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
