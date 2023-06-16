import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ViewFilesPage extends StatefulWidget {
  const ViewFilesPage({Key? key}) : super(key: key);

  @override
  State<ViewFilesPage> createState() => _ViewFilesPageState();
}

class _ViewFilesPageState extends State<ViewFilesPage> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _paymentDocuments;

  @override
  void initState() {
    super.initState();
    fetchPaymentDocuments();
  }

  Future<void> fetchPaymentDocuments() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('documents').get();
    setState(() {
      _paymentDocuments = snapshot.docs;
    });
  }

  Future<void> downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final fileExtension = url.split('.').last;
      final filePath = '${directory.path}/file.$fileExtension';

      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      print('File downloaded to: $filePath');
    } else {
      print('Failed to download file. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Files'),
        centerTitle: true,
      ),
      body: _paymentDocuments != null
          ? ListView.builder(
              itemCount: _paymentDocuments!.length,
              itemBuilder: (context, index) {
                final paymentData = _paymentDocuments![index].data();
                final fileUrl = paymentData['file_url'];

                return ListTile(
                  title: Text('Payment ${index + 1}'),
                  subtitle: Text('Amount: ${paymentData['amount']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () {
                      downloadFile(fileUrl);
                    },
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
