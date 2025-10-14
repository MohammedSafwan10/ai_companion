import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_constants.dart';

final aiModelProvider = Provider<String>((ref) {
  return AppConstants.geminiModel;
});
