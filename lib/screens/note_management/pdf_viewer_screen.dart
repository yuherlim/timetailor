import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl; // The URL of the PDF to display

  const PDFViewerScreen({super.key, required this.pdfUrl});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _downloadPDF();
  }

  Future<void> _downloadPDF() async {
    try {
      // Download the PDF file from the URL
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        // Get the temporary directory
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp.pdf');

        // Write the file
        await file.writeAsBytes(response.bodyBytes);

        // Update the local file path
        if (await file.exists()) {
          setState(() {
            localFilePath = file.path;
          });
          debugPrint("File exists: ${file.path}");
        } else {
          debugPrint("File does not exist: ${file.path}");
        }

        debugPrint("PDF downloaded to: $localFilePath");
      } else {
        throw Exception('Failed to load PDF');
      }
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: localFilePath == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loader while downloading
          : PDFView(
              filePath: localFilePath, // Provide the local file path
              fitPolicy: FitPolicy.BOTH,
              onError: (error) {
                debugPrint('PDF error: $error');
              },
            ),
    );
  }
}
