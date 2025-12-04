import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';

void compressVideo(String inputFile, num size, Function(String) logMessage) {
  String encoding;

  if (Platform.isAndroid) {
    encoding = 'h264_mediacodec -b:v 2M';
    logMessage('Using hardware encoding (Android MediaCodec)\n');
  } else if (Platform.isIOS || Platform.isMacOS) {
    encoding = 'h264_videotoolbox -b:v 2M';
    logMessage('Using hardware encoding (VideoToolbox)\n');
  } else {
    encoding = 'mpeg4 -preset ultrafast';
    logMessage('Using software encoding\n');
  }
  logMessage("\n");

  FFmpegKitConfig.selectDocumentForWrite('compressed-${DateTime.now().millisecondsSinceEpoch}.mp4', 'video/*')
      .then((uri) {
        FFmpegKitConfig.getSafParameterForWrite(uri!).then((safUrl) {
          FFmpegKit.executeAsync(
            "-i $inputFile -c:v $encoding $safUrl",
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
