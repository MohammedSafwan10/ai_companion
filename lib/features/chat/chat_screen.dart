import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:native_file_picker/native_file_picker.dart';
import '../../core/widgets/message_bubble.dart';
import '../../core/widgets/thinking_indicator.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/ai_model_provider.dart';
import '../../providers/gemini_provider.dart';
import '../../services/storage_service.dart';
import '../../services/system_prompts.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  String? _selectedImagePath;
  bool _showScrollToBottom = false;
  bool _shouldCancelRequest = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _scrollController.addListener(_onScroll);
    // Use addListener with debounce for better performance
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    // Only rebuild if send button state actually changes
    final hasText = _messageController.text.isNotEmpty;
    if ((hasText && _selectedImagePath == null) ||
        (!hasText && _selectedImagePath != null)) {
      if (mounted) setState(() {});
    } else if (hasText || _selectedImagePath != null) {
      if (mounted) setState(() {});
    }
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final showButton =
          _scrollController.offset <
          _scrollController.position.maxScrollExtent - 100;
      if (showButton != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = showButton;
        });
      }
    }
  }

  void _initializeChat() {
    final geminiService = ref.read(geminiServiceProvider);
    final currentModel = ref.read(aiModelProvider);
    final isThinking = ref.read(thinkingProvider);
    final history = StorageService.getChatHistory();

    if (history.isEmpty) {
      geminiService.startChat(
        SystemPrompts.chatbot,
        currentModel,
        isThinking: isThinking,
      );
    } else {
      final contentHistory = history.map((msg) {
        final role = msg['role'] == 'user' ? 'user' : 'model';
        return Content(role, [TextPart(msg['message'] as String)]);
      }).toList();

      geminiService.resumeChat(
        currentModel,
        SystemPrompts.chatbot,
        contentHistory,
        isThinking: isThinking,
      );

      setState(() {
        _messages.addAll(
          history.map(
            (e) => {
              'role': e['role'] as String,
              'message': e['message'] as String,
            },
          ),
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedImagePath == null) {
      return;
    }

    final userMessage = _messageController.text.trim();
    final imagePath = _selectedImagePath;

    // Clear immediately for smooth UX
    _messageController.clear();

    // Reset cancel flag
    _shouldCancelRequest = false;

    // Single setState for all changes
    if (mounted) {
      setState(() {
        _selectedImagePath = null;
        _messages.add({
          'role': 'user',
          'message': userMessage,
          if (imagePath != null) 'image': imagePath,
        });
        // Add empty AI message for streaming
        _messages.add({'role': 'ai', 'message': ''});
        _isLoading = true;
      });
    }

    // Scroll after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    final geminiService = ref.read(geminiServiceProvider);
    final aiMessageIndex = _messages.length - 1;
    String fullResponse = '';

    try {
      // Use streaming for real-time responses
      final isThinking = ref.read(thinkingProvider);
      final responseStream = geminiService.sendChatMessageStream(
        userMessage,
        imagePath: imagePath,
        isThinking: isThinking,
      );

      await for (final chunk in responseStream) {
        // Check if request was cancelled
        if (_shouldCancelRequest || !mounted) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }

        fullResponse += chunk;

        if (mounted) {
          setState(() {
            _messages[aiMessageIndex]['message'] = fullResponse;
          });

          // Auto-scroll as text appears
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Save in background without blocking UI
      StorageService.saveChatHistory(_messages);

      final snippet = userMessage.isEmpty
          ? (imagePath != null ? 'Sent an attachment' : 'Message sent')
          : (userMessage.length > 40
                ? '${userMessage.substring(0, 37)}...'
                : userMessage);
      unawaited(
        StorageService.recordFeatureUsage(
          feature: 'chat',
          description: snippet,
        ),
      );
    } catch (e) {
      if (_shouldCancelRequest || !mounted) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _messages[aiMessageIndex]['message'] = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _stopGeneration() {
    setState(() {
      _shouldCancelRequest = true;
      _isLoading = false;
    });
  }

  void _regenerateLastResponse() async {
    if (_messages.isEmpty) return;

    // Find the last user message
    String? lastUserMessage;
    String? lastImagePath;

    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i]['role'] == 'user') {
        lastUserMessage = _messages[i]['message'];
        lastImagePath = _messages[i]['image'];
        break;
      }
    }

    if (lastUserMessage == null) return;

    // Remove the last AI response and add empty message for streaming
    setState(() {
      if (_messages.isNotEmpty && _messages.last['role'] == 'ai') {
        _messages.removeLast();
      }
      _messages.add({'role': 'ai', 'message': ''});
      _isLoading = true;
      _shouldCancelRequest = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    final geminiService = ref.read(geminiServiceProvider);
    final aiMessageIndex = _messages.length - 1;
    String fullResponse = '';

    try {
      // Use streaming for regenerate too
      final isThinking = ref.read(thinkingProvider);
      final responseStream = geminiService.sendChatMessageStream(
        lastUserMessage,
        imagePath: lastImagePath,
        isThinking: isThinking,
      );

      await for (final chunk in responseStream) {
        if (_shouldCancelRequest || !mounted) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          return;
        }

        fullResponse += chunk;

        if (mounted) {
          setState(() {
            _messages[aiMessageIndex]['message'] = fullResponse;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      StorageService.saveChatHistory(_messages);
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages[aiMessageIndex]['message'] = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Request permissions with auto-grant
      bool hasPermission = await _requestPermission(source);

      if (!hasPermission) {
        return; // Error already shown by _requestPermission
      }

      // Now pick the image
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Details',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Image Picker Error'),
                    content: SingleChildScrollView(
                      child: Text(
                        '${e.toString()}\n\nTroubleshooting:\n\n1. Stop the app completely\n2. Run: flutter clean\n3. Run: flutter pub get\n4. Run: flutter run\n\n(Hot restart doesn\'t work for permission plugins)',
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      // Pick file
      final result = await NativeFilePicker.pickFile(type: FileType.any);

      if (result != null && result.files.isNotEmpty && mounted) {
        final pickedFile = result.files.first;

        // Check file size (50MB limit)
        if (pickedFile.size > 50 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File too large! Max 50MB allowed.'),
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImagePath =
              pickedFile.path; // Reuse same variable for simplicity
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  bool _isImageFile(String path) {
    final ext = path.toLowerCase().split('.').last;
    return [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
      'heic',
      'heif',
    ].contains(ext);
  }

  IconData _getFileIcon(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'txt':
        return Icons.description;
      case 'doc':
      case 'docx':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileSize(String path) {
    try {
      final file = File(path);
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return '';
    }
  }

  Future<bool> _requestPermission(ImageSource source) async {
    try {
      // Only camera needs permission on Android 13+
      // Gallery uses system photo picker (no permission needed!)
      if (source == ImageSource.camera) {
        var status = await Permission.camera.status;

        if (status.isDenied || status.isRestricted) {
          status = await Permission.camera.request();
        }

        if (status.isPermanentlyDenied) {
          if (mounted) {
            _showPermissionDialog(
              'Camera Permission Required',
              'Camera access is required to take photos. Please enable it in Settings.',
            );
          }
          return false;
        }

        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera permission is required to take photos'),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return false;
        }

        return true;
      } else {
        // For gallery: Android 13+ uses system photo picker (no permission!)
        // Android 12 and below needs storage permission
        if (Platform.isAndroid) {
          // Try storage permission for Android 12 and below
          var storageStatus = await Permission.storage.status;

          // If permission is not determined, it means Android 13+ (no permission needed)
          if (storageStatus.isDenied) {
            storageStatus = await Permission.storage.request();

            if (!storageStatus.isGranted &&
                storageStatus != PermissionStatus.permanentlyDenied) {
              // On Android 13+, this will be "denied" but gallery still works
              return true; // Allow it to proceed
            }

            if (storageStatus.isPermanentlyDenied) {
              if (mounted) {
                _showPermissionDialog(
                  'Storage Permission',
                  'For Android 12 and below, storage permission is needed. Please enable it in Settings.',
                );
              }
              return false;
            }
          }
        }

        // Allow gallery access (works on Android 13+ without permission)
        return true;
      }
    } catch (e) {
      // If permission check fails, likely Android 13+ where no permission needed
      if (source == ImageSource.gallery) {
        return true; // Allow gallery on Android 13+
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return source ==
          ImageSource.gallery; // Allow gallery, block camera on error
    }
  }

  void _showPermissionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showAttachmentOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quick Access Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                  isDark: isDark,
                ),
                _buildQuickOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Photos',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                  isDark: isDark,
                ),
                _buildQuickOption(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'Files',
                  onTap: () {
                    Navigator.pop(context);
                    _pickFile();
                  },
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // AI Tools Options
            _buildToolOption(
              icon: Icons.auto_awesome,
              title: 'Create image',
              subtitle: 'Visualize anything',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Image generation coming soon!'),
                  ),
                );
              },
              isDark: isDark,
            ),
            _buildToolOption(
              icon: Icons.science_rounded,
              title: 'Deep research',
              subtitle: 'Get a detailed report',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deep research coming soon!')),
                );
              },
              isDark: isDark,
            ),
            _buildToolOption(
              icon: Icons.travel_explore_rounded,
              title: 'Web search',
              subtitle: 'Find real-time news and info',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Web search coming soon!')),
                );
              },
              isDark: isDark,
            ),

            const SizedBox(height: 12),

            // Explore Tools Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Explore tools',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF818CF8), const Color(0xFF3B82F6)]
                      : [const Color(0xFF6366F1), const Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF818CF8), const Color(0xFF3B82F6)]
                      : [const Color(0xFF6366F1), const Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear all messages?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Cancel any ongoing request
      _shouldCancelRequest = true;

      setState(() {
        _messages.clear();
        _isLoading = false;
      });
      await StorageService.clearChatHistory();

      final geminiService = ref.read(geminiServiceProvider);
      final currentModel = ref.read(aiModelProvider);
      geminiService.startChat(SystemPrompts.chatbot, currentModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearChat,
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Start a conversation',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 140),
                        itemCount: _messages.length + (_isLoading ? 1 : 0),
                        physics: const BouncingScrollPhysics(),
                        cacheExtent: 500, // Increased for smoother scrolling
                        addAutomaticKeepAlives: true,
                        addRepaintBoundaries: true,
                        itemBuilder: (context, index) {
                          if (index == _messages.length && _isLoading) {
                            return const ThinkingIndicator();
                          }
                          final message = _messages[index];
                          final isLastAiMessage =
                              message['role'] == 'ai' &&
                              index == _messages.length - 1 &&
                              !_isLoading;

                          return MessageBubble(
                            key: ValueKey('message_$index'),
                            message: message['message'] ?? '',
                            isUser: message['role'] == 'user',
                            imagePath: message['image'],
                            onRegenerate: isLastAiMessage
                                ? _regenerateLastResponse
                                : null,
                          );
                        },
                      ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedImagePath != null) ...[
                      Builder(
                        builder: (context) {
                          final isDark =
                              Theme.of(context).brightness == Brightness.dark;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8, left: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: _isImageFile(_selectedImagePath!)
                                          ? Image.file(
                                              File(_selectedImagePath!),
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: isDark
                                                      ? [
                                                          Colors
                                                              .purple
                                                              .shade700,
                                                          Colors.blue.shade700,
                                                        ]
                                                      : [
                                                          Colors
                                                              .purple
                                                              .shade400,
                                                          Colors.blue.shade400,
                                                        ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                _getFileIcon(
                                                  _selectedImagePath!,
                                                ),
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 120,
                                          child: Text(
                                            _selectedImagePath!
                                                .split('/')
                                                .last
                                                .split('\\')
                                                .last,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getFileSize(_selectedImagePath!),
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.black54,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => setState(
                                        () => _selectedImagePath = null,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.white.withValues(
                                                  alpha: 0.1,
                                                )
                                              : Colors.grey.withValues(
                                                  alpha: 0.2,
                                                ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Plus button (separate)
                        GestureDetector(
                          onTap: _showAttachmentOptions,
                          child: GlassCard(
                            padding: const EdgeInsets.all(11),
                            borderRadius: BorderRadius.circular(25),
                            opacity: isDark ? 0.08 : 0.04,
                            child: Icon(
                              Icons.add_rounded,
                              size: 24,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GlassCard(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                            borderRadius: BorderRadius.circular(28),
                            opacity: isDark ? 0.08 : 0.04,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintText: 'Ask AI Companion',
                                      hintStyle: TextStyle(
                                        fontSize: 16,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white.withValues(
                                                alpha: 0.4,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.35,
                                              ),
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    maxLines: 5,
                                    minLines: 1,
                                    textInputAction: TextInputAction.newline,
                                    keyboardType: TextInputType.multiline,
                                    cursorColor:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Send/Stop button inside
                                GestureDetector(
                                  onTap: _isLoading
                                      ? _stopGeneration
                                      : ((_messageController.text.isEmpty &&
                                                _selectedImagePath == null)
                                            ? null
                                            : _sendMessage),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient:
                                          (_isLoading ||
                                              _messageController
                                                  .text
                                                  .isNotEmpty ||
                                              _selectedImagePath != null)
                                          ? LinearGradient(
                                              colors:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? [
                                                      const Color(0xFF818CF8),
                                                      const Color(0xFF3B82F6),
                                                    ]
                                                  : [
                                                      const Color(0xFF6366F1),
                                                      const Color(0xFFEC4899),
                                                    ],
                                            )
                                          : null,
                                      color:
                                          (_messageController.text.isEmpty &&
                                              _selectedImagePath == null &&
                                              !_isLoading)
                                          ? (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? Colors.white.withValues(
                                                    alpha: 0.15,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.15,
                                                  ))
                                          : null,
                                      shape: BoxShape.circle,
                                    ),
                                    child: _isLoading
                                        ? Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.3,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          )
                                        : Icon(
                                            Icons.arrow_upward_rounded,
                                            size: 20,
                                            color:
                                                (_messageController
                                                        .text
                                                        .isNotEmpty ||
                                                    _selectedImagePath != null)
                                                ? Colors.white
                                                : (Theme.of(
                                                            context,
                                                          ).brightness ==
                                                          Brightness.dark
                                                      ? Colors.white.withValues(
                                                          alpha: 0.4,
                                                        )
                                                      : Colors.black.withValues(
                                                          alpha: 0.3,
                                                        )),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          if (_showScrollToBottom)
            Positioned(
              bottom: 90,
              right: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF818CF8)
                    : const Color(0xFF6366F1),
                onPressed: () {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
