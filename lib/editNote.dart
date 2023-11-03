import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/home.dart';
import 'package:todoapp/sqldb.dart';

class EditNote extends StatefulWidget {
  const EditNote({
    super.key,
    required this.isDone,
    required this.id,
    required this.note,
    required this.title,
  });

  final int id;
  final String title;
  final String note;
  final bool isDone;

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  SqlDb sqlDb = SqlDb();
  late bool isdone;
  late bool showAppBar;
  File? backgroundImage;

  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController noteController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isdone = widget.isDone;
    noteController.text = widget.note;
    titleController.text = widget.title;
    _loadBackgroundImage();
  }

  Future<void> _loadBackgroundImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('backgroundImagePath');
    print(imagePath);
    if (imagePath != null) {
      setState(() {
        backgroundImage = File(imagePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).viewInsets.bottom > 0 &&
        MediaQuery.of(context).orientation.name == "landscape") {
      showAppBar = false;
    } else {
      showAppBar = true;
    }
    setState(() {});
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text("Edit Note"),
              actions: [
                Switch(
                    value: isdone,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "Note Marked as ${isdone == true ? 'To Be Done' : 'Done'}")));

                      setState(() {
                        isdone = value;
                      });
                    }),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await sqlDb.updateData(
              "UPDATE 'notes' SET note = '${noteController.text}' , title = '${titleController.text}' , isDone = ${isdone == false ? 0 : 1} , createdAt = '${DateTime.now().toIso8601String()}' WHERE id = ${widget.id}");
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => Home(),
          ));
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Note Edited Correctly")));
          setState(() {});
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.done),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: backgroundImage != null
              ? DecorationImage(
                  image: FileImage(backgroundImage!),
                  fit: BoxFit.fill,
                )
              : null,
        ),
        padding: const EdgeInsets.all(5),
        child: ListView(
          children: [
            Form(
              key: formState,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextFormField(
                    validator: (value) {
                      if (value == "") {
                        return 'you have cleared the title';
                      } else if (value!.trim().isEmpty) {
                        return "Spaces is not considered as a valid title , Please enter a valid one";
                      }
                      return null; // Return null if the input is valid
                    },
                    textInputAction: TextInputAction.next,
                    controller: titleController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: "title",
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.transparent,
                      hintStyle: TextStyle(color: Colors.black12),
                    ),
                    cursorColor: Colors.black,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Joypixels',
                    ),
                  ),
                  TextFormField(
                    validator: (value) {
                      if (value == "") {
                        return 'You have cleared the note!';
                      } else if (value!.trim().isEmpty) {
                        return "Spaces is not considered as a valid note , Please enter a valid one!";
                      }
                      return null; // Return null if the input is valid
                    },
                    controller: noteController,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      hintText: "note",
                      border: InputBorder.none,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.transparent,
                      hintStyle: TextStyle(color: Colors.black12),
                    ),
                    cursorColor: Colors.black,
                    maxLines: null,
                  ),
                  Container(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
