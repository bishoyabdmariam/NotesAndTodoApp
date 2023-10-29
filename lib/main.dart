import 'package:flutter/material.dart';

import 'home.dart';

void main() {
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
      home: Home(
        dark: MediaQuery.platformBrightnessOf(context) == Brightness.dark
            ? true
            : false,
      ),
    );
  }
}
