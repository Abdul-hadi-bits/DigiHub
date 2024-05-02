// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:digi_hub/Business_Logic/Wallet_Logic/bloc/wallet_bloc.dart';
import "package:flutter/material.dart";

import 'package:digi_hub/Business_Logic/Chat_Logic/bloc/chat_bloc.dart';
import 'package:digi_hub/Business_Logic/Global_States/internetCubit.dart';
import 'package:digi_hub/Business_Logic/Settings_Logic/bloc/settings_bloc.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:digi_hub/Presentation_Layer/Home_pages/settings/settings.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/todo/main_todo_page.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/wallet/wallet_main_page.dart';

import 'chat/main_chat_page.dart' as chat;

class DigiHub extends StatefulWidget {
  final InternetCubit internetCubit;
  const DigiHub({
    Key? key,
    required this.internetCubit,
  }) : super(key: key);

  @override
  _DigiHubState createState() => _DigiHubState(internetCubit: internetCubit);
}

class _DigiHubState extends State<DigiHub> {
  _DigiHubState({required this.internetCubit});

  late InternetCubit internetCubit;

  int previousPage = 0;
  int _page = 0;
  int index = 0;
  late List<Widget> pages;
  late ChatBloc _chatBloc;

  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  late SettingsBloc _settingsBloc;
  @override
  void initState() {
    _chatBloc = ChatBloc(internetCubit: internetCubit);

    // TODO: implement initState

    _settingsBloc = SettingsBloc();

    pages = [
      const TodoList(),
      BlocProvider(
        create: (context) => WalletBloc(),
        child: const Wallet(),
      ),
      BlocProvider.value(
        value: _chatBloc,
        child: chat.ChatPage(),
      ),
      MultiBlocProvider(
        providers: [
          BlocProvider.value(
            value: _settingsBloc,
          ),
          BlocProvider.value(
            value: _chatBloc,
          ),
        ],
        child: Setting(),
      )
    ];
    super.initState();
  }

  @override
  void dispose() {
    _chatBloc.dispose();
    _chatBloc.close();

    _settingsBloc.close();
    super.dispose();
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
        duration: const Duration(milliseconds: 300),
      ),
      bottomNavigationBar: Card(
        color: Colors.white,
        elevation: 10,
        child: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 60.0,
          items: const <Widget>[
            // Icon(Icons.add, size: 30, color: Colors.white),
            Card(
              elevation: 8,
              color: Colors.white,
              child: FaIcon(Icons.list, size: 30, color: Colors.black),
            ),
            // Icon(Icons.compare_arrows, size: 30, color: Colors.white),
            Card(
              elevation: 8,
              color: Colors.white,
              child: Icon(Icons.account_balance_wallet_outlined,
                  size: 30, color: Colors.black),
            ),
            Card(
              elevation: 8,
              color: Colors.white,
              child: Icon(Icons.chat_outlined, size: 30, color: Colors.black),
            ),
            Card(
              elevation: 8,
              color: Colors.white,
              child: Icon(Icons.settings, size: 30, color: Colors.black),
            ),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.grey.shade200,
          backgroundColor: Colors.white,
          animationCurve: Curves.fastLinearToSlowEaseIn,
          animationDuration: const Duration(milliseconds: 300),
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
