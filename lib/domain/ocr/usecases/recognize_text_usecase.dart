import 'package:timetailor/domain/ocr/repositories/ocr_repository_interface.dart';

class RecognizeTextUseCase {
  final OCRRepositoryInterface repository;

  RecognizeTextUseCase(this.repository);

  Future<String> call(String imagePath) async {
    return await repository.recognizeTextFromImage(imagePath);
  }
}
