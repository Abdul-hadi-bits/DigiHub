import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:digi_hub/Data_Layer/Data_Providers/Local_Database_Provider.dart';
import 'package:digi_hub/Data_Layer/Module/ToDo_Data_Module.dart';
import 'package:digi_hub/Data_Layer/Repositories/Todo_Data_Repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:intl/intl.dart';
import 'package:digi_hub/Utillity/notification_helper.dart' as notif;

class MissedTaskPage extends StatefulWidget {
  const MissedTaskPage({Key? key}) : super(key: key);

  @override
  State<MissedTaskPage> createState() => _MissedTaskPageState();
}

class _MissedTaskPageState extends State<MissedTaskPage> {
  TodoDataRepository _todoRepository =
      TodoDataRepository(database: LocalDbProvider.database);

  Map<String, dynamic> taskColors = {
    'none': Colors.grey.shade500,
    'personal': Colors.orange.shade500,
    'work': Colors.green.shade500,
    'shopping': Colors.pink.shade500,
    'familly': Colors.yellow.shade600
  };

  late FToast ftoast;
  @override
  void initState() {
    ftoast = FToast();
    ftoast.init(context);
    super.initState();

    _todoRepository
        .getTodoTasksInYear(date: DateTime.now().toString(), hasTime: false)
        .then((taskData) async {
      await _checkForExpiredTasks(listOfTodoObjects: taskData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        context: context,
        onPressed: () {
          Navigator.pop(context);
        },
        titleSpacing: 50,
        fitTitle: true,
        ttle: "Missed Schedules",
        italikTitle: true,
        statusBarDark: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: FutureBuilder<List<TodoModule>>(
            future: _todoRepository.getTodoTaskByState(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<TodoModule>? data = snapshot.data;
                print('has data');

                try {
                  data!.first.taskDescription;
                  return Center(child: todoTasks(data: snapshot.data!));
                } catch (e) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.085,
                    child: ListTile(
                      title: const Text(
                        "No Schedule's Missed So Far",
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      leading: const Icon(Icons.circle_outlined, size: 25),
                      trailing: const Icon(
                        Icons.circle,
                        size: 15,
                      ),
                      style: ListTileStyle.drawer,

                      /* //subtitle: (time.substring(10) != "00:00:00")
                      ? Text((time.substring(10, 16)))
                      : const Text("00:00"), */
                      shape: RoundedRectangleBorder(
                          side:
                              const BorderSide(color: Colors.white, width: 0.5),
                          borderRadius: BorderRadius.circular(0)),
                    ),
                  );
                }
              }
              return const Center(child: LinearProgressIndicator());
            }),
      ),
    );
  }

  _checkForExpiredTasks({required List<TodoModule> listOfTodoObjects}) async {
    DateTime pastDays = DateTime.now().subtract(const Duration(days: 2));

    DateTime taskDate;

    for (TodoModule todoObject in listOfTodoObjects) {
      taskDate = DateTime.parse(todoObject.taskEndDate);

      if (todoObject.taskCompletion != 'true' && taskDate.isBefore(pastDays)) {
        await _todoRepository
            .deleteTodoTask(taskId: todoObject.taskId)
            .then((value) {
          setState(() {});
        });
        print('task deleted date: $taskDate');
      }
    }
  }

  Widget todoTasks({required List<TodoModule> data}) {
    String taskDescription = "";
    String time = "";
    String endTime = "";
    String typeOfTask = "";
    String newEndTime = "";
    int taskId;

    return Column(
      children: [
        ListView.builder(
            physics: const BouncingScrollPhysics(),
            /* separatorBuilder: ((context, index) => Divider(
                  color: Colors.grey.shade400,
                  //endIndent: MediaQuery.of(context).size.width / 15,
                  indent: MediaQuery.of(context).size.width / 18,
                  height: 1,
                  thickness: 1,
                )), */
            shrinkWrap: true,
            addAutomaticKeepAlives: true,
            controller: ScrollController(keepScrollOffset: true),
            scrollDirection: Axis.vertical,
            itemCount: data.length,
            itemBuilder: (BuildContext context, int itemIndex) {
              taskDescription = data[itemIndex].taskDescription;
              time = data[itemIndex].taskDate;
              endTime = data[itemIndex].taskEndDate;
              typeOfTask = data[itemIndex].taskType;

              taskId = data[itemIndex].taskId;

              String subDate = time.substring(0, 10);

              String newtime = DateFormat.jm().format(DateTime.parse(time));
              newEndTime = DateFormat.jm().format(DateTime.parse(endTime));
              //print("subtime $subtime ");

              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.17,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      tileColor: Colors.white,
                      trailing: Card(
                        color: Colors.grey.shade50,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.grey.shade50),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(typeOfTask,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: taskColors[typeOfTask],
                                  fontWeight: FontWeight.bold
                                  //Colors.blue.shade400, //taskColors[typeOfTask],
                                  )),
                        ),
                      ),
                      style: ListTileStyle.drawer,
                      title: Text(taskDescription,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width *
                                        0.015),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          newtime,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const Text(" - "),
                                        Text(
                                          newEndTime,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Row(
                                        children: [
                                          Text(
                                            subDate,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // const SizedBox(width: 20),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      splashFactory: NoSplash.splashFactory,
                                    ),
                                    child: Card(
                                      color: Colors.orange.shade50,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.orange.shade50),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text("Reschedual",
                                            style: TextStyle(
                                                color: Colors.orange.shade700,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    onPressed: () {
                                      print(data[itemIndex].taskId);
                                      showBottomSheet(
                                          todoDesctiption:
                                              data[itemIndex].taskDescription,
                                          todoType: data[itemIndex].taskType,
                                          taskId: data[itemIndex].taskId);
                                    },
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      splashFactory: NoSplash.splashFactory,
                                    ),
                                    child: Card(
                                      color: Colors.orange.shade50,
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.orange.shade50),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text("Dismiss",
                                            style: TextStyle(
                                                color: Colors.orange.shade700,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    onPressed: () {
                                      _showToast();
                                    },
                                    onLongPress: () async {
                                      int taskId = data[itemIndex].taskId;
                                      await _todoRepository
                                          .deleteTodoTask(taskId: taskId)
                                          .then((value) {
                                        setState(() {});
                                      });
                                    },
                                  )
                                ],
                              ),
                            ]),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ],
    );
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

  showBottomSheet(
      {required String todoType,
      required String todoDesctiption,
      required int taskId}) {
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
            alignment: Alignment.topRight,
            children: [
              MyBottomSheet(todoDesctiption, todoType, taskId),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                icon: Icon(Icons.close, color: Colors.grey.shade400),
              ),
            ],
          );
        }).then((value) {
      setState(() {});
    });
  }
}

