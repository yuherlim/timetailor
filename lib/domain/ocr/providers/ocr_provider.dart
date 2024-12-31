import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timetailor/data/ocr/repositories/ocr_repository.dart';
import 'package:timetailor/domain/ocr/ocr_service.dart';
import 'package:timetailor/domain/ocr/repositories/ocr_repository_interface.dart';
import 'package:timetailor/domain/ocr/usecases/recognize_text_usecase.dart';

final ocrRepositoryProvider = Provider<OCRRepository>((ref) {
  final repository = OCRRepository();
  ref.onDispose(() => repository.dispose());
  return repository;
});


final recognizeTextUseCaseProvider =
    AutoDisposeProvider<RecognizeTextUseCase>((ref) {
  final ocrRepository = ref.read(ocrRepositoryProvider);
  return RecognizeTextUseCase(ocrRepository as OCRRepositoryInterface);
});

final ocrServiceProvider = Provider<OCRService>((ref) => OCRService());
