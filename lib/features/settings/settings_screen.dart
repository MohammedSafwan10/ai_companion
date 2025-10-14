import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/config/app_constants.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: RepaintBoundary(
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildThemeCard(context, ref, isDark),
            const SizedBox(height: 16),
            _buildAboutCard(context, isDark),
            const SizedBox(height: 16),
            _buildDetailedAboutCard(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, WidgetRef ref, bool isDark) {
    return RepaintBoundary(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: isDark
                    ? const Color(0xFF818CF8)
                    : const Color(0xFF6366F1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Switch(
                value: isDark,
                onChanged: (_) {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                activeTrackColor: const Color(0xFF818CF8),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
    );
  }

  Widget _buildAboutCard(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: isDark
                      ? const Color(0xFF818CF8)
                      : const Color(0xFF6366F1),
                ),
                const SizedBox(width: 8),
                Text('About', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${AppConstants.appName} v${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'All-in-One AI Tools powered by Gemini 2.5 Flash',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildDetailedAboutCard(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Icon and Title
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF818CF8), const Color(0xFF3B82F6)]
                            : [
                                const Color(0xFF6366F1),
                                const Color(0xFFEC4899),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (isDark
                                      ? const Color(0xFF818CF8)
                                      : const Color(0xFF6366F1))
                                  .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 16),

            // Powered By
            _buildInfoRow(
              context,
              Icons.flash_on_rounded,
              'Powered By',
              'Google Gemini 2.5 Flash',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.code_rounded,
              'Framework',
              'Flutter',
              isDark,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              Icons.devices_rounded,
              'Platform',
              'Android & iOS',
              isDark,
            ),

            const SizedBox(height: 24),
            Divider(color: isDark ? Colors.white12 : Colors.black12),
            const SizedBox(height: 16),

            // Description
            Text(
              'Features',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              '• AI-powered chat conversations\n'
              '• Email generation with custom tones\n'
              '• Code generation in 14+ languages\n'
              '• Interactive quiz creation\n'
              '• YouTube video summarization\n'
              '• Social media content creation\n'
              '• Multi-language translation',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontSize: 14,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 24),

            // Contact/Links
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // Add link to website or repo
                },
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('Visit Website'),
                style: TextButton.styleFrom(
                  foregroundColor: isDark
                      ? const Color(0xFF818CF8)
                      : const Color(0xFF6366F1),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
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
            color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
