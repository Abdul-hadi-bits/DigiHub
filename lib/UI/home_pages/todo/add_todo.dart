import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:my_project/UI/home_pages/home_page.dart';
import 'package:my_project/UI/home_pages/todo/main_todo_page.dart';
import 'package:my_project/databaste/database_helper.dart';
import 'package:my_project/databaste/todo_database_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart' as calender;
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';

import 'package:my_project/Utillity/notification_helper.dart' as notif;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_project/main.dart' as main;

import 'package:draggable_bottom_sheet_nullsafety/draggable_bottom_sheet_nullsafety.dart'
    as bottom_sheet;

class AddTodoTask extends StatefulWidget {
  const AddTodoTask({Key? key}) : super(key: key);

  @override
  State<AddTodoTask> createState() => _AddTodoTaskState();
}

class _AddTodoTaskState extends State<AddTodoTask> {
  static bool nextDayIsChecked = false;
  static String todoStartDate = "";
  //static String todoEndDate = "";
  late SharedPreferences pref;

  static String todoDescription = "";
  static String todoType = "none";
  static String todoTime = "00:00:00";
  static String todoEndTime = "23:59:59";
  static Color taskColor = Colors.grey;

  LiquidController controller = LiquidController();

  TextEditingController textField = TextEditingController();
  List<Widget> widgets = const [
    CalenderTable(),
    TimerPicker(),
    EndTimerPicker(),
    TaskInGroups(),
  ];
  ToDoDatabase todoDatabase = ToDoDatabase();
  late notif.NotificationClass notification;
  static String taskTypeLabel = "none";
  static int indexOfTask = 0;
  int index = 3;
  late FToast ftoast;

  @override
  void initState() {
    todoTime= DateTime.now().hour.toString()+":"+DateTime.now().minute.toString()+":"+DateTime.now().second.toString();
    notification = notif.NotificationClass();
    notification.initializeNotification();
    SharedPreferences.getInstance().then((instance) {
      pref = instance;
    });
    todoStartDate = dateFormatter(date: DateTime.now());
    ftoast = FToast();
    ftoast.init(context);

    super.initState();
  }

