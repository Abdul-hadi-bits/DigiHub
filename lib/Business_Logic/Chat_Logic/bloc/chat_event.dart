part of 'chat_bloc.dart';

sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class ChatNewRoomCreateEvent extends ChatEvent {
  final chat.User joiningUser;

  ChatNewRoomCreateEvent({required this.joiningUser});
}

class ChatSwitchBetweenUsersAndRoomsEvent extends ChatEvent {}

class ChatInitializeChatUsers extends ChatEvent {
  //final List<chat.User> users;

  ChatInitializeChatUsers();
}

class ChatDeleteConversationEvent extends ChatEvent {
  final String roomId;

  ChatDeleteConversationEvent({required this.roomId});
}

class ChatInitializeChatRooms extends ChatEvent {
  // final List<chat.Room> rooms;

  ChatInitializeChatRooms();
}

class ChatInitializeChatMessagesEvent extends ChatEvent {
  final chat.Room room;

  ChatInitializeChatMessagesEvent({required this.room});
}

class ChatUpdateNewMesssageStatus extends ChatEvent {
  final String roomId;
  final int timeStamp;

  ChatUpdateNewMesssageStatus({required this.roomId, required this.timeStamp});
}

class ChatInitializeRoom extends ChatEvent {
  final String roomId;

  ChatInitializeRoom({required this.roomId});
}

class ChatSearchBarEditEvent extends ChatEvent {
  final String searchBarText;

  ChatSearchBarEditEvent({required this.searchBarText});
}

class ChatHandleFileSelectionEvent extends ChatEvent {
  final chat.User user;

  ChatHandleFileSelectionEvent({required this.user});
}

class ChatHandleImageSelectionEvent extends ChatEvent {
  final chat.User user;

  ChatHandleImageSelectionEvent({required this.user});
}

class ChatHandleVideoSelectionEvent extends ChatEvent {}

class ChatHandleMessageTapEvent extends ChatEvent {
  final chat.Message message;
  final BuildContext? context;

  ChatHandleMessageTapEvent({this.context, required this.message});
}

class ChatHandleSendPressedEvent extends ChatEvent {
  final chat.PartialText message;
  final chat.User user;

  ChatHandleSendPressedEvent({required this.message, required this.user});
}

class ChatHandlePreviewedDataFetchEvent extends ChatEvent {
  final chat.TextMessage message;
  final chat.PreviewData previewData;

  ChatHandlePreviewedDataFetchEvent(
      {required this.message, required this.previewData});
}

class ChatHandleAttachmentPressedEvent extends ChatEvent {}

class ChatUpdateInternetStatus extends ChatEvent {
  final bool isOnline;

  ChatUpdateInternetStatus({required this.isOnline});
}

class ChatEnteredRoomEvent extends ChatEvent {
  final chat.Room room;

  ChatEnteredRoomEvent({required this.room});
}

class ChatLeavedRoomEvent extends ChatEvent {
  final chat.Room room;

  ChatLeavedRoomEvent({required this.room});
}

class ChatDeleteMessageEvent extends ChatEvent {
  final chat.Room room;
  final chat.Message message;

  ChatDeleteMessageEvent({required this.room, required this.message});
}

class ChatUpdateMessageEvent extends ChatEvent {
  final chat.PartialText message;
  final String messageId;

  ChatUpdateMessageEvent({required this.message, required this.messageId});
}

class ChatToggleMessageEditing extends ChatEvent {
  final bool isClose;

  ChatToggleMessageEditing({required this.isClose});
}

class ChatDeleteAllUserChatData extends ChatEvent {}
