import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (pickedFile != null) {
        print("Picked image path: ${pickedFile.path}");
      } else {
        print("No image selected.");
      }

      return pickedFile?.path;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }
}
