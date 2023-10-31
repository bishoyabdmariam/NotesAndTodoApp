import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/editNote.dart';
import 'package:todoapp/sqldb.dart';

import 'addNotes.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SqlDb sqlDb = SqlDb();
  final ThemeData lightTheme = ThemeData.light();
  final ThemeData darkTheme = ThemeData.dark();
  late bool isDarkMode;

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
    isDarkMode = widget.dark;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {});
    return Theme(
      data: isDarkMode ? darkTheme : lightTheme,
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Home Page"),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                  icon: const Icon(Icons.lightbulb)),
            ],
            /*actions: [
              IconButton(
                  onPressed: () async {
                    sqlDb.deleteDataBase();
                    setState(() {});
                  },
                  icon: const Icon(Icons.delete)),
            ],*/
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => AddNotes(
                        themeData: isDarkMode == false ? lightTheme : darkTheme,
                      )));
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endContained,
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
                                  child: Text("There is no data"),
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
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (context) => EditNote(
                                                    themeData:
                                                        isDarkMode == false
                                                            ? lightTheme
                                                            : darkTheme,
                                                    id: id,
                                                    title: title,
                                                    note: note,
                                                    isDone: isdone == 0
                                                        ? false
                                                        : true,
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
                                        var title =
                                            snapshot.data![index]["title"];
                                        var note =
                                            snapshot.data![index]["note"];
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
                                            .showSnackBar(SnackBar(
                                          content: const Text('Item dismissed'),
                                          action: SnackBarAction(
                                            label: 'Undo',
                                            onPressed: () async {
                                              // Undo the dismissal of the Dismissible widget
                                              await sqlDb.insertData(
                                                  "INSERT INTO 'notes' ('id' , 'title' , 'note' , 'isDone' , 'createdAt' ) VALUES ( '$id', '$title' , '$note' , '$isDone' , '$time')");
                                              setState(() {});
                                            },
                                          ),
                                        ));
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
                                          snapshot.data![index]["note"]
                                              .toString(),
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
                                              formatDateTime(snapshot
                                                  .data![index]["createdAt"]),
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
                              child: Text("Something Wrong"),
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
          )),
    );
  }
}
