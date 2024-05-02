part of 'chat_bloc.dart';

enum ChatStatus {
  initial,
  loaded,
  loadedChatUsers,
  loadedChatRooms,
  loadedSingleRoom,
  updatedActiveRoom,
  loadingSingleRoomInProgress,
  createNewRoomInProgress,
  createNewRoomDone,
  createNewRoomError,
  deleteConversationInProgress,
  deleteConversationDone,
  deleteConversationError,
  loadedNewMessageStatus,
  updatedNewMessageStatus,
  loadedAllMessagesOfOneRoom,
  loadingAllMessagesOfOneRoomInProgress,
  connectonChanged,
  error,
  offline,
  offlineRoomsLoaded,
  offlineMessagesLoaded,
  messageDeleted,
  offlineLoaded,
  chatRoomError,
  inProgress,
  roomCreated,
  searchBarEdit,
  messageUpdateInProgress,
  messageUpdateDone,
  deletingUserDataDone,
}

class ChatState extends Equatable {
  ChatState({
    required this.isMessageEditing,
    required this.isOnline,
    required this.attachmentFileUploading,
    required this.chatRoomError,
    required this.activeRoom,
    required this.activeRoomId,
    required this.myUserId,
    required this.showUsers,
    required this.searchBarText,
    required this.users,
    required this.messages,
    required this.rooms,
    required this.status,
    required this.messageUploading,
    required this.error,
    required this.thumbnail,
  });

  final String error;
  final bool isOnline;
  final bool isMessageEditing;

  final bool messageUploading;

  final String myUserId;

  final ChatStatus status;
  final bool showUsers;
  final String searchBarText;
  final Map<String, dynamic> thumbnail;

  final List<chat.Room> rooms;
  final List<chat.User> users;
  final Map<String, List<chat.Message>> messages;
  // The room where the user is currently in or was.
  final chat.Room activeRoom;
  final String activeRoomId;

  final bool attachmentFileUploading;
  final String chatRoomError;
  @override
  List<Object> get props => [
        thumbnail,
        error,
        isOnline,
        chatRoomError,
        status,
        showUsers,
        searchBarText,
        rooms,
        users,
        myUserId,
        activeRoom,
        activeRoomId,
        messages,
        attachmentFileUploading,
        messageUploading,
        isMessageEditing,
      ];

  ChatState copyWith({
    bool? isMessageEditing,
    Map<String, dynamic>? thumbnail,
    String? error,
    bool? messageUploding,
    bool? isOnline,
    Map<String, List<chat.Message>>? messages,
    String? chatRoomError,
    bool? attahcmentFileUploading,
    String? myUserId,
    ChatStatus? status,
    bool? showUsers,
    String? searchBarText,
    List<chat.User>? users,
    List<chat.Room>? rooms,
    chat.Room? activeRoom,
    String? activeRoomId,
  }) {
    return ChatState(
      isMessageEditing: isMessageEditing ?? this.isMessageEditing,
      thumbnail: thumbnail ?? this.thumbnail,
      error: error ?? this.error,
      messageUploading: messageUploding ?? this.messageUploading,
      isOnline: isOnline ?? this.isOnline,
      chatRoomError: chatRoomError ?? this.chatRoomError,
      attachmentFileUploading:
          attahcmentFileUploading ?? this.attachmentFileUploading,
      activeRoom: activeRoom ?? this.activeRoom,
      activeRoomId: activeRoomId ?? this.activeRoomId,
      messages: messages ?? this.messages,
      myUserId: myUserId ?? this.myUserId,
      rooms: rooms ?? this.rooms,
      status: status ?? this.status,
      showUsers: showUsers ?? this.showUsers,
      searchBarText: searchBarText ?? this.searchBarText,
      users: users ?? this.users,
    );
  }
}
