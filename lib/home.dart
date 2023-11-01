import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/intl.dart';
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

  Future<List<Map>> readData() async {
    setState(() {});
    List<Map> response = await sqlDb.readData("SELECT * FROM 'notes'");

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialization();
    ThemeHelper.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),

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
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
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
            // Add more ListTiles for additional items in the Drawer
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AddNotes()));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      body: Column(
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
                              bool isDone = isdone == 0 ? false : true;

                              return InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => EditNote(
                                            id: id,
                                            title: title,
                                            note: note,
                                            isDone: isdone == 0 ? false : true,
                                          )));
                                },
                                child: Dismissible(
                                  key: UniqueKey(),
                                  background: Container(
                                    color: Colors.red,
                                    child: const Icon(Icons.delete,
                                        color: Colors.white),
                                  ),
                                  onDismissed: (direction) async {
                                    var id = snapshot.data![index]["id"];
                                    var title = snapshot.data![index]["title"];
                                    var note = snapshot.data![index]["note"];
                                    var isDone =
                                        snapshot.data![index]["isDone"];
                                    var time =
                                        snapshot.data![index]["createdAt"];
                                    await sqlDb.readData(
                                        "SELECT * FROM 'notes' WHERE id = '${snapshot.data![index]["id"]}'");
                                    await sqlDb.deleteData(
                                        "DELETE FROM 'notes' WHERE id = '${snapshot.data![index]["id"]}'");
                                    setState(() {});
                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Text('Item dismissed'),
                                            SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () async {
                                                // Undo the dismissal of the Dismissible widget
                                                await sqlDb.insertData(
                                                    "INSERT INTO 'notes' ('id' , 'title' , 'note' , 'isDone' , 'createdAt' ) VALUES ( '$id', '$title' , '$note' , '$isDone' , '$time')");
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: isDone,
                                      onChanged: (value) async {
                                        await sqlDb.updateData(
                                            "UPDATE 'notes' SET 'isDone' = ${value == true ? 1 : 0}  WHERE id = ${snapshot.data![index]["id"]}");
                                        setState(() {
                                          isDone = value!;
                                        });
                                      },
                                    ),
                                    subtitle: Text(
                                      snapshot.data![index]["note"].toString(),
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
    );
  }
}
