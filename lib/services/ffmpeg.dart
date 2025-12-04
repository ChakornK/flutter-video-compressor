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
            '-v error -show_entries format=duration:stream=width,height,r_frame_rate -of default=noprint_wrappers=1:nokey=1 $inputFile',
          ).then((info) async => (await info.getOutput())!)).toString().split("\n");
          final int width = int.parse(info[0]);
          final int height = int.parse(info[1]);
          final int frameRate = (num.parse(info[2].split("/")[0]) / num.parse(info[2].split("/")[1])).round();
          final num duration = num.parse(info[3].contains("/") ? info[4] : info[3]);

          final num target = size * 1024 * 1024;
          final num totalBitrate = target / duration * 8;
          final num audioBitrate = min(96 * 1000, 0.2 * totalBitrate);
          final num videoBitrate = totalBitrate - audioBitrate;

          final args = [
            "-b:v $videoBitrate",
            "-maxrate:v $videoBitrate",
            "-bufsize:v ${target / 2}",
            "-b:a $audioBitrate",
            "-c:v $encoding",
            "-c:a aac",
            "-ar 44100",
            "-color_trc iec61966-2-1",
            "-bitrate_mode 1",
            "-g ${frameRate * 10}",
            "-r ${min(frameRate, 60)}",
            "-threads ${Platform.numberOfProcessors}",
          ];

          if (max(width, height) > 1280) {
            if (width > height) {
              args.add("-vf scale=1280:-2");
            } else {
              args.add("-vf scale=-2:1280");
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
