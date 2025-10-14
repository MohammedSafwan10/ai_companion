import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/settings_screen.dart';
import '../../services/storage_service.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF818CF8), Color(0xFF3B82F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF818CF8,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'AI User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ai.user@example.com',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: isDark ? Colors.white12 : Colors.black12,
                thickness: 1,
                height: 1,
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.settings_rounded,
                      title: 'Settings',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.timeline_rounded,
                      title: 'Activity Log',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        _showActivityLog(context, isDark);
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.data_saver_off_rounded,
                      title: 'Clear Insights',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        _confirmClearInsights(context, isDark);
                      },
                    ),
                    _buildDrawerItem(
                      context: context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      isDark: isDark,
                      onTap: () {
                        Navigator.pop(context);
                        _showSupportDialog(context, isDark);
                      },
                    ),
                  ],
                ),
              ),

              // App Version
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'AI Companion v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark
              ? Colors.white.withValues(alpha: 0.87)
              : Colors.black.withValues(alpha: 0.87),
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showActivityLog(BuildContext context, bool isDark) {
    final activities = StorageService.getActivityLog();

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: isDark ? const Color(0xFF101327) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Activity Log',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Recent AI interactions and generated content summaries.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                if (activities.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No activity recorded yet.\nStart using the tools and insights will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: activities.length,
                      separatorBuilder: (_, __) => Divider(
                        color: isDark ? Colors.white10 : Colors.black12,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        final icon = _featureIcon(activity.feature);
                        final color = _featureColor(activity.feature);
                        final title = _featureTitle(activity.feature);
                        final timestamp = _formatTimestamp(activity.timestamp);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            activity.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                          trailing: Text(
                            timestamp,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white38 : Colors.black45,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmClearInsights(BuildContext context, bool isDark) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF101327) : null,
          title: const Text('Clear insights?'),
          content: const Text(
            'This removes usage statistics and the activity log. '
            'You can start collecting insights again right away.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                await StorageService.resetUsageStats();
                await StorageService.clearActivityLog();
                navigator.pop();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Insights cleared.')),
                  );
                }
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showSupportDialog(BuildContext context, bool isDark) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF101327) : null,
          title: const Text('Help & Support'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Need assistance or want to share feedback?'),
              SizedBox(height: 12),
              Text('• Email: support@ai-companion.app'),
              Text('• Documentation: docs.ai-companion.app'),
              Text('• Community: community.ai-companion.app'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  IconData _featureIcon(String feature) {
    switch (feature) {
      case 'chat':
        return Icons.chat_rounded;
      case 'code_generator':
        return Icons.code_rounded;
      case 'email_generator':
        return Icons.email_rounded;
      case 'translator':
        return Icons.translate_rounded;
      case 'quiz_generator':
        return Icons.quiz_rounded;
      case 'youtube_summarizer':
        return Icons.video_library_rounded;
      case 'tweet_crafter':
        return Icons.alternate_email_rounded;
      case 'instagram_caption':
        return Icons.camera_alt_rounded;
      default:
        return Icons.bolt_rounded;
    }
  }

  Color _featureColor(String feature) {
    switch (feature) {
      case 'chat':
        return const Color(0xFF3B82F6);
      case 'code_generator':
        return const Color(0xFF10B981);
      case 'email_generator':
        return const Color(0xFFF59E0B);
      case 'translator':
        return const Color(0xFF8B5CF6);
      case 'quiz_generator':
        return const Color(0xFF6366F1);
      case 'youtube_summarizer':
        return const Color(0xFFFF4B55);
      case 'tweet_crafter':
        return const Color(0xFF1DA1F2);
      case 'instagram_caption':
        return const Color(0xFFE1306C);
      default:
        return const Color(0xFF818CF8);
    }
  }

  String _featureTitle(String feature) {
    switch (feature) {
      case 'chat':
        return 'Chat Session';
      case 'code_generator':
        return 'Code Generated';
      case 'email_generator':
        return 'Email Created';
      case 'translator':
        return 'Translation Completed';
      case 'quiz_generator':
        return 'Quiz Crafted';
      case 'youtube_summarizer':
        return 'YouTube Summary';
      case 'tweet_crafter':
        return 'Tweet Crafted';
      case 'instagram_caption':
        return 'Instagram Caption';
      default:
        return 'AI Activity';
    }
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
}
