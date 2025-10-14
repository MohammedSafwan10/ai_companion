import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_constants.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/ai_model_provider.dart';
import '../../providers/gemini_provider.dart';
import '../../services/storage_service.dart';

class EmailGeneratorScreen extends ConsumerStatefulWidget {
  const EmailGeneratorScreen({super.key});

  @override
  ConsumerState<EmailGeneratorScreen> createState() =>
      _EmailGeneratorScreenState();
}

class _EmailGeneratorScreenState extends ConsumerState<EmailGeneratorScreen> {
  final TextEditingController _requestController = TextEditingController();
  String _selectedTone = AppConstants.emailTones.first;
  String _generatedEmail = '';
  bool _isLoading = false;

  Future<void> _generateEmail() async {
    if (_requestController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your request')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final geminiService = ref.read(geminiServiceProvider);
    final currentModel = ref.read(aiModelProvider);

    try {
      final result = await geminiService.generateEmail(
        _requestController.text.trim(),
        _selectedTone,
        currentModel,
      );

      setState(() {
        _generatedEmail = result;
        _isLoading = false;
      });

      await StorageService.recordFeatureUsage(
        feature: 'email_generator',
        description: 'Email generated (${_selectedTone.toLowerCase()} tone)',
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

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedEmail));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Generator')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _requestController,
              hintText: 'What do you want to write about?',
              labelText: 'Email Request',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedTone,
              decoration: const InputDecoration(
                labelText: 'Tone',
                prefixIcon: Icon(Icons.tonality),
              ),
              items: AppConstants.emailTones.map((tone) {
                return DropdownMenuItem(value: tone, child: Text(tone));
              }).toList(),
              onChanged: (value) => setState(() => _selectedTone = value!),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Generate Email',
              icon: Icons.email,
              onPressed: _generateEmail,
              isLoading: _isLoading,
            ),
            if (_generatedEmail.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated Email',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _generatedEmail,
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
    _requestController.dispose();
    super.dispose();
  }
}
