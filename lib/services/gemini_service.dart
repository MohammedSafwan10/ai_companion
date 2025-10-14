import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../core/config/env_config.dart';
import 'system_prompts.dart';

class GeminiService {
  ChatSession? _chatSession;
  
  ChatSession startChat(String systemPrompt, String modelName) {
    final model = GenerativeModel(
      model: modelName,
      apiKey: EnvConfig.geminiApiKey,
      systemInstruction: Content.system(systemPrompt),
    );
    
    _chatSession = model.startChat(history: []);
    return _chatSession!;
  }
  
  ChatSession resumeChat(
    String modelName,
    String systemPrompt,
    List<Content> history,
  ) {
    final model = GenerativeModel(
      model: modelName,
      apiKey: EnvConfig.geminiApiKey,
      systemInstruction: Content.system(systemPrompt),
    );
    
    _chatSession = model.startChat(history: history);
    return _chatSession!;
  }
  
  Future<String> sendChatMessage(String message, {String? imagePath}) async {
    if (_chatSession == null) {
      throw StateError('Chat session not started. Call startChat() first.');
    }
    
    try {
      if (imagePath != null) {
        final file = File(imagePath);
        final fileBytes = await file.readAsBytes();
        
        // Detect MIME type based on extension
        String mimeType = 'image/jpeg';
        final extension = imagePath.toLowerCase().split('.').last;
        
        if (extension == 'pdf') {
          mimeType = 'application/pdf';
        } else if (extension == 'txt') {
          mimeType = 'text/plain';
        } else if (extension == 'png') {
          mimeType = 'image/png';
        } else if (extension == 'webp') {
          mimeType = 'image/webp';
        } else if (extension == 'gif') {
          mimeType = 'image/gif';
        }
        
        final filePart = DataPart(mimeType, fileBytes);
        final textPart = TextPart(message.isEmpty ? 'Analyze this file' : message);
        
        final response = await _chatSession!.sendMessage(
          Content.multi([textPart, filePart]),
        );
        return response.text ?? 'No response generated';
      } else {
        final response = await _chatSession!.sendMessage(
          Content.text(message),
        );
        return response.text ?? 'No response generated';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // Streaming version for real-time responses
  Stream<String> sendChatMessageStream(String message, {String? imagePath}) async* {
    if (_chatSession == null) {
      throw StateError('Chat session not started. Call startChat() first.');
    }
    
    try {
      Stream<GenerateContentResponse> responseStream;
      
      if (imagePath != null) {
        final file = File(imagePath);
        final fileBytes = await file.readAsBytes();
        
        // Detect MIME type based on extension
        String mimeType = 'image/jpeg';
        final extension = imagePath.toLowerCase().split('.').last;
        
        if (extension == 'pdf') {
          mimeType = 'application/pdf';
        } else if (extension == 'txt') {
          mimeType = 'text/plain';
        } else if (extension == 'png') {
          mimeType = 'image/png';
        } else if (extension == 'webp') {
          mimeType = 'image/webp';
        } else if (extension == 'gif') {
          mimeType = 'image/gif';
        }
        
        final filePart = DataPart(mimeType, fileBytes);
        final textPart = TextPart(message.isEmpty ? 'Analyze this file' : message);
        
        responseStream = _chatSession!.sendMessageStream(
          Content.multi([textPart, filePart]),
        );
      } else {
        responseStream = _chatSession!.sendMessageStream(
          Content.text(message),
        );
      }
      
      // Stream each chunk as it arrives
      await for (final chunk in responseStream) {
        final text = chunk.text;
        if (text != null && text.isNotEmpty) {
          yield text;
        }
      }
    } catch (e) {
      yield 'Error: ${e.toString()}';
    }
  }
  
  List<Content> getChatHistory() {
    return _chatSession?.history.toList() ?? [];
  }

  Future<String> generateQuizWithFunctionCalling(
    String topic,
    int questionCount,
    String modelName,
  ) async {
    try {
      final quizFunction = FunctionDeclaration(
        'generate_quiz',
        'Generate a quiz with multiple choice questions on a given topic',
        Schema(
          SchemaType.object,
          properties: {
            'topic': Schema(SchemaType.string, description: 'The quiz topic'),
            'questions': Schema(
              SchemaType.array,
              description: 'Array of quiz questions',
              items: Schema(
                SchemaType.object,
                properties: {
                  'question': Schema(SchemaType.string, description: 'The question text'),
                  'optionA': Schema(SchemaType.string, description: 'Option A'),
                  'optionB': Schema(SchemaType.string, description: 'Option B'),
                  'optionC': Schema(SchemaType.string, description: 'Option C'),
                  'optionD': Schema(SchemaType.string, description: 'Option D'),
                  'correctAnswer': Schema(SchemaType.string, description: 'Correct answer: A, B, C, or D'),
                  'explanation': Schema(SchemaType.string, description: 'Explanation of the correct answer'),
                },
                requiredProperties: ['question', 'optionA', 'optionB', 'optionC', 'optionD', 'correctAnswer', 'explanation'],
              ),
            ),
          },
          requiredProperties: ['topic', 'questions'],
        ),
      );
      
      final model = GenerativeModel(
        model: modelName,
        apiKey: EnvConfig.geminiApiKey,
        systemInstruction: Content.system(SystemPrompts.quizGenerator),
        tools: [Tool(functionDeclarations: [quizFunction])],
        generationConfig: GenerationConfig(
          temperature: 0.7,
        ),
      );
      
      final prompt = 'Generate $questionCount quiz questions about: $topic';
      final response = await model.generateContent([Content.text(prompt)]);
      
      final functionCall = response.functionCalls.firstOrNull;
      if (functionCall != null && functionCall.name == 'generate_quiz') {
        final args = functionCall.args;
        final questions = args['questions'] as List;
        
        final buffer = StringBuffer();
        buffer.writeln('Quiz: ${args['topic']}\n');
        
        for (var i = 0; i < questions.length; i++) {
          final q = questions[i] as Map;
          buffer.writeln('Question ${i + 1}: ${q['question']}');
          buffer.writeln('A) ${q['optionA']}');
          buffer.writeln('B) ${q['optionB']}');
          buffer.writeln('C) ${q['optionC']}');
          buffer.writeln('D) ${q['optionD']}');
          buffer.writeln('Correct Answer: ${q['correctAnswer']}');
          buffer.writeln('Explanation: ${q['explanation']}\n');
        }
        
        return buffer.toString();
      }
      
      return response.text ?? 'Failed to generate quiz';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> generateContent(
    String prompt,
    String modelName,
    String systemPrompt,
  ) async {
    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: EnvConfig.geminiApiKey,
        systemInstruction: Content.system(systemPrompt),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 2048,
        ),
      );
      
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> generateEmail(String request, String tone, String modelName) async {
    final prompt = 'Create an email with a $tone tone. Request: $request';
    return generateContent(prompt, modelName, SystemPrompts.emailGenerator);
  }

  Future<String> generateCode(
    String description,
    String language,
    String modelName,
  ) async {
    final prompt = 'Generate $language code for: $description\n\nProvide clean, well-commented code with best practices.';
    return generateContent(prompt, modelName, SystemPrompts.codeGenerator);
  }

  Future<String> generateQuiz(String topic, int questionCount, String modelName) async {
    return generateQuizWithFunctionCalling(topic, questionCount, modelName);
  }

  Future<String> summarizeYouTube(String youtubeUrl, String modelName) async {
    final prompt = '''${SystemPrompts.youtubeSummarizer}

Please analyze and summarize this YouTube video: $youtubeUrl

Provide a comprehensive summary including:
1. Main topic and key points
2. Important insights or takeaways
3. Any notable conclusions or recommendations''';
    
    return generateContent(prompt, modelName, SystemPrompts.youtubeSummarizer);
  }

  Future<String> craftTweet(String topic, String modelName) async {
    final prompt = 'Create an engaging, attention-grabbing tweet about: $topic';
    return generateContent(prompt, modelName, SystemPrompts.tweetCrafter);
  }

  Future<String> generateInstagramCaption(String description, String modelName) async {
    final prompt = 'Create an Instagram caption for: $description';
    return generateContent(prompt, modelName, SystemPrompts.instagramCaption);
  }

  Future<String> translate(
    String text,
    String targetLanguage,
    String modelName,
  ) async {
    final prompt = 'Translate this to $targetLanguage:\n\n$text';
    return generateContent(prompt, modelName, SystemPrompts.translator);
  }
}
