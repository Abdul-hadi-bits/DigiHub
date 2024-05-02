import 'package:digi_hub/Data_Layer/Module/Local_Database_Module.dart';
import "package:sqflite/sqflite.dart" as sqflite;

import "dart:io" as io;
import "package:path_provider/path_provider.dart" as path_provider;

import "package:path/path.dart" as path_package;

// the localDb provider will provide a static intance of the database.
// if an instance is already created once, it will return it. if not created before
// it will initialize an instance

class LocalDbProvider {
  static sqflite.Database? database;
  LocalDbProvider() {
    // LocalDatabaseModule(databaseName: "digiDatabase", databaseVersion: 1);
  }

  static Future<sqflite.Database?> get getDatabase async {
    if (database != null) {
      return database;
    }
    database = await LocalDatabaseModule.initializeDatabase();

    return database;
  }

  Future delDatabase({required String dbName}) async {
    io.Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    String path = path_package.join(directory.path, dbName);
    sqflite.deleteDatabase(path).whenComplete(() {});
  }

  void closeDb({required String dbName}) async {
    try {
      (await LocalDbProvider.getDatabase)!.close();
    } catch (error) {
      print("database was unable to get closed!!!");
      print(error);
    }
  }
}
