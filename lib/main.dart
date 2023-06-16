import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_upload/pages/home.dart';
import 'package:image_upload/pages/view_files.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const TabPage(),
        '/viewfiles': (context) => const ViewFilesPage(),
      },
    );
  }
}