  @override
  void dispose() {
    // fixing the existance of old data when revisiting  add todo task page
    nextDayIsChecked = false;
    taskColor = Colors.grey;
    todoStartDate = "";
    todoDescription = "";
    todoType = "none";
    todoTime = "00:00:00";
    todoEndTime = "23:59:59";
    indexOfTask = 0;
    taskTypeLabel = "none";
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.08,
          backgroundColor: Colors.white,
          leadingWidth: 80,
          leading: TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 18),
            ),
            onPressed: () {
              //print('canceled');
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              child: const Text(
                "Done",
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () async {
                String todoEndDate = todoStartDate;
                if (nextDayIsChecked) {
                  DateTime nextDay =
                      DateTime.parse(todoStartDate).add(Duration(days: 1));
                  todoEndDate = dateFormatter(date: nextDay);
                }
                String date = "$todoStartDate $todoTime";
                String endDate = "$todoEndDate $todoEndTime";

                print("the complete start date is : $date");
                print("the complete end date is : $endDate");
                if (todoDescription.isNotEmpty) {
                  if (DateTime.parse(date).isBefore(DateTime.parse(endDate)) ||
                      nextDayIsChecked) {
                    try {
                      todoDescription =
                          todoDescription.characters.first.toUpperCase() +
                              todoDescription.substring(1);
                      if (await addTodoTask(
                          date: date,
                          endDate: endDate,
                          desc: todoDescription,
                          type: todoType)) {
                        int id = await todoDatabase.getTaskId(
                            date: date, desc: todoDescription);
                        // schedule notificaion
                        if (pref.getString('notif') == 'true') {
                          await notification.scheduleNotification(
                              id: id,
                              title: todoType,
                              body: todoDescription,
                              scheduledTime: DateTime.parse(date));
                          await notification.schedualEndNotification(
                              id: id * 5,
                              body: todoDescription,
                              scheduledTime: DateTime.parse(endDate));
                        }
                        Navigator.pop(context);
                      } else {
                        print("addin task was not succesfull");
                      }
                    } catch (e) {
                      print("not added");
                      print(e);
                    }
                  } else {
                    _showToast("Invalid Time Period", 2);
                  }
                } else {
                  _showToast("Please add a Description", 1);
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height * 0.885,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 8,
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextField(
                            controller: textField,
                            cursorHeight: 20,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                                hintText: "What do you want to do?",
                                hintStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                suffixIcon: Icon(
                                  Icons.circle,
                                  size: 15,
                                  color: taskColor,
                                ),
                                //enabledBorder: InputBorder.none,
                                border: InputBorder.none,
                                prefixIcon: const Icon(
                                  Icons.circle_outlined,
                                  size: 30,
                                  color: Colors.grey,
                                )),
                            onSubmitted: (text) {
                              setState(() {
                                todoDescription = text.isNotEmpty ? text : "";
                              });
                            },
                          ),
                          Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Text(
                                  "Date: ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                todoStartDate,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue,
                                ),
                              ),
                            ],
                          ),
                          FittedBox(
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    "Start Time: ",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Text(
                                    DateFormat.jm().format(
                                        DateTime.parse("2000-01-01 $todoTime")),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlue,
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    "End Time: ",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  DateFormat.jm().format(DateTime.parse(
                                      "2000-01-01 $todoEndTime")),
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.calendar_month),
                                onPressed: () {
                                  setState(() {
                                    /* controller.shouldDisableGestures(
                                        disable: true);
                                    controller.animateToPage(
                                        page: 0, duration: 500); */
                                    index = 0;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(FontAwesomeIcons.clock),
                                onPressed: () {
                                  setState(() {
                                    /* controller.shouldDisableGestures(
                                        disable: true);
                                    controller.animateToPage(
                                        page: 1, duration: 500); */
                                    index = 1;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(FontAwesomeIcons.clock),
                                onPressed: () {
                                  setState(() {
                                    /* controller.shouldDisableGestures(
                                        disable: true);
                                    controller.animateToPage(
                                        page: 1, duration: 500); */
                                    index = 2;
                                  });
                                },
                              ),
                              Spacer(),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    index = 3;
                                  });
                                },
                                child: Text(
                                  taskTypeLabel,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 17),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Icon(
                                  Icons.circle,
                                  size: 15,
                                  color: taskColor,
                                ),
                              )
                            ],
                          ),
                        ),

                        Expanded(
                          flex: 10,
                          child: Container(
                            color: Colors.white,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: widgets[index],
                              /*  transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                    scale: animation, child: child);
                              }, */
                            ), /* Builder(
                              builder: (context) => LiquidSwipe(
                                disableUserGesture: true,
                                enableLoop: true,
                                enableSideReveal: true,
                                pages: widgets,
                                initialPage: 0,
                                liquidController: controller,
                              ),
                            ), */
                          ),
                        ), //Center(child: widgets[index]))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  _showToast(String message, int duration) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color.fromARGB(255, 255, 160, 0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FontAwesomeIcons.timesCircle),
          const SizedBox(
            width: 12.0,
          ),
          Text(
            message,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    ftoast.showToast(
      child: toast,
      fadeDuration: const Duration(seconds: 2),
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: duration),
    );
  }

  String currentDateFormatted() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    return formatted;
  }

  Future<bool> addTodoTask(
      {required String date,
      required String endDate,
      required String desc,
      required String type}) async {
    bool result = await todoDatabase.addTodoTask(
      date: date,
      endDate: endDate,
      //'2022-03-21',
      description: desc,
      taskType: type,
      //isDateTime: false,
    );
    return result;
  }

  String dateFormatter({required DateTime date}) {
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    String formatted = formatter.format(date);
    return formatted;
  }
}

class TimerPicker extends StatefulWidget {
  const TimerPicker({Key? key}) : super(key: key);

  @override
  State<TimerPicker> createState() => _TimerPickerState();
}

class _TimerPickerState extends State<TimerPicker> {
  ToDoDatabase todoDatabase = ToDoDatabase();
  List<Map<String, dynamic>> tasks = [];
  String startTime = _AddTodoTaskState.todoTime;
  late FToast ftoast;

