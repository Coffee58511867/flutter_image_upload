import 'package:flutter/material.dart';
import 'package:image_upload/pages/upload_image.dart';
import 'package:image_upload/pages/view_uploads.dart';

class TabPage extends StatefulWidget {
  const TabPage({super.key});

  @override
  State<TabPage> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Dashboard"),
            centerTitle: true,
            bottom: const TabBar(tabs: [
              Tab(text: "Upload"),
              Tab(text: "My Uploads"),
            ]),
          ),
          body: const TabBarView(
            children: [UploadImagePage(), UploadsPage()],
          ),
        ),
      );
}
