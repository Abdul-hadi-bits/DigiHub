import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi_hub/Business_Logic/Global_States/internetState.dart';

class InternetCubit extends Cubit<InternetState> {
  late StreamSubscription _connectivityStream;
  // create a constructor to initialize the internetSate too
  InternetCubit()
      : super(InternetState(
            connectivityType: ConnectivityResult.none, isConnected: false)) {
    print("******** internet cubit initalized *******");

    _connectivityStream =
        Connectivity().onConnectivityChanged.listen((connectivityResult) {
      _handleChange(connectivityResult);
      print(
          "------------------------------${connectivityResult.name}---------------------------------");
    });
  }
  _handleChange(ConnectivityResult connectivityResult) {
    connectivityResult == ConnectivityResult.wifi ||
            connectivityResult == ConnectivityResult.mobile
        ? connect(connectivityResult)
        : disconnect();
  }

  void connect(ConnectivityResult connectivityResult) {
    emit(
        InternetState(isConnected: true, connectivityType: connectivityResult));
  }

  void disconnect() {
    print(" internet disconnected");
    emit(InternetState(
        isConnected: false, connectivityType: ConnectivityResult.none));
  }

////always call this dispose when you close the app, or when ever you start not needing the connectivity stream!
  void dispose() {
    _connectivityStream.cancel();
  }
}
