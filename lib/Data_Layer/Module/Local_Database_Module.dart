import "dart:io" as io;
import "package:path_provider/path_provider.dart" as path_provider;

import "package:path/path.dart" as path_package;
import "package:sqflite/sqflite.dart" as sqflite;

// a module for the local Database, it represents the database and its functions.
// it will open and return the database if created before, if not created it will create a database and
// the specified tables, then return it.

class LocalDatabaseModule {
  static late final String dbName = 'digiDatabase';
  static late final int version = 1;

  /*  LocalDatabaseModule({required databaseName, required databaseVersion}) {
    LocalDatabaseModule.dbName = databaseName;
    LocalDatabaseModule.version = databaseVersion;
  } */

  static initializeDatabase() async {
    io.Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    String path = path_package.join(directory.path, dbName);
    return await sqflite.openDatabase(path,
        version: version, onCreate: _onCreate);
  }

  static Future<void> _onCreate(sqflite.Database db, int ver) async {
    try {
      db.execute('''
      CREATE TABLE todo_table(
       taskId INTEGER PRIMARY KEY,
       taskDate date,
       taskEndDate date,
       taskDescription TEXT NOT NULL,
       taskType varchar(20),
       taskCompletion varchar(5),
       taskSate varchar(10)
       )
    ''');
    } on sqflite.DatabaseException {}

    try {
      await db.execute('''create table daily_trans ( 
        transactionId INTEGER  PRIMARY KEY ,
        transactionDate date, transactionAmount bigint,
        transactionType varchar(10) check(transactionType in('gain','spent') ),
        transactionDescription text,
        transactionTitle text,
        transactionCategory text)''');
    } on sqflite.DatabaseException {}
  }
}
