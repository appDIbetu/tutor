import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/api_response_models.dart';
import '../../../core/premium/premium_bloc.dart';
import '../../notes/view/pdf_viewer_screen.dart';

class MasyaudaSubjectsScreen extends StatefulWidget {
  const MasyaudaSubjectsScreen({super.key});

  @override
  State<MasyaudaSubjectsScreen> createState() => _MasyaudaSubjectsScreenState();
}

// Old model classes removed - now using API models

class _MasyaudaSubjectsScreenState extends State<MasyaudaSubjectsScreen> {
  final Map<String, bool> _expanded = {};
  List<DraftingResponse> _draftingTopics = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDraftingTopics();
  }

  Future<void> _loadDraftingTopics() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final topics = await ApiService.getDrafting();
      setState(() {
        _draftingTopics = topics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Static sample data based on the syllabus image (fallback) - removed as we now use API
  /*
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
  */

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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Error loading drafting topics',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDraftingTopics,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_draftingTopics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No drafting topics available',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new content',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _draftingTopics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final topic = _draftingTopics[index];
        final isExpanded = _expanded[topic.id] ?? false;
        return _buildTopicCard(context, topic, isExpanded);
      },
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    DraftingResponse topic,
    bool isExpanded,
  ) {
    return _buildTopicCardContent(context, topic, isExpanded);
  }

  Widget _buildTopicCardContent(
    BuildContext context,
    DraftingResponse topic,
    bool isExpanded,
  ) {
    return BlocBuilder<PremiumBloc, PremiumState>(
      builder: (context, state) {
        // Use the is_locked field directly from API instead of checking premium status
        final isLocked = topic.isLocked;

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
          child: Stack(
            children: [
              Column(
                children: [
                  // Header section
                  InkWell(
                    onTap: () {
                      // Always allow expansion - don't check isLocked here
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
                              color: isLocked
                                  ? Colors.grey.shade100
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.folder_open,
                              color: AppColors.primary,
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
                                            ? AppColors.primary.withValues(
                                                alpha: 0.1,
                                              )
                                            : Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        topic.isPremium
                                            ? 'प्रीमियम'
                                            : 'निःशुल्क',
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
                                        _buildPdfItem(context, topic.name, pdf),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              // Lock icon in top right corner
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? Colors.grey.shade100
                        : Colors
                              .grey
                              .shade50, // Use grey background for unlocked (matching exam screen)
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock : Icons.lock_open,
                    color: isLocked
                        ? Colors.grey.shade600
                        : Colors
                              .grey
                              .shade600, // Use grey for unlocked (matching exam screen)
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPdfItem(
    BuildContext context,
    String topicName,
    PDFResponse pdf,
  ) {
    return _buildPdfItemContent(context, topicName, pdf);
  }

  Widget _buildPdfItemContent(
    BuildContext context,
    String topicName,
    PDFResponse pdf,
  ) {
    // Use the is_locked field directly from API instead of checking premium status
    final bool locked = pdf.isLocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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

// The dedicated Masyauda PDF viewer is no longer needed; using PdfViewerScreen
