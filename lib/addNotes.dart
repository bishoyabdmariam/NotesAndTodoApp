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
  GlobalKey<FormState> formState = GlobalKey();
  TextEditingController note = TextEditingController();
  TextEditingController title = TextEditingController();
  bool isDone = false;
  late bool showAppBar;

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
                Switch(
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
                ),
              ],
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await sqlDb.insertData(
              "INSERT INTO 'notes' ('title', 'note', 'isDone', 'createdAt') VALUES ('${title.text}', '${note.text}', $isDone, '${DateTime.now().toIso8601String()}')");
          setState(() {});
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              Form(
                key: formState,
                child: Column(
                  children: [
                    TextFormField(
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
