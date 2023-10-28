import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageTwo extends StatelessWidget {
  const PageTwo({super.key});

  Future<String> getSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("name")!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FutureBuilder<String>(
            future: getSaved(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text("data"),
                    Text(snapshot.data!),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text("Error: ${snapshot.error}");
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}
