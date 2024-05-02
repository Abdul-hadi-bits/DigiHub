import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
//  final _fireabseMessageing = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    /*  await _fireabseMessageing.requestPermission();
    final fCMToken = await _fireabseMessageing.getToken();
    print("Token is : $fCMToken"); */
    initPushNotifications();
  }

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
  }

  Future<void> handleOnBackgroundMessage() async {}

  Future initPushNotifications() async {
    await FirebaseMessaging.instance.getInitialMessage();

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
