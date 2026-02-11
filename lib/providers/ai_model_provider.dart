import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

final aiModelProvider = StateProvider<String>((ref) {
  return StorageService.getAiModel();
});

final thinkingProvider = StateProvider<bool>((ref) {
  return StorageService.getThinkingEnabled();
});
