import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:timetailor/data/note_management/repositories/firebase_storage_service.dart';

class DisplayImage extends StatelessWidget {
  final String imagePath; // Path in Firebase Storage
  final VoidCallback onDelete; // Callback to handle delete action

  const DisplayImage({
    super.key,
    required this.imagePath,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final connectivityStream = Connectivity()
        .onConnectivityChanged
        .map((connectivityResults) => connectivityResults.first);

    return Stack(
      children: [
        StreamBuilder<ConnectivityResult>(
          stream: connectivityStream,
          builder: (context, connectivitySnapshot) {
            if (connectivitySnapshot.hasData &&
                connectivitySnapshot.data == ConnectivityResult.none) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: Colors.red,
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        "You're offline. The image may not load.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    const Icon(Icons.cloud_off, size: 50, color: Colors.grey),
                  ],
                ),
              );
            }

            return FutureBuilder<String>(
              future: FirebaseStorageService.getDownloadURL(imagePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Image.network(snapshot.data!);
                } else {
                  return const Text('No image found');
                }
              },
            );
          },
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}
