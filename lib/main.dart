import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class ThemeHelper {
  static Future<void> setTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', isDark);
  }

  static Future<bool> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDark') ??
        false; // Returning false as default (light) theme
  }
}

void main() async {
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
    return FutureBuilder(
      future: ThemeHelper.getTheme(),
      builder: (context, snapshot) {
        bool isDark =
            snapshot.data ?? false; // Using false as default (light) theme

        return MaterialApp(
          theme: isDark ? ThemeData.dark() : ThemeData.light(),
          home: Home(),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Toggle theme
            ThemeHelper.getTheme().then((isDark) {
              ThemeHelper.setTheme(!isDark).then((_) {
                // Reload the app after setting the theme
                runApp(MyApp());
              });
            });
          },
          child: Text('Change Theme '),
        ),
      ),
    );
  }
}