class MyBottomSheet extends StatefulWidget {
  String todoDescription = "";
  String todoType = "";
  int taskId;
  MyBottomSheet(this.todoDescription, this.todoType, this.taskId, {Key? key})
      : super(key: key);

  @override
  State<MyBottomSheet> createState() =>
      _MyBottomSheetState(todoDescription, todoType, taskId);
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  late SharedPreferences pref;
  TodoDataRepository _todoRepository =
      TodoDataRepository(database: LocalDbProvider.database);
  String todoDate = "";
  static String todoStartTime = "00:00:00";
  static String todoEndTime = "23:59:59";
  String todoDescription = "";
  String todoType = "";
  int taskId;
  late notif.NotificationClass notification;
  List<Widget> widgets = [];
  int index = 0;
  int previous = 0;
  _MyBottomSheetState(this.todoDescription, this.todoType, this.taskId);

  @override
  void initState() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('kk:mm:ss').format(now);
    todoStartTime = formattedDate;
    todoEndTime = formattedDate;
    print("$todoEndTime , $todoStartTime");
    notification = notif.NotificationClass();
    notification.initializeNotification();
    SharedPreferences.getInstance().then((instance) {
      pref = instance;
    });
    todoDate = currentDateFormatted();
    widgets = [StartTimeSpinner(), EndTimeSpinner()];
    super.initState();

