import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/theme_provider.dart';
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
      body: RepaintBoundary(
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            selectedFontSize: 12.0,
            unselectedFontSize: 11.0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: 'Features',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
            ],
          ),
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
      appBar: AppBar(title: const Text('AI Features')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildFeatureCard(
            context,
            'Email Generator',
            Icons.email,
            const Color(0xFF6366F1),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EmailGeneratorScreen(),
              ),
            ),
          ),
          _buildFeatureCard(
            context,
            'Code Generator',
            Icons.code,
            const Color(0xFFEC4899),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CodeGeneratorScreen(),
              ),
            ),
          ),
          _buildFeatureCard(
            context,
            'Quiz Generator',
            Icons.quiz,
            const Color(0xFF8B5CF6),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QuizGeneratorScreen(),
              ),
            ),
          ),
          _buildFeatureCard(
            context,
            'Tweet Crafter',
            Icons.chat,
            const Color(0xFF1DA1F2),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TweetCrafterScreen(),
              ),
            ),
          ),
          _buildFeatureCard(
            context,
            'Instagram Caption',
            Icons.photo_camera,
            const Color(0xFFE1306C),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InstagramCaptionScreen(),
              ),
            ),
          ),
          _buildFeatureCard(
            context,
            'YouTube Summarizer',
            Icons.video_library,
            const Color(0xFFFF0000),
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const YouTubeSummarizerScreen(),
              ),
            ),
          ),
          _buildFeatureCard(
            context,
            'Translator',
            Icons.translate,
            const Color(0xFF10B981),
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TranslatorScreen()),
            ),
          ),
        ],
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
  return Card(
    elevation: 3,
    shadowColor: color.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
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
