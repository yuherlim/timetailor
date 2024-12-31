import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/data/ai/api/gemini_service.dart';
import 'package:timetailor/domain/ai/gemini_action_handler.dart';
import 'package:timetailor/env.dart';

final geminiProvider = Provider((ref) => GeminiService(Env.geminiApiKey));

// final geminiContentProcessorProvider =
//     FutureProvider.family<String, Map<String, String>>((ref, params) async {
//   final geminiService = ref.read(geminiProvider);
//   final action = params['action']!;
//   final content = params['content']!;
//   return await geminiService.processContent(action, content);
// });

final geminiActionHandlerProvider =
    Provider<GeminiActionHandler>((ref) => GeminiActionHandler());
