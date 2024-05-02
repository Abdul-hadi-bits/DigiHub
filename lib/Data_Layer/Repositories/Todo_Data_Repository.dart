// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:digi_hub/Data_Layer/Data_Providers/Todo_Data_Provider.dart';
import 'package:digi_hub/Data_Layer/Module/ToDo_Data_Module.dart';
import "package:sqflite/sqflite.dart" as sqflite;

class TodoDataRepository {
  sqflite.Database? database;
  static late TodoDataProvider _todoProvider;

  TodoDataRepository({
    required this.database,
  }) {
    _todoProvider = TodoDataProvider(database: database);
  }

  //late int sumOfYear;
  Future<bool> addTodoTask(
      {required String date,
      required String endDate,
      required String description,
      required String taskCompl,
      required String taskType,
      required String taskState}) async {
    description = description.replaceAll(RegExp("'"), "''");
    bool result = await _todoProvider.addTask(
        date: date,
        endDate: endDate,
        // isDatetime: isDateTime,
        taskDesc: description,
        taskType: taskType,
        taskCompl: taskType,
        taskSate: taskState);
    return result;
  }

  Future<void> deleteTodoTask({required int taskId}) async {
    await _todoProvider.deleteToDoTask(taskId: taskId);
  }

  Future<List<TodoModule>> getTodoTasks(
      {required String date, required bool hasTime}) async {
    return TodoModule.fromListMap(
        await _todoProvider.getAllTodoTasks(date: date, hasTime: hasTime));
  }

  Future<List<TodoModule>> getTodoTasksWithOutMissed(
      {required String date, required bool hasTime}) async {
    // add day before intersects tasks

    return TodoModule.fromListMap(_removeMissedTasks(
        await _todoProvider.getAllTodoTasksDayBeforeEndsAtCurrentDaye(
            date: date, hasTime: hasTime)));
  }

  Future<List<TodoModule>> getTodoTaskByState() async {
    return TodoModule.fromListMap(await _todoProvider.getAllTodoTasksByState(
        date: DateTime.now().toString(), hasTime: false));
  }

/////   ??????????????????   getTask Id //////////changed to /////////getsTaskById//////
  Future<int> getTaskId({required String date, required String desc}) async {
    desc = desc.replaceAll(RegExp("'"), "''");
    List<Map<String, dynamic>> taskMap =
        await _todoProvider.getTaskId(date: date, description: desc);
    return taskMap.first['taskId'];
  }

  Future<List<TodoModule>> getTodoTasksInYear(
      {required String date, required bool hasTime}) async {
    return TodoModule.fromListMap(await _todoProvider.getAllTodoTasksInYear(
        date: date, hasTime: hasTime));
  }

  Future<List<TodoModule>> getTodoTasksInYearNotMissed(
      {required String date, required bool hasTime}) async {
    return TodoModule.fromListMap(_removeMissedTasks(await _todoProvider
        .getAllTodoTasksInYear(date: date, hasTime: hasTime)));
  }

  Future<List<TodoModule>> getTodoTasksByTypeInYearNotMissed(
      {required String date, required String taskType}) async {
    return TodoModule.fromListMap(_removeMissedTasks(await _todoProvider
        .getTodoTasksByTypeInYear(date: date, taskType: taskType)));
  }

  Future<bool> updateTodoTask(
      {required int taskId,
      required String endDate,
      required String taskDesc,
      required String taskDate,
      required String taskType}) async {
    taskDesc.replaceAll(RegExp("'"), "''");
    int response = await _todoProvider.updateTodoTask(
        endDate: endDate,
        taskId: taskId,
        taskDate: taskDate,
        taskDesc: taskDesc,
        taskType: taskType);
    if (response == 1) {
      return true;
    }
    return false;
  }

  Future<bool> updateTaskCompletion(
      {required int taskId, required String taskCompletion}) async {
    return await _todoProvider.updateTaskCompletion(
                taskId: taskId, taskCompletion: taskCompletion) !=
            0
        ? true
        : false;
  }

  Future<bool> updateTaskState(
      {required int taskId, required String taskState}) async {
    return await _todoProvider.updateTaskState(
                taskId: taskId, taskState: taskState) !=
            0
        ? true
        : false;
  }

  List<Map<String, dynamic>> _removeMissedTasks(
      List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> newData = [];
    data.forEach((raw) {
      raw['taskSate'] != 'missed' ? newData.add(raw) : false;
    });
    return newData;
  }
}
