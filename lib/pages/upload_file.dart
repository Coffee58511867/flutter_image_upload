import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UploadFilesPage extends StatefulWidget {
  const UploadFilesPage({Key? key}) : super(key: key);

  @override
  State<UploadFilesPage> createState() => _UploadFilesPageState();
}

class _UploadFilesPageState extends State<UploadFilesPage> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  String? amountErrorText;
  String? phoneErrorText;
  File? _file;
  String? _fileUrl;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _file = file;
      });
    }
  }

  Future<void> _payment() async {
    String phone = phoneController.text;
    String amount = amountController.text;

    // Validate phone field
    if (phone.isEmpty) {
      setState(() {
        phoneErrorText = 'Phone number is required';
      });
    } else {
      setState(() {
        phoneErrorText = null;
      });
    }

    // Validate amount field
    if (amount.isEmpty) {
      setState(() {
        amountErrorText = 'Amount is required';
      });
    } else {
      setState(() {
        amountErrorText = null;
      });
    }

    // Proceed with payment if both fields are valid
    if (amountErrorText == null && phoneErrorText == null) {
      try {
        // Upload file if available
        if (_file != null) {
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final extension = _file!.path.split('.').last;
          final destination = 'files/$fileName.$extension';

          final ref =
              firebase_storage.FirebaseStorage.instance.ref(destination);
          final uploadTask = ref.putFile(_file!);

          final snapshot = await uploadTask.whenComplete(() {});

          if (snapshot.state == firebase_storage.TaskState.success) {
            final downloadUrl = await ref.getDownloadURL();
            setState(() {
              _fileUrl = downloadUrl;
            });
          } else {
            Fluttertoast.showToast(
              msg: "File upload failed",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.black54,
              textColor: Colors.red,
            );
            return;
          }
        }

        // Create a map of the data you want to send
        Map<String, dynamic> paymentData = {
          'amount': amount,
          'phone': phone,
          'file_url': _fileUrl,
        };

        // Send the data to Firestore
        await FirebaseFirestore.instance
            .collection('documents')
            .add(paymentData);

        // Clear fields
        amountController.clear();
        phoneController.clear();

        // Clear file
        setState(() {
          _file = null;
          _fileUrl = null;
        });

        Fluttertoast.showToast(
          msg: "Payment Made Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.green,
        );
      } catch (e) {
        // Handle any errors that occur during the data submission
        print('Error submitting data: $e');
        Fluttertoast.showToast(
          msg: "Something went wrong, please try again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            TextField(
              controller: phoneController,
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    phoneErrorText = 'Phone number is required';
                  });
                } else {
                  setState(() {
                    phoneErrorText = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Phone Numbers',
                errorText: phoneErrorText,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: amountController,
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    amountErrorText = 'Amount is required';
                  });
                } else {
                  setState(() {
                    amountErrorText = null;
                  });
                }
              },
              decoration: InputDecoration(
                labelText: 'Amount',
                errorText: amountErrorText,
              ),
            ),
            const SizedBox(height: 12.0),
            if (_file != null) ...[
              const SizedBox(height: 16.0),
              Text(_file!.path),
            ],
            const SizedBox(height: 12.0),
            ElevatedButton(
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  const Size(250, 30),
                ),
              ),
              onPressed: () {
                if (_file == null) {
                  _pickFile();
                } else {
                  _payment();
                }
              },
              child: _file == null
                  ? const Text('Select File')
                  : const Text('Proceed to Pay'),
            ),
          ],
        ),
      ),
    );
  }
}
