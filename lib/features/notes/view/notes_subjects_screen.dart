import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final locked = topic.isPremium && !userHasPremium;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
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
                _expandedTopics[topic.id] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icon container
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
                      locked
                          ? Icons.lock
                          : _getSubjectIcon(topic.name, topic.isSpecial),
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
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: topic.id.toUpperCase()),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${topic.id.toUpperCase()} copied to clipboard',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              },
                              child: Text(
                                topic.id.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              ' | ${topic.isSpecial ? 'विशिष्टिकृत' : 'संविधान र कानून'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
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
                              '${topic.pdfCount} ${topic.pdfCount == 1 ? 'PDF' : 'PDFs'}',
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

                  // Price and expand button
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (topic.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'रु. ${topic.price.toInt()}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
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
                            (pdf) => _buildPdfItem(
                              context,
                              pdf,
                              userHasPremium,
                              topic.name,
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
    );
  }

  Widget _buildPdfItem(
    BuildContext context,
    NotesPdf pdf,
    bool userHasPremium,
    String topicName,
  ) {
    final locked = pdf.isPremium && !userHasPremium;

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

  IconData _getSubjectIcon(String subjectName, bool isSpecial) {
    // More specific icons for different types of legal subjects
    final name = subjectName.toLowerCase();

    if (name.contains('संवैधानिक') || name.contains('constitutional')) {
      return Icons.account_balance; // Supreme Court building
    } else if (name.contains('प्रशासकीय') || name.contains('administrative')) {
      return Icons.admin_panel_settings; // Administrative settings
    } else if (name.contains('अपराध') ||
        name.contains('criminal') ||
        name.contains('फौजदारी')) {
      return Icons.gavel; // Gavel for criminal law
    } else if (name.contains('देवानी') || name.contains('civil')) {
      return Icons.handshake; // Handshake for civil law
    } else if (name.contains('न्याय') || name.contains('justice')) {
      return Icons.balance; // Scales of justice
    } else if (name.contains('प्रमाण') || name.contains('evidence')) {
      return Icons.fact_check; // Evidence/fact check
    } else if (name.contains('विधिशास्त्र') || name.contains('jurisprudence')) {
      return Icons.menu_book; // Book for jurisprudence
    } else if (name.contains('व्याख्या') || name.contains('interpretation')) {
      return Icons.translate; // Translation/interpretation
    } else if (name.contains('अदालत') || name.contains('court')) {
      return Icons.account_balance; // Court building
    } else if (name.contains('नेपालको कानून') || name.contains('nepal law')) {
      return Icons.flag; // Flag for Nepal law system
    } else if (name.contains('कानून व्याख्या') ||
        name.contains('legal interpretation')) {
      return Icons.translate; // Translation/interpretation
    }
    // Specialized subjects
    else if (name.contains('अन्तर्राष्ट्रिय') ||
        name.contains('international')) {
      return Icons.public; // Globe for international law
    } else if (name.contains('मानव अधिकार') || name.contains('human rights')) {
      return Icons.favorite; // Heart for human rights
    } else if (name.contains('कम्पनी') || name.contains('company')) {
      return Icons.business; // Business building
    } else if (name.contains('लैंगिक हिंसा') ||
        name.contains('gender') ||
        name.contains('violence')) {
      return Icons.security; // Security shield
    } else if (name.contains('बाल') || name.contains('child')) {
      return Icons.child_care; // Child care
    } else if (name.contains('संगठित अपराध') ||
        name.contains('organized crime')) {
      return Icons.warning; // Warning sign
    } else if (name.contains('विद्युतीय') ||
        name.contains('electronic') ||
        name.contains('digital')) {
      return Icons.computer; // Computer/electronic
    } else if (name.contains('भ्रष्टाचार') || name.contains('corruption')) {
      return Icons.block; // Block/stop corruption
    } else if (name.contains('विवाद समाधान') ||
        name.contains('dispute resolution')) {
      return Icons.mediation; // Mediation
    } else if (name.contains('बौद्धिक सम्पत्ति') ||
        name.contains('intellectual property')) {
      return Icons.lightbulb; // Lightbulb for ideas/IP
    } else if (name.contains('कर') || name.contains('tax')) {
      return Icons.account_balance_wallet; // Wallet for tax/money
    } else if (name.contains('पीडित') || name.contains('victim')) {
      return Icons.support; // Support for victims
    } else if (name.contains('आचार संहिता') ||
        name.contains('code of conduct')) {
      return Icons.rule; // Rules/conduct
    } else if (name.contains('वातावरण') || name.contains('environmental')) {
      return Icons.eco; // Eco/environment
    } else if (name.contains('बीमा') || name.contains('insurance')) {
      return Icons.security; // Security for insurance
    } else if (name.contains('श्रम') || name.contains('labor')) {
      return Icons.work; // Work for labor
    } else if (name.contains('बैंक') ||
        name.contains('banking') ||
        name.contains('वित्तीय')) {
      return Icons.account_balance_wallet; // Wallet for banking
    } else if (name.contains('अध्यागमन') || name.contains('immigration')) {
      return Icons.flight; // Flight for immigration
    } else if (name.contains('अनुसन्धान') || name.contains('research')) {
      return Icons.search; // Search for research
    } else if (name.contains('कानून') || name.contains('law')) {
      return Icons.library_books; // Law books
    } else {
      return Icons.balance; // Default scales of justice
    }
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
