//@dart=2.9

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:my_todo_list/Models/Task.dart';

class SqlUtil
{

  static final _tableName = "Task";

  static final SqlUtil _sqlUtil = SqlUtil._internal();

  SqlUtil._internal();

  factory SqlUtil()
  {
    return _sqlUtil;
  }

  static Database _db;

  Future<Database> get db async
  {
    if(_db!=null)
      return _db;

    _db = await initializeDb();

    return _db;

  }

  Future<Database> initializeDb() async
  {
    return await openDatabase('TaskDb.db',onCreate: createDbTable, version: 1);
  }

  String tableName = "Task";


  Future<void> createDbTable(Database db, int version) async
  {
    await db.execute('CREATE TABLE $_tableName(id INTEGER PRIMARY KEY, name TEXT, description TEXT, dueDateTime TEXT, priority INTEGER)');
  }

  Future<int> insertDb(Task taskToBeInserted) async
  {
    var db = await this.db;
    return await db.insert(_tableName,taskToBeInserted.toMap());
  }

  Future<List<Map<String,Object>>> getAllTasksDb() async
  {
    var database = await db;
    return await database.rawQuery('SELECT * FROM $_tableName');
  }

  Future<int>getCountDb() async
  {
    var database = await db;
    var res = await database.rawQuery('SELECT COUNT(*) FROM $_tableName');
    return Sqflite.firstIntValue(res);
  }

  Future<int>deleteFromDb(int idToDelete) async
  {
    var database = await db;
    var res = await database.delete(_tableName,where: 'id = ?', whereArgs: [idToDelete]);
    return res;
  }
  
}