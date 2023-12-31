import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/home.dart';

class BackgroundImageApp extends StatefulWidget {
  @override
  _BackgroundImageAppState createState() => _BackgroundImageAppState();
}

class _BackgroundImageAppState extends State<BackgroundImageApp> {
  File? backgroundImage; // Initialize as null

  Future<void> getImageFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backgroundImagePath', pickedFile.path);
      setState(() {
        backgroundImage = File(pickedFile.path);
      });

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Background Image has been selected correctly"),
        ),
      );
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
    }
  }

  Future<void> clearImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('backgroundImagePath');
    setState(() {
      backgroundImage = null;
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Background Image has been cleared"),
      ),
    );
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Background Image App'),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: clearImage,
                child: Text('Clear Background Image'),
              ),
              ElevatedButton(
                onPressed: getImageFromGallery,
                child: Text(
                  backgroundImage != null
                      ? 'Select another Image'
                      : 'Select Image',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
