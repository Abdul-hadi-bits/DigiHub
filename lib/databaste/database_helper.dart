import "package:path_provider/path_provider.dart" as path_provider;
import "dart:io" as io;
import "package:path/path.dart" as path_package;
import "package:sqflite/sqflite.dart" as sqflite;

class DatabaseHelper {
  final String _dBname = 'Plans.db';
  final int _version = 1;
  final String _tableName = 'TeacherTemplate';

  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static sqflite.Database? _database;
  Future<sqflite.Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initializeDatabase();

    return _database;
  }

  initializeDatabase() async {
    io.Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    String path = path_package.join(directory.path, _dBname);
    return await sqflite.openDatabase(path,
        version: _version, onCreate: onCreate);
  }

  Future<void> onCreate(sqflite.Database db, int ver) async {
    try {
      db.execute('''
      CREATE TABLE todo_table(
       task_id INTEGER PRIMARY KEY,
       task_date date,
       task_end_date date,
       task_desc TEXT NOT NULL,
       task_type varchar(20),
       task_compl varchar(5),
       task_state varchar(10)
       )
    ''');
    } on sqflite.DatabaseException catch (e) {}

    try {
      await db.execute('''create table daily_trans ( 
        trans_id INTEGER  PRIMARY KEY ,
        trans_date date, trans_amount bigint,
        trans_type varchar(10) check(trans_type in('gain','spent') ),
        trans_desc text,
        trans_title text)''');
    } on sqflite.DatabaseException catch (e) {}
  }

  //************************************* to do list table queries *********************** */

  Future<List<Map<String, dynamic>>> getAllTodoTasks(
      {required String date, required bool hasTime}) async {
    try {
      if (hasTime) {
        sqflite.Database? db = await instance.database;

        return await db!.rawQuery('''
        SELECT * from todo_table 
        WHERE task_date=datetime('$date')
    ''');
      } else {
        sqflite.Database? db = await instance.database;

        return await db!.rawQuery('''
        SELECT * from todo_table 
        WHERE strftime('%Y-%m-%d',task_date)=date('$date')

    ''');
      }
    } on sqflite.DatabaseException catch (e) {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTodoTasksDayBeforeEndsAtCurrentDaye(
      {required String date, required bool hasTime}) async {
    try {
      if (hasTime) {
        sqflite.Database? db = await instance.database;

        return await db!.rawQuery('''
        SELECT * from todo_table 
        WHERE task_end_date=datetime('$date') 
    ''');
      } else {
        sqflite.Database? db = await instance.database;

        return await db!.rawQuery('''
        SELECT * from todo_table 
        WHERE strftime('%Y-%m-%d',task_end_date)=date('$date') OR strftime('%Y-%m-%d',task_date)=date('$date')

    ''');
      }
    } on sqflite.DatabaseException catch (e) {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getTaskId(
      {required String date, required String description}) async {
    try {
      sqflite.Database? db = await instance.database;

      return await db!.rawQuery('''
        SELECT task_id from todo_table 
        WHERE strftime('%Y-%m-%d',task_date)=date('$date') AND
        task_desc='$description'
    ''');
    } on sqflite.DatabaseException catch (e) {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTodoTasksInMonth(
      {required String date, required bool hasTime}) async {
    try {
      sqflite.Database? db = await instance.database;

      return await db!.rawQuery('''
        SELECT * from todo_table 
        WHERE strftime('%Y-%m',task_date)=strftime('%Y-%m',datetime('$date'))
    ''');
    } on sqflite.DatabaseException catch (e) {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTodoTasksInYear(
      {required String date, required bool hasTime}) async {
    try {
      sqflite.Database? db = await instance.database;

      return await db!.rawQuery('''
        SELECT * from todo_table 
        WHERE strftime('%Y',task_date)=strftime('%Y',datetime('$date'))
    ''');
    } on sqflite.DatabaseException catch (e) {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTodoTasksByState(
      {required String date, required bool hasTime}) async {
    try {
      sqflite.Database? db = await instance.database;

      return await db!.rawQuery('''
        SELECT * from todo_table 
        WHERE task_state= 'missed'
    ''');
    } on sqflite.DatabaseException catch (e) {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getTodoTasksByTypeInYear(
      {required String date, required String taskType}) async {
    try {
      sqflite.Database? db = await instance.database;

      return await db!.rawQuery('''
        SELECT * from todo_table 
        WHERE (
        strftime('%Y',task_date)=strftime('%Y', '$date')
        AND
        task_type='$taskType'
        )
    ''');
    } on sqflite.DatabaseException catch (e) {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<bool> addTask(
      {required String taskDesc,
      required String date,
      required String endDate,
      //required bool isDatetime,
      required String taskType}) async {
    try {
      sqflite.Database? db = await instance.database;
      await db!.execute('''insert into todo_table(
          task_date,
          task_end_date,
          task_desc,
          task_type)
          values(datetime('$date'),datetime('$endDate'),'$taskDesc','$taskType')
      ''');
      // print("date type is : datetime");

      return true;
    } on sqflite.DatabaseException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<int> updateTodoTask(
      {required int taskId,
      required String endDate,
      required String taskDesc,
      required String taskDate,
      required String taskType}) async {
    try {
      sqflite.Database? db = await instance.database;
      return await db!.rawUpdate(''' 
      UPDATE todo_table
      SET task_desc='$taskDesc', task_date=datetime('$taskDate'), task_end_date=datetime('$endDate'), task_type='$taskType'
      WHERE task_id=$taskId;
    ''');
    } on sqflite.DatabaseException catch (e) {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> updateTaskCompletion(
      {required int taskId, required String taskCompletion}) async {
    try {
      sqflite.Database? db = await instance.database;
      return await db!.rawUpdate(''' 
      UPDATE todo_table
      SET  task_compl='$taskCompletion'
      WHERE task_id=$taskId;
    ''');
    } on sqflite.DatabaseException catch (e) {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> updateTaskState(
      {required int taskId, required String taskState}) async {
    try {
      sqflite.Database? db = await instance.database;
      return await db!.rawUpdate(''' 
      UPDATE todo_table
      SET  task_state='$taskState'
      WHERE task_id=$taskId;
    ''');
    } on sqflite.DatabaseException catch (e) {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteToDoTask({required int taskId}) async {
    try {
      sqflite.Database? db = await instance.database;
      return await db!.rawDelete('''
      delete from todo_table where task_id=$taskId
     ''');
    } on sqflite.DatabaseException catch (e) {
      return 0;
    } catch (e) {
      return 0;
    }
  }
  //***********************************transaction quries ********************************* */

  Future<bool> addTransaction(
      {required String date,
      required int amount,
      required String transType,
      required String description,
      required String title}) async {
    try {
      sqflite.Database? db = await instance.database;
      await db!.execute('''insert into daily_trans(
        trans_date,
         trans_amount,
         trans_type,
         trans_desc,
         trans_title
         )values(date('$date'),$amount,'$transType','$description','$title')
      ''');
      return true;
    } on sqflite.DatabaseException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<int> getSumOfYear(
      {required String date, required String transType}) async {
    try {
      sqflite.Database? db = await instance.database;
      List<Map<String, dynamic>> result;
      if (transType.isEmpty) {
        result = await db!.rawQuery(''' 
      select sum(trans_amount)  
      from daily_trans 
      where strftime('%Y', trans_date)=strftime('%Y', '$date')
       ''');
      } else {
        result = await db!.rawQuery(''' 
      select sum(trans_amount)  
      from daily_trans 
      where (
        strftime('%Y', trans_date)=strftime('%Y', '$date') AND 
        trans_type='$transType'
        )
       ''');
      }
      return result.first["sum(trans_amount)"];
    } on sqflite.DatabaseException catch (e) {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getSumOfMonth(
      {required String date, required String transType}) async {
    try {
      sqflite.Database? db = await instance.database;
      List<Map<String, dynamic>> result;
      if (transType.isEmpty) {
        result = await db!.rawQuery(''' 
      select sum(trans_amount)  
      from daily_trans 
      where (
          strftime('%Y', trans_date)=strftime('%Y', '$date') 
          AND strftime('%m', trans_date)=strftime('%m', '$date')
      )
       ''');
      } else {
        result = await db!.rawQuery(''' 
      select sum(trans_amount)  
      from daily_trans 
      where (
          strftime('%Y', trans_date)=strftime('%Y', '$date') 
          AND strftime('%m', trans_date)=strftime('%m', '$date')
          AND trans_type='$transType'
          )
      ''');
      }

      // print('in database helper : ${result.first["sum(trans_amount)"]}');
      if (result.first["sum(trans_amount)"] != null) {
        return result.first["sum(trans_amount)"];
      }
      return 0;
    } on sqflite.DatabaseException catch (e) {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getSumOfDay(
      {required String date, required String transType}) async {
    try {
      sqflite.Database? db = await instance.database;
      List<Map<String, dynamic>> result;
      if (transType.isEmpty) {
        result = await db!.rawQuery(''' 
      select sum(trans_amount)  
      from daily_trans 
       where (
          date(trans_date)=date('$date') 
          
      )
       ''');
      } else {
        result = await db!.rawQuery(''' 
      select sum(trans_amount)  
      from daily_trans 
       where (
          date(trans_date)=date('$date') 
          AND trans_type='$transType'
      )
       ''');
      }

      return result.first["sum(trans_amount)"];
    } on sqflite.DatabaseException catch (e) {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsInDay(
      {required String date, required String transType}) async {
    try {
      sqflite.Database? db = await instance.database;

      if (transType.isEmpty) {
        return await db!.rawQuery('''
        SELECT * from daily_trans 
        WHERE trans_date=date('$date')
    ''');
      } else {
        return await db!.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( trans_date=date('$date')
        AND trans_type='$transType'
        )

    ''');
      }
    } on sqflite.DatabaseException catch (e) {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsInMonth(
      {required String date, required String transType}) async {
    try {
      sqflite.Database? db = await instance.database;

      if (transType.isEmpty) {
        return await db!.rawQuery('''
        SELECT * from daily_trans 
        WHERE (
          strftime('%Y', trans_date)=strftime('%Y', '$date') 
          AND strftime('%m', trans_date)=strftime('%m', '$date')
          )
    ''');
      } else {
        return await db!.rawQuery('''
        SELECT * from daily_trans WHERE (
          strftime('%Y',trans_date)= strftime('%Y',date('$date') ) AND
          strftime('%m',trans_date)= strftime('%m',date('$date') ) AND
          trans_type='$transType'
          )
    ''');
      }
    } on sqflite.DatabaseException catch (e) {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTransactionsInYear(
      {required String date, required String transType}) async {
    try {
      sqflite.Database? db = await instance.database;
      if (transType.isEmpty) {
        return await db!.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( strftime('%Y',trans_date)=strftime('%Y','$date')
        )
    ''');
      } else {
        return await db!.rawQuery('''
        SELECT * from daily_trans 
        WHERE ( strftime('%Y',trans_date)=strftime('%Y','$date') AND
        trans_type='$transType'
        )
    ''');
      }
    } on sqflite.DatabaseException catch (e) {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<int> updateTransaction(
      {required int transId,
      required int amount,
      required String transType,
      required String description}) async {
    try {
      sqflite.Database? db = await instance.database;
      return await db!.rawUpdate(''' 
      UPDATE daily_trans
      SET trans_amount=$amount, trans_type='$transType', trans_desc='$description' 
      WHERE trans_id=$transId;
    ''');
    } on sqflite.DatabaseException catch (e) {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteTransaction({required int transId}) async {
    try {
      sqflite.Database? db = await instance.database;
      return await db!.rawDelete('''
      delete from daily_trans where trans_id=$transId
     ''');
    } on sqflite.DatabaseException catch (e) {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  //************************************************************************************* */

  //*****************CRUD OPERRATION */
  Future<List<Map<String, dynamic>>> queryAll() async {
    sqflite.Database? db = await instance.database;
    return await db!.query(_tableName);
  }

/*   Future<Map<String, dynamic>> readFirstRow() async {
    Database db = await instance.database;
  } */

  Future<int> insert(Map<String, dynamic> row) async {
    sqflite.Database? db = await instance.database;
    return await db!.insert(_tableName, row);
  }

  Future<int> delete(Map<String, dynamic> row) async {
    sqflite.Database? db = await instance.database;
    int id = row['id'];
    return await db!.delete(_tableName, where: 'id=?', whereArgs: [id]);
  }

  Future<int> update(Map<String, dynamic> row) async {
    sqflite.Database? db = await instance.database;
    int id = row['id'];
    return await db!.update(_tableName, row, where: 'id=?', whereArgs: [id]);
  }

  Future delDatabase({required String dbName}) async {
    io.Directory directory =
        await path_provider.getApplicationDocumentsDirectory();
    String path = path_package.join(directory.path, dbName);
    sqflite.deleteDatabase(path).whenComplete(() {});
  }

  Future closeDb({required String dbName}) async {
    instance
        .closeDb(dbName: dbName)
        .onError((error, stackTrace) => print(error));
  }
}
