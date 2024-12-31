import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/data/ai/api/gemini_service.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/env.dart';

class GeminiActionHandler {
  void handleGeminiStreamingAction(String action, WidgetRef ref) async {
    final content = ref.read(noteFormNotifierProvider).content.trim();
    final geminiService = GeminiService(Env.geminiApiKey);

    try {
      // Show a loading indicator or clear the result display
      CustomSnackbars.shortDurationSnackBar(
          contentString: 'Processing $action...');

      final stream = geminiService.generateStreamedContent(content, action);
      String result = '';

      await for (final chunk in stream) {
        // Append each streamed chunk
        result += chunk!;

        // Optionally display intermediate results
        ref.read(noteFormNotifierProvider.notifier).updateContent(
              "${content.trim()}\n\n### $action Result ###\n$result",
            );
      }

      // Final result display
      CustomSnackbars.shortDurationSnackBar(
          contentString: '$action completed successfully!');
    } catch (e) {
      CustomSnackbars.shortDurationSnackBar(
          contentString: 'Failed to $action: ${e.toString()}');
    }
  }
}
