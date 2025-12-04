import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_compressor/pages/compress.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? inputFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Compressor')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: FilledButton.icon(
              onPressed: () {
                FilePicker.platform.pickFiles(type: FileType.video).then((result) {
                  if (result != null) {
                    setState(() {
                      inputFile = result.files.single.path!;
                    });
                    if (context.mounted) {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CompressPage(inputFile: inputFile!)));
                    }
                  }
                });
              },
              label: const Text('Select file'),
              icon: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
