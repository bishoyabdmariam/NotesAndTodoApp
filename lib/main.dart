import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'home.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /*print(MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? true
        : false);*/
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Home(
        dark: MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? true
            : false,
      ),
    );
  }
}
