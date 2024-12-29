import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:timetailor/core/shared/custom_snackbars.dart';
import 'package:timetailor/data/note_management/repositories/firebase_storage_service.dart';
import 'package:timetailor/screens/note_management/pdf_viewer_screen.dart';
import 'package:path/path.dart' as path;

class NotePDFCard extends StatelessWidget {
  final String pdfPath; // The Firebase Storage path to the PDF file

  const NotePDFCard({super.key, required this.pdfPath});

  String extractFileName(String filePath) {
    return path.basename(filePath);
  }

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
          // Show offline banner
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

        // Show the PDF card when online
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(extractFileName(pdfPath)),
            trailing: const Icon(Icons.picture_as_pdf, color: Colors.red),
            onTap: () async {
              // Fetch the PDF URL
              final pdfUrl =
                  await FirebaseStorageService.getDownloadURL(pdfPath);

              // Navigate to the PDF viewer
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
    );
  }
}
