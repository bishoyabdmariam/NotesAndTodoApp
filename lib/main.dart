import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

class ThemeHelper {
  static Future<void> setTheme(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', isDark);
  }

  static Future<bool?> getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? storedTheme = prefs.getBool('isDark');
    return storedTheme;
  }
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool?>(
      future: ThemeHelper.getTheme(),
      builder: (context, snapshot) {
        bool isDark = snapshot.data ?? false;

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            theme: isDark ? ThemeData.dark() : ThemeData.light(),
            home: Home(),
          );
        } else {
          return CircularProgressIndicator(); // Or any loading indicator
        }
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
            ThemeHelper.getTheme().then((isDark) {
              ThemeHelper.setTheme(!(isDark ?? false)).then((_) {
                runApp(MyApp());
                // You might consider updating the current screen
              });
            });
          },
          child: Text('Change Theme'),
        ),
      ),
    );
  }
}
