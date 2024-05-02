import 'package:digi_hub/Business_Logic/Global_States/userStatusState.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/signin_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class UserStatusCubit extends Cubit<UserStatusState> {
  late BuildContext mainContext;
  UserStatusCubit({required this.mainContext})
      : super(UserStatusState(user: FirebaseAuth.instance.currentUser)) {
    try {
      print(
          "user status changes Cubit is initialized!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
      FirebaseAuth.instance.userChanges().listen((user) {
        print(
            "user change listener has run!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        // if user was not logged in
        if (user == null) {
          print("user is null!!!!!!!!!!!!!!!!!!!!!!!!!!!");
          // we go through all the routes

          Navigator.pushAndRemoveUntil(
              mainContext,
              MaterialPageRoute(
                builder: (context) => WellcomePage(),
              ),
              (route) => false);
        }
      });
    } on FirebaseException catch (e) {
      print(e.code);
    } catch (e) {
      print(e.toString() + " in side user status cubit");
    }
  }
}
