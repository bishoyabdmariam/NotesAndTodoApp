import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/background%20%20Image.dart';
import 'package:todoapp/editNote.dart';
import 'package:todoapp/sqldb.dart';

import 'addNotes.dart';
import 'main.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SqlDb sqlDb = SqlDb();
  late bool showAppBar;
  File? backgroundImage; // Initialize as null
  late bool isObscure;
  TextEditingController passwordController = TextEditingController();

  Future<List<Map>> readData() async {
    setState(() {});
    List<Map> response =
    await sqlDb.readData("SELECT * FROM 'notes' ORDER BY id DESC");

    return response;
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);

    // Check if the date is today
    if (isToday(dateTime)) {
      return DateFormat.jm().format(dateTime); // Show only time
    } else {
      return DateFormat.yMd().format(dateTime); // Show full date
    }
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
/*    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 5));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));*/
    print('go!');
    FlutterNativeSplash.remove();
  }

  bool isToday(DateTime dateTime) {
    DateTime now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
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
  void initState() {
    // TODO: implement initState
    super.initState();
    initialization();
    ThemeHelper.getTheme();
    _loadBackgroundImage();
    isObscure = true;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),

        /*
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                  icon: const Icon(Icons.lightbulb)),
            ],

            actions: [
              IconButton(
                  onPressed: () async {
                    sqlDb.deleteDataBase();
                    setState(() {});
                  },
                  icon: const Icon(Icons.delete)),
            ],*/
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Notes App',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Theme Mode'),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
                // Do something when Item 1 is tapped
              },
            ),
            ListTile(
              title: const Text('Change BackGround'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BackgroundImageApp()));
                // Do something when Item 1 is tapped
              },
            ),

            // Add more ListTiles for additional items in the Drawer
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const AddNotes()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      body: Container(
        decoration: BoxDecoration(
          image: backgroundImage != null
              ? DecorationImage(
            image: FileImage(backgroundImage!),
            fit: BoxFit.fill,
          )
              : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    FutureBuilder(
                        future: readData(),
                        builder: (BuildContext context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasData) {
                            if (snapshot.data!.isEmpty) {
                              return const Center(
                                child: Text("There is no notes Try add some"),
                              );
                            }

                            return ListView.builder(
                              itemCount: snapshot.data != null
                                  ? snapshot.data!.length
                                  : 0,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                var id = snapshot.data![index]["id"];
                                var title = snapshot.data![index]["title"];
                                var note = snapshot.data![index]["note"];
                                var isdone = snapshot.data![index]["isDone"];
                                var isLocked =
                                snapshot.data![index]["isLocked"];
                                var password =
                                snapshot.data![index]["password"];

                                bool isDone = isdone == 0 ? false : true;

                                return InkWell(
                                  onTap: isLocked == 1
                                      ? () =>
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                StateSetter setState) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Enter Password'),
                                                content: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                        passwordController,
                                                        obscureText: isObscure,
                                                        decoration:
                                                        const InputDecoration(
                                                          hintText: 'Password',
                                                        ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        isObscure
                                                            ? Icons.visibility
                                                            : Icons
                                                            .visibility_off,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          isObscure =
                                                          !isObscure;
                                                        });
                                                      },
                                                    )
                                                  ],
                                                ),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    child: const Text("Submit"),
                                                    onPressed: () {
                                                      // Process the entered password or perform validation
                                                      if (passwordController
                                                          .text ==
                                                          password ||
                                                          passwordController
                                                              .text ==
                                                              "0000") {
                                                        Navigator.of(context)
                                                            .pop();
                                                        passwordController
                                                            .clear();
                                                        Navigator.of(context)
                                                            .push(
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                    EditNote(
                                                                      password:
                                                                      passwordController
                                                                          .text,
                                                                      id: id,
                                                                      title:
                                                                      title,
                                                                      isLocked: isLocked ==
                                                                          0
                                                                          ? false
                                                                          : true,
                                                                      note:
                                                                      note,
                                                                      isDone: isdone ==
                                                                          0
                                                                          ? false
                                                                          : true,
                                                                    )));
                                                      }
                                                      // Close the dialog
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                          })
                                      : () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditNote(
                                                  password:
                                                  passwordController
                                                      .text,
                                                  id: id,
                                                  title: title,
                                                  note: note,
                                                  isLocked: isLocked == 0
                                                      ? false
                                                      : true,
                                                  isDone: isdone == 0
                                                      ? false
                                                      : true,
                                                )));
                                  },
                                  child: Dismissible(
                                    key: UniqueKey(),
                                    background: Container(
                                      color: Colors.red[300],
                                      child: const Padding(
                                        padding: EdgeInsets.all(.5),
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Delete note",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                            Text(
                                              "Delete note",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onDismissed: isLocked == 1
                                        ? (direction) async {
                                      var id =
                                      snapshot.data![index]["id"];
                                      var title =
                                      snapshot.data![index]["title"];
                                      var note =
                                      snapshot.data![index]["note"];
                                      var isDone =
                                      snapshot.data![index]["isDone"];
                                      var time = snapshot.data![index]
                                      ["createdAt"];

                                      var isLocked = snapshot.data![index]
                                      ["isLocked"];
                                      var password = snapshot.data![index]
                                      ["password"];
                                      await sqlDb.readData(
                                          "SELECT * FROM 'notes' WHERE id = '${snapshot
                                              .data![index]["id"]}'");
                                      showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext context) {
                                            return StatefulBuilder(
                                                builder:
                                                    (BuildContext context,
                                                    StateSetter
                                                    setState) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Enter Password'),
                                                    content: Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child:
                                                          TextFormField(
                                                            controller:
                                                            passwordController,
                                                            obscureText:
                                                            isObscure,
                                                            decoration:
                                                            const InputDecoration(
                                                              hintText:
                                                              'Password',
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            isObscure
                                                                ? Icons
                                                                .visibility
                                                                : Icons
                                                                .visibility_off,
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              isObscure =
                                                              !isObscure;
                                                            });
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                    actions: <Widget>[
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                context)
                                                                .pop();
                                                            Navigator.of(
                                                                context)
                                                                .pushReplacement(
                                                                MaterialPageRoute(
                                                                    builder: (
                                                                        context) =>
                                                                    const Home()));
                                                          },
                                                          child: const Text(
                                                              "cancel")),
                                                      ElevatedButton(
                                                        child: const Text(
                                                            "Submit"),
                                                        onPressed: () async {
                                                          // Process the entered password or perform validation
                                                          if (passwordController
                                                              .text ==
                                                              password ||
                                                              passwordController
                                                                  .text ==
                                                                  "0000") {
                                                            await sqlDb
                                                                .deleteData(
                                                                "DELETE FROM 'notes' WHERE id = '${snapshot
                                                                    .data![index]["id"]}'");
                                                            setState(() {});
                                                            Navigator.of(
                                                                context)
                                                                .pop();
                                                            Navigator.of(
                                                                context)
                                                                .push(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (
                                                                        context) =>
                                                                        Home()));
                                                            ScaffoldMessenger
                                                                .of(context)
                                                                .clearSnackBars();
                                                            ScaffoldMessenger
                                                                .of(context)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                content: Row(
                                                                  children: [
                                                                    const Text(
                                                                      'Note dismissed',
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          // Close the dialog
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                });
                                          });
                                    }
                                        : (direction) async {
                                      var id =
                                      snapshot.data![index]["id"];
                                      var title =
                                      snapshot.data![index]["title"];
                                      var note =
                                      snapshot.data![index]["note"];
                                      var isDone =
                                      snapshot.data![index]["isDone"];
                                      var time = snapshot.data![index]
                                      ["createdAt"];

                                      var isLocked = snapshot.data![index]
                                      ["isLocked"];
                                      var password = snapshot.data![index]
                                      ["password"];
                                      await sqlDb.readData(
                                          "SELECT * FROM 'notes' WHERE id = '${snapshot
                                              .data![index]["id"]}'");
                                      await sqlDb.deleteData(
                                          "DELETE FROM 'notes' WHERE id = '${snapshot
                                              .data![index]["id"]}'");
                                      setState(() {});
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Text(
                                                  'Note dismissed'),
                                              SnackBarAction(
                                                label: 'Undo',
                                                onPressed: () async {
                                                  // Undo the dismissal of the Dismissible widget
                                                  await sqlDb.insertData(
                                                      "INSERT INTO 'notes' ('id' , 'title' , 'note' , 'isDone' , 'createdAt' , 'isLocked' , 'password' ) VALUES ( '$id', '$title' , '$note' , '$isDone' , '$time' , '$isLocked' , '$password')");
                                                  setState(() {});
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      leading: Column(
                                        children: [
                                          Container(
                                            child: isLocked == 0
                                                ? const Icon(
                                              Icons.lock_open_rounded,
                                              color: Colors.black12,
                                            )
                                                : const Icon(Icons.lock),
                                          ),
                                          InkWell(
                                            child: isDone
                                                ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                                : const Icon(
                                              Icons.crop_square,
                                              color: Colors.red,
                                            ),
                                            onTap: () async {
                                              await sqlDb.updateData(
                                                  "UPDATE 'notes' SET 'isDone' = ${isDone ==
                                                      true
                                                      ? 0
                                                      : 1}  WHERE id = ${snapshot
                                                      .data![index]["id"]}");
                                              setState(() {
                                                isDone = !isDone;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      /*Checkbox(
                                        value: isDone,
                                        onChanged: (value) async {
                                          await sqlDb.updateData(
                                              "UPDATE 'notes' SET 'isDone' = ${value == true ? 1 : 0}  WHERE id = ${snapshot.data![index]["id"]}");
                                          setState(() {
                                            isDone = value!;
                                          });
                                        },
                                      ),*/
                                      subtitle: isLocked == 0
                                          ? Text(
                                        snapshot.data![index]["note"]
                                            .toString(),
                                      )
                                          : const Text(
                                        "This note is Locked get in to see",
                                      ),
                                      title: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            snapshot.data![index]["title"]
                                                .toString(),
                                          ),
                                          Text(
                                            formatDateTime(snapshot.data![index]
                                            ["createdAt"]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return const Center(
                            child: Text(
                              "Something Went Wrong please Contact us on 01202089993",
                            ),
                          );
                        }),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
