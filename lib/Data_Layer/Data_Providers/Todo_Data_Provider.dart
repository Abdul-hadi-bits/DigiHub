import "package:sqflite/sqflite.dart" as sqflite;

class TodoDataProvider {
  late sqflite.Database? database;
  TodoDataProvider({
    this.database,
  });

  Future<List<Map<String, dynamic>>> getAllTodoTasks(
      {required String date, required bool hasTime}) async {
    try {
      if (hasTime) {
        return await database!.rawQuery('''
        SELECT * from todo_table 
        WHERE taskDate=datetime('$date')
    ''');
      } else {
        return await database!.rawQuery('''
        SELECT * from todo_table 
        WHERE strftime('%Y-%m-%d',taskDate)=date('$date')

    ''');
      }
    } on sqflite.DatabaseException {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTodoTasksDayBeforeEndsAtCurrentDaye(
      {required String date, required bool hasTime}) async {
    try {
      if (hasTime) {
        return await database!.rawQuery('''
        SELECT * from todo_table 
        WHERE taskEndDate=datetime('$date') 
    ''');
      } else {
        return await database!.rawQuery('''
        SELECT * from todo_table 
        WHERE strftime('%Y-%m-%d',taskEndDate)=date('$date') OR strftime('%Y-%m-%d',taskDate)=date('$date')

    ''');
      }
    } on sqflite.DatabaseException {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getTaskId(
      {required String date, required String description}) async {
    try {
      return await database!.rawQuery('''
        SELECT taskId from todo_table 
        WHERE strftime('%Y-%m-%d',taskDate)=date('$date') AND
        taskDescription='$description'
    ''');
    } on sqflite.DatabaseException {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTodoTasksInMonth(
      {required String date, required bool hasTime}) async {
    try {
      return await database!.rawQuery('''
        SELECT * from todo_table 
        WHERE strftime('%Y-%m',taskDate)=strftime('%Y-%m',datetime('$date'))
    ''');
    } on sqflite.DatabaseException {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTodoTasksInYear(
      {required String date, required bool hasTime}) async {
    try {
      return await database!.rawQuery('''
        SELECT * from todo_table 
        WHERE strftime('%Y',taskDate)=strftime('%Y',datetime('$date'))
    ''');
    } on sqflite.DatabaseException {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTodoTasksByState(
      {required String date, required bool hasTime}) async {
    try {
      return await database!.rawQuery('''
        SELECT * from todo_table 
        WHERE taskSate= 'missed'
    ''');
    } on sqflite.DatabaseException {
      return [{}];
    } catch (e) {
      return [{}];
    }
  }

  Future<List<Map<String, dynamic>>> getTodoTasksByTypeInYear(
      {required String date, required String taskType}) async {
    try {
      return await database!.rawQuery('''
        SELECT * from todo_table 
        WHERE (
        strftime('%Y',taskDate)=strftime('%Y', '$date')
        AND
        taskType='$taskType'
        )
    ''');
    } on sqflite.DatabaseException {
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
      required String taskType,
      required String taskCompl,
      required String taskSate}) async {
    try {
      await database!.execute('''insert into todo_table(
          taskDate,
          taskEndDate,
          taskDescription,
          taskType,
          taskCompletion,
          taskSate)
          values(datetime('$date'),datetime('$endDate'),'$taskDesc','$taskType','$taskCompl','$taskSate')
      ''');
      print("task was added to database , inside database query");

      return true;
    } on sqflite.DatabaseException {
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
      return await database!.rawUpdate(''' 
      UPDATE todo_table
      SET taskDescription='$taskDesc', taskDate=datetime('$taskDate'), taskEndDate=datetime('$endDate'), taskType='$taskType'
      WHERE taskId=$taskId;
    ''');
    } on sqflite.DatabaseException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> updateTaskCompletion(
      {required int taskId, required String taskCompletion}) async {
    try {
      return await database!.rawUpdate(''' 
      UPDATE todo_table
      SET  taskCompletion='$taskCompletion'
      WHERE taskId=$taskId;
    ''');
    } on sqflite.DatabaseException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> updateTaskState(
      {required int taskId, required String taskState}) async {
    try {
      return await database!.rawUpdate(''' 
      UPDATE todo_table
      SET  taskSate='$taskState'
      WHERE taskId=$taskId;
    ''');
    } on sqflite.DatabaseException {
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> deleteToDoTask({required int taskId}) async {
    try {
      return await database!.rawDelete('''
      delete from todo_table where taskId=$taskId
     ''');
    } on sqflite.DatabaseException {
      return 0;
    } catch (e) {
      return 0;
    }
  }
}
