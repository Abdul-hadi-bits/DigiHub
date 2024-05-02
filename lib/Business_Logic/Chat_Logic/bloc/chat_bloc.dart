import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:digi_hub/Business_Logic/Global_States/internetCubit.dart';
import 'package:digi_hub/Business_Logic/Utility.dart';
import 'package:digi_hub/Data_Layer/Module/Local_noSql_Module.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/chat/new_message_counter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as chat;
import 'package:http/http.dart' as http;

import 'package:equatable/equatable.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  bool isRoomInitialized = false;
  bool skip = true;
  late StreamSubscription intenertSubscription;
  late InternetCubit internetCubit;
  late Stream<List<chat.Room>> _roomsStream;
  late Stream<List<chat.Message>> _messagesStream;
  late Stream<List<chat.User>> _users;
  ChatBloc({required this.internetCubit})
      : super(ChatState(
          isMessageEditing: false,
          thumbnail: {},
          error: "",
          messageUploading: false,
          isOnline: NetworkConnection.isConnected,
          chatRoomError: "",
          attachmentFileUploading: false,
          activeRoom: chat.Room(id: "", users: [], type: null),
          activeRoomId: "",
          messages: {},
          myUserId: FirebaseChatCore.instance.firebaseUser!.uid,
          status: ChatStatus.initial,
          showUsers: false,
          searchBarText: "",
          users: [],
          rooms: [],
        )) {
    print("********** chat bloc initalized **********");

    on<ChatInitializeChatUsers>(_initializeChatUsers);
    on<ChatInitializeChatRooms>(_initializeChatRooms);
    on<ChatInitializeChatMessagesEvent>(_initializeChatMessages);

    on<ChatNewRoomCreateEvent>(_createNewRoom);
    on<ChatSwitchBetweenUsersAndRoomsEvent>(_switchBetweenUsersAndRooms);
    on<ChatSearchBarEditEvent>(_searchBarEdited);
    on<ChatInitializeRoom>(_getRoom);
    on<ChatHandleFileSelectionEvent>(_handleFileSelection);
    on<ChatHandleImageSelectionEvent>(_handleImageSelection);
    on<ChatHandleMessageTapEvent>(_handleMessageTap);
    on<ChatHandleSendPressedEvent>(_handleSendPressed);
    on<ChatHandlePreviewedDataFetchEvent>(_handlePreviewDataFetched);
    on<ChatUpdateInternetStatus>(_updateInternetStatus);
    on<ChatEnteredRoomEvent>(_enteredRoomEvent);
    on<ChatLeavedRoomEvent>(_leavedRoomEvent);
    on<ChatDeleteConversationEvent>(_deleteConversation);
    on<ChatDeleteMessageEvent>(_deleteMessage);
    on<ChatUpdateMessageEvent>(_updateMessage);
    on<ChatHandleVideoSelectionEvent>(_handleVideoSelection);
    on<ChatToggleMessageEditing>(_toggleMessageEditing);
    on<ChatDeleteAllUserChatData>(_deleteAllUserChatData);

    add(ChatInitializeChatRooms());
    _initializeAllMessages();
    _listenForInternetChanges();
  }
  FutureOr<void> _deleteAllUserChatData(
      ChatDeleteAllUserChatData evenet, Emitter<ChatState> emit) async {
    try {
      final rooms = state.rooms;
      rooms.forEach((room) async {
        await _deleteRoomLocaly;
        await FirebaseChatCore.instance.deleteRoom(room.id);
      });
      await FirebaseChatCore.instance
          .deleteUserFromFirestore(FirebaseChatCore.instance.firebaseUser!.uid);
      emit(state.copyWith(status: ChatStatus.deletingUserDataDone));
    } catch (e) {
      print("*** deleting rooms faild : $e");
    }
  }

  FutureOr<void> _toggleMessageEditing(
      ChatToggleMessageEditing event, Emitter<ChatState> emit) async {
    if (event.isClose) {
      emit(state.copyWith(isMessageEditing: false));
      return;
    }
    emit(state.copyWith(isMessageEditing: false));
    await Future.delayed(Duration(milliseconds: 300));
    emit(state.copyWith(isMessageEditing: true));
  }

  FutureOr<void> _updateMessage(
      ChatUpdateMessageEvent event, Emitter<ChatState> emit) async {
    try {
      if (!state.isOnline) return;
      emit(state.copyWith(status: ChatStatus.initial));

      final message = chat.TextMessage.fromPartial(
        author: chat.User(id: FirebaseChatCore.instance.firebaseUser!.uid),
        id: event.messageId,
        partialText: event.message,
      );
      emit(state.copyWith(
          messageUploding: true, status: ChatStatus.messageUpdateInProgress));
      await FirebaseChatCore.instance
          .updateMessage(message, state.activeRoomId);
      emit(state.copyWith(
        messageUploding: false,
      ));
      try {
        final lastMessage = state.messages[state.activeRoomId]!.first;

        if (message.id == lastMessage.id) {
          FirebaseChatCore.instance.updateLastMessage(
            message: state.messages[state.activeRoomId]!.first,
            roomId: state.activeRoomId,
            updateOnlyText: true,
          );
        }
      } catch (e) {
        print("** updated last message error: $e");
      }
    } catch (e) {
      print("errrorr $e");
      emit(state.copyWith(
          messageUploding: false, status: ChatStatus.messageUpdateDone));
    }
  }

  FutureOr<void> _deleteMessage(
      ChatDeleteMessageEvent event, Emitter<ChatState> emit) async {
    if (!state.isOnline) return;

    try {
      if (event.message.author.id !=
          FirebaseChatCore.instance.firebaseUser!.uid) return;
      String idOfLastMessage = state.messages[event.room.id]!.first.id;

      await FirebaseChatCore.instance
          .deleteMessage(event.room.id, event.message.id);
      if (event.message.type != chat.MessageType.text) {
        if (event.message.type == chat.MessageType.file) {
          final fileMessage = event.message as chat.FileMessage;
          deleteMedia(name: fileMessage.name);
        } else if (event.message.type == chat.MessageType.image) {
          final imageMessage = event.message as chat.ImageMessage;
          deleteMedia(name: imageMessage.name);
        }
      }

      emit(state.copyWith(status: ChatStatus.messageDeleted));
      try {
        /*        try {
          state.messages[event.room.id]!.first;
        } catch (e) {
          add(ChatDeleteConversationEvent(roomId: event.room.id));
        } */

        print(event.message.id);
        print(idOfLastMessage);
        if (event.message.id == idOfLastMessage) {
          FirebaseChatCore.instance.updateLastMessage(
              message: state.messages[event.room.id]!.first,
              roomId: event.room.id);
        }
      } catch (e) {
        print("** updated last message error: $e");
      }
    } catch (e) {
      print("** delete message error: $e");
    }
  }

  FutureOr<void> _deleteConversation(
      ChatDeleteConversationEvent event, Emitter<ChatState> emit) async {
    try {
      if (!state.isOnline) {
        emit(state.copyWith(
            status: ChatStatus.deleteConversationError,
            error: "can't delete conversation, you are offline"));
        emit(state.copyWith(status: ChatStatus.initial));
        return;
      }

      // emit(state.copyWith(status: ChatStatus.deleteConversationInProgress));

      await _deleteRoomLocaly;
      await FirebaseChatCore.instance.deleteRoom(event.roomId);
      emit(state.copyWith(
        status: ChatStatus.deleteConversationInProgress,
      ));
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.deleteConversationError));
      print("** delete conversation error: $e");
    }
  }

  FutureOr<void> _leavedRoomEvent(
      ChatLeavedRoomEvent event, Emitter<ChatState> emit) async {
    try {
      // at room should be empty means user is not inside any room.
      emit(
        state.copyWith(
          activeRoomId: "",
          status: ChatStatus.initial,
        ),
      );
      if (!state.isOnline) return;

      // update the user online status to false in room where user is.
      FirebaseChatCore.instance
          .updateUserOnlineStatus(room: event.room, isOnline: false);
    } catch (e) {
      print("** leave chat room error: $e");
    }
  }

  FutureOr<void> _enteredRoomEvent(
      ChatEnteredRoomEvent event, Emitter<ChatState> emit) async {
    try {
      //
      emit(state.copyWith(activeRoomId: event.room.id));
      // initialize the room that user entered
      add(ChatInitializeRoom(roomId: event.room.id));
      // update the local room timestamp to the latest room timestamp (tracking room timestamp to show new messages)
      MessageCounter.updateRoomTimeStamp(
          roomId: event.room.id, timeStamp: event.room.updatedAt.toString());

      if (!state.isOnline) return;
      // update user online status in that room
      FirebaseChatCore.instance
          .updateUserOnlineStatus(room: event.room, isOnline: true);
    } catch (e) {
      print("** enter chat room error: $e");
    }
  }

  void _updateInternetStatus(
      ChatUpdateInternetStatus event, Emitter<ChatState> emit) {
    //
    emit(state.copyWith(
        isOnline: event.isOnline, status: ChatStatus.connectonChanged));
  }

  void _handlePreviewDataFetched(
      ChatHandlePreviewedDataFetchEvent event, Emitter<ChatState> emit) {
    final updatedMessage =
        event.message.copyWith(previewData: event.previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, state.activeRoomId);
  }

  void _handleSendPressed(
      ChatHandleSendPressedEvent event, Emitter<ChatState> emit) async {
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(chatRoomError: "", status: ChatStatus.initial));

      emit(state.copyWith(
          status: ChatStatus.chatRoomError, chatRoomError: "You are offline."));
      return;
    }
    try {
      emit(state.copyWith(messageUploding: true));
      await FirebaseChatCore.instance.sendMessage(
        event.message,
        state.activeRoomId,
      );

      emit(state.copyWith(messageUploding: false));
      await pushNotification(
          event.user.firstName, event.message.text, event.user.notifToken);
    } catch (e) {
      emit(state.copyWith(
          status: ChatStatus.chatRoomError,
          messageUploding: false,
          chatRoomError: "could not send message."));
    }
  }

  void _handleMessageTap(
      ChatHandleMessageTapEvent event, Emitter<ChatState> emit) async {
    chat.Message message = event.message;
    if (message is chat.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http') && NetworkConnection.isConnected) {
        try {
          final updatedMessage = message.copyWith(isLoading: true);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            state.activeRoomId,
          );

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final updatedMessage = message.copyWith(isLoading: false);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            state.activeRoomId,
          );
          emit(state.copyWith(status: ChatStatus.loaded));
        }
      } else {
        emit(state.copyWith(
            status: ChatStatus.chatRoomError,
            chatRoomError: "You are offline, can't open files"));
      }

      await OpenFilex.open(localPath);
    }
  }

  FutureOr<void> _handleImageSelection(
      ChatHandleImageSelectionEvent event, Emitter<ChatState> emit) async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(chatRoomError: "", status: ChatStatus.initial));

      emit(state.copyWith(
          status: ChatStatus.chatRoomError,
          chatRoomError: "You are offline, can't send image."));
      return;
    }

    if (result != null) {
      emit(state.copyWith(attahcmentFileUploading: true));
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = chat.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          state.activeRoomId,
        );

        emit(state.copyWith(attahcmentFileUploading: false));
        await pushNotification(
            event.user.firstName, "#IMAGE", event.user.notifToken);
      } finally {
        emit(state.copyWith(attahcmentFileUploading: false));
      }
    }
  }

  FutureOr<void> _handleVideoSelection(
      ChatHandleVideoSelectionEvent event, Emitter<ChatState> emit) async {
    final result = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );

    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(chatRoomError: "", status: ChatStatus.initial));

      emit(state.copyWith(
          status: ChatStatus.chatRoomError,
          chatRoomError: "You are offline, can't send image."));
      return;
    }

    if (result != null) {
      try {
        emit(state.copyWith(attahcmentFileUploading: true));
        final file = File(result.path);
        final size = file.lengthSync();
        // final bytes = await result.readAsBytes();
        // final video = await decodeImageFromList(bytes);
        final name = result.name;

        print("uploading video");
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();
        emit(state.copyWith(attahcmentFileUploading: true));
        final videoMessage = chat.PartialVideo(
          name: name,
          size: size,
          //    height: video.height.toDouble(),
          // width: video.width.toDouble(),
          uri: uri,
        );

        await FirebaseChatCore.instance.sendMessage(
          videoMessage,
          state.activeRoomId,
        );
        emit(state.copyWith(attahcmentFileUploading: false));
      } finally {
        emit(state.copyWith(attahcmentFileUploading: false));
      }
    }
  }

  Future<void> pushNotification(
      String? title, String? body, String? token) async {
    try {
      await callOnFcmApiSendPushNotifications(token!, title!, body!);
      print(title);
      print("notification was pushed !!");
    } catch (e) {
      print("could not push notification!!!!!!! $e");
    }
  }

  FutureOr<void> _handleFileSelection(
      ChatHandleFileSelectionEvent event, Emitter<ChatState> emit) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(chatRoomError: "", status: ChatStatus.initial));
      emit(state.copyWith(
          status: ChatStatus.chatRoomError,
          chatRoomError: "You are offline, can't Send File."));
      return;
    }

    if (result != null && result.files.single.path != null) {
      emit(state.copyWith(attahcmentFileUploading: true));
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = chat.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, state.activeRoomId);

        emit(state.copyWith(attahcmentFileUploading: false));
        await pushNotification(
            event.user.firstName, "#FILE", event.user.notifToken);
      } finally {
        emit(state.copyWith(attahcmentFileUploading: false));
      }
    }
  }

  FutureOr<void> _getRoom(
      ChatInitializeRoom event, Emitter<ChatState> emit) async {
    try {
      chat.Room room = chat.Room(id: "", type: chat.RoomType.direct, users: []);

      room = state.rooms.firstWhere((room) => room.id == event.roomId);

      emit(state.copyWith(
          status: ChatStatus.loadedSingleRoom, activeRoom: room));

      /*  if (NetworkConnection.isConnected) {
        _roomStream = await FirebaseChatCore.instance.room(event.roomId);

        await emit.forEach(
          _roomStream,
          onData: (room) {
            return state.copyWith(
                room: room, status: ChatStatus.loadedSingleRoom);
          },
        );
      } */
    } catch (e) {
      print("** initialize room error: $e");
    }
  }

  FutureOr<void> _searchBarEdited(
      ChatSearchBarEditEvent event, Emitter<ChatState> emit) async {
    emit(state.copyWith(
      searchBarText: event.searchBarText,
      status: ChatStatus.searchBarEdit,
    ));
  }

  FutureOr<void> _initializeChatUsers(
      ChatInitializeChatUsers event, Emitter<ChatState> emit) async {
    emit(state.copyWith(status: ChatStatus.initial));

    if (!NetworkConnection.isConnected) {
      return;
    }
    try {
      _users = await FirebaseChatCore.instance.users();
      await emit.forEach(_users, onData: (listOfUsrs) {
        return state.copyWith(
            status: ChatStatus.loadedChatUsers, users: listOfUsrs);
      });
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error));
      print("** initialize chat users error: $e");
    }
  }

  FutureOr<void> _initializeChatMessages(
      ChatInitializeChatMessagesEvent event, Emitter<ChatState> emit) async {
    try {
      print("*** initializing chat Messages for room ${event.room.id} ***");
      Map<String, List<chat.Message>> allMessages = state.messages;

      if (NetworkConnection.isConnected) {
        emit(state.copyWith(
          status: ChatStatus.loadingAllMessagesOfOneRoomInProgress,
        ));
        _messagesStream = await FirebaseChatCore.instance.messages(event.room);
        await emit.forEach(
          _messagesStream,
          onData: (messages) {
            allMessages.addIf(true, event.room.id, messages);
            _copyOneRoomMessagesLocaly(
                messages: messages, roomID: event.room.id);

            return state.copyWith(
                status: ChatStatus.loadedAllMessagesOfOneRoom,
                messages: allMessages);
          },
        );
      }
      List<chat.Message> messages = [];

      List<Object?>? listOfMessageObjects =
          await LocalMemory.readDynamic(key: event.room.id);
      if (listOfMessageObjects != null)
        listOfMessageObjects.forEach((message) {
          messages.add(chat.Message.fromJson(message as Map<String, dynamic>));
        });

      allMessages.addIf(true, event.room.id, messages);

      emit(state.copyWith(
          status: ChatStatus.offlineMessagesLoaded, messages: allMessages));
    } catch (e) {
      print("** get all messages of a room (${event.room.id}) error : $e");
    }
  }

  FutureOr<void> _initializeChatRooms(
      ChatInitializeChatRooms event, Emitter<ChatState> emit) async {
    print("Initializing All Chat Rooms");

    try {
      if (NetworkConnection.isConnected) {
        _roomsStream =
            await FirebaseChatCore.instance.rooms(orderByUpdatedAt: true);
        await emit.forEach(
          _roomsStream,
          onData: (listOfRooms) {
            // store a local copy of the rooms
            _copyRoomsLocaly(listOfRooms: listOfRooms);
            // update message new status counter
            _updateNewStatusCounter(listOfRooms: listOfRooms);
            // initializing chats for when someone creates a room whith this user.
            if (listOfRooms.length > state.rooms.length) {
              print(" updating rooms, rooms are added");
              final newRoom = getNewRoom(listOfRooms, state.rooms);
              if (newRoom != null) {
                add(ChatInitializeChatMessagesEvent(room: newRoom));
              }
            }

            try {
              listOfRooms.firstWhere((room) {
                if (room.id == state.activeRoomId) {
                  // setting the active room to where the user is.
                  emit(state.copyWith(
                      activeRoom: room, status: ChatStatus.updatedActiveRoom));
                }
                return false;
              });
            } catch (e) {}

            isRoomInitialized = true;

            return state.copyWith(
                status: ChatStatus.loadedChatRooms, rooms: listOfRooms);
          },
        );
      }
      List<chat.Room> rooms = [];
      List<Object?>? listOfRoomsObject =
          await LocalMemory.readDynamic(key: 'rooms');
      if (listOfRoomsObject != null)
        listOfRoomsObject.forEach((element) {
          rooms.add(chat.Room.fromJson(element as Map<String, dynamic>));
        });

      emit(state.copyWith(status: ChatStatus.offlineRoomsLoaded, rooms: rooms));
      isRoomInitialized = true;
    } catch (e) {
      emit(state.copyWith(status: ChatStatus.error));
      isRoomInitialized = true;

      print("** initialize rooms error: $e");
    }
  }

  FutureOr<void> _switchBetweenUsersAndRooms(
      ChatSwitchBetweenUsersAndRoomsEvent event,
      Emitter<ChatState> emit) async {
    emit(state.copyWith(
        showUsers: state.showUsers ? false : true, searchBarText: ""));
    if (state.showUsers) {
      add(ChatInitializeChatUsers());
    }
  }

  FutureOr<void> _createNewRoom(
      ChatNewRoomCreateEvent event, Emitter<ChatState> emit) async {
    try {
      if (!NetworkConnection.isConnected) {
        emit(state.copyWith(status: ChatStatus.offline));
        return;
      }
      emit(state.copyWith(status: ChatStatus.createNewRoomInProgress));

      final partialRoom =
          await FirebaseChatCore.instance.createRoom(event.joiningUser);

      final room =
          await FirebaseChatCore.instance.getRoom(roomId: partialRoom.id);
      add(ChatInitializeChatMessagesEvent(room: room));
      add(ChatEnteredRoomEvent(room: room));
      emit(state.copyWith(status: ChatStatus.createNewRoomDone));
      emit(state.copyWith(showUsers: false, status: ChatStatus.initial));
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      emit(state.copyWith(
          status: ChatStatus.createNewRoomError,
          error: "faild to create conversation"));
      print("** create room error: $e");
    }
  }

  void _copyRoomsLocaly({required List<chat.Room> listOfRooms}) {
    List<Map<String, dynamic>> roomsMap = listOfRooms.map((room) {
      return room.toJson();
    }).toList();
    LocalMemory.storeDynamic(key: 'rooms', value: roomsMap);
  }

  void _deleteRoomLocaly({required String roomId}) async {
    await LocalMemory.deleteRecord(key: roomId);
  }

  void _copyOneRoomMessagesLocaly(
      {required List<chat.Message> messages, required String roomID}) async {
    List<Map<String, dynamic>> messagesMap = messages.map((message) {
      return message.toJson();
    }).toList();
    //print(messagesMap);
    await LocalMemory.storeDynamic(key: roomID, value: messagesMap);
  }

  void _updateNewStatusCounter({required List<chat.Room> listOfRooms}) {
    // Map<dynamic, bool> newMessages = {};
    listOfRooms.forEach((room) {
      if (room.id == state.activeRoomId) {
        //   print("room should be labled new!");
        MessageCounter.updateRoomTimeStamp(
            timeStamp: room.updatedAt.toString(), roomId: state.activeRoomId);
      }
    });
    //  add(ChatInitializeNewMessages(newMessages: newMessages));
  }

  void dispose() async {
    intenertSubscription.cancel();
    _messagesStream = Stream.empty();
    _roomsStream = Stream.empty();
    _users = Stream.empty();
    /*     FirebaseChatCore.instance
        .updateUserOnlineStatus(room: state.room, isOnline: false); */
  }

  _initializeAllMessages() async {
    while (!isRoomInitialized) {
      print("## waitin on rooms ##");
      await Future.delayed(Duration(seconds: 1));
    }
    state.rooms.forEach(
      (room) {
        add(ChatInitializeChatMessagesEvent(room: room));
      },
    );
  }

  void _listenForInternetChanges() async {
    intenertSubscription = await internetCubit.stream.listen((state) async {
      try {
        add(ChatUpdateInternetStatus(isOnline: NetworkConnection.isConnected));
        // based on internet status changes start or stop listening to firebase
        if (!state.isConnected) {
          isRoomInitialized = false;
          _messagesStream = Stream.empty();
          _roomsStream = Stream.empty();
          _users = Stream.empty();
        }
        add(ChatInitializeChatRooms());
        _initializeAllMessages();
      } catch (e) {
        print("internet state error : $e");
      }
    });
  }

  /*  Future<String?> getImageThumbnail({required String url}) async {
    print(url);
    final uint8list = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight:
          64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );
    print(url);
    return uint8list;
  } */

  chat.Room? getNewRoom(List<chat.Room> newRooms, List<chat.Room> oldRooms) {
    chat.Room? newRoom = null;
    List<String> newRoomsId = [];
    List<String> oldRoomsId = [];
    newRooms.forEach((room) {
      newRoomsId.add(room.id);
    });
    oldRooms.forEach((room) {
      oldRoomsId.add(room.id);
    });
    newRoomsId.forEach((newRoomId) {
      if (!(oldRoomsId.contains(newRoomId))) {
        newRoom = newRooms.firstWhere((room) => room.id == newRoomId);
        return;
      }
    });

    return newRoom;
  }

  Future<bool> callOnFcmApiSendPushNotifications(
      String userToken, String title, String body) async {
    final uri = await Uri.parse('https://fcm.googleapis.com/fcm/send');
    /*    final data = {
      "registration_ids": userToken,
      "collapse_key": "type_a",
      "notification": {
        "title": title,
        "body": body,
      }
    }; */
    print("sent to token : $userToken");
    final data = {
      "to": "$userToken",
      "priority": "high",
      "notification": {
        "title": "$title",
        "body": "$body",
        "channel_id": "1",
        "sound": "default"
      }
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=Your_Key'
    };
    // 'key=YOUR_SERVER_KEY'

    final response = await http.post(uri,
        body: json.encode(data),
        encoding: Encoding.getByName('utf-8'),
        headers: headers);

    if (response.statusCode == 200) {
      // on success do sth
      print('test ok push CFM');
      return true;
    } else {
      print(' CFM error ${response.statusCode}');
      // on failure do sth
      return false;
    }
  }

  Future<void> deleteMedia({required String name}) async {
    try {
      // Create a reference to the file to delete
      Reference reference = FirebaseStorage.instance.ref().child('$name');

// Delete the file
      await reference.delete();
    } catch (e) {
      print("could not delete media $e");
    }
  }
}
