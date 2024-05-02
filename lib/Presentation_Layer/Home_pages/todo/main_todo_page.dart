import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/todo/add_todo.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/todo/missed_tasks.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:digi_hub/Data_Layer/Data_Providers/Local_Database_Provider.dart';
import 'package:digi_hub/Data_Layer/Module/ToDo_Data_Module.dart';
import 'package:digi_hub/Data_Layer/Repositories/Todo_Data_Repository.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';
import 'package:digi_hub/Utillity/notification_helper.dart' as notif;

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late SharedPreferences pref;
  //late notif.NotificationClass notification;

  // bool isCompleted = false;

  TodoDataRepository _todoRepository =
      TodoDataRepository(database: LocalDbProvider.database);
  List<String> taskTypes = ["none", "personal", "work", "shopping", "familly"];
  Map<String, dynamic> tasksPerType = {
    'none': 0,
    'personal': 0,
    'work': 0,
    'shopping': 0,
    'familly': 0
  };

  Map<String, dynamic> taskColors = {
    'none': Colors.grey.shade300,
    'personal': Colors.orange.shade300,
    'work': Colors.green.shade300,
    'shopping': Colors.pink.shade200,
    'familly': Colors.yellow.shade300
  };

  Map<String, dynamic> textColors = {
    'none': Colors.black,
    'personal': Colors.black,
    'work': Colors.white,
    'shopping': Colors.white,
    'familly': Colors.black
  };
  DateTime? date;
  late FToast ftoast;
  late notif.NotificationClass notification;
  @override
  void initState() {
    // TODO: implement initState
    notification = notif.NotificationClass();
    notification.initializeNotification();
    SharedPreferences.getInstance().then((instance) {
      pref = instance;
    });
    _todoRepository
        .getTodoTasksInYearNotMissed(
            date: currentDateFormatted(), hasTime: false)
        .then((dataInMonth) {
      findTasksPerType(dataInMonth);
    });
    ftoast = FToast();
    ftoast.init(context);

    _todoRepository
        .getTodoTasksInYearNotMissed(
            date: DateTime.now().toString(), hasTime: false)
        .then((taskData) async {
      await _checkForExpiredTasks(listOfTodoObjects: taskData);
      await findTasksPerType(taskData);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        context: context,
        ttle: dateFormatter(date) == currentDateFormatted()
            ? "Today"
            : dateFormatter(date, true),
        italikTitle: true,
        fitTitle: true,
        statusBarDark: false,
        showLeading: false,
        titleSpacing: 70,
        actions: [
          IconButton(
            onPressed: () async {
              date = await showDatePicker(
                builder: (context, child) {
                  return Theme(
                    data: ThemeData(
                      primarySwatch: Colors.grey,
                      splashColor: Colors.black,
                      textTheme: TextTheme(
                        titleMedium: TextStyle(color: Colors.black),
                        labelLarge: TextStyle(color: Colors.black),
                      ),
                      //accentColor: Colors.black,
                      colorScheme: ColorScheme.light(
                          primary: Color(0xffffbc00),
                          //  primaryVariant: Colors.black,
                          //  secondaryVariant: Colors.black,
                          onSecondary: Colors.black,
                          onPrimary: Colors.white,
                          surface: Colors.white,
                          onSurface: Colors.black,
                          secondary: Colors.white),
                      dialogBackgroundColor: Colors.white,
                    ),
                    child: child ?? Text(""),
                  );
                },
                context: context,
                firstDate: DateTime(1900),
                initialDate: date ?? DateTime.now(),
                lastDate: DateTime(2100),
              );

              setState(() {});
            },
            icon: const Hero(
              tag: "edit",
              child: Icon(
                Icons.more_horiz,
                color: Colors.blue,
                size: 30,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              /* Navigator.pushNamed(
                context,
                "/MissedTasksPage",
                /* MaterialPageRoute(
                    builder: (context) => const MissedTaskPage(),), */
              ) */
              Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: MissedTaskPage()))
                  .then((value) {
                _todoRepository
                    .getTodoTasksInYearNotMissed(
                        date: currentDateFormatted(), hasTime: false)
                    .then((dataInMonth) {
                  findTasksPerType(dataInMonth);
                  setState(() {});
                });
              });
            },
            icon: const Icon(
              Icons.double_arrow,
              color: Colors.orange,
              size: 25,
            ),
          ),
        ],
      ),
      body: Builder(builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height -
              Scaffold.of(context).appBarMaxHeight!.toDouble(),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: FutureBuilder<List<TodoModule>>(
                    future: _todoRepository.getTodoTasksWithOutMissed(
                        date: dateFormatter(date), hasTime: false),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<TodoModule>? data = snapshot.data;

                        try {
                          data!.first.taskDescription;
                          return Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, top: 10, bottom: 10),
                                child: Text(
                                    "Completed ${getNumberOfTasksCompleted(data)}/${data.length}"),
                              ),
                            ],
                          );
                        } catch (e) {
                          return Text("");
                        }
                      }
                      return Text("");
                    }),
              ),
              Expanded(
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: FutureBuilder<List<TodoModule>>(
                          future: _todoRepository.getTodoTasksWithOutMissed(
                              date: dateFormatter(date), hasTime: false),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<TodoModule>? data = snapshot.data;

                              try {
                                data!.first.taskDescription;

                                return todoTasks(data: snapshot.data!);
                              } catch (e) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.085,
                                  child: ListTile(
                                    leading: const Icon(Icons.circle_outlined,
                                        size: 25),
                                    trailing: const Icon(
                                      Icons.circle,
                                      size: 17,
                                    ),
                                    style: ListTileStyle.drawer,
                                    title: const Text(
                                      "Nothing Scheduled",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                    /* //subtitle: (time.substring(10) != "00:00:00")
                          ? Text((time.substring(10, 16)))
                          : const Text("00:00"), */
                                    shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: Colors.black, width: 0.5),
                                        borderRadius: BorderRadius.circular(0)),
                                  ),
                                );
                              }
                            }
                            return const Center(
                                child: LinearProgressIndicator());
                          }),
                    ),
                  ),
                  flex: 15),
              Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: listOfGroups(),
                  ),
                  flex: 20),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: FaIcon(
          FontAwesomeIcons.plus,
          size: 20,
          color: Colors.blue.shade800,
        ),
        backgroundColor: Colors.white,
        onPressed: () async {
          /*  Navigator.pushNamed(
            context,
            "/AddTodoTaskPage",
            //     MaterialPageRoute(builder: (context) => AddTodoTask()),
          ) */
          Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: AddTodoTask()))
              .then((value) {
            setState(() {
              _todoRepository
                  .getTodoTasksInYearNotMissed(
                      date: currentDateFormatted(), hasTime: false)
                  .then((dataInMonth) async {
                await _checkForExpiredTasks(listOfTodoObjects: dataInMonth);
                await findTasksPerType(dataInMonth);
              });
            });
          });
        },
      ),
    );
  }

  String currentDateFormattedIntoMonth() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM');
    String formatted = formatter.format(now);
    return formatted;
  }

  String dateFormatter(DateTime? date, [bool? inText]) {
    if (date != null) {
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      DateFormat formatterText = DateFormat(DateFormat.ABBR_MONTH_DAY);

      String formatted =
          inText == true ? formatterText.format(date) : formatter.format(date);

      return formatted;
    }
    return currentDateFormatted();
  }

  showBottomSheet({required String taskType, required int numOfTasks}) {
    return showModalBottomSheet<dynamic>(
        isDismissible: false,
        isScrollControlled: true,
        enableDrag: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        context: context,
        builder: (constext) {
          return Stack(
            alignment: Alignment.topLeft,
            children: [
              MyBottomSheet(taskType, numOfTasks, taskColors[taskType]),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close),
              ),
            ],
          );
        }).whenComplete(() {
      _todoRepository
          .getTodoTasksInYearNotMissed(
              date: currentDateFormatted(), hasTime: false)
          .then((dataInMonth) {
        findTasksPerType(dataInMonth);
      }).then((value) {
        setState(() {});
      });
    });
  }

  findTasksPerType(List<TodoModule> data) {
    // data contains tasks in a month
    int work = 0;
    int familly = 0;
    int shopping = 0;
    int personal = 0;
    int none = 0;
    for (int i = 0; i < data.length; i++) {
      data[i].taskType == 'work' ? {work++} : false;
      data[i].taskType == 'familly' ? {familly++} : false;
      data[i].taskType == 'shopping' ? {shopping++} : false;
      data[i].taskType == 'none' ? {none++} : false;
      data[i].taskType == 'personal' ? {personal++} : false;
    }
    tasksPerType['work'] = work;
    tasksPerType['shopping'] = shopping;
    tasksPerType['none'] = none;
    tasksPerType['familly'] = familly;
    tasksPerType['personal'] = personal;

    setState(() {});
  }

  Widget todoTasks({required List<TodoModule> data}) {
    String taskDescription = "";
    String timeDate = "";
    String endTimeDate = "";
    String typeOfTask = "";
    int taskId;

    String newtime = "";
    String newEndTime = "";

    data.length;

    return Column(
      children: [
        ListView.separated(
            physics: const BouncingScrollPhysics(),
            separatorBuilder: ((context, index) => Divider(
                  color: Colors.grey.shade400,
                  //endIndent: MediaQuery.of(context).size.width / 15,
                  indent: MediaQuery.of(context).size.width / 18,
                  height: 1,
                  thickness: 1,
                )),
            shrinkWrap: true,
            addAutomaticKeepAlives: true,
            controller: ScrollController(keepScrollOffset: true),
            scrollDirection: Axis.vertical,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int itemIndex) {
              taskDescription = data[itemIndex].taskDescription;
              timeDate = data[itemIndex].taskDate;
              endTimeDate = data[itemIndex].taskEndDate;
              typeOfTask = data[itemIndex].taskType;

              //isCompleted = taskCompl == 'true' ? true : false;
              //DateTime taskDate = DateTime.parse(time);

              //subtime = timeDate.substring(10);
              newtime = DateFormat.jm().format(DateTime.parse(timeDate));
              newEndTime = DateFormat.jm().format(DateTime.parse(endTimeDate));

              //print("subtime $subtime ");

              return InkWell(
                splashColor: Colors.amber.shade600,
                onTap: () {
                  _showToast();
                },
                onLongPress: () async {
                  int taskId = data[itemIndex].taskId;
                  await notification.cancelNotificaion(id: taskId);
                  await _todoRepository.deleteTodoTask(taskId: taskId);
                  _todoRepository
                      .getTodoTasksInYearNotMissed(
                          date: currentDateFormatted(), hasTime: false)
                      .then((dataInMonth) {
                    findTasksPerType(dataInMonth);
                    setState(() {});
                  });
                  setState(() {});
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.085,
                  child: ListTile(
                      leading: IconButton(
                        icon: data[itemIndex].taskCompletion == 'true'
                            ? const Icon(Icons.check_circle_outline,
                                size: 28, color: Colors.green)
                            : Icon(Icons.check_circle_outline,
                                size: 28, color: Colors.grey.shade300),
                        onPressed: () async {
                          taskId = data[itemIndex].taskId;

                          await _todoRepository
                              .updateTaskCompletion(
                                  taskId: taskId,
                                  taskCompletion:
                                      data[itemIndex].taskCompletion == 'true'
                                          ? 'false'
                                          : 'true')
                              .then((value) async {
                            setState(() {});
                            if (data[itemIndex].taskCompletion == 'true') {
                              if (pref.getString('notif') == 'true') {
                                // schedual end of task notification
                                await notification.schedualEndNotification(
                                    id: taskId * 5,
                                    body: taskDescription,
                                    scheduledTime: DateTime.parse(
                                        data[itemIndex].taskEndDate));
                              }
                            } else if (data[itemIndex].taskCompletion !=
                                'true') {
                              if (pref.getString('notif') == 'true') {
                                await notification.cancelNotificaion(
                                    id: taskId * 5);
                              }
                            }
                          });
                        },
                      ),
                      trailing: Icon(
                        Icons.circle,
                        size: 15,
                        color: taskColors[typeOfTask],
                      ),
                      style: ListTileStyle.drawer,
                      title: Text(taskDescription,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        children: [
                          Text(
                            newtime,
                          ),
                          const Text(" - "),
                          Text(
                            newEndTime,
                          ),
                        ],
                      )),
                ),
              );
            }),
      ],
    );
  }

  _checkForExpiredTasks({required List<TodoModule> listOfTodoObjects}) async {
    // DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    DateTime pastDays = DateTime.now().subtract(const Duration(days: 2));

    DateTime taskDate;

    for (TodoModule todoObject in listOfTodoObjects) {
      taskDate = DateTime.parse(todoObject.taskEndDate);

      if (todoObject.taskCompletion == 'true' &&
          taskDate.isBefore(DateTime.now())) {
        await _todoRepository.deleteTodoTask(taskId: todoObject.taskId);
        print('task deleted date was completed: $taskDate');
      } else if (todoObject.taskCompletion != 'true' &&
          taskDate.isBefore(DateTime.now()) &&
          todoObject.taskSate != 'missed') {
        _todoRepository.updateTaskState(
            taskId: todoObject.taskId, taskState: 'missed');
      } else if (todoObject.taskCompletion != 'true' &&
          taskDate.isBefore(pastDays)) {
        await _todoRepository
            .deleteTodoTask(taskId: todoObject.taskId)
            .then((value) {
          setState(() {});
        });
        print("task date: $taskDate now passedLimitDate: $pastDays");
        print('task deleted date was passed two days: $taskDate');
      }
    }
  }

  _showToast() {
    //ftoast.removeCustomToast();
    ftoast.init(context);
    ftoast.showToast(
        gravity: ToastGravity.TOP,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: const Color.fromARGB(255, 255, 160, 0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(FontAwesomeIcons.timesCircle),
              SizedBox(
                width: 12.0,
              ),
              Text(
                "Long press to Dismiss",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ));

    /* ftoast.showToast(
      child: toast,
      fadeDuration: 2,
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    ); */
  }

  Widget listOfGroups() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child: Card(
              color: Colors.white,
              elevation: 1,
              child: Padding(
                padding: EdgeInsets.only(
                    //left: MediaQuery.of(context).size.width * 0.135,
                    left: MediaQuery.of(context).size.width * 0.05),
                child: const Text("List",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 14,
          child: /*  Padding(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width / 11),
            child:  */
              SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: ListView.separated(
              physics: BouncingScrollPhysics(),
              controller: ScrollController(keepScrollOffset: true),
              scrollDirection: Axis.vertical,
              itemCount: taskTypes.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 70, // MediaQuery.of(context).size.height * 0.085,
                  decoration: BoxDecoration(
                    color: taskColors[taskTypes[index]],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 20, right: 20),
                    style: ListTileStyle.list,
                    title: Text(
                      taskTypes[index],
                      style: TextStyle(
                          color: textColors[taskTypes[index]],
                          fontSize: 18,
                          fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text('${tasksPerType[taskTypes[index]]} Tasks'),
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.blue, width: 0.5),
                        borderRadius: BorderRadius.circular(20)),
                    onTap: () {
                      print("click $index");
                      showBottomSheet(
                        taskType: taskTypes[index],
                        numOfTasks: tasksPerType[taskTypes[index]],
                      );
                    },
                  ),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                thickness: 5,
                height: 5,
                color: Colors.white,
              ),
            ),
          ),
        ),
        // ),
      ],
    );
  }

  String currentDateFormatted() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    return formatted;
  }

  int getNumberOfTasksCompleted(List<TodoModule> data) {
    int sum = 0;
    data.forEach((element) {
      if (element.taskCompletion == "true") {
        sum += 1;
      }
    });

    return sum;
  }
}

class MyBottomSheet extends StatefulWidget {
  String taskType = "";
  int numOfTasks = 0;
  Color color = Colors.white;
  MyBottomSheet(this.taskType, this.numOfTasks, this.color, {Key? key})
      : super(key: key);

  @override
  State<MyBottomSheet> createState() =>
      _MyBottomSheetState(taskType, numOfTasks, color);
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  late notif.NotificationClass notification;
  TodoDataRepository _todoRepository =
      TodoDataRepository(database: LocalDbProvider.database);
  Color color = Colors.white;
  String taskType = "";
  int numOftasks = 0;

  _MyBottomSheetState(this.taskType, this.numOftasks, this.color);

  Map<String, dynamic> textColorsDesc = {
    'none': Colors.black,
    'personal': Colors.black,
    'work': Colors.white,
    'shopping': Colors.white,
    'familly': Colors.black
  };
  Map<String, dynamic> textColorsTitleAndIcon = {
    'none': Colors.black,
    'personal': Colors.black,
    'work': Colors.white,
    'shopping': Colors.white,
    'familly': Colors.black
  };
  Map<String, dynamic> taskNumColors = {
    'none': Colors.black,
    'personal': Colors.black,
    'work': Colors.black,
    'shopping': Colors.black,
    'familly': Colors.black
  };
  Map<String, dynamic> iconColors = {
    'none': Colors.white,
    'personal': Colors.white,
    'work': Colors.black,
    'shopping': Colors.black,
    'familly': Colors.white
  };
  int selectedIndex = 0;
  bool isSelected = false;
  int taskId = 0;

