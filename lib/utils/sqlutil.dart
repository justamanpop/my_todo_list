import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:async/async.dart';
import 'package:path_provider/path_provider.dart';

class SqlUtil
{

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
    return await openDatabase('TaskDb.db',onCreate: createDbTable);
  }

  String tableName = "Task";


  FutureOr<void> createDbTable(Database db, int version) {
    await db.execute('CREATE TABLE ')
  }
}