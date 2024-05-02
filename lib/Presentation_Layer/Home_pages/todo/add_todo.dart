
import 'package:digi_hub/Data_Layer/Module/Cache_Memory_Module.dart';
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:digi_hub/Data_Layer/Data_Providers/Local_Database_Provider.dart';
import 'package:digi_hub/Data_Layer/Module/ToDo_Data_Module.dart';
import 'package:digi_hub/Data_Layer/Repositories/Todo_Data_Repository.dart';
import 'package:table_calendar/table_calendar.dart' as calender;
import 'package:intl/intl.dart';

import 'package:digi_hub/Utillity/notification_helper.dart' as notif;

import 'package:fluttertoast/fluttertoast.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';


class AddTodoTask extends StatefulWidget {
  const AddTodoTask({Key? key}) : super(key: key);

  @override
  State<AddTodoTask> createState() => _AddTodoTaskState();
}

class _AddTodoTaskState extends State<AddTodoTask> {
  static bool nextDayIsChecked = false;
  static String todoStartDate = "";
  //static String todoEndDate = "";

  static String todoDescription = "";
  static String todoType = "none";
  static String todoTime = "00:00:00";
  static String todoEndTime = "23:59:59";
  String taskState = "";
  String taskCompl = 'false';
  static Color taskColor = Colors.grey;

  LiquidController controller = LiquidController();

  TextEditingController textField = TextEditingController();
  List<Widget> widgets = const [
    CalenderTable(),
    TimerPicker(),
    EndTimerPicker(),
    TaskInGroups(),
  ];
  TodoDataRepository _todoRepository =
      TodoDataRepository(database: LocalDbProvider.database);

  late notif.NotificationClass notification;
  static String taskTypeLabel = "none";
  static int indexOfTask = 0;
  int index = 0;
  late FToast ftoast;

