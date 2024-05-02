import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:digi_hub/Business_Logic/Global_States/internetCubit.dart';

class NetworkConnection {
  static late ConnectivityResult networkType;
  static late bool isConnected;
  NetworkConnection({required InternetCubit internetCubit}) {
    networkType = internetCubit.state.connectivityType;
    isConnected = internetCubit.state.isConnected;
    internetCubit.stream.listen((connectivityResult) {
      isConnected = connectivityResult.isConnected;

      switch (connectivityResult.connectivityType) {
        case ConnectivityResult.wifi:
          networkType = ConnectivityResult.wifi;

          break;
        case ConnectivityResult.mobile:
          networkType = ConnectivityResult.mobile;

          break;
        case ConnectivityResult.none:
          networkType = ConnectivityResult.none;
          break;
        case ConnectivityResult.bluetooth:
          networkType = ConnectivityResult.bluetooth;

          break;
        case ConnectivityResult.ethernet:
          networkType = ConnectivityResult.ethernet;

          break;

        default:
          print("network connectivity result didn't match any case!!!!");
          break;
      }
    });
  }
}
