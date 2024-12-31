import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/data/note_management/repositories/firebase_storage_service.dart';
import 'package:timetailor/screens/note_management/pdf_viewer_screen.dart';
import 'package:path/path.dart' as path;

class NotePDFCard extends StatelessWidget {
  final String pdfPath; // The Firebase Storage path to the PDF file
  final VoidCallback onDelete; // Callback to handle delete action

  const NotePDFCard({
    super.key,
    required this.pdfPath,
    required this.onDelete,
  });

  String extractFileName(String filePath) {
    return path.basename(filePath);
  }

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
                child: Card(
                  color: Colors.grey[300],
                  child: ListTile(
                    title: Text(
                      extractFileName(pdfPath),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.cloud_off, color: Colors.grey),
                    onTap: () {
                      CustomSnackbars.shortDurationSnackBar(
                          contentString:
                              "You're offline. Please connect to the internet to view this PDF.");
                    },
                  ),
                ),
              );
            }

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(extractFileName(pdfPath)),
                trailing: const Icon(Icons.picture_as_pdf, color: Colors.red),
                onTap: () async {
                  final pdfUrl =
                      await FirebaseStorageService.getDownloadURL(pdfPath);

                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFViewerScreen(pdfUrl: pdfUrl),
                      ),
                    );
                  }
                },
              ),
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
