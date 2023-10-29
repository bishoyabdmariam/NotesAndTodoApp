import 'package:flutter/material.dart';
import 'package:todoapp/sqldb.dart';

class EditNote extends StatefulWidget {
  const EditNote({
    super.key,
    required this.isDone,
    required this.id,
    required this.note,
    required this.title,
    required this.themeData,
  });

  final int id;
  final String title;
  final String note;
  final bool isDone;
  final ThemeData themeData;

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  SqlDb sqlDb = SqlDb();
  late bool isdone;

  GlobalKey<FormState> formstate = GlobalKey();
  TextEditingController noteController = TextEditingController();
  TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isdone = widget.isDone;
    noteController.text = widget.note;
    titleController.text = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.themeData,
      child: Scaffold(
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
                    Switch(
                        value: isdone,
                        onChanged: (value) {
                          setState(() {
                            isdone = value;
                          });
                        }),
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
                            "UPDATE 'notes' SET note = '${noteController.text}' , title = '${titleController.text}' , isDone = ${isdone == false ? 0 : 1}  WHERE id = ${widget.id}");
                        Navigator.of(context).pop();
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
      ),
    );
  }
}
