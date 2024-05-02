import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:get/get.dart' as nav;
import 'package:digi_hub/Presentation_Layer/Home_pages/todo/main_todo_page.dart';
//import 'package:rxdart/subjects.dart' as rxSub;

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationClass {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // initializing notifications
  initializeNotification() async {
    //tz.initializeTimeZones();
    _configureLocalTimeZone();

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('icon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {},
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // NotificationResponse response=NotificationResponse(notificationResponseType: NotificationResponseType.selectedNotification);
    /*   await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: (details) {
        print("notification bar is clicked");
        nav.Get.to(const TodoList());
      },
    ); */
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(
      NotificationResponse notificationResponse) {
    print("notification bar is clicked");
    nav.Get.to(const TodoList());

    // ignore: avoid_print
    print('notification(${notificationResponse.id}) action tapped: '
        '${notificationResponse.actionId} with'
        ' payload: ${notificationResponse.payload}');
    if (notificationResponse.input?.isNotEmpty ?? false) {
      // ignore: avoid_print
      print(
          'notification action tapped with input: ${notificationResponse.input}');
    }
  }

  // creating scheduled notification
  Future<void> scheduleNotification(
      {required int id,
      required String title,
      required String body,
      required DateTime scheduledTime}) async {
    var androidSpecifics = const AndroidNotificationDetails(
      'cha1', 'channelOne',
      icon: 'icon',
      enableVibration: true,
      playSound: true,
      showWhen: true,
      color: Colors.orange,
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,

      /* largeIcon: DrawableResourceAndroidBitmap(
        'icon',
      ), */
      //color: Colors.blueGrey,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidSpecifics);

    tz.TZDateTime time = tz.TZDateTime.from(scheduledTime, tz.local);
    print("scheduling the notification for ${time.toString()}");
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    try {
      if (now.isBefore(time)) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title.toUpperCase(),
          body.capitalizeFirst,
          time,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        print("task has been scheduled");
      } else {
        print("could not schedule the notificaion, time is in past");
      }
    } on tz.TimeZoneInitException catch (e) {
      print(e.msg);
    } on tz.LocationNotFoundException catch (e) {
      print(e.msg);
    } catch (e) {
      print("schedule notifs error catch : $e");
    }

    // This literally schedules the notification
  }

  Future<void> schedualEndNotification(
      {required int id,
      required String body,
      required DateTime scheduledTime}) async {
    var androidSpecifics = const AndroidNotificationDetails(
      'cha1',
      'channelOne',
      icon: 'icon',
      enableVibration: true,
      playSound: true,
      showWhen: true,
      color: Colors.orange,
      fullScreenIntent: true,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidSpecifics);

    tz.TZDateTime time = tz.TZDateTime.from(scheduledTime, tz.local);
    print("scheduling the notification for ${time.toString()} (end of task)");
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    try {
      if (now.isBefore(time)) {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          "Schedule is missed!",
          body.capitalizeFirst,
          time,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          androidScheduleMode: AndroidScheduleMode.alarmClock,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        print("end of task has been scheduled");
      } else {
        print(
            "could not schedule the notificaion (end of task), time is in past");
      }
    } on tz.TimeZoneInitException catch (e) {
      print(e.msg);
    } on tz.LocationNotFoundException catch (e) {
      print(e.msg);
    } catch (e) {
      print("schedule notifs error catch (end of task) : $e");
    }

    // This literally schedules the notification
  }

  Future<void> cancelNotificaion({required int id}) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print("scheduled notificaion was canceled");
  }

  // this function is used to set local location to be used in tz.local for getting the time zone of your current location
  Future<void> _configureLocalTimeZone() async {
    try {
      tz.initializeTimeZones();
      final String? timeZoneName =
          await FlutterNativeTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName!));
      print("setting local time zone : $timeZoneName");
    } on tz.TimeZoneInitException catch (e) {
      print(e.msg);
    } on tz.LocationNotFoundException catch (e) {
      print(e.msg);
    } catch (e) {
      print("local timezone error catch : $e");
    }
  }
}
