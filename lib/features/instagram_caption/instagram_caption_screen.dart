import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/ai_model_provider.dart';
import '../../providers/gemini_provider.dart';
import '../../services/storage_service.dart';

class InstagramCaptionScreen extends ConsumerStatefulWidget {
  const InstagramCaptionScreen({super.key});

  @override
  ConsumerState<InstagramCaptionScreen> createState() =>
      _InstagramCaptionScreenState();
}

class _InstagramCaptionScreenState
    extends ConsumerState<InstagramCaptionScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String _generatedCaption = '';
  bool _isLoading = false;

  Future<void> _generateCaption() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final geminiService = ref.read(geminiServiceProvider);
    final currentModel = ref.read(aiModelProvider);

    try {
      final result = await geminiService.generateInstagramCaption(
        _descriptionController.text.trim(),
        currentModel,
      );

      setState(() {
        _generatedCaption = result;
        _isLoading = false;
      });

      final description = _descriptionController.text.trim();
      final snippet = description.isEmpty
          ? 'post'
          : (description.length > 40
                ? '${description.substring(0, 37)}...'
                : description);

      await StorageService.recordFeatureUsage(
        feature: 'instagram_caption',
        description: 'Caption generated for $snippet',
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

  void _copyCaption() {
    Clipboard.setData(ClipboardData(text: _generatedCaption));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caption copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instagram Caption')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _descriptionController,
              hintText: 'Describe your post...',
              labelText: 'Post Description',
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Generate Caption',
              icon: Icons.photo_camera,
              onPressed: _generateCaption,
              isLoading: _isLoading,
            ),
            if (_generatedCaption.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated Caption',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyCaption,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _generatedCaption,
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
    _descriptionController.dispose();
    super.dispose();
  }
}
