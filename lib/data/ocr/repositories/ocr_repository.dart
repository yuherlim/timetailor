import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:timetailor/domain/ocr/repositories/ocr_repository_interface.dart';

class OCRRepository implements OCRRepositoryInterface {
  final TextRecognizer _textRecognizer;

  OCRRepository() : _textRecognizer = TextRecognizer();

  @override
  Future<String> recognizeTextFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } catch (e) {
      throw Exception("Error recognizing text: $e");
    }
  }

  void dispose() {
    _textRecognizer.close(); // Release resources
  }
}