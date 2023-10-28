import 'package:flutter/material.dart';
import 'package:todoapp/editNote.dart';
import 'package:todoapp/sqldb.dart';

import 'addNotes.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  SqlDb sqlDb = SqlDb();

  Future<List<Map>> readData() async {
    List<Map> response = await sqlDb.readData("SELECT * FROM 'notes'");
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home Page"),
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
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AddNotes()));
          },
        ),
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
                                                  id: id,
                                                  title: title,
                                                  note: note,
                                                  isDone: isDone,
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
                                      var note = snapshot.data![index]["note"];
                                      var data = sqlDb.readData(
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
                                                "INSERT INTO 'notes' ('id' , 'title' , 'note') VALUES ( '$id', '$title' , '$note')");
                                            setState(() {});
                                          },
                                        ),
                                      ));
                                    },
                                    child: ListTile(
                                      leading: Checkbox(
                                        value: isDone,
                                        onChanged: (value) {
                                          setState(() {
                                            isDone = !isDone;
                                          });
                                        },
                                      ),
                                      subtitle: Text(
                                        snapshot.data![index]["note"]
                                            .toString(),
                                      ),
                                      title: Text(
                                        snapshot.data![index]["title"]
                                            .toString(),
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
          ],
        ));
  }
}
