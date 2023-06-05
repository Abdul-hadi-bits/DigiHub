import 'package:my_project/databaste/database_helper.dart' as helper;

class ToDoDatabase {
  //late int sumOfYear;
  Future<bool> addTodoTask(
      {required String date,
      required String endDate,
      required String description,
      // required bool isDateTime,
      required String taskType}) async {
    bool result = await helper.DatabaseHelper.instance.addTask(
        date: date,
        endDate: endDate,
        // isDatetime: isDateTime,
        taskDesc: description,
        taskType: taskType);
    return result;
  }

  Future<void> deleteTodoTask({required int taskId}) async {
    await helper.DatabaseHelper.instance.deleteToDoTask(taskId: taskId);
  }

  Future<List<Map<String, dynamic>>> getTodoTasks(
      {required String date, required bool hasTime}) async {
    return await helper.DatabaseHelper.instance
        .getAllTodoTasks(date: date, hasTime: hasTime);
  }

  /* String dateFormatter(DateTime date) {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(date);
    print(formatted);
    return formatted;
  } */

  Future<List<Map<String, dynamic>>> getTodoTasksWithOutMissed(
      {required String date, required bool hasTime}) async {
    // add day before intersects tasks

    return _removeMissedTasks(await helper.DatabaseHelper.instance
        .getAllTodoTasksDayBeforeEndsAtCurrentDaye(
            date: date, hasTime: hasTime));
  }

  Future<List<Map<String, dynamic>>> getTodoTaskByState() async {
    return await helper.DatabaseHelper.instance.getAllTodoTasksByState(
        date: DateTime.now().toString(), hasTime: false);
  }

  Future<int> getTaskId({required String date, required String desc}) async {
    List<Map<String, dynamic>> id = await helper.DatabaseHelper.instance
        .getTaskId(date: date, description: desc);
    return id[0]['task_id'];
  }

  /*  Future<List<Map<String, dynamic>>> getTodoTasksInMonth(
      {required String date, required bool hasTime}) async {
    return await helper.DatabaseHelper.instance
        .getAllTodoTasksInMonth(date: date, hasTime: hasTime);
  } */

  Future<List<Map<String, dynamic>>> getTodoTasksInYear(
      {required String date, required bool hasTime}) async {
    return await helper.DatabaseHelper.instance
        .getAllTodoTasksInYear(date: date, hasTime: hasTime);
  }

  Future<List<Map<String, dynamic>>> getTodoTasksInYearNotMissed(
      {required String date, required bool hasTime}) async {
    return _removeMissedTasks(await helper.DatabaseHelper.instance
        .getAllTodoTasksInYear(date: date, hasTime: hasTime));
  }

  Future<List<Map<String, dynamic>>> getTodoTasksByTypeInYearNotMissed(
      {required String date, required String taskType}) async {
    return _removeMissedTasks(await helper.DatabaseHelper.instance
        .getTodoTasksByTypeInYear(date: date, taskType: taskType));
  }

  Future<bool> updateTodoTask(
      {required int taskId,
      required String endDate,
      required String taskDesc,
      required String taskDate,
      required String taskType}) async {
    int response = await helper.DatabaseHelper.instance.updateTodoTask(
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

  Future<void> updateTaskCompletion(
      {required int taskId, required String taskCompletion}) async {
    await helper.DatabaseHelper.instance
        .updateTaskCompletion(taskId: taskId, taskCompletion: taskCompletion);
  }

  Future<void> updateTaskState(
      {required int taskId, required String taskState}) async {
    await helper.DatabaseHelper.instance
        .updateTaskState(taskId: taskId, taskState: taskState);
  }

  List<Map<String, dynamic>> _removeMissedTasks(
      List<Map<String, dynamic>> data) {
    List<Map<String, dynamic>> newData = [];
    // print(data);
    for (int i = 0; i < data.length; i++) {
      //print('run');
      if (data[i]['task_state'] != 'missed') {
        /*  print(data[i]['task_desc']);
        print("index : $i"); */
        newData.add(data[i]);
      }
    }
    //  print("data is : $newData");
    return newData;
  }
}
