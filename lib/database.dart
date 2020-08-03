import 'dart:async';
import 'dart:io';

import 'package:cogbeh/thoughtModel.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "CB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Thought ("
          "id INTEGER PRIMARY KEY,"
          "content TEXT,"
          "datetime TEXT,"
          "distortions TEXT"
          ")");
    });
  }

//при удалении появился удаленные и добавлении появился удаленный эл вместо старого
  newThought(ThoughtModel newThought) async {
    final db = await database;
    var res = await db.insert("Thought", newThought.toMap());
    print('res');
    print(res);
    return res;
  }

  Future<List<ThoughtModel>> getAllThoughts() async {
    final db = await database;
    var res = await db.query("Thought");
    List<ThoughtModel> list =
        res.isNotEmpty ? res.map((c) => ThoughtModel.fromMap(c)).toList() : [];
    return list;
  }

  getNThought(int skip, int take) async {
    final db = await database;
    var res = await db.query("Thought",
        offset: skip, limit: take, orderBy: "id DESC");

    List<ThoughtModel> list =
        res.isNotEmpty ? res.map((c) => ThoughtModel.fromMap(c)).toList() : [];
    return list;
  }

  deleteThought(int id) async {
    final db = await database;
    db.delete("Thought", where: "id = ?", whereArgs: [id]);
  }

  updateThought(ThoughtModel newThought) async {
    final db = await database;
    var res = await db.update("Thought", newThought.toMap(),
        where: "id = ?", whereArgs: [newThought.id]);
    return res;
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("DELETE FROM Thought");
  }
}
