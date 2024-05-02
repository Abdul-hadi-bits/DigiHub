import 'dart:convert';

class TodoModule {
  int taskId = 0;
  String taskType = "";
  String taskDate = "";
  String taskEndDate = "";
  String taskDescription = "";
  String taskCompletion = "";
  String taskSate = "";

  TodoModule({
    required this.taskId,
    required this.taskType,
    required this.taskDate,
    required this.taskEndDate,
    required this.taskDescription,
    required this.taskCompletion,
    required this.taskSate,
  });

  TodoModule copyWith({
    int? taskId,
    String? taskType,
    String? taskDate,
    String? taskEndDate,
    String? taskDescription,
    String? taskCompletion,
    String? taskSate,
  }) {
    return TodoModule(
      taskId: taskId ?? this.taskId,
      taskType: taskType ?? this.taskType,
      taskDate: taskDate ?? this.taskDate,
      taskEndDate: taskEndDate ?? this.taskEndDate,
      taskDescription: taskDescription ?? this.taskDescription,
      taskCompletion: taskCompletion ?? this.taskCompletion,
      taskSate: taskSate ?? this.taskSate,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'taskId': taskId,
      'taskType': taskType,
      'taskDate': taskDate,
      'taskEndDate': taskEndDate,
      'taskDescription': taskDescription,
      'taskCompletion': taskCompletion,
      'taskSate': taskSate,
    };
  }

  factory TodoModule.fromMap(Map<String, dynamic> map) {
    return TodoModule(
      taskId: map['taskId'] as int,
      taskType: map['taskType'] as String,
      taskDate: map['taskDate'] as String,
      taskEndDate: map['taskEndDate'] as String,
      taskDescription: map['taskDescription'] as String,
      taskCompletion: map['taskCompletion'] as String,
      taskSate: map['taskSate'] as String,
    );
  }

  static List<TodoModule> fromListMap(List<Map<String, dynamic>> listMap) {
    List<TodoModule> listOfTodoModuleObjects = [];

    if (listMap.isEmpty) {
      return listOfTodoModuleObjects;
    } else if (listMap[0].isEmpty) {
      return listOfTodoModuleObjects;
    }

    listMap.forEach((map) {
      listOfTodoModuleObjects.add(TodoModule.fromMap(map));
    });
    return listOfTodoModuleObjects;
  }

  String toJson() => json.encode(toMap());

  factory TodoModule.fromJson(String source) =>
      TodoModule.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TodoModule(taskId: $taskId, taskType: $taskType, taskDate: $taskDate, taskEndDate: $taskEndDate, taskDescription: $taskDescription, taskCompletion: $taskCompletion, taskSate: $taskSate)';
  }

  @override
  bool operator ==(covariant TodoModule other) {
    if (identical(this, other)) return true;

    return other.taskId == taskId &&
        other.taskType == taskType &&
        other.taskDate == taskDate &&
        other.taskEndDate == taskEndDate &&
        other.taskDescription == taskDescription &&
        other.taskCompletion == taskCompletion &&
        other.taskSate == taskSate;
  }

  @override
  int get hashCode {
    return taskId.hashCode ^
        taskType.hashCode ^
        taskDate.hashCode ^
        taskEndDate.hashCode ^
        taskDescription.hashCode ^
        taskCompletion.hashCode ^
        taskSate.hashCode;
  }
}
