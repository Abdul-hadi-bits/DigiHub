import 'package:shared_preferences/shared_preferences.dart';

class CacheMemory {
  static late SharedPreferences cacheMemory;

  static void setCasheMemory(SharedPreferences sharedPreferences) {
    CacheMemory.cacheMemory = sharedPreferences;
  }
}
