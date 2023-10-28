import 'package:flutter/material.dart';
import 'package:todoapp/sqldb.dart';

import 'home.dart';

class EditNote extends StatefulWidget {
  const EditNote(
      {super.key, required this.id, required this.note, required this.title});

  final int id;
  final String title;
  final String note;

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  SqlDb sqlDb = SqlDb();
  GlobalKey<FormState> formstate = GlobalKey();
  TextEditingController noteController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    noteController.text = widget.note;
    titleController.text = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Note"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: [
            Form(
              key: formstate,
              child: Column(
                children: [
                  TextFormField(
                    controller: noteController,
                    decoration: InputDecoration(hintText: "note"),
                  ),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(hintText: "title"),
                  ),
                  Container(
                    height: 20,
                  ),
                  MaterialButton(
                    onPressed: () async {
                      await sqlDb.updateData(
                          "UPDATE 'notes' SET note = '${noteController.text}' , title = '${titleController.text}' WHERE id = ${widget.id}");
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => Home()));
                    },
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Text("Submit Note"),
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
