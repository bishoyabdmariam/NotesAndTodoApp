import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/home.dart';
import 'package:todoapp/sqldb.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({super.key});

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  SqlDb sqlDb = SqlDb();
  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController note = TextEditingController();
  TextEditingController title = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isDone = false;
  late bool showAppBar;
  File? backgroundImage;
  late bool isObscure;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadBackgroundImage();
    isObscure = true;
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    note.dispose();
    title.dispose();
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
              title: const Text("Add Note"),
              actions: [
                Container(
                  width: 70,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      child: isDone
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
                                "Note Marked as ${isDone == true ? 'To Be Done' : 'Done'}")));
                        setState(() {
                          isDone = !isDone;
                        });
                      },
                    ),
                  ),
                ),

                /*Switch(
                  activeColor: Colors.green,
                  value: isDone,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "Note Marked as ${isDone == true ? 'To Be Done' : 'Done'}")));
                    setState(() {
                      isDone = value;
                    });
                  },
                ),*/
              ],
            )
          : null,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Initial value for password visibility

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
                                  controller: password,
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
              child: password.text.isEmpty
                  ? Icon(Icons.lock_open)
                  : Icon(Icons.lock),
            ),
          ),
          FloatingActionButton(
            onPressed: () async {
              if (formState.currentState!.validate()) {
                await sqlDb.insertData(
                    "INSERT INTO 'notes' ('title', 'note', 'isDone', 'createdAt' , 'isLocked' , 'password') VALUES ('${title.text}', '${note.text}', $isDone, '${DateTime.now().toIso8601String()}' , ${password.text.isNotEmpty} , '${password.text}')");
                setState(() {});
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => Home()));

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Note Added Correctly")));
              }
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: backgroundImage != null
                ? DecorationImage(
                    image: FileImage(backgroundImage!),
                    fit: BoxFit.fill,
                  )
                : null,
          ),
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              Form(
                key: formState,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == "") {
                          return 'Please enter title';
                        } else if (value!.trim().isEmpty) {
                          return "Spaces is not considered as a valid title , Please enter a valid one";
                        }
                        return null; // Return null if the input is valid
                      },
                      textInputAction: TextInputAction.next,
                      controller: title,
                      decoration: const InputDecoration(
                        hintText: "title",
                        hoverColor: Colors.green,
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.transparent,
                        hintStyle: TextStyle(color: Colors.green),
                      ),
                      cursorColor: Colors.black,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value == "") {
                          return 'Please enter note';
                        } else if (value!.trim().isEmpty) {
                          return "Spaces is not considered as a valid note , Please enter a valid one";
                        }
                        return null; // Return null if the input is valid
                      },
                      controller: note,
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
                        hintStyle: TextStyle(color: Colors.green),
                      ),
                      cursorColor: Colors.black,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*Future<void> _showPasswordDialog(BuildContext context) async {
  String password = ''; // Initialize password variable

}*/
