import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/domain/note_management/providers/note_form_provider.dart';
import 'package:timetailor/domain/ocr/image_picker_service.dart';
import 'package:timetailor/domain/ocr/providers/ocr_provider.dart';

class OCRService {
  void onOCRSelected(BuildContext context, WidgetRef ref) async {
    final imagePickerService = ImagePickerService();

    // Show a dialog to let the user choose between camera or gallery
    final String? imagePath = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose Image Source'),
          actions: [
            TextButton(
              onPressed: () async {
                // ignore: use_build_context_synchronously
                Navigator.pop(context,
                    await imagePickerService.pickImage(fromCamera: true));
              },
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () async {
                // ignore: use_build_context_synchronously
                Navigator.pop(context,
                    await imagePickerService.pickImage(fromCamera: false));
              },
              child: const Text('Gallery'),
            ),
          ],
        );
      },
    );

    if (imagePath != null) {
      // Call the OCR method with the selected image path
      performOCR(imagePath, ref);

      // Provide feedback
      CustomSnackbars.shortDurationSnackBar(
          contentString: 'OCR processing started...');
    } else {
      // Notify the user if no image was selected
      CustomSnackbars.shortDurationSnackBar(
          contentString: 'No image selected!');
    }
  }

  void performOCR(String imagePath, WidgetRef ref) async {
    try {

      final recognizeTextUseCase = ref.read(recognizeTextUseCaseProvider);
      final recognizedText = await recognizeTextUseCase(imagePath);


      // Append recognized text to the current content
      final formNotifier = ref.read(noteFormNotifierProvider.notifier);
      final currentContent = ref.read(noteFormNotifierProvider).content;
      final updatedContent = "$currentContent\n###OCR Result###\n$recognizedText";
      formNotifier.updateContent(updatedContent);

      // Provide feedback to the user
      CustomSnackbars.shortDurationSnackBar(
          contentString: 'OCR result appended to the note!');
    } catch (e) {
      debugPrint("OCR Error: $e");
      CustomSnackbars.shortDurationSnackBar(
          contentString: 'Failed to recognize text: $e');
    }
  }

  Future<String?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    return pickedFile?.path; // Return the file path or null if canceled
  }
}
