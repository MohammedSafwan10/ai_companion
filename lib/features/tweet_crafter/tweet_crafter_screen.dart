import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/ai_model_provider.dart';
import '../../providers/gemini_provider.dart';
import '../../services/storage_service.dart';

class TweetCrafterScreen extends ConsumerStatefulWidget {
  const TweetCrafterScreen({super.key});

  @override
  ConsumerState<TweetCrafterScreen> createState() => _TweetCrafterScreenState();
}

class _TweetCrafterScreenState extends ConsumerState<TweetCrafterScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _generatedTweet = '';
  bool _isLoading = false;

  Future<void> _craftTweet() async {
    if (_topicController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a topic')));
      return;
    }

    setState(() => _isLoading = true);

    final geminiService = ref.read(geminiServiceProvider);
    final currentModel = ref.read(aiModelProvider);

    try {
      final result = await geminiService.craftTweet(
        _topicController.text.trim(),
        currentModel,
      );

      setState(() {
        _generatedTweet = result;
        _isLoading = false;
      });

      final topic = _topicController.text.trim();
      final snippet = topic.isEmpty
          ? 'general topic'
          : (topic.length > 40 ? '${topic.substring(0, 37)}...' : topic);

      await StorageService.recordFeatureUsage(
        feature: 'tweet_crafter',
        description: 'Tweet crafted about: $snippet',
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

  void _copyTweet() {
    Clipboard.setData(ClipboardData(text: _generatedTweet));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tweet copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    final characterCount = _generatedTweet.length;
    final isOverLimit = characterCount > 280;

    return Scaffold(
      appBar: AppBar(title: const Text('Tweet Crafter')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _topicController,
              hintText: 'What do you want to tweet about?',
              labelText: 'Topic',
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Craft Tweet',
              icon: Icons.auto_awesome,
              onPressed: _craftTweet,
              isLoading: _isLoading,
            ),
            if (_generatedTweet.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated Tweet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      Text(
                        '$characterCount/280',
                        style: TextStyle(
                          color: isOverLimit ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _copyTweet,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        _generatedTweet,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (isOverLimit)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Warning: Tweet exceeds 280 characters',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
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
    _topicController.dispose();
    super.dispose();
  }
}
