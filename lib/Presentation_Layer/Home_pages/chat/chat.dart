import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:digi_hub/Business_Logic/Chat_Logic/bloc/chat_bloc.dart' as bloc;
import 'package:digi_hub/Business_Logic/Utility.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_ui/src/conditional/conditional.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';

enum Status { delivered, error, seen, sending, sent }

class ChatPage extends StatefulWidget {
  ChatPage({
    super.key,
    required this.room,
  });

  final types.Room room;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  types.Message? editingMessage;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:

        //Execute the code here when user come back the app.
        //In my case, I needed to show if user active or not,
        context.read<bloc.ChatBloc>().add(bloc.ChatEnteredRoomEvent(
            room: context.read<bloc.ChatBloc>().state.activeRoom));
        print("in");

        break;
      case AppLifecycleState.paused:

        //Execute the code the when user leave the app
        context.read<bloc.ChatBloc>().add(bloc.ChatLeavedRoomEvent(
            room: context.read<bloc.ChatBloc>().state.activeRoom));
        print("out");

        break;
      default:
        break;
    }
  }

  types.User getOtherUser(types.Room room) {
    try {
      types.User otherUserId = room.users.firstWhere((element) =>
          element.id != FirebaseChatCore.instance.firebaseUser!.uid);
      return otherUserId;
    } catch (e) {
      return types.User(id: "");
    }
    //
  }

  @override
  Widget build(BuildContext context) {
    void _handleAtachmentPressed() {
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext _) => SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(_);
                    context.read<bloc.ChatBloc>().add(
                        bloc.ChatHandleImageSelectionEvent(
                            user: getOtherUser(context
                                .read<bloc.ChatBloc>()
                                .state
                                .activeRoom)));
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<bloc.ChatBloc>().add(
                        bloc.ChatHandleFileSelectionEvent(
                            user: getOtherUser(context
                                .read<bloc.ChatBloc>()
                                .state
                                .activeRoom)));
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    void _handleMessageTap(BuildContext context, types.Message p1) {
      context
          .read<bloc.ChatBloc>()
          .add(bloc.ChatHandleMessageTapEvent(message: p1, context: context));
    }

    void _handleUpdatePressed(types.PartialText message) {
      context
          .read<bloc.ChatBloc>()
          .add(bloc.ChatToggleMessageEditing(isClose: true));
      final editTextMessage = editingMessage as types.TextMessage;
      print("${message.text} :  ${editTextMessage.text}");

      if (message.text != editTextMessage.text) {
        context.read<bloc.ChatBloc>().add(bloc.ChatUpdateMessageEvent(
              message: message,
              messageId: editingMessage!.id,
            ));
      }
    }

    void _handlePreviewDataFetched(types.TextMessage p1, types.PreviewData p2) {
      context.read<bloc.ChatBloc>().add(
          bloc.ChatHandlePreviewedDataFetchEvent(message: p1, previewData: p2));
    }

    void _handleSendPressed(types.PartialText p1) {
      context.read<bloc.ChatBloc>().add(bloc.ChatHandleSendPressedEvent(
          message: p1,
          user: getOtherUser(context.read<bloc.ChatBloc>().state.activeRoom)));
    }

    bool checkOnlineStatus(types.Room room) {
      try {
        var otherUser = room.users.firstWhere((element) =>
            element.id != FirebaseChatCore.instance.firebaseUser!.uid);

        if (context
                .read<bloc.ChatBloc>()
                .state
                .activeRoom
                .userStatus!['${otherUser.id}'] ==
            true) {
          return true;
        }
        return false;
      } catch (e) {
        print("checkOnlinestatus" + e.toString());
        return false;
      }
    }

    ImageProvider<Object> _imageProviderBuilder(
        {required Conditional conditional,
        required Map<String, String>? imageHeaders,
        required String uri}) {
      return CachedNetworkImageProvider(
        uri,
      );
    }

    void _showPopupMenu(
        {required types.Message message,
        required types.Room room,
        required Offset offset}) async {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }

      List<PopupMenuItem> items = [];
      if (message.type == types.MessageType.text) {
        items.add(
          PopupMenuItem<void>(
            child: Row(
              children: [
                Icon(Icons.copy),
                const Text(" copy"),
              ],
            ),
            onTap: () async {
              final textMessage = message as types.TextMessage;

              await Clipboard.setData(ClipboardData(text: textMessage.text));
              // _handleVideoSelection();
            },
          ),
        );
        items.add(
          PopupMenuItem<void>(
            child: Row(
              children: [
                Icon(Icons.edit_note_outlined),
                const Text(" edit"),
              ],
            ),
            onTap: () async {
              if (!NetworkConnection.isConnected) {
                awesomeTopSnackbar(
                  context,
                  "You are offline",
                  textStyle: const TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                  backgroundColor: Colors.grey.shade400,
                  icon: Icon(Icons.error, color: Colors.red.shade300),
                  iconWithDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white),
                  ),
                );
                return;
              }
              editingMessage = message;
              context
                  .read<bloc.ChatBloc>()
                  .add(bloc.ChatToggleMessageEditing(isClose: false));
            },
          ),
        );
      }

      items.add(PopupMenuItem<void>(
        child: Row(
          children: [
            Icon(Icons.delete),
            Text(" delete"),
          ],
        ),
        onTap: () {
          if (!NetworkConnection.isConnected) {
            awesomeTopSnackbar(
              context,
              "You are offline",
              textStyle: const TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              backgroundColor: Colors.grey.shade400,
              icon: Icon(Icons.error, color: Colors.red.shade300),
              iconWithDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white),
              ),
            );
            return;
          }
          context
              .read<bloc.ChatBloc>()
              .add(bloc.ChatDeleteMessageEvent(message: message, room: room));
        },
      ));

      await showMenu(
        context: context,
        // position: RelativeRect.,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            side: new BorderSide(color: Colors.grey.shade200, width: 2),
            borderRadius: new BorderRadius.all(new Radius.circular(20))),

        popUpAnimationStyle:
            AnimationStyle(duration: Duration(milliseconds: 200)),
        position:
            RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx, offset.dy),
        items: items,
        elevation: 3,
      );
    }

    void _onMessageLongPress(BuildContext context, types.Message p1,
        GlobalKey<State<StatefulWidget>> key) async {
      final roomId = context.read<bloc.ChatBloc>().state.activeRoom;
      if (p1.author == getOtherUser(roomId)) return;
      final RenderBox renderBox =
          key.currentContext?.findRenderObject() as RenderBox;

      final Offset offset = renderBox.localToGlobal(Offset.zero);

      _showPopupMenu(message: p1, room: roomId, offset: offset);
    }

    Widget _avatarBuilder(types.User author) {
      return Container(
        padding: EdgeInsets.only(right: 4),
        child: CircleAvatar(
          backgroundImage:
              CachedNetworkImageProvider(author.imageUrl.toString()),
        ),
      );
    }

    void _onCancelPress() {
      context
          .read<bloc.ChatBloc>()
          .add(bloc.ChatToggleMessageEditing(isClose: true));
    }

    return BlocListener<bloc.ChatBloc, bloc.ChatState>(
        listener: (context, state) {
      if (state.status == bloc.ChatStatus.connectonChanged) {
        awesomeTopSnackbar(context, state.isOnline ? "Online" : "Offline",
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
      if (state.status == bloc.ChatStatus.chatRoomError) {
        awesomeTopSnackbar(
          context,
          state.chatRoomError,
          textStyle: const TextStyle(
              color: Colors.white,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              fontSize: 16),
          backgroundColor: Colors.grey.shade400,
          icon: Icon(Icons.error, color: Colors.red.shade300),
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white),
          ),
        );
      }
    }, child: BlocBuilder<bloc.ChatBloc, bloc.ChatState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(CupertinoIcons.back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              Text("status : "),
              NetworkConnection.isConnected == false
                  ? Text(
                      "unknown",
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ).paddingOnly(right: 10)
                  : checkOnlineStatus(state.activeRoom)
                      ? Text(
                          " online",
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold),
                        ).paddingOnly(right: 10)
                      : Text("offline",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold))
                          .paddingOnly(right: 10),
            ],
            title: Row(
              children: [
                Text(
                    "${getOtherUser(state.activeRoom).firstName.toString()} ${getOtherUser(state.activeRoom).lastName.toString()}"),
              ],
            ),
          ),
          body: Container(
            // padding: EdgeInsets.only(right: 8, left: 8),
            child: Chat(
              onCancelPressed: _onCancelPress,
              isEditMode: state.isMessageEditing,
              messageEdit: editingMessage,
              onUpdatePressed: _handleUpdatePressed,
              imageProviderBuilder: _imageProviderBuilder,
              onMessageLongPress: _onMessageLongPress,
              isLastPage: true,
              isLeftStatus: true,
              showUserAvatars: true,
              usePreviewData: true,
              showUserNames: true,
              useTopSafeAreaInset: true,
              avatarBuilder: _avatarBuilder,
              theme: DefaultChatTheme(seenIcon: Icon(Icons.check)),
              textMessageOptions: TextMessageOptions(
                isTextSelectable: false,
              ),
              scrollPhysics: ScrollPhysics(),
              isAttachmentUploading:
                  state.attachmentFileUploading || state.messageUploading,
              messages: state.messages[state.activeRoomId] == null
                  ? []
                  : state.messages[state.activeRoomId]!,
              onAttachmentPressed: _handleAtachmentPressed,
              onMessageTap: _handleMessageTap,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              user: types.User(
                id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
              ),
            ),
          ),
        );
      },
    ));
  }
}
