import 'package:ffmpeg_kit_flutter_new/ffmpeg_session.dart';
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
  bool isRunning = false;
  FFmpegSession? session;

  num targetSize = 8;
  num targetDimension = 1280;

  final ScrollController _controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compress'), elevation: 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text("Compression settings", style: Theme.of(context).textTheme.titleLarge),
              TextFormField(
                onChanged: (value) => setState(() {
                  if (value.isEmpty) return;
                  try {
                    targetSize = num.parse(value.replaceAll(RegExp(r'[^\d]'), ""));
                  } catch (_) {}
                }),
                validator: (value) {
                  try {
                    num.parse(value!);
                    return null;
                  } catch (_) {
                    return "Invalid value";
                  }
                },
                autovalidateMode: AutovalidateMode.always,
                keyboardType: TextInputType.number,
                initialValue: targetSize.toString(),
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, suffixText: "MB", labelText: "Maximum file size"),
              ),
              TextFormField(
                onChanged: (value) => setState(() {
                  if (value.isEmpty) return;
                  try {
                    targetDimension = num.parse(value.replaceAll(RegExp(r'[^\d]'), ""));
                  } catch (_) {}
                }),
                validator: (value) {
                  try {
                    final v = int.parse(value!);
                    if (v % 2 != 0) return "Must be an even integer";
                    if (v < 202) return "Too small";
                    return null;
                  } catch (_) {
                    return "Invalid value";
                  }
                },
                autovalidateMode: AutovalidateMode.always,
                keyboardType: TextInputType.number,
                initialValue: targetDimension.toString(),
                decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true, suffixText: "px", labelText: "Maximum dimension"),
              ),
              Divider(),
              Text("Log", style: Theme.of(context).textTheme.titleLarge),
              Expanded(
                child: SizedBox(
                  width: double.maxFinite,
                  child: SingleChildScrollView(
                    controller: _controller,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: log.map((ln) => ln.trim().isEmpty ? const Divider() : Text(ln, style: TextStyle(fontFamily: "monospace"))).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isRunning
          ? FloatingActionButton.extended(
              onPressed: () => session?.cancel().then(
                (_) => setState(() {
                  isRunning = false;
                  session = null;
                }),
              ),
              icon: const Icon(Icons.stop),
              label: const Text("Cancel"),
            )
          : FloatingActionButton.extended(
              onPressed: () {
                try {
                  compressVideo(
                    inputFile: widget.inputFile,
                    targetSize: targetSize,
                    targetDimension: targetDimension,
                    logMessage: (String value) => setState(() {
                      if (value.contains("\n")) {
                        log.add(value.replaceFirst(RegExp(r'\n$'), ''));
                      } else {
                        log[log.length - 1] += value;
                      }
                      _controller.animateTo(_controller.position.maxScrollExtent, duration: Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                    }),
                    onStateChange: (bool value) => setState(() => isRunning = value),
                    setSession: (FFmpegSession value) => setState(() => session = value),
                  );
                } catch (e) {
                  setState(() {
                    isRunning = false;
                    session = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Something went wrong")));
                }
              },
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text("Compress"),
            ),
    );
  }
}
