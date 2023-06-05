import 'dart:io' as io;

import 'package:connectivity_plus/connectivity_plus.dart';
import "package:flutter/material.dart";
//import 'package:connectivity_plus/connectivity_plus.dart' as network_connection;
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_project/UI/AUTH_pages/registeration/register_page.dart';
import 'package:my_project/UI/AUTH_pages/sign_in/email_sign_in.dart';
import 'package:my_project/UI/home_pages/settings/settings.dart';
import 'package:my_project/UI/home_pages/todo/main_todo_page.dart';
import 'package:my_project/UI/home_pages/wallet/wallet_main_page.dart';
import 'package:my_project/Utillity/video_player.dart';

import 'chat/main_chat_page.dart';

class DigiHub extends StatefulWidget {
  const DigiHub({Key? key}) : super(key: key);

  @override
  _DigiHubState createState() => _DigiHubState();
}

class _DigiHubState extends State<DigiHub> {
  int previousPage = 0;
  int _page = 0;
  int index = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();
  bool networkConnection = false;
  bool internetConnection = false;
  late bool isOnline;
  late SharedPreferences user;
  List<Widget> pages = [
    const TodoList(),
    const Wallet(),
    const ChatPage(),
    const Settings(),
  ];

  @override
  initState() {
    isOnline = auth.FirebaseAuth.instance.currentUser != null ? true : false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedSwitcher(
        child: pages[_page],
        switchInCurve: Curves.easeInToLinear,
        switchOutCurve: const Threshold(0),
        transitionBuilder: (child, animation) {
          bool isForward = (previousPage > _page) ? false : true;

          return SlideTransition(
            child: child,
            position: Tween(
              begin: Offset(isForward ? 1 : -1, 0),
              end: Offset.zero,
            ).animate(animation),
          );
        },
        duration: const Duration(milliseconds: 500),
      ),
      bottomNavigationBar: Card(
        elevation: 10,
        child: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 60.0,
          items: const <Widget>[
            // Icon(Icons.add, size: 30, color: Colors.white),
            Card(
              elevation: 8,
              child: FaIcon(Icons.list, size: 30, color: Colors.black),
            ),
            // Icon(Icons.compare_arrows, size: 30, color: Colors.white),
            Card(
              elevation: 8,
              child: Icon(Icons.account_balance_wallet_outlined,
                  size: 30, color: Colors.black),
            ),
            Card(
              elevation: 8,
              child: Icon(Icons.chat_outlined, size: 30, color: Colors.black),
            ),
            Card(
              elevation: 8,
              child: Icon(Icons.perm_identity, size: 30, color: Colors.black),
            ),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.grey.shade200,
          backgroundColor: Colors.white,
          animationCurve: Curves.fastLinearToSlowEaseIn,
          animationDuration: const Duration(milliseconds: 1000),
          onTap: (index) {
            setState(() {
              previousPage = _page;
              _page = index;
            });
          },
          letIndexChange: (index) => true,
        ),
      ),
    );
  }
}
