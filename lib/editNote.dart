import 'package:flutter/material.dart';
import 'package:todoapp/home.dart';
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
  late bool showAppBar;

  GlobalKey<FormState> formState = GlobalKey();
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
    if (MediaQuery.of(context).viewInsets.bottom > 0 &&
        MediaQuery.of(context).orientation.name == "landscape") {
      showAppBar = false;
    } else {
      showAppBar = true;
    }
    setState(() {});
    return Theme(
      data: widget.themeData,
      child: Scaffold(
        appBar: showAppBar
            ? AppBar(
                title: const Text("Edit Note"),
                actions: [
                  Switch(
                      value: isdone,
                      onChanged: (value) {
                        setState(() {
                          isdone = value;
                        });
                      }),
                ],
              )
            : null,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await sqlDb.updateData(
                "UPDATE 'notes' SET note = '${noteController.text}' , title = '${titleController.text}' , isDone = ${isdone == false ? 0 : 1} , createdAt = '${DateTime.now().toIso8601String()}' WHERE id = ${widget.id}");
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => Home(
                dark:
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark
                        ? true
                        : false,
              ),
            ));
            setState(() {});
          },
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: const Icon(Icons.done),
        ),
        body: Container(
          padding: const EdgeInsets.all(5),
          child: ListView(
            children: [
              Form(
                key: formState,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        hintText: "title",
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.transparent,
                        hintStyle: TextStyle(color: Colors.black12),
                      ),
                      cursorColor: Colors.black,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Joypixels',
                      ),
                    ),
                    TextFormField(
                      controller: noteController,
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
                        hintStyle: TextStyle(color: Colors.black12),
                      ),
                      cursorColor: Colors.black,
                      maxLines: null,
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
      ),
    );
  }
}
