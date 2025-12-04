import 'dart:io';
import 'dart:math';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';

void compressVideo(String inputFile, num size, Function(String) logMessage) {
  String encoding;

  if (Platform.isAndroid) {
    encoding = 'h264_mediacodec';
    logMessage('Using hardware encoding (Android MediaCodec)\n');
  } else if (Platform.isIOS || Platform.isMacOS) {
    encoding = 'h264_videotoolbox';
    logMessage('Using hardware encoding (VideoToolbox)\n');
  } else {
    encoding = 'mpeg4';
    logMessage('Using software encoding\n');
  }
  logMessage("\n");

  FFmpegKitConfig.selectDocumentForWrite('compressed-${DateTime.now().millisecondsSinceEpoch}.mp4', 'video/*')
      .then((uri) {
        FFmpegKitConfig.getSafParameterForWrite(uri!).then((safUrl) async {
          final List<String> info = (await FFprobeKit.getMediaInformationFromCommand(
            '-v error -show_entries format=duration:stream=width,height -of default=noprint_wrappers=1:nokey=1 $inputFile',
          ).then((info) async => (await info.getOutput())!)).toString().split("\n");
          final int height = int.parse(info[0]);
          final int width = int.parse(info[1]);
          final num duration = num.parse(info[2]);

          final num target = size * 1024 * 1024;
          final num totalBitrate = target / duration;
          final num audioBitrate = min(96 * 1000, 0.2 * totalBitrate);
          final num videoBitrate = totalBitrate - audioBitrate;

          final args = [
            "-b:v ${videoBitrate.floor()}",
            "-maxrate:v ${videoBitrate.floor()}",
            "-bufsize:v ${target / 20}",
            "-b:a ${audioBitrate.floor()}",
            "-c:v $encoding",
            "-c:a aac",
            "-ar 44100",
            "-color_trc iec61966-2-1",
            "-bitrate_mode 1",
          ];

          if (max(width, height) > 1280) {
            if (width > height) {
              args.add("-vf scale=1280:-1");
            } else {
              args.add("-vf scale=-1:1280");
            }
          }

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
