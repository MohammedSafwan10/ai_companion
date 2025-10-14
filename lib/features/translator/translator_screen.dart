import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_constants.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/ai_model_provider.dart';
import '../../providers/gemini_provider.dart';
import '../../services/storage_service.dart';

class TranslatorScreen extends ConsumerStatefulWidget {
  const TranslatorScreen({super.key});

  @override
  ConsumerState<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends ConsumerState<TranslatorScreen> {
  final TextEditingController _textController = TextEditingController();
  String _selectedLanguage = AppConstants.supportedLanguages.first;
  String _translatedText = '';
  bool _isLoading = false;

  Future<void> _translate() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text to translate')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final geminiService = ref.read(geminiServiceProvider);
    final currentModel = ref.read(aiModelProvider);

    try {
      final result = await geminiService.translate(
        _textController.text.trim(),
        _selectedLanguage,
        currentModel,
      );

      setState(() {
        _translatedText = result;
        _isLoading = false;
      });

      await StorageService.recordFeatureUsage(
        feature: 'translator',
        description: 'Translated to $_selectedLanguage',
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

  void _copyTranslation() {
    Clipboard.setData(ClipboardData(text: _translatedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Translation copied to clipboard')),
    );
  }

  void _swapLanguages() {
    if (_translatedText.isNotEmpty) {
      setState(() {
        final temp = _textController.text;
        _textController.text = _translatedText;
        _translatedText = temp;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Translator')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _textController,
              hintText: 'Enter text to translate...',
              labelText: 'Text',
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Target Language',
                prefixIcon: Icon(Icons.language),
              ),
              items: AppConstants.supportedLanguages.map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (value) => setState(() => _selectedLanguage = value!),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Translate',
              icon: Icons.translate,
              onPressed: _translate,
              isLoading: _isLoading,
            ),
            if (_translatedText.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Translation',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.swap_vert),
                        onPressed: _swapLanguages,
                        tooltip: 'Swap',
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _copyTranslation,
                        tooltip: 'Copy',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _translatedText,
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
    _textController.dispose();
    super.dispose();
  }
}
