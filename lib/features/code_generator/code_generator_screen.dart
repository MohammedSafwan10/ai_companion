import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import '../../core/config/app_constants.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/ai_model_provider.dart';
import '../../providers/gemini_provider.dart';
import '../../services/storage_service.dart';

class CodeGeneratorScreen extends ConsumerStatefulWidget {
  const CodeGeneratorScreen({super.key});

  @override
  ConsumerState<CodeGeneratorScreen> createState() =>
      _CodeGeneratorScreenState();
}

class _CodeGeneratorScreenState extends ConsumerState<CodeGeneratorScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedLanguage = AppConstants.programmingLanguages.first;
  String _generatedCode = '';
  bool _isLoading = false;

  Future<void> _generateCode() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter code description')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final geminiService = ref.read(geminiServiceProvider);
    final currentModel = ref.read(aiModelProvider);

    try {
      final result = await geminiService.generateCode(
        _descriptionController.text.trim(),
        _selectedLanguage,
        currentModel,
      );

      setState(() {
        _generatedCode = result;
        _isLoading = false;
      });

      await StorageService.recordFeatureUsage(
        feature: 'code_generator',
        description: 'Generated ${_selectedLanguage.toLowerCase()} code',
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

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _generatedCode));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Code copied to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Code Generator')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _descriptionController,
              hintText: 'Describe what you want to code...',
              labelText: 'Code Description',
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'Programming Language',
                prefixIcon: Icon(Icons.code),
              ),
              items: AppConstants.programmingLanguages.map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (value) => setState(() => _selectedLanguage = value!),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Generate Code',
              icon: Icons.code,
              onPressed: _generateCode,
              isLoading: _isLoading,
            ),
            if (_generatedCode.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated Code',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyCode,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SyntaxView(
                    code: _generatedCode,
                    syntax: _getSyntaxFromLanguage(_selectedLanguage),
                    syntaxTheme: SyntaxTheme.vscodeDark(),
                    withZoom: true,
                    withLinesCount: true,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Syntax _getSyntaxFromLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return Syntax.PYTHON;
      case 'javascript':
      case 'typescript':
        return Syntax.JAVASCRIPT;
      case 'java':
        return Syntax.JAVA;
      case 'c++':
      case 'c#':
        return Syntax.CPP;
      case 'dart':
        return Syntax.DART;
      case 'swift':
        return Syntax.SWIFT;
      case 'kotlin':
        return Syntax.KOTLIN;
      default:
        return Syntax.DART;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
