import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch URL: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Files'),
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
                      launchURL(fileUrl);
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
