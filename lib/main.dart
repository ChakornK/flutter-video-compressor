import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:video_compressor/pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent, systemNavigationBarDividerColor: Colors.transparent));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: [SystemUiOverlay.top]);

  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final _defaultLightColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue);
  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(primarySwatch: Colors.blue, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Video Compressor',
          theme: ThemeData(colorScheme: lightDynamic ?? _defaultLightColorScheme, splashFactory: InkSparkle.splashFactory),
          darkTheme: ThemeData(colorScheme: darkDynamic ?? _defaultDarkColorScheme, splashFactory: InkSparkle.splashFactory),
          home: Scaffold(body: HomePage()),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
