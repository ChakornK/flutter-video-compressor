import 'package:flutter/material.dart';
import 'package:video_compressor/services/ffmpeg.dart';

class CompressPage extends StatefulWidget {
  final String inputFile;
  const CompressPage({super.key, required this.inputFile});

  @override
  State<CompressPage> createState() => _CompressPageState();
}

class _CompressPageState extends State<CompressPage> {
  List<String> log = [];

  num targetSize = 8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compress'), elevation: 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Text("Compression settings", style: Theme.of(context).textTheme.titleLarge),
            SizedBox(
              width: double.maxFinite,
              child: TextFormField(
                onChanged: (value) => setState(() {
                  targetSize = num.parse(value);
                }),
                keyboardType: TextInputType.number,
                initialValue: targetSize.toString(),
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, suffixText: "MB", labelText: "Target size"),
              ),
            ),
            Divider(),
            Text("Log", style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: log
                          .map(
                            (ln) => ln.trim().isEmpty
                                ? const Divider()
                                : InkWell(
                                    onTap: () {},
                                    child: Text(ln, style: TextStyle(fontFamily: "monospace")),
                                  ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          compressVideo(
            widget.inputFile,
            targetSize,
            (String value) => setState(() {
              if (value.contains("\n")) {
                log.add(value.replaceFirst(RegExp(r'\n$'), ''));
              } else {
                log[log.length - 1] += value;
              }
            }),
          );
        },
        icon: const Icon(Icons.rocket_launch_rounded),
        label: const Text("Compress"),
      ),
    );
  }
}
