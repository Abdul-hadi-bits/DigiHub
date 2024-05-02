import 'package:cached_network_image/cached_network_image.dart';
import 'package:digi_hub/Business_Logic/Chat_Logic/bloc/chat_bloc.dart';
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/chat/new_message_counter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import 'chat.dart';
import 'util.dart';

class RoomsPage extends StatelessWidget {
  const RoomsPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return state.rooms.isEmpty
            ? Column(
                children: [
                  SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10)),
                      child: Text("You don't have any conversation"),
                    ),
                  ),
                ],
              )
            : AllConverations(rooms: state.rooms);
      },
    );
  }
}

class AllConverations extends StatelessWidget {
  final List<types.Room> rooms;

  const AllConverations({super.key, required this.rooms});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];

        return GestureDetector(
            onLongPress: () async {
              confirmDialog(
                context: context,
                alertText: "Delete Conversation?",
                confirmButton: TextButton(
                  onPressed: () {
                    context
                        .read<ChatBloc>()
                        .add(ChatDeleteConversationEvent(roomId: room.id));
                    Navigator.pop(context);
                  },
                  child: Text("yes"),
                ),
                cancelButton: TextButton(
                  onPressed: () {
                    /*  if (context.read<ChatBloc>().state.status !=
                            ChatStatus.deleteConversationInProgress) */
                    Navigator.pop(context);
                  },
                  child: Text("no"),
                ),
              );
            },
            onTap: () {
              context.read<ChatBloc>().add(ChatEnteredRoomEvent(room: room));

              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                          value: context.read<ChatBloc>(),
                          child: ChatPage(
                            room: room,
                          )),
                    ),
                  )
                  .whenComplete(() => context.read<ChatBloc>().add(
                      ChatLeavedRoomEvent(
                          room: context.read<ChatBloc>().state.activeRoom)));
            },
            child: ConversationTile(
              room: room,
            ));
      },
    );
  }
}

class ConversationTile extends StatelessWidget {
  final types.Room room;

  const ConversationTile({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    var color = Colors.transparent;

    if (room.type == types.RoomType.direct) {
      try {
        final otherUser = room.users.firstWhere(
          (u) => u.id != context.read<ChatBloc>().state.myUserId,
        );

        color = getUserAvatarNameColor(otherUser);
      } catch (e) {
        // Do nothing if other user is not found.
      }
    }

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: EdgeInsets.only(right: 20, left: 20, top: 15, bottom: 15),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                CircleAvatar(
                  backgroundColor: hasImage ? Colors.transparent : color,
                  backgroundImage: hasImage
                      ? CachedNetworkImageProvider(room.imageUrl!)
                      : null,
                  radius: 40,
                ),
                Expanded(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 8.0, left: 8),
                              child: Text(
                                name,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        //show last messge of each conversation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RoomLastMessage(room: room),
                            RoomTimeStamp(room: room),
                          ],
                        ),
                      ]),
                ),
              ],
            ),
            Align(
              child: NewMessageStatus(room: room),
              alignment: Alignment.centerRight,
            )
          ],
        ),
      ),
    );
  }
}

class RoomLastMessage extends StatelessWidget {
  final types.Room room;

  const RoomLastMessage({super.key, required this.room});
  @override
  Widget build(BuildContext context) {
    //print(room.lastMessage);
    return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: room.lastMessage != null
            ? Row(
                children: [
                  /*  checkSeenStatus()
                    ? Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: Colors.green,
                      ).paddingOnly(right: 5)
                    : Icon(
                        CupertinoIcons.check_mark_circled_solid,
                        color: Colors.grey,
                      ).paddingOnly(right: 5), */
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Builder(
                      builder: (context) {
                        if (room.lastMessage!['text'] != null)
                          return Text(
                            "${room.lastMessage!['text']}",
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: lastMessageIsThisUser(room)
                                    ? Colors.grey
                                    : MessageCounter.checkNewMessages(
                                            roomId: room.id,
                                            roomTimeStamp:
                                                room.updatedAt.toString())
                                        ? Colors.deepPurple
                                        : Colors.grey),
                          );
                        if (room.lastMessage!['type'] != null)
                          return Text(
                            "FILE",
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: 17,
                                color: lastMessageIsThisUser(room)
                                    ? Colors.green
                                    : MessageCounter.checkNewMessages(
                                            roomId: room.id,
                                            roomTimeStamp:
                                                room.updatedAt.toString())
                                        ? Colors.deepPurple
                                        : Colors.green),
                          );
                        return Text(
                          "${"Unknown Message Formart"}}",
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: lastMessageIsThisUser(room)
                                  ? Colors.green
                                  : MessageCounter.checkNewMessages(
                                          roomId: room.id,
                                          roomTimeStamp:
                                              room.updatedAt.toString())
                                      ? Colors.deepPurple
                                      : Colors.green),
                        );
                      },
                    ),
                  ),
                ],
              )
            : Text(" no message"));
  }

  bool lastMessageIsThisUser(types.Room room) {
    try {
      var currentUser = room.users.firstWhere((element) =>
          element.id == FirebaseChatCore.instance.firebaseUser!.uid);
      return room.lastMessage!['authorId'].toString() == currentUser.id;
    } catch (e) {
      return false;
    }
  }
}

class RoomTimeStamp extends StatelessWidget {
  final types.Room room;

  const RoomTimeStamp({super.key, required this.room});
  @override
  Widget build(BuildContext context) {
    return room.updatedAt != null
        ? Text(
            "${DateTime.fromMillisecondsSinceEpoch(room.updatedAt!).hour}:${DateTime.fromMillisecondsSinceEpoch(room.updatedAt!).minute}",
            style: TextStyle(
                color: lastMessageIsThisUser(room)
                    ? Colors.black
                    : MessageCounter.checkNewMessages(
                            roomId: room.id,
                            roomTimeStamp: room.updatedAt.toString())
                        ? Colors.deepPurple
                        : Colors.black),
          )
        : Container();
  }

  bool lastMessageIsThisUser(types.Room room) {
    try {
      var currentUser = room.users.firstWhere((element) =>
          element.id == FirebaseChatCore.instance.firebaseUser!.uid);
      return room.lastMessage!['authorId'].toString() == currentUser.id;
    } catch (e) {
      return false;
    }
  }
}

class NewMessageStatus extends StatelessWidget {
  final types.Room room;

  const NewMessageStatus({super.key, required this.room});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return lastMessageIsThisUser(room)
            ? Container()
            : MessageCounter.checkNewMessages(
                    roomId: room.id, roomTimeStamp: room.updatedAt.toString())
                ? Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(60),
                        color: Colors.deepPurple,
                      ),
                      height: MediaQuery.of(context).size.height / 40,
                      width: MediaQuery.of(context).size.height / 40,
                      child: FittedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            "N",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Container();
      },
    );
  }

  bool lastMessageIsThisUser(types.Room room) {
    try {
      var currentUser = room.users.firstWhere((element) =>
          element.id == FirebaseChatCore.instance.firebaseUser!.uid);
      return room.lastMessage!['authorId'].toString() == currentUser.id;
    } catch (e) {
      return false;
    }
  }
}