  @override
  void initState() {
   
    print(startTime);
    ftoast = FToast();
    ftoast.init(context);
    todoDatabase
        .getTodoTasksWithOutMissed(
            date: dateFormatterDate(
                DateTime.parse(_AddTodoTaskState.todoStartDate)),
            hasTime: false)
        .then((data) {
      tasks = data;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: bottom_sheet.DraggableBottomSheet(
        blurBackground: true,

        previewChild: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey, width: 3),
            color: Colors.grey.shade400,
            /*  borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ), */
          ),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
        expandedChild: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            /*  borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ), */
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  width: 80,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                    child: Text("Booked Hours",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black))),
              ),
              Expanded(
                flex: 10,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    children: List.generate(tasks.length, (index) {
                      String startTime = DateFormat.jm()
                          .format(DateTime.parse(tasks[index]['task_date']));
                      String endTime = DateFormat.jm().format(
                          DateTime.parse(tasks[index]['task_end_date']));
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50,
                          width: 150,
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 7,
                            child: Center(
                                child: FittedBox(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, right: 8),
                                child: Text(
                                  "$startTime - $endTime",
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              )
            ],
          ),
        ),
        minExtent: 60,
        // maxExtent: MediaQuery.of(context).size.height * 0.8,
        backgroundWidget: Container(
          color: Colors.white,
          child: Stack(
            children: [
              /* Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.25),
                child: const Center(
                  child: Divider(thickness: 3, color: Colors.black45),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.11),
                child: const Center(
                  child: Divider(
                    thickness: 3,
                    color: Colors.black45,
                  ),
                ),
              ), */
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: TimePickerSpinner(
                      is24HourMode: false,
                      time: DateTime.parse("2000-01-01 $startTime"),
                      normalTextStyle:
                          const TextStyle(fontSize: 25, color: Colors.grey),
                      highlightedTextStyle: const TextStyle(
                          fontSize: 30,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      spacing: 20,
                      itemHeight: 60,
                      isForce2Digits: true,
                      onTimeChange: (time) {
                        //print(dateFormatter(date: time));
                        startTime = dateFormatter(date: time);
                        setState(() {
                          //print("the time is : ${time.hour}:${time.minute}");
                        });
                      },
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        _AddTodoTaskState.todoTime = startTime;
                        _showToast("Time is set", 1);
                      },
                      child: const Text("Set",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)))
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.06,
                color: Colors.white,
                child: Column(
                  children: const [
                    Text("Start Time", style: TextStyle(fontSize: 20)),
                    Divider(
                        thickness: 3,
                        endIndent: 70,
                        indent: 70,
                        color: Colors.black45),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showToast(String message, int duration) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color.fromARGB(255, 255, 160, 0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FontAwesomeIcons.timesCircle),
          const SizedBox(
            width: 12.0,
          ),
          Text(
            message,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    ftoast.showToast(
      child: toast,
      fadeDuration: const Duration(seconds: 2),
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: duration),
    );
  }

  String dateFormatterDate(DateTime? date) {
    if (date != null) {
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String formatted = formatter.format(date);
      return formatted;
    }
    return currentDateFormatted();
  }

  String currentDateFormatted() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    print("heeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeer $formatted");
    return formatted;
  }

  String dateFormatter({required DateTime date}) {
    DateFormat formatter = DateFormat('HH:mm:00');

    String formatted = formatter.format(date);
    return formatted;
  }
}

class EndTimerPicker extends StatefulWidget {
  const EndTimerPicker({Key? key}) : super(key: key);

  @override
  State<EndTimerPicker> createState() => _EndTimerPickerState();
}

class _EndTimerPickerState extends State<EndTimerPicker> {
  ToDoDatabase todoDatabase = ToDoDatabase();
  List<Map<String, dynamic>> tasks = [];
  String endTime = _AddTodoTaskState.todoEndTime;
  bool isChecked = false;
  late FToast ftoast;
  @override
  void initState() {
    ftoast = FToast();
    ftoast.init(context);
    todoDatabase
        .getTodoTasksWithOutMissed(
            date: dateFormatterDate(
                DateTime.parse(_AddTodoTaskState.todoStartDate)),
            hasTime: false)
        .then((data) {
      tasks = data;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: bottom_sheet.DraggableBottomSheet(
        blurBackground: true,

        previewChild: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            /* borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ), */
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
        ),
        expandedChild: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            /*   borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ), */
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  width: 80,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                    child: Text("Booked Hours",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black))),
              ),
              Expanded(
                flex: 10,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Wrap(
                    children: List.generate(tasks.length, (index) {
                      String startTime = DateFormat.jm()
                          .format(DateTime.parse(tasks[index]['task_date']));
                      String endTime = DateFormat.jm().format(
                          DateTime.parse(tasks[index]['task_end_date']));
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 50,
                          width: 150,
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 7,
                            child: Center(
                                child: FittedBox(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8.0, right: 8),
                                child: Text(
                                  "$startTime - $endTime",
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              )
            ],
          ),
        ),
        minExtent: 60,
        // maxExtent: MediaQuery.of(context).size.height * 0.8,
        backgroundWidget: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    //height: MediaQuery.of(context).size.height * 0.06,
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.3),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("End Time       ",
                                  style: TextStyle(fontSize: 20)),
                              const Text("Tomorrow"),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      isChecked =
                                          isChecked == true ? false : true;
                                    });
                                  },
                                  icon: Icon(
                                    isChecked
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: isChecked
                                        ? Colors.orange
                                        : Colors.grey.shade300,
                                  )),
                            ],
                          ),
                        ),
                        const Divider(
                            thickness: 3,
                            endIndent: 70,
                            indent: 70,
                            color: Colors.black45),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.01),
                    child: Column(
                      children: [
                        TimePickerSpinner(
                          is24HourMode: false,
                          time: DateTime.parse("2000-01-01 $endTime"),
                          normalTextStyle:
                              const TextStyle(fontSize: 25, color: Colors.grey),
                          highlightedTextStyle: const TextStyle(
                              fontSize: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          spacing: 20,
                          itemHeight: 60,
                          isForce2Digits: true,
                          onTimeChange: (time) {
                            //print(dateFormatter(date: time));
                            endTime = dateFormatter(date: time);
                            setState(() {
                              //print("the time is : ${time.hour}:${time.minute}");
                            });
                          },
                        ),
                        TextButton(
                            onPressed: () {
                              _AddTodoTaskState.todoEndTime = endTime;
                              _AddTodoTaskState.nextDayIsChecked = isChecked;
                              _showToast("Time is set", 1);
                              setState(() {});
                              print("set");
                            },
                            child: const Text("Set",
                                style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showToast(String message, int duration) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: const Color.fromARGB(255, 255, 160, 0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(FontAwesomeIcons.timesCircle),
          const SizedBox(
            width: 12.0,
          ),
          Text(
            message,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    ftoast.showToast(
      child: toast,
      fadeDuration: const Duration(seconds: 2),
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: duration),
    );
  }

  String dateFormatterDate(DateTime? date) {
    if (date != null) {
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String formatted = formatter.format(date);
      return formatted;
    }
    return currentDateFormatted();
  }

  String currentDateFormatted() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    return formatted;
  }

  String dateFormatter({required DateTime date}) {
    DateFormat formatter = DateFormat('HH:mm:00');

    String formatted = formatter.format(date);
    return formatted;
  }
}

class CalenderTable extends StatefulWidget {
  const CalenderTable({Key? key}) : super(key: key);

  @override
  State<CalenderTable> createState() => _CalenderTableState();
}

class _CalenderTableState extends State<CalenderTable> {
  calender.CalendarFormat _calendarFormat = calender.CalendarFormat.month;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.parse(_AddTodoTaskState.todoStartDate);

  Widget? marker(BuildContext context, DateTime date, bool istrue) {
    return istrue ? const Icon(Icons.circle_rounded) : null;
  }

  String currentDate = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: calender.TableCalendar(
          calendarStyle: const calender.CalendarStyle(
              defaultTextStyle: TextStyle(fontWeight: FontWeight.bold),
              weekendTextStyle: TextStyle(fontWeight: FontWeight.bold)),
          /* enabledDayPredicate: (day) {
            DateTime now = DateTime.now();

            if (now.isBefore(day) ||
                now.month == day.month && now.day == day.day) {
              return true;
            }
            return false;
          }, */
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          //calendarBuilders: calender.CalendarBuilders(),
          selectedDayPredicate: (day) {
            // Use `selectedDayPredicate` to determine which day is currently selected.
            // If this returns true, then `day` will be marked as selected.

            // Using `isSameDay` is recommended to disregard
            // the time-part of compared DateTime objects.

            return calender.isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            // print("onDaySelected");
            if (!calender.isSameDay(_selectedDay, selectedDay)) {
              // Call `setState()` when updating the selected day
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                // print(dateFormatter(date: selectedDay));
                _AddTodoTaskState.todoStartDate =
                    dateFormatter(date: selectedDay);
              });
            }
          },
          onFormatChanged: (format) {
            //print("on formate change");
            if (_calendarFormat != format) {
              // Call `setState()` when updating calendar format
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onPageChanged: (focusedDay) {
            //print("on page change");
            // No need to call `setState()` here
            _focusedDay = focusedDay;
          },
        ),
      ),
    );
  }

  String dateFormatter({required DateTime date}) {
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    String formatted = formatter.format(date);
    return formatted;
  }
}

