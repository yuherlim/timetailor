import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String apiKey;

  GeminiService(this.apiKey);

  Stream<String?> generateStreamedContent(String prompt, String action) async* {
    // Map actions to prompts
    String actionPrompt = '';
    switch (action.toLowerCase()) {
      case 'summarise': // British spelling
      case 'summarize': // American spelling
        actionPrompt = 'Summarize the following content: $prompt';
        break;
      case 'translate':
        actionPrompt =
            'Translate the following content to Chinese: $prompt'; // Adjust language as needed
        break;
      case 'improve content':
        actionPrompt =
            'Improve the grammar and readability of the following content: $prompt';
        break;
      default:
        throw Exception('Unknown action: $action');
    }

    // Configure the Generative Model
    final model = GenerativeModel(
      model: 'gemini-1.5-flash', // Ensure this matches your chosen model
      apiKey: apiKey,
    );

    // Stream the content
    final responses = model.generateContentStream([Content.text(actionPrompt)]);

    await for (final response in responses) {
      yield response.text; // Yield each chunk of the generated response
    }
  }
}