    // DatabaseHelper.instance.delDatabase(dbName: "Plans.db");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 1,
          minChildSize: 0.5,
          builder: (context, controller) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    //   height: MediaQuery.of(context).size.height * 0.7,
                    // width: MediaQuery.of(context).size.width,
                    child: Column(
                      //mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Text(
                              "Select a Date",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange),
                            ),
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: const Divider(
                                  thickness: 3,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              child: DatePicker(
                                DateTime.now(),
                                initialSelectedDate: DateTime.now(),
                                selectionColor: Colors.black,
                                selectedTextColor: Colors.white,
                                onDateChange: (date) {
                                  // New date selected
                                  setState(() {
                                    todoDate = dateFormatter(date: date);

                                    //_selectedValue = date;
                                  });
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        previous = index;
                                        index = 0;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.navigate_before_outlined,
                                      color: index == 0
                                          ? Colors.grey
                                          : Colors.black,
                                      size: 40,
                                    )),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  child: widgets[index],
                                  switchInCurve: Curves
                                      .easeInToLinear, /* 
                                  switchOutCurve: const Threshold(0),
                                  transitionBuilder: (child, animation) {
                                    print("run");
                                    bool isForward =
                                        (previous > index) ? false : true;
                                    print(isForward);

                                    return SlideTransition(
                                      child: child,
                                      position: Tween(
                                        begin: Offset(isForward ? 1 : -1, 0),
                                        end: Offset.zero,
                                      ).animate(animation),
                                    );
                                  }, */
                                ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        previous = index;
                                        index = 1;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.navigate_next_outlined,
                                      size: 40,
                                      color: index == 1
                                          ? Colors.grey
                                          : Colors.black,
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                // Respond to button press
                                String endDate = "$todoDate $todoEndTime";
                                String startDate = "$todoDate $todoStartTime";
                                print(
                                    "the complete Start date is : $startDate");
                                print("the complete end date is : $endDate");
                                print("$todoDescription $todoType");

                                try {
                                  if (await updateTask(
                                      endDate: endDate,
                                      date: startDate,
                                      desc: todoDescription,
                                      type: todoType,
                                      id: taskId)) {
                                    // schedule notificaion

                                    if (pref.getString('notif') == 'true') {
                                      await notification.scheduleNotification(
                                          id: taskId,
                                          title: todoType,
                                          body: todoDescription,
                                          scheduledTime:
                                              DateTime.parse(startDate));
                                      await notification
                                          .schedualEndNotification(
                                              id: taskId * 5,
                                              body: todoDescription,
                                              scheduledTime:
                                                  DateTime.parse(endDate));
                                    }
                                    // update task state
                                    await _todoRepository.updateTaskState(
                                        taskId: taskId, taskState: '');

                                    Navigator.pop(context);
                                  } else {
                                    print("not succesfull");
                                  }
                                } catch (e) {
                                  print("not added");
                                  print(e);
                                }
                              },
                              icon: const Icon(Icons.alarm, size: 18),
                              label: const Text("Reschedual"),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.resolveWith(
                                  (states) => RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                textStyle: MaterialStateTextStyle.resolveWith(
                                    (textStyle) => const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                backgroundColor: MaterialStateColor.resolveWith(
                                    (color) =>
                                        Color.fromARGB(255, 255, 160, 0)),
                                foregroundColor: MaterialStateColor.resolveWith(
                                    (color) => Colors.black),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String currentDateFormatted() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    String formatted = formatter.format(now);
    return formatted;
  }

  String timeFormatter({required DateTime date}) {
    DateFormat formatter = DateFormat('HH:mm:00');

    String formatted = formatter.format(date);
    return formatted;
  }

  String dateFormatter({required DateTime date}) {
    DateFormat formatter = DateFormat('yyyy-MM-dd');

    String formatted = formatter.format(date);
    return formatted;
  }

  Future<bool> updateTask(
      {required String date,
      required String endDate,
      required String desc,
      required String type,
      required int id}) async {
    return _todoRepository.updateTodoTask(
      endDate: endDate,
      taskDate: date, //'2022-03-21',
      taskDesc: desc,
      taskType: type,
      taskId: id,
      //isDateTime: false,
    );
  }
}

class StartTimeSpinner extends StatefulWidget {
  const StartTimeSpinner({Key? key}) : super(key: key);