class TaskInGroups extends StatefulWidget {
  const TaskInGroups({Key? key}) : super(key: key);

  @override
  State<TaskInGroups> createState() => _TaskInGroupsState();
}

class _TaskInGroupsState extends State<TaskInGroups> {
  ToDoDatabase todoDatabase = ToDoDatabase();
  List<String> taskTypes = ["none", "personal", "work", "shopping", "familly"];
  Map<String, dynamic> tasksPerType = {
    'none': 0,
    'personal': 0,
    'work': 0,
    'shopping': 0,
    'familly': 0
  };

  Map<String, dynamic> textColors = {
    'none': Colors.black,
    'personal': Colors.white,
    'work': Colors.white,
    'shopping': Colors.white,
    'familly': Colors.black
  };
  Map<String, dynamic> taskColors = {
    'none': Colors.grey.shade300,
    'personal': Colors.orange.shade300,
    'work': Colors.green.shade300,
    'shopping': Colors.pink.shade200,
    'familly': Colors.yellow.shade300
  };
  Map<String, dynamic> indexOfTask = {
    'none': 0,
    'personal': 1,
    'work': 2,
    'shopping': 3,
    'familly': 4
  };
  int selectedIndex = _AddTodoTaskState.indexOfTask;
  @override
  void initState() {
    todoDatabase
        .getTodoTasksInYearNotMissed(
            date: currentDateFormatted(), hasTime: false)
        .then((data) {
      findTasksPerType(data);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Card(
                elevation: 8,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      bottom: 8,
                    ),
                    child: Text("List",
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
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  controller: ScrollController(keepScrollOffset: true),
                  scrollDirection: Axis.vertical,
                  itemCount: taskTypes.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 70,
                      decoration: BoxDecoration(
                        color: taskColors[taskTypes[index]],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: ListTile(
                          contentPadding: EdgeInsets.only(left: 20, right: 20),
                          style: ListTileStyle.drawer,
                          title: Text(
                            taskTypes[index],
                            style: TextStyle(
                                color: textColors[taskTypes[index]],
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                          trailing: selectedIndex == index
                              ? const Icon(
                                  Icons.check_circle_sharp,
                                  color: Colors.blueAccent,
                                  size: 30,
                                )
                              : null,
                          subtitle:
                              Text('${tasksPerType[taskTypes[index]]} Tasks'),
                          shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  color: Colors.black, width: 0.5),
                              borderRadius: BorderRadius.circular(20)),
                          onTap: () {
                            print('selected');
                            _AddTodoTaskState.taskColor =
                                taskColors[taskTypes[index]];
                            selectedIndex = index;
                            _AddTodoTaskState.todoType = taskTypes[index];
                            _AddTodoTaskState.taskTypeLabel = taskTypes[index];
                            _AddTodoTaskState.indexOfTask = index;

                            setState(() {});
                          },
                        ),
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
          ],
        ),
      ),
    );
  }

  findTasksPerType(List<Map<String, dynamic>> data) {
    int work = 0;
    int familly = 0;
    int shopping = 0;
    int none = 0;
    int personal = 0;
    for (int i = 0; i < data.length; i++) {
      data[i]['task_type'] == 'work' ? {work++} : false;
      data[i]['task_type'] == 'familly' ? {familly++} : false;
      data[i]['task_type'] == 'shopping' ? {shopping++} : false;
      data[i]['task_type'] == 'none' ? {none++} : false;
      data[i]['task_type'] == 'personal' ? {personal++} : false;
    }
    tasksPerType['work'] = work;
    tasksPerType['shopping'] = shopping;
    tasksPerType['none'] = none;
    tasksPerType['familly'] = familly;
    tasksPerType['personal'] = personal;
    setState(() {});
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
