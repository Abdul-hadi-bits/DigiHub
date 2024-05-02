import 'package:digi_hub/Data_Layer/Module/Cache_Memory_Module.dart';

class MessageCounter {
  // static late SharedPreferences prefMemory;

  static void updateRoomNewMessageStatus(
      {required bool isNewMessage, required String roomId}) async {
    await CacheMemory.cacheMemory
        .setBool(roomId, isNewMessage)
        .whenComplete(() => print("time NewStatus added to memory "));

    //MessageCounter(roomId: roomId);
  }

  static void updateRoomTimeStamp(
      {required String timeStamp, required String roomId}) async {
    try {
      await CacheMemory.cacheMemory
          .setString(roomId, timeStamp)
          .whenComplete(() => print("time timeStamp updated memory "));
    } catch (e) {
      print("inside update room time stamp" + e.toString());
    }

    //MessageCounter(roomId: roomId);
  }

  static bool checkNewMessages(
      {required String roomId, required String roomTimeStamp}) {
    try {
/*       print(
          "tims stamps are: ${CacheMemory.cacheMemory.getString(roomId)}  and  ${roomTimeStamp}"); */
      return (CacheMemory.cacheMemory.getString(roomId) == roomTimeStamp)
          ? false
          : true;
    } catch (e) {
      print(" room don't exist new message counter $e");
      return false;
    }
  }
}
