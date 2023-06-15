import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploadsPage extends StatefulWidget {
  const UploadsPage({Key? key}) : super(key: key);

  @override
  State<UploadsPage> createState() => _UploadsPageState();
}

class _UploadsPageState extends State<UploadsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uploads'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('payments').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final payments = snapshot.data!.docs;
            return ListView.builder(
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                final amount = payment['amount'];
                final phone = payment['phone'];
                final imageUrl = payment['image_url'];

                return ListTile(
                  leading: imageUrl != null
                      ? Image.network(imageUrl)
                      : const SizedBox(),
                  title: Text('Amount: $amount'),
                  subtitle: Text('Phone: $phone'),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error retrieving data'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
