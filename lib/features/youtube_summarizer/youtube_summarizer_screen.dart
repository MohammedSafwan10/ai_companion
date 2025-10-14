import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/ai_model_provider.dart';
import '../../providers/gemini_provider.dart';
import '../../services/storage_service.dart';

class YouTubeSummarizerScreen extends ConsumerStatefulWidget {
  const YouTubeSummarizerScreen({super.key});

  @override
  ConsumerState<YouTubeSummarizerScreen> createState() =>
      _YouTubeSummarizerScreenState();
}

class _YouTubeSummarizerScreenState
    extends ConsumerState<YouTubeSummarizerScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _summary = '';
  bool _isLoading = false;

  Future<void> _summarizeVideo() async {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a YouTube URL')),
      );
      return;
    }

    final url = _urlController.text.trim();

    // Validate YouTube URL
    if (!url.contains('youtube.com') && !url.contains('youtu.be')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid YouTube URL')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final geminiService = ref.read(geminiServiceProvider);
      final currentModel = ref.read(aiModelProvider);

      // Gemini can directly process YouTube URLs
      final summary = await geminiService.summarizeYouTube(url, currentModel);

      setState(() {
        _summary = summary;
        _isLoading = false;
      });

      await StorageService.recordFeatureUsage(
        feature: 'youtube_summarizer',
        description: 'Summarized video $url',
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _copySummary() {
    Clipboard.setData(ClipboardData(text: _summary));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Summarizer')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _urlController,
              hintText: 'Paste YouTube URL here...',
              labelText: 'YouTube URL',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Summarize Video',
              icon: Icons.summarize,
              onPressed: _summarizeVideo,
              isLoading: _isLoading,
            ),
            if (_summary.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copySummary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _summary,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
