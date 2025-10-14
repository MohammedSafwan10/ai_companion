import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_drawer.dart';
import '../../services/storage_service.dart';
import '../chat/chat_screen.dart';
import '../code_generator/code_generator_screen.dart';
import '../email_generator/email_generator_screen.dart';
import '../translator/translator_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<void> _refreshDashboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    if (mounted) setState(() {});
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour < 12) return Icons.wb_sunny_rounded;
    if (hour < 17) return Icons.wb_sunny_outlined;
    if (hour < 21) return Icons.wb_twilight_rounded;
    return Icons.nightlight_round;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usageStats = StorageService.getUsageStats();
    final recentActivities = StorageService.getActivityLog(limit: 6);

    final totalSessions = usageStats.values.fold<int>(
      0,
      (sum, value) => sum + value,
    );
    final uniqueFeaturesUsed = usageStats.entries
        .where((entry) => entry.value > 0)
        .length;

    final topFeatureEntry = usageStats.entries.isEmpty
        ? null
        : usageStats.entries.reduce(
            (current, next) => current.value >= next.value ? current : next,
          );
    final topFeature = topFeatureEntry == null
        ? null
        : _metaFor(topFeatureEntry.key);

    final highlightedStats = [
      _metaFor('chat'),
      _metaFor('code_generator'),
      _metaFor('email_generator'),
      _metaFor('translator'),
    ];

    final quickActions = [
      _QuickAction(
        meta: _metaFor('chat'),
        subtitle: 'Start a fresh conversation',
        builder: () => const ChatScreen(),
      ),
      _QuickAction(
        meta: _metaFor('code_generator'),
        subtitle: 'Generate production-ready snippets',
        builder: () => const CodeGeneratorScreen(),
      ),
      _QuickAction(
        meta: _metaFor('email_generator'),
        subtitle: 'Draft polished emails in seconds',
        builder: () => const EmailGeneratorScreen(),
      ),
      _QuickAction(
        meta: _metaFor('translator'),
        subtitle: 'Translate text across languages',
        builder: () => const TranslatorScreen(),
      ),
    ];

    final lastActivity = recentActivities.isEmpty
        ? null
        : recentActivities.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              _buildHeroSection(
                context: context,
                isDark: isDark,
                totalSessions: totalSessions,
                topFeature: topFeature,
                topFeatureUsage: topFeatureEntry?.value,
                uniqueFeaturesUsed: uniqueFeaturesUsed,
                lastActivity: lastActivity,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Quick Stats',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.trending_up_rounded,
                          size: 20,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildStatsGrid(
                      context: context,
                      isDark: isDark,
                      stats: highlightedStats,
                      usageStats: usageStats,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.bolt_rounded,
                          size: 20,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...quickActions.map(
                      (action) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildQuickAction(
                          context: context,
                          isDark: isDark,
                          action: action,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.history_rounded,
                          size: 20,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (recentActivities.isEmpty)
                      _buildEmptyActivityState(isDark)
                    else
                      ...recentActivities.map(
                        (activity) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildActivityCard(
                            context: context,
                            isDark: isDark,
                            activity: activity,
                          ),
                        ),
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

  Widget _buildHeroSection({
    required BuildContext context,
    required bool isDark,
    required int totalSessions,
    required _FeatureMeta? topFeature,
    required int? topFeatureUsage,
    required int uniqueFeaturesUsed,
    required DashboardActivity? lastActivity,
  }) {
    final greeting = _getGreeting();
    final greetingIcon = _getGreetingIcon();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF818CF8), const Color(0xFF3B82F6)]
              : [const Color(0xFF6366F1), const Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(greetingIcon, color: Colors.white, size: 24),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          uniqueFeaturesUsed > 0
                              ? '$uniqueFeaturesUsed tools used'
                              : 'Let\'s get started',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                '$greeting! 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                totalSessions > 0
                    ? 'You have completed $totalSessions AI tasks so far.'
                    : 'Kick off a conversation or try one of the creative tools.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        topFeature?.icon ?? Icons.bolt_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topFeature == null
                                ? 'No activity yet'
                                : '${topFeature.title} is on fire',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lastActivity == null
                                ? 'Your recent actions will appear here.'
                                : 'Last activity ${_formatTimestamp(lastActivity.timestamp)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (topFeatureUsage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          topFeatureUsage == 1
                              ? '1 use'
                              : '$topFeatureUsage uses',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  Widget _buildStatsGrid({
    required BuildContext context,
    required bool isDark,
    required List<_FeatureMeta> stats,
    required Map<String, int> usageStats,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                isDark: isDark,
                meta: stats[0],
                value: usageStats[stats[0].key] ?? 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                isDark: isDark,
                meta: stats[1],
                value: usageStats[stats[1].key] ?? 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                isDark: isDark,
                meta: stats[2],
                value: usageStats[stats[2].key] ?? 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                isDark: isDark,
                meta: stats[3],
                value: usageStats[stats[3].key] ?? 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required _FeatureMeta meta,
    required int value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  meta.color.withValues(alpha: 0.2),
                  meta.color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(meta.icon, color: meta.color, size: 24),
          ),
          const SizedBox(height: 14),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            meta.title,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required bool isDark,
    required _QuickAction action,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => action.builder()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      action.meta.color.withValues(alpha: 0.2),
                      action.meta.color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.meta.icon,
                  color: action.meta.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.meta.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required BuildContext context,
    required bool isDark,
    required DashboardActivity activity,
  }) {
    final meta = _metaFor(activity.feature);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  meta.color.withValues(alpha: 0.15),
                  meta.color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(meta.icon, size: 20, color: meta.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meta.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.9)
                        : Colors.black.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatTimestamp(activity.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No activity yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Run your first chat or generator task to start collecting insights.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  _FeatureMeta _metaFor(String key) {
    return _featureCatalog[key] ??
        _FeatureMeta(
          key: key,
          title: key
              .replaceAll('_', ' ')
              .split(' ')
              .map((word) {
                if (word.isEmpty) return word;
                final lower = word.toLowerCase();
                return '${lower[0].toUpperCase()}${lower.substring(1)}';
              })
              .join(' '),
          icon: Icons.bolt_rounded,
          color: const Color(0xFF818CF8),
        );
  }
}

class _FeatureMeta {
  const _FeatureMeta({
    required this.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String key;
  final String title;
  final IconData icon;
  final Color color;
}

class _QuickAction {
  const _QuickAction({
    required this.meta,
    required this.subtitle,
    required this.builder,
  });

  final _FeatureMeta meta;
  final String subtitle;
  final Widget Function() builder;
}

const Map<String, _FeatureMeta> _featureCatalog = {
  'chat': _FeatureMeta(
    key: 'chat',
    title: 'Chats',
    icon: Icons.chat_rounded,
    color: Color(0xFF3B82F6),
  ),
  'code_generator': _FeatureMeta(
    key: 'code_generator',
    title: 'Code Generated',
    icon: Icons.code_rounded,
    color: Color(0xFF10B981),
  ),
  'email_generator': _FeatureMeta(
    key: 'email_generator',
    title: 'Emails Crafted',
    icon: Icons.email_rounded,
    color: Color(0xFFF59E0B),
  ),
  'translator': _FeatureMeta(
    key: 'translator',
    title: 'Translations',
    icon: Icons.translate_rounded,
    color: Color(0xFF8B5CF6),
  ),
  'quiz_generator': _FeatureMeta(
    key: 'quiz_generator',
    title: 'Quizzes Built',
    icon: Icons.quiz_rounded,
    color: Color(0xFF6366F1),
  ),
  'youtube_summarizer': _FeatureMeta(
    key: 'youtube_summarizer',
    title: 'Video Summaries',
    icon: Icons.video_library_rounded,
    color: Color(0xFFFF4B55),
  ),
  'tweet_crafter': _FeatureMeta(
    key: 'tweet_crafter',
    title: 'Tweets Crafted',
    icon: Icons.alternate_email_rounded,
    color: Color(0xFF1DA1F2),
  ),
  'instagram_caption': _FeatureMeta(
    key: 'instagram_caption',
    title: 'Captions Written',
    icon: Icons.camera_alt_rounded,
    color: Color(0xFFE1306C),
  ),
};