  @override
  void initState() {
    todoTime = getFormattedTimeOfNow();
    notification = notif.NotificationClass();
    notification.initializeNotification();

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

  String getFormattedTimeOfNow() {
    // getting time in 2 digit format like 00:00:00
    int hour = DateTime.now().hour;
    int minute = DateTime.now().minute;
    int second = DateTime.now().second;

    String hourS = hour < 10 ? "0" + hour.toString() : hour.toString();
    String minS = minute < 10 ? "0" + minute.toString() : minute.toString();
    String sec = second < 10 ? "0" + second.toString() : second.toString();
    String result = hourS + ":" + minS + ":" + sec;

    print("formatted time of Now is :  $result");

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          // toolbarHeight: MediaQuery.of(context).size.height * 0.05,
          backgroundColor: Colors.white,
          leadingWidth: 80,
          leading: TextButton(
            child: const Text(
              "Cancel",
              style: TextStyle(fontSize: 18, color: Colors.red),
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
                style: TextStyle(fontSize: 18, color: Colors.green),
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
                if (todoDescription.isNotEmpty) {
                  if (DateTime.parse(date).isBefore(DateTime.parse(endDate)) ||
                      nextDayIsChecked) {
                    todoDescription =
                        todoDescription.characters.first.toUpperCase() +
                            todoDescription.substring(1);
                    if (await addTodoTask(
                        date: date,
                        endDate: endDate,
                        desc: todoDescription,
                        type: todoType,
                        taskCompl: taskCompl,
                        taskState: taskState)) {
                      int id = await _todoRepository.getTaskId(
                          date: date, desc: todoDescription);
                      // schedule notificaion
                      if (await CacheMemory.cacheMemory.getString('notif') ==
                          'true') {
                        print("notification is schedualed");
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
                    /*  } catch (e) {
                      print("not added");
                    } */
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
        body: Builder(builder: (context) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height -
                  Scaffold.of(context).appBarMaxHeight!.toDouble(),
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
                              cursorHeight: 25,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                  hintText: "What do you want to do?",
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
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
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
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
                                      DateFormat.jm().format(DateTime.parse(
                                          "2000-01-01 $todoTime")),
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
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
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
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
                                  icon: Icon(Icons.calendar_month,
                                      size: index == 0 ? 30 : 25,
                                      color: index == 0
                                          ? Colors.orange
                                          : Colors.blue.shade800),
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
                                  icon: Icon(FontAwesomeIcons.clock,
                                      size: index == 1 ? 30 : 23,
                                      color: index == 1
                                          ? Colors.orange
                                          : Colors.blue.shade800),
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
                                  icon: Icon(FontAwesomeIcons.clock,
                                      size: index == 2 ? 30 : 25,
                                      color: index == 2
                                          ? Colors.orange
                                          : Colors.blue.shade800),
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
                                    style: TextStyle(
                                        color: index == 3
                                            ? Colors.orange
                                            : Colors.black,
                                        fontSize: index == 3 ? 20 : 17),
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
          );
        }));
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

  Future<bool> addTodoTask({
    required String date,
    required String endDate,
    required String desc,
    required String type,
    required String taskCompl,
    required String taskState,
  }) async {
    bool result = await _todoRepository.addTodoTask(
        date: date,
        endDate: endDate,
        //'2022-03-21',
        description: desc,
        taskType: type,
        taskCompl: taskCompl,
        taskState: taskState);
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
  TodoDataRepository _todoRepository =
      TodoDataRepository(database: LocalDbProvider.database);
  List<TodoModule> tasks = [];
  String startTime = _AddTodoTaskState.todoTime;
  late FToast ftoast;

  @override
  void initState() {
    print(startTime);
    ftoast = FToast();
    ftoast.init(context);
    _todoRepository
        .getTodoTasksWithOutMissed(
            date: dateFormatterDate(
                DateTime.parse(_AddTodoTaskState.todoStartDate)),
            hasTime: false)
        .then((data) {
      tasks = data;
    });
    super.initState();
  }

  bool isShown = false;
  double height = 80;
  final textStyle = TextStyle(fontSize: 32.0, height: 1.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DraggableBottomSheet(
        setHeight: height,
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
                child: IconButton(
                  icon: Icon(
                    Icons.keyboard_double_arrow_up,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isShown) {
                        isShown = false;
                        height = 80;
                      } else {
                        isShown = true;
                        height = double.maxFinite;
                      }
                    });
                  },
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
                  child: IconButton(
                    icon: Icon(
                      Icons.keyboard_double_arrow_down,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isShown) {
                          isShown = false;
                          height = 80;
                        } else {
                          isShown = true;
                          height = double.maxFinite;
                        }
                      });
                    },
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
                          .format(DateTime.parse(tasks[index].taskDate));
                      String endTime = DateFormat.jm()
                          .format(DateTime.parse(tasks[index].taskEndDate));
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
        minExtent: 80,
        // maxExtent: MediaQuery.of(context).size.height * 0.8,
        backgroundWidget: Container(
          color: Colors.amber.shade50,
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  child: SizedBox(
                    //width: MediaQuery.of(context).size.width,
                    child: const Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        bottom: 8,
                      ),
                      child: Text("Start At",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              //SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              Column(
                children: [
                  showPicker(
                    dialogInsetPadding: EdgeInsets.all(0),
                    wheelHeight: MediaQuery.of(context).size.height / 4,

                    hourLabel: "Hour",
                    isOnChangeValueMode: true,
                    onChange: (time) {},
                    disableAutoFocusToNextInput: true,
                    // unselectedColor: Colors.orange,
                    accentColor: Colors.black,

                    themeData: ThemeData(
                      dialogBackgroundColor: Colors.transparent,
                      cardColor: Colors.transparent,
                    ),
                    minuteLabel: "Minute",
                    displayHeader: false,
                    hideButtons: true,
                    iosStylePicker: true,

                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3.5,
                    sunAsset: Image.asset(
                      'assets/images/sun.png',
                      height: 50,
                    ),
                    moonAsset: Image.asset('assets/images/sun.png'),
                    isInlinePicker: true,
                    elevation: 0,
                    context: context,
                    value: Time(
                        hour: DateTime.parse("2000-01-01 $startTime").hour,
                        minute: DateTime.parse("2000-01-01 $startTime").minute),
                    sunrise: TimeOfDay(hour: 6, minute: 0), // optional
                    sunset: TimeOfDay(hour: 18, minute: 0), // optional
                    duskSpanInMinutes: 120, // optional
                    onChangeDateTime: (time) {
                      startTime = dateFormatter(date: time);
                      setState(() {
                        //print("the time is : ${time.hour}:${time.minute}");
                      });
                    },
                  ),
                  TextButton(
                      onPressed: () {
                        _AddTodoTaskState.todoTime = startTime;
                        _showToast(
                            "Time is set", 1, Colors.green, Icon(Icons.check));
                      },
                      child: const Text("Set",
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange)))
                  /* TimePickerSpinner(
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
                  ), */
                  //  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _showToast(String message, int duration, Color color, Icon icon) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
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
      fadeDuration: const Duration(microseconds: 300),
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
  TodoDataRepository _todoRepository =
      TodoDataRepository(database: LocalDbProvider.database);
  List<TodoModule> tasks = [];
  String endTime = _AddTodoTaskState.todoEndTime;
  bool isChecked = false;
  late FToast ftoast;
  @override
  void initState() {
    ftoast = FToast();
    ftoast.init(context);
    _todoRepository
        .getTodoTasksWithOutMissed(
            date: dateFormatterDate(
                DateTime.parse(_AddTodoTaskState.todoStartDate)),
            hasTime: false)
        .then((data) {
      tasks = data;
    });
    super.initState();
  }

  _showToast(String message, int duration, Color color, Icon icon) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
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
      fadeDuration: const Duration(microseconds: 300),
      gravity: ToastGravity.TOP,
      toastDuration: Duration(seconds: duration),
    );
  }

  double height = 80;
  bool isShowen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DraggableBottomSheet(
        blurBackground: true,
        minExtent: 80,

        setHeight: height,

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
                child: IconButton(
                  icon: Icon(
                    Icons.keyboard_double_arrow_up,
                    size: 30,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isShowen) {
                        isShowen = false;
                        height = 80;
                      } else {
                        isShowen = true;
                        height = double.maxFinite;
                      }
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        expandedChild: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  child: IconButton(
                    icon: Icon(
                      Icons.keyboard_double_arrow_down_rounded,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isShowen) {
                          isShowen = false;
                          height = 80;
                        } else {
                          isShowen = true;
                          height = double.maxFinite;
                        }
                      });
                    },
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
                          .format(DateTime.parse(tasks[index].taskDate));
                      String endTime = DateFormat.jm()
                          .format(DateTime.parse(tasks[index].taskEndDate));
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
        // maxExtent: MediaQuery.of(context).size.height * 0.8,
        backgroundWidget: Container(
          color: Colors.amber.shade50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          child: SizedBox(
                            //width: MediaQuery.of(context).size.width,
                            child: const Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                                bottom: 8,
                              ),
                              child: Text("End At",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        Spacer(),
                        const Text("Day After"),
                        IconButton(
                            onPressed: () {
                              setState(() {
                                isChecked = isChecked == true ? false : true;
                              });
                            },
                            icon: Icon(
                              isChecked
                                  ? Icons.check_circle_rounded
                                  : Icons.check_circle_outline,
                              color: isChecked
                                  ? Colors.orange
                                  : Colors.grey.shade600,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  showPicker(
                    dialogInsetPadding: EdgeInsets.all(0),
                    wheelHeight: MediaQuery.of(context).size.height / 4,

                    hourLabel: "Hour",
                    isOnChangeValueMode: true,
                    onChange: (time) {},
                    disableAutoFocusToNextInput: true,
                    // unselectedColor: Colors.orange,
                    accentColor: Colors.black,

                    themeData: ThemeData(
                      dialogBackgroundColor: Colors.transparent,
                      cardColor: Colors.transparent,
                    ),
                    minuteLabel: "Minute",
                    displayHeader: false,
                    hideButtons: true,
                    iosStylePicker: true,

                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3.5,
                    sunAsset: Image.asset(
                      'assets/images/sun.png',
                      height: 50,
                    ),
                    moonAsset: Image.asset('assets/images/sun.png'),
                    isInlinePicker: true,
                    elevation: 0,
                    context: context,
                    value: Time(
                        hour: DateTime.parse("2000-01-01 $endTime").hour,
                        minute: DateTime.parse("2000-01-01 $endTime").minute),
                    sunrise: TimeOfDay(hour: 6, minute: 0), // optional
                    sunset: TimeOfDay(hour: 18, minute: 0), // optional
                    duskSpanInMinutes: 120, // optional
                    onChangeDateTime: (time) {
                      endTime = dateFormatter(date: time);
                      setState(() {
                        //print("the time is : ${time.hour}:${time.minute}");
                      });
                    },
                  ),
                  /* TimePickerSpinner(
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
                  ), */
                  SizedBox(height: 20),
                  TextButton(
                      onPressed: () {
                        _AddTodoTaskState.todoEndTime = endTime;
                        _AddTodoTaskState.nextDayIsChecked = isChecked;
                        _showToast(
                            "Time is set", 1, Colors.green, Icon(Icons.check));
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
            ],
          ),
        ),
      ),
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
      color: Colors.amber.shade50,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Card(
              elevation: 0,
              color: Colors.white,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: const Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    bottom: 8,
                  ),
                  child: Text("Date",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: calender.TableCalendar(
              calendarStyle: const calender.CalendarStyle(
                  defaultTextStyle: TextStyle(fontWeight: FontWeight.bold),
                  weekendTextStyle: TextStyle(fontWeight: FontWeight.bold)),
              enabledDayPredicate: (day) {
                DateTime now = DateTime.now();

                if (now.isBefore(day) ||
                    now.month == day.month && now.day == day.day) {
                  return true;
                }
                return false;
              },
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
        ],
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
    _todoRepository
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
      color: Colors.amber.shade50,
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Card(
                elevation: 0,
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      bottom: 8,
                    ),
                    child: Text("Category",
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
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
                separatorBuilder: (context, index) => Divider(
                  thickness: 5,
                  height: 5,
                  color: Colors.amber.shade50,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  findTasksPerType(List<TodoModule> data) {
    int work = 0;
    int familly = 0;
    int shopping = 0;
    int none = 0;
    int personal = 0;
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
