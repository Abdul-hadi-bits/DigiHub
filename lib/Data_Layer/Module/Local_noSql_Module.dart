import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';

import 'package:path/path.dart';
import 'package:sembast/sembast_io.dart';

class LocalMemory {
  static var store = StoreRef.main();

// We use the database factory to open the database

  static late Database db;

  static initializeDb() async {
    print("inside init db");
    try {
      var dir = await getApplicationDocumentsDirectory();
      // make sure it exists
      await dir.create(recursive: true);
      // build the database path
      var dbPath = join(dir.path, 'digiHub_database.db');
      // open the database
      db = await databaseFactoryIo.openDatabase(dbPath);
      print("*** local noSQL database is initialized ***");
    } catch (e) {
      print("*** local noSQL database is not initialized ***");
      print(e);
    }
  }

  static deleteDb() async {
    try {
      var dir = await getApplicationDocumentsDirectory();
      // make sure it exists
      await dir.create(recursive: true);
      // build the database path
      var dbPath = join(dir.path, 'digiHub_database.db');
      // delete

      await databaseFactoryIo.deleteDatabase(dbPath);
      print("*** local noSQL database is deleted ***");
    } catch (e) {
      print("*** local noSQL database is not deleted ***");
      print(e);
    }
  }

  //storing

  static Future<void> storeString(
      {required String key, required String value}) async {
    try {
      await store.record(key).put(db, value);
    } catch (e) {
      print(e);
    }
  }

  static Future<void> storeInt(
      {required String key, required int value}) async {
    try {
      await store.record(key).put(db, value);
    } catch (e) {
      print(e);
    }
  }

  static Future<void> storeBoolean(
      {required String key, required bool value}) async {
    try {
      await store.record(key).put(db, value);
    } catch (e) {
      print(e);
    }
  }

  static Future<void> storeDynamic(
      {required String key, required dynamic value}) async {
    try {
      await store.record(key).put(db, value);
    } catch (e) {
      print(" store dynamic localmemory" + e.toString());
    }
  }

  static Future<void> storeMap(
      {required String key, required Map<String, dynamic> value}) async {
    try {
      await store.record(key).put(db, value);
    } catch (e) {
      print(e);
    }
  }

  static Future<void> storeListMap(
      {required String key, required List<Map<String, dynamic>> value}) async {
    try {
      await store.record(key).put(db, value);
    } catch (e) {
      print(e);
    }
  }

  //reading
  static Future<int> readInt({required String value}) async {
    try {
      int resutl = await store.record(value).get(db) as int;
      return resutl;
    } catch (e) {
      print(e);
      return 0;
    }
  }

  static Future<String> readString({required String value}) async {
    try {
      String resutl = await store.record(value).get(db) as String;
      return resutl;
    } catch (e) {
      print(e);
      return "";
    }
  }

  static Future<bool> readBoolean({required String value}) async {
    try {
      bool resutl = await store.record(value).get(db) as bool;
      return resutl;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<Map<String, dynamic>> readMap({required String key}) async {
    try {
      Map<String, dynamic> resutl =
          await store.record(key).get(db) as Map<String, dynamic>;

      return resutl;
    } catch (e) {
      print(e);
      return Map();
    }
  }

  static Future<List<Map<String, dynamic>>> readListMap(
      {required String key}) async {
    try {
      List<Map<String, dynamic>> resutl =
          await store.record(key).get(db) as List<Map<String, dynamic>>;

      return resutl;
    } catch (e) {
      print(e);
      return [{}];
    }
  }

  static Future<dynamic> readDynamic({required String key}) async {
    try {
      dynamic resutl = await store.record(key).get(db);

      return resutl;
    } catch (e) {
      print(e);
      return null;
    }
  }

  //deleting

  static Future<void> deleteRecord({required String key}) async {
    try {
      await store.record(key).delete(db);
    } catch (e) {
      print(e);
    }
  }
}