  @override
  State<StartTimeSpinner> createState() => _StartTimeSpinnerState();
}

class _StartTimeSpinnerState extends State<StartTimeSpinner> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          "Select a Start Time",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: const Divider(
              thickness: 3,
              color: Colors.black45,
            ),
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          color: Colors.white,
          child: showPicker(
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

            // width: MediaQuery.of(context).size.width * 0.2,
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
                hour: DateTime.parse(
                        "2000-01-01 ${_MyBottomSheetState.todoStartTime}")
                    .hour,
                minute: DateTime.parse(
                        "2000-01-01 ${_MyBottomSheetState.todoStartTime}")
                    .minute),
            sunrise: TimeOfDay(hour: 6, minute: 0), // optional
            sunset: TimeOfDay(hour: 18, minute: 0), // optional
            duskSpanInMinutes: 120, // optional
            onChangeDateTime: (time) {
              //print(dateFormatter(date: time));
              _MyBottomSheetState.todoStartTime = timeFormatter(date: time);
              setState(() {
                //print("the time is : ${time.hour}:${time.minute}");
              });
            },
          ), /* TimePickerSpinner(
            is24HourMode: false,
            time: DateTime.parse(
                "2000-01-01 ${_MyBottomSheetState.todoStartTime}"),
            normalTextStyle: const TextStyle(fontSize: 25, color: Colors.grey),
            highlightedTextStyle: const TextStyle(
                fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
            spacing: 20,
            itemHeight: 60,
            isForce2Digits: true,
            onTimeChange: (time) {
              //print(dateFormatter(date: time));
              _MyBottomSheetState.todoStartTime = timeFormatter(date: time);
              setState(() {
                //print("the time is : ${time.hour}:${time.minute}");
              });
            },
          ), */
        ),
      ],
    );
  }

  String timeFormatter({required DateTime date}) {
    DateFormat formatter = DateFormat('HH:mm:00');

    String formatted = formatter.format(date);
    return formatted;
  }
}

class EndTimeSpinner extends StatefulWidget {
  const EndTimeSpinner({Key? key}) : super(key: key);

  @override
  State<EndTimeSpinner> createState() => EndTimeSpinnerState();
}

class EndTimeSpinnerState extends State<EndTimeSpinner> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select An End Time",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: const Divider(
                thickness: 3,
                color: Colors.black45,
              ),
            ),
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          color: Colors.white,
          child: showPicker(
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

            // width: MediaQuery.of(context).size.width * 0.2,
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
                hour: DateTime.parse(
                        "2000-01-01 ${_MyBottomSheetState.todoEndTime}")
                    .hour,
                minute: DateTime.parse(
                        "2000-01-01 ${_MyBottomSheetState.todoEndTime}")
                    .minute),
            sunrise: TimeOfDay(hour: 6, minute: 0), // optional
            sunset: TimeOfDay(hour: 18, minute: 0), // optional
            duskSpanInMinutes: 120, // optional
            onChangeDateTime: (time) {
              //print(dateFormatter(date: time));
              _MyBottomSheetState.todoEndTime = timeFormatter(date: time);
              setState(() {
                //print("the time is : ${time.hour}:${time.minute}");
              });
            },
          ), /* TimePickerSpinner(
            is24HourMode: false,
            time:
                DateTime.parse("2000-01-01 ${_MyBottomSheetState.todoEndTime}"),
            normalTextStyle: const TextStyle(fontSize: 25, color: Colors.grey),
            highlightedTextStyle: const TextStyle(
                fontSize: 30, color: Colors.black, fontWeight: FontWeight.bold),
            spacing: 20,
            itemHeight: 60,
            isForce2Digits: true,
            onTimeChange: (time) {
              //print(dateFormatter(date: time));
              _MyBottomSheetState.todoEndTime = timeFormatter(date: time);
              setState(() {
                //print("the time is : ${time.hour}:${time.minute}");
              });
            },
          ), */
        ),
      ],
    );
  }

  String timeFormatter({required DateTime date}) {
    DateFormat formatter = DateFormat('HH:mm:00');

    String formatted = formatter.format(date);
    return formatted;
  }
}
