import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UploadImagePage2 extends StatefulWidget {
  const UploadImagePage2({Key? key}) : super(key: key);

  @override
  State<UploadImagePage2> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage2> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  String? amountErrorText;
  String? phoneErrorText;
  File? _image;
  String? _imageUrl;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
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
        // Upload image if available
        if (_image != null) {
          final fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final destination = 'images/$fileName.png';

          final ref =
              firebase_storage.FirebaseStorage.instance.ref(destination);
          final uploadTask = ref.putFile(_image!);

          final snapshot = await uploadTask.whenComplete(() {});

          if (snapshot.state == firebase_storage.TaskState.success) {
            final downloadUrl = await ref.getDownloadURL();
            setState(() {
              _imageUrl = downloadUrl;
            });
          } else {
            Fluttertoast.showToast(
              msg: "Image upload failed",
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
          'image_url': _imageUrl,
        };

        // Send the data to Firestore
        await FirebaseFirestore.instance
            .collection('payments')
            .add(paymentData);

        // Clear fields
        amountController.clear();
        phoneController.clear();

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
            const SizedBox(height: 24.0),
            ElevatedButton(
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size>(
                  const Size(250, 30),
                ),
              ),
              onPressed: () {
                if (_image == null) {
                  _pickImage();
                } else {
                  _payment();
                }
              },
              child: _image == null
                  ? const Text('Select Image')
                  : const Text('Proceed to Pay'),
            ),
            if (_image != null) ...[
              const SizedBox(height: 16.0),
              Image.file(_image!, height: 200),
            ],
          ],
        ),
      ),
    );
  }
}
