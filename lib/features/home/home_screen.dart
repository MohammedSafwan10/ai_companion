import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/theme_provider.dart';
import '../../core/widgets/glass_card.dart';
import '../dashboard/dashboard_screen.dart';
import '../chat/chat_screen.dart';
import '../email_generator/email_generator_screen.dart';
import '../code_generator/code_generator_screen.dart';
import '../quiz_generator/quiz_generator_screen.dart';
import '../youtube_summarizer/youtube_summarizer_screen.dart';
import '../tweet_crafter/tweet_crafter_screen.dart';
import '../instagram_caption/instagram_caption_screen.dart';
import '../translator/translator_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    _FeaturesHubScreen(),
    ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return Scaffold(
      extendBody: true,
      body: RepaintBoundary(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            borderRadius: BorderRadius.circular(30),
            opacity: isDark ? 0.1 : 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  Icons.window_rounded,
                  Icons.window_outlined,
                  'Hub',
                  isDark,
                ),
                _buildNavItem(
                  1,
                  Icons.category_rounded,
                  Icons.category_outlined,
                  'Tools',
                  isDark,
                ),
                _buildNavItem(
                  2,
                  Icons.rocket_launch_rounded,
                  Icons.rocket_launch_outlined,
                  'Chat',
                  isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData selectedIcon,
    IconData unselectedIcon,
    String label,
    bool isDark,
  ) {
    final isSelected = _currentIndex == index;
    final primaryColor = isDark
        ? const Color(0xFF818CF8)
        : const Color(0xFF6366F1);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              blurRadius: isSelected ? 15 : 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? Colors.white54 : Colors.black45),
                  size: 24,
                )
                .animate(target: isSelected ? 1 : 0)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.1, 1.1),
                )
                .shimmer(color: Colors.white24),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ).animate().fadeIn().slideX(begin: -0.2),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeaturesHubScreen extends StatelessWidget {
  const _FeaturesHubScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Features'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.fromLTRB(16, 120, 16, 200),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildFeatureCard(
              context,
              'Email Generator',
              Icons.email_rounded,
              const Color(0xFF6366F1),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmailGeneratorScreen(),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
            _buildFeatureCard(
              context,
              'Code Generator',
              Icons.code_rounded,
              const Color(0xFFEC4899),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CodeGeneratorScreen(),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            _buildFeatureCard(
              context,
              'Quiz Generator',
              Icons.quiz_rounded,
              const Color(0xFF8B5CF6),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QuizGeneratorScreen(),
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            _buildFeatureCard(
              context,
              'Tweet Crafter',
              Icons.chat_bubble_rounded,
              const Color(0xFF1DA1F2),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TweetCrafterScreen(),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
            _buildFeatureCard(
              context,
              'Instagram Caption',
              Icons.camera_rounded,
              const Color(0xFFE1306C),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const InstagramCaptionScreen(),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
            _buildFeatureCard(
              context,
              'YouTube Summarizer',
              Icons.video_library_rounded,
              const Color(0xFFFF0000),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const YouTubeSummarizerScreen(),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
            _buildFeatureCard(
              context,
              'Translator',
              Icons.translate_rounded,
              const Color(0xFF10B981),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TranslatorScreen(),
                ),
              ),
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
          ],
        ),
      ),
    );
  }
}

Widget _buildFeatureCard(
  BuildContext context,
  String title,
  IconData icon,
  Color color,
  VoidCallback onTap,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return GlassCard(
    padding: EdgeInsets.zero,
    opacity: isDark ? 0.05 : 0.02,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
