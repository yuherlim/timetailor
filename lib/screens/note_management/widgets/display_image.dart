import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:timetailor/data/note_management/repositories/firebase_storage_service.dart';

class DisplayImage extends StatelessWidget {
  final String imagePath; // Path in Firebase Storage

  const DisplayImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Transform the Stream<List<ConnectivityResult>> to Stream<ConnectivityResult>
    final connectivityStream = Connectivity()
        .onConnectivityChanged
        .map((connectivityResults) => connectivityResults.first);

    return StreamBuilder<ConnectivityResult>(
      stream: connectivityStream,
      builder: (context, connectivitySnapshot) {
        if (connectivitySnapshot.hasData &&
            connectivitySnapshot.data == ConnectivityResult.none) {
          // Display offline banner
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

        // Proceed to load the image if online
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
      },
    );
  }
}
