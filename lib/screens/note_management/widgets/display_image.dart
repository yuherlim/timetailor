import 'package:flutter/material.dart';
import 'package:timetailor/data/note_management/repositories/firebase_storage_service.dart';

class DisplayImage extends StatelessWidget {
  final String imagePath; // Path in Firebase Storage

  const DisplayImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: FirebaseStorageService.getDownloadURL(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return Image.network(snapshot.data!); // Display image
        } else {
          return const Text('No image found');
        }
      },
    );
  }
}