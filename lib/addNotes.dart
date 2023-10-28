import 'package:flutter/material.dart';
import 'package:todoapp/home.dart';
import 'package:todoapp/sqldb.dart';

class AddNotes extends StatefulWidget {
  const AddNotes({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Note"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            Form(
                key: formstate,
                child: Column(
                  children: [
                    Switch(
                      value: isDone,
                      onChanged: (value) {
                        setState(() {
                          isDone = value;
                        });
                      },
                    ),
                    TextFormField(
                      controller: title,
                      decoration: InputDecoration(hintText: "title"),
                    ),
                    TextFormField(
                      controller: note,
                      decoration: InputDecoration(hintText: "note"),
                    ),
                    Container(
                      height: 20,
                    ),
                    MaterialButton(
                      onPressed: () async {
                        await sqlDb.insertData(
                            "INSERT INTO 'notes' ('title' , 'note' , 'isDone' ) VALUES ('${title.text}' , '${note.text}' , $isDone )");
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => Home()));
                      },
                      color: Colors.blue,
                      textColor: Colors.white,
                      child: Text("Submit Note"),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