  late FToast ftoast;
  @override
  void initState() {
    notification = notif.NotificationClass();
    notification.initializeNotification();
    ftoast = FToast();
    ftoast.init(context);
    super.initState();
    // DatabaseHelper.instance.delDatabase(dbName: "Plans.db");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 1,
        minChildSize: 0.7,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: color,
                        child: Column(children: [
                          Padding(
                            padding: EdgeInsets.only(
                                right: 10,
                                left: MediaQuery.of(context).size.width / 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  taskType,
                                  style: TextStyle(
                                      fontSize: 30,
                                      color: textColorsTitleAndIcon[taskType],
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      print("clicked");
                                      if (isSelected) {
                                        await _todoRepository.deleteTodoTask(
                                            taskId: taskId);
                                        await notification.cancelNotificaion(
                                            id: taskId);
                                        await notification.cancelNotificaion(
                                            id: taskId * 5);
                                        setState(() {
                                          isSelected = false;
                                        });
                                      } else {
                                        _showToast();
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 30,
                                    ))
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width / 5),
                              child: Text(
                                "Tasks $numOftasks",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: taskNumColors[taskType],
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: FutureBuilder<List<TodoModule>>(
                            future: _todoRepository
                                .getTodoTasksByTypeInYearNotMissed(
                                    date: currentDateFormatted(),
                                    taskType: taskType),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<TodoModule>? data = snapshot.data;
                                try {
                                  data![0];
                                  return todoTasks(data: data);
                                } catch (e) {
                                  return Container(
                                    height: 65,
                                    color: color,
                                    child: ListTile(
                                      leading: const Icon(Icons.circle_outlined,
                                          size: 20),
                                      trailing: const Icon(
                                        Icons.circle,
                                        size: 15,
                                      ),
                                      style: ListTileStyle.drawer,
                                      title: Text("No Task To Do"),
                                      /* //subtitle: (time.substring(10) != "00:00:00")
                      ? Text((time.substring(10, 16)))
                      : const Text("00:00"), */
                                      shape: RoundedRectangleBorder(
                                          side: const BorderSide(
                                              color: Colors.black, width: 0.5),
                                          borderRadius:
                                              BorderRadius.circular(0)),
                                    ),
                                  );
                                }
                              }
                              return const Center(child: Text("Loadin..."));
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color.fromARGB(255, 255, 160, 0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(FontAwesomeIcons.timesCircle),
          SizedBox(
            width: 12.0,
          ),
          Text(
            "Please select a Task",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    ftoast.showToast(
      child: toast,
      fadeDuration: const Duration(seconds: 2),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Widget todoTasks({required List<TodoModule> data}) {
    String taskDescription = "";
    String date = "";
    String dateEnd = "";

    return Column(
      children: [
        ListView.separated(
            physics: const BouncingScrollPhysics(),
            separatorBuilder: ((context, index) => Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width * 0.8,
                  color: Colors.grey,
                )),
            shrinkWrap: true,
            addAutomaticKeepAlives: true,
            controller: ScrollController(keepScrollOffset: true),
            scrollDirection: Axis.vertical,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              int itemIndex = (data.length - 1) - index;
              taskDescription = data[itemIndex].taskDescription;
              date = data[itemIndex].taskDate;
              dateEnd = data[itemIndex].taskEndDate;
              taskType = data[itemIndex].taskType;

              return Container(
                height: 65,
                color: color,
                child: ListTile(
                  leading: Icon(
                    isSelected && (selectedIndex == itemIndex)
                        ? Icons.circle
                        : Icons.circle_outlined,
                    size: 30,
                    color: isSelected && (selectedIndex == itemIndex)
                        ? Colors.lightBlue
                        : Colors.grey,
                  ),
                  trailing: Icon(
                    Icons.circle,
                    size: 15,
                    color: textColorsTitleAndIcon[taskType],
                  ),
                  style: ListTileStyle.drawer,
                  title: Text(
                    taskDescription,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: textColorsDesc[taskType],
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                  subtitle: (dateFormatter(date: DateTime.parse(date)) ==
                              currentDateFormatted()) ||
                          (dateFormatter(date: DateTime.parse(dateEnd)) ==
                              currentDateFormatted())
                      ? Row(
                          children: [
                            Icon(
                              Icons.today,
                              color: iconColors[taskType],
                            ),
                            const Text(" Today")
                          ],
                        )
                      : Row(
                          children: [
                            Icon(
                              Icons.today,
                              color: iconColors[taskType],
                            ),
                            Text(
                                " ${dateFormatter(date: DateTime.parse(date))}"),
                          ],
                        ),
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(0)),
                  onTap: () {
                    if (isSelected) {
                      setState(() {
                        isSelected = false;
                      });
                    } else {
                      setState(() {
                        isSelected = true;
                        selectedIndex = itemIndex;
                        taskId = data[itemIndex].taskId;
                      });
                    }
                  },
                ),
              );
            }),
        const Divider(
          color: Colors.grey,
          height: 1,
          thickness: 1,
        )
      ],
    );
  }

  String currentDateFormatted() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    return formatted;
  }

  String dateFormatter({required DateTime date}) {
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(date);
    return formatted;
  }
}
