import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/pageTwo.dart';

class SharedExample extends StatefulWidget {
  const SharedExample({super.key});

  @override
  State<SharedExample> createState() => _SharedExampleState();
}

class _SharedExampleState extends State<SharedExample> {
  savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("name", "Bishoy");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Shared Preferences Example",
        ),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await savePrefs();
            },
            child: Text("Save Prefs"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => PageTwo()));
            },
            child: Text("Go to page 2"),
          ),
        ],
      ),
    );
  }
}
