import 'dart:io';
import 'dart:math';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';

void compressVideo(String inputFile, num size, Function(String) logMessage) {
  String encoding;

  if (Platform.isAndroid) {
    encoding = 'hevc_mediacodec';
    logMessage('Using hardware encoding (Android MediaCodec)\n');
  } else if (Platform.isIOS || Platform.isMacOS) {
    encoding = 'hevc_videotoolbox';
    logMessage('Using hardware encoding (VideoToolbox)\n');
  } else {
    encoding = 'libx265';
    logMessage('Using software encoding\n');
  }
  encoding = 'libx265';
  logMessage("\n");

  FFmpegKitConfig.selectDocumentForWrite('compressed-${DateTime.now().millisecondsSinceEpoch}.mp4', 'video/*')
      .then((uri) {
        FFmpegKitConfig.getSafParameterForWrite(uri!).then((safUrl) async {
          final num duration = await FFprobeKit.getMediaInformationFromCommand(
            '-v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $inputFile',
          ).then((info) async => num.parse((await info.getOutput())!));

          final num target = size * 1024 * 1024;
          final num totalBitrate = target / duration;
          final num audioBitrate = min(96 * 1000, 0.2 * totalBitrate);
          final num videoBitrate = totalBitrate - audioBitrate;

          final args = ["-b:v $videoBitrate", "-maxrate:v $videoBitrate", "-bufsize:v ${target / 20}", "-b:a $audioBitrate", "-c:v $encoding"];

          FFmpegKit.executeAsync(
            "-i $inputFile ${args.join(" ")} $safUrl",
            (s) {
              logMessage("Finished\n");
            },
            (e) {
              final msg = e.getMessage();
              if (!msg.trim().startsWith("configuration:")) {
                logMessage(msg);
              }
            },
            (c) => logMessage(c.toString().replaceFirst(RegExp(r"Instance of '.+?'"), '')),
          );
        });
      })
      .catchError((_) {});
}
