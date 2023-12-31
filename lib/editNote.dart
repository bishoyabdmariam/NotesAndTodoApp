import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/home.dart';
import 'package:todoapp/sqldb.dart';
import 'package:todoapp/textFormField.dart';

class EditNote extends StatefulWidget {
  const EditNote({
    super.key,
    required this.isDone,
    required this.id,
    required this.note,
    required this.title,
    required this.isLocked,
    required this.password,
  });

  final int id;
  final bool isLocked;
  final String title;
  final String password;
  final String note;
  final bool isDone;

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  SqlDb sqlDb = SqlDb();
  late bool isdone;
  late bool islocked;
  late bool showAppBar;
  File? backgroundImage;
  late bool isObscure;

  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController noteController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isdone = widget.isDone;
    islocked = widget.isLocked;
    noteController.text = widget.note;
    titleController.text = widget.title;
    passwordController.text = widget.password;
    isObscure = true;

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
                Container(
                  width: 70,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      child: isdone
                          ? Icon(
                              Icons.check,
                              color: Colors.green,
                            )
                          : Icon(
                              Icons.crop_square,
                              color: Colors.red,
                            ),
                      onTap: () async {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "Note Marked as ${isdone == true ? 'To Be Done' : 'Done'}")));
                        setState(() {
                          isdone = !isdone;
                        });
                      },
                    ),
                  ),
                ),
              ],
            )
          : null,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          title: const Text('Enter Password'),
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: isObscure,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isObscure = !isObscure;
                                  });
                                },
                              )
                            ],
                          ),
                          actions: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                // Process the entered password or perform validation
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: Text('Submit'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: passwordController.text.isEmpty
                  ? Icon(Icons.lock_open)
                  : Icon(Icons.lock),
            ),
          ),
          FloatingActionButton(
            onPressed: () async {
              if (formState.currentState!.validate()) {
                await sqlDb.updateData(
                    "UPDATE 'notes' SET note = '${noteController.text}' , title = '${titleController.text}' , isDone = ${isdone == false ? 0 : 1} , createdAt = '${DateTime.now().toIso8601String()}' , isLocked = ${islocked == false ? 0 : 1} , password = '${passwordController.text}' WHERE id = ${widget.id}");
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Home(),
                ));
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Note Edited Correctly")));
                setState(() {});
              }
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.done),
          ),
        ],
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
                  textformfield(
                    controller: titleController,
                    validation: (value) {
                      if (value == "") {
                        return 'You have cleared the title!';
                      } else if (value!.trim().isEmpty) {
                        return "Spaces is not considered as a valid title , Please enter a valid one!";
                      }
                      return null; // Return null if the input is valid
                    },
                    formKey: formState,
                    hintText: "Title",
                    maxLines: 1,
                  ),
                  textformfield(
                    validation: (value) {
                      if (value == "") {
                        return 'You have cleared the note!';
                      } else if (value!.trim().isEmpty) {
                        return "Spaces is not considered as a valid note , Please enter a valid one!";
                      }
                      return null; // Return null if the input is valid
                    },
                    controller: noteController,
                    maxLines: null,
                    formKey: formState,
                    hintText: 'Note',
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
