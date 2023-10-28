import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlDb {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "bosh.db");
    Database myDb = await openDatabase(path,
        onCreate: _onCreate, version: 5, onUpgrade: _onUpgrade);
    return myDb;
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE "notes" (
        "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT ,
        "title" TEXT NOT NULL ,
        "note" TEXT NOT NULL 
      )
    ''');
    print("Create database");
  }

  _onUpgrade(Database myDb, int oldVersion, int newVersion) async {
    print("database upgraded");
  }

  readData(String sql) async {
    Database? myDb = await db;
    List<Map> response = await myDb!.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database? myDb = await db;
    int response = await myDb!.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database? myDb = await db;
    int response = await myDb!.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Database? myDb = await db;
    int response = await myDb!.rawDelete(sql);
    return response;
  }

  deleteDataBase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "bosh.db");
    await deleteDatabase(path);
  }
}
