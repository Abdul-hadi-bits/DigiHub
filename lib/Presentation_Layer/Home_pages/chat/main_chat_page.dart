import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:digi_hub/Business_Logic/Chat_Logic/bloc/chat_bloc.dart' as bloc;
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:digi_hub/Presentation_Layer/Home_pages/chat/room.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'chat.dart' as rooms;
import 'util.dart';

class ChatPage extends StatelessWidget {
  ChatPage({Key? key}) : super(key: key);

  /*  late MessageCounter messageStatus;
  TextEditingController searchField = TextEditingController(); */
  final FocusNode focus = FocusNode();

  final Map<String, dynamic> result = {};

  @override
  Widget build(BuildContext context) {
    return BlocListener<bloc.ChatBloc, bloc.ChatState>(
      listener: (context, state) {
        print("state : ${state.status.name}");
        if (state.status == bloc.ChatStatus.createNewRoomDone) {
          types.Room room = state.activeRoom;

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                      value: context.read<bloc.ChatBloc>(),
                      child: rooms.ChatPage(room: room))));
        }
        if (state.status == bloc.ChatStatus.deleteConversationError) {
          awesomeTopSnackbar(
              context, /*  state.isOnline ? "Online" : "Offline" */ state.error,
              backgroundColor: Colors.grey.shade200,
              iconWithDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(),
                  color: Colors.white),
              textStyle:
                  TextStyle(color: state.isOnline ? Colors.green : Colors.red),
              icon: Icon(
                state.isOnline
                    ? Icons.check_circle_outline
                    : Icons.cancel_rounded,
                color: state.isOnline ? Colors.green : Colors.red,
              ));
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: MyAppBar(
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: BlocBuilder<bloc.ChatBloc, bloc.ChatState>(
                  builder: (context, state) {
                    return Text.rich(
                      TextSpan(children: <InlineSpan>[
                        WidgetSpan(
                            child: Icon(
                          CupertinoIcons.circle_fill,
                          size: 16,
                          color: state.isOnline
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        )),
                        TextSpan(
                            text: state.isOnline ? "online" : "offline",
                            style: TextStyle(fontSize: 16)),
                      ]),
                    );
                  },
                ),
              )
            ],
            ttle: "Chats",
            fitTitle: true,
            italikTitle: true,
            context: context,
            titleSpacing: 70,
            statusBarDark: false,
            onPressed: () {},
            showLeading: false,
          ),
          body: GestureDetector(
            onTap: () {
              //dimiss keyboard on tap
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus &&
                  currentFocus.focusedChild != null) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            child: ProgressHUD(
              inAsyncCall: context.watch<bloc.ChatBloc>().state.status ==
                  bloc.ChatStatus.createNewRoomInProgress,
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.86,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      UserSearchBar(),
                      BlocBuilder<bloc.ChatBloc, bloc.ChatState>(
                        builder: (context, state) {
                          return state.showUsers
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  width: MediaQuery.of(context).size.width,
                                  child: AllUsers(),
                                )
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height / 1.5,
                                  width: MediaQuery.of(context).size.width,
                                  child: BlocProvider.value(
                                      value: context.read<bloc.ChatBloc>(),
                                      child: RoomsPage()),
                                );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AllUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // get users and create a list of users
    return BlocBuilder<bloc.ChatBloc, bloc.ChatState>(
      /*   buildWhen: (previous, current) =>
          current.users.length != previous.users.length, */
      builder: (context, state) {
        if (!state.isOnline) {
          return Column(
            children: [
              SizedBox(height: 10),
              Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text("You are offline can't find users"),
                ),
              ),
            ],
          );
        }
        if (state.users.isEmpty) {
          return Column(
            children: [
              SizedBox(height: 10),
              Center(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text("No Users Available"),
                ),
              ),
            ],
          );
        }
        return ListView.builder(
          itemCount: state.users.length,
          itemBuilder: (context, index) {
            final user = state.users[index];

            if ((user.firstName! + user.lastName!).toLowerCase().contains(
                context
                    .read<bloc.ChatBloc>()
                    .state
                    .searchBarText
                    .toLowerCase())) {
              return GestureDetector(
                onTap: () {
                  // dismiss keyboard
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus &&
                      currentFocus.focusedChild != null) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  }
                  // on tap, create a new room, then navigato to that new room

                  context
                      .read<bloc.ChatBloc>()
                      .add(bloc.ChatNewRoomCreateEvent(joiningUser: user));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: UserAvatar(user: user),
                ),
              );
            }
            return Container();
          },
        );
      },
    );
  }
}

class UserSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: BlocBuilder<bloc.ChatBloc, bloc.ChatState>(
        builder: (context, state) {
          return SearchBar(
              onChanged: (text) {
                context
                    .read<bloc.ChatBloc>()
                    .add(bloc.ChatSearchBarEditEvent(searchBarText: text));
              },
              controller: state.showUsers == false
                  ? TextEditingController(text: "")
                  : null,
              hintText: "Search Friends",
              shadowColor: MaterialStateProperty.resolveWith(
                  (states) => Colors.transparent),
              backgroundColor: MaterialStateColor.resolveWith(
                  (states) => Colors.grey.shade100),
              onTap: () {
                //toggle between conversations and users
                if (state.showUsers == false)
                  context
                      .read<bloc.ChatBloc>()
                      .add(bloc.ChatSwitchBetweenUsersAndRoomsEvent());
                //context.read<bloc.ChatBloc>().add(bloc.ChatGetAllChatUsers());
              },
              leading: context.read<bloc.ChatBloc>().state.showUsers
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                      ),
                      onPressed: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus &&
                            currentFocus.focusedChild != null) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                        context
                            .read<bloc.ChatBloc>()
                            .add(bloc.ChatSwitchBetweenUsersAndRoomsEvent());
                      })
                  : Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Icon(CupertinoIcons.search),
                    ));
        },
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final types.User user;
  UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final color = getUserAvatarNameColor(user);
    final hasImage = user.imageUrl != null;
    final name = getUserName(user);

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.blueGrey.shade50,
      ),
      //margin: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: hasImage ? Colors.transparent : color,
            backgroundImage:
                hasImage ? CachedNetworkImageProvider(user.imageUrl!) : null,
            radius: 30,
            child: !hasImage
                ? Text(
                    name.isEmpty ? '' : name[0],
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              name,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700),
            ),
          )
        ],
      ),
    );
  }
}
