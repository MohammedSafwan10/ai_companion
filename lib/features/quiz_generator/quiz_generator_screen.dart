import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../providers/ai_model_provider.dart';
import '../../providers/gemini_provider.dart';
import '../../services/storage_service.dart';

class QuizGeneratorScreen extends ConsumerStatefulWidget {
  const QuizGeneratorScreen({super.key});

  @override
  ConsumerState<QuizGeneratorScreen> createState() =>
      _QuizGeneratorScreenState();
}

class _QuizGeneratorScreenState extends ConsumerState<QuizGeneratorScreen> {
  final TextEditingController _topicController = TextEditingController();
  int _questionCount = 5;
  String _generatedQuiz = '';
  bool _isLoading = false;

  Future<void> _generateQuiz() async {
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
      final result = await geminiService.generateQuiz(
        _topicController.text.trim(),
        _questionCount,
        currentModel,
      );

      setState(() {
        _generatedQuiz = result;
        _isLoading = false;
      });

      final topic = _topicController.text.trim();
      await StorageService.recordFeatureUsage(
        feature: 'quiz_generator',
        description:
            'Quiz on ${topic.isEmpty ? 'Untitled topic' : topic} ($_questionCount questions)',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Generator')),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _topicController,
              hintText: 'Enter quiz topic...',
              labelText: 'Topic',
            ),
            const SizedBox(height: 16),
            Text(
              'Number of Questions: $_questionCount',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _questionCount.toDouble(),
              min: 3,
              max: 10,
              divisions: 7,
              label: _questionCount.toString(),
              onChanged: (value) =>
                  setState(() => _questionCount = value.toInt()),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Generate Quiz',
              icon: Icons.quiz,
              onPressed: _generateQuiz,
              isLoading: _isLoading,
            ),
            if (_generatedQuiz.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Generated Quiz',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    _generatedQuiz,
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
    _topicController.dispose();
    super.dispose();
  }
}
