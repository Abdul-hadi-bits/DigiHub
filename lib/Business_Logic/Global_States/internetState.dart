// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:connectivity_plus/connectivity_plus.dart';

class InternetState {
  late bool isConnected;
  late ConnectivityResult connectivityType;
  InternetState({
    required this.isConnected,
    required this.connectivityType,
  });
}
