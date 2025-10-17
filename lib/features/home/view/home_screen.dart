import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../bloc/home_bloc.dart';
import '../widgets/exam_code_card.dart';
import '../../../core/constants/app_colors.dart';
import '../../exam/view/available_exams_screen.dart';
import '../../exam/view/subject_list_screen.dart';
import '../../notes/view/notes_subjects_screen.dart';
import '../../masyauda/view/masyauda_subjects_screen.dart';
import '../../bastugat/view/bastugat_subjects_screen.dart';
import '../../quiz/view/quiz_subjects_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(backgroundColor: AppColors.primary, elevation: 0),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoadInProgress || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeLoadFailure) {
            return Center(child: Text('Failed to load data: ${state.error}'));
          }
          if (state is HomeLoadSuccess) {
            // Main content of the screen
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        String userName = 'Guest';
                        if (state is HomeLoadSuccess) {
                          userName = state.userName;
                        }
                        return SizedBox(
                          height: 225,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 65,
                                child: Container(
                                  color: AppColors.primary,
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    20,
                                  ),
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'नमस्ते,\n$userName 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 16,
                                right: 16,
                                bottom: 0,
                                child: ExamCodeCard(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 25)),
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: const Text(
                        'विषयहरू',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  // Topics as a real SliverGrid to avoid unbounded height issues
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      delegate: SliverChildListDelegate([
                        _buildTopicItem(context, Icons.notes, 'वस्तुगत नोट्स'),
                        _buildTopicItem(
                          context,
                          Icons.flag_circle_outlined,
                          'विषयगत प्रश्नोत्तर',
                        ),
                        _buildTopicItem(
                          context,
                          Icons.edit_note,
                          'मस्यौदा लेखन',
                        ),
                        _buildTopicItem(
                          context,
                          Icons.quiz_outlined,
                          'वस्तुगत सेटहरु',
                        ),
                      ]),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 2.5,
                          ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  // Quiz card
                  SliverToBoxAdapter(child: _buildQuizOfTheDayCard(context)),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  // Promo carousel
                  SliverToBoxAdapter(child: _buildPromoCarousel()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          }
          return const Center(child: Text('Something went wrong!'));
        },
      ),
    );
  }

  Widget _buildTopicItem(BuildContext context, IconData icon, String label) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () {
          if (label == 'विषयगत प्रश्नोत्तर') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    SubjectListScreen.network(userHasPremium: false),
              ),
            );
          } else if (label == 'वस्तुगत सेटहरु') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AvailableExamsScreen()),
            );
          } else if (label == 'वस्तुगत नोट्स') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotesSubjectsScreen()),
            );
          } else if (label == 'मस्यौदा लेखन') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MasyaudaSubjectsScreen()),
            );
          } else if (label == 'वस्तुगत सेटहरु') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BastugatSubjectListScreen.network(),
              ),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }

  // Card below topics section with requested text
  Widget _buildQuizOfTheDayCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const QuizSubjectsScreen()));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 30),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '३४औ अधिवक्ता तहको परीक्षाका लागि तोकिएका नजिरहरु',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '३४औ अधिवक्ता तहको परीक्षाका लागि तोकिएका नजिरहरुको व्याख्या',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Promo carousel with 3 advertisement cards
  Widget _buildPromoCarousel() {
    return _PromoCarouselWidget();
  }
}

class _PromoCarouselWidget extends StatefulWidget {
  @override
  _PromoCarouselWidgetState createState() => _PromoCarouselWidgetState();
}

class _PromoCarouselWidgetState extends State<_PromoCarouselWidget> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> promoData = [
    {
      'title': 'बार लाइसेन्स तयारी संस्थान',
      'subtitle': 'व्यावसायिक कानूनी शिक्षा',
      'description': 'अधिवक्ता परीक्षाको लागि व्यावसायिक तयारी',
      'icon': Icons.school,
    },
    {
      'title': 'कानूनी पुस्तकहरू',
      'subtitle': 'संविधान र कानून',
      'description': 'सबै विषयका लागि व्यापक पुस्तकहरू',
      'icon': Icons.menu_book,
    },
    {
      'title': 'अनलाइन कोर्स',
      'subtitle': 'डिजिटल शिक्षा',
      'description': 'घरबाटै सिक्नुहोस् र तयार हुनुहोस्',
      'icon': Icons.laptop,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: CarouselSlider.builder(
            itemCount: promoData.length,
            itemBuilder: (context, index, realIndex) {
              final promo = promoData[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              promo['icon'],
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  promo['title'],
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  promo['subtitle'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        promo['description'],
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: false,
              viewportFraction: 1.0,
              aspectRatio: 2.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            promoData.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
