import 'package:flutter/material.dart';
import 'package:todoapp/home.dart';
import 'package:todoapp/sqldb.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({
    super.key,
    required this.themeData,
  });

  final ThemeData themeData;

  @override
  State<AddNotes> createState() => _AddNotesState();
}

class _AddNotesState extends State<AddNotes> {
  SqlDb sqlDb = SqlDb();
  GlobalKey<FormState> formstate = GlobalKey();
  TextEditingController note = TextEditingController();
  TextEditingController title = TextEditingController();
  bool isDone = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    note.dispose();
    title.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Note"),
          actions: [
            Switch(
              value: isDone,
              onChanged: (value) {
                setState(() {
                  isDone = value;
                });
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await sqlDb.insertData(
                "INSERT INTO 'notes' ('title', 'note', 'isDone', 'createdAt') VALUES ('${title.text}', '${note.text}', $isDone, '${DateTime.now().toIso8601String()}')");
            setState(() {});
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Home(
                      dark: MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark
                          ? true
                          : false,
                    )));
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: [
                Form(
                  key: formstate,
                  child: Column(
                    children: [
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: title,
                        decoration: InputDecoration(
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
                          hintStyle: TextStyle(color: Colors.white),
                        ),
                        cursorColor: Colors.black,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextFormField(
                        controller: note,
                        decoration: InputDecoration(
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
                          hintStyle: TextStyle(color: Colors.white),
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
      ),
    );
  }
}
