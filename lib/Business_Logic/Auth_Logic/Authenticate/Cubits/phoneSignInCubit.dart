import 'dart:async';

import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/phoneSignInState.dart';
import 'package:digi_hub/Business_Logic/Utility.dart';
import 'package:digi_hub/Data_Layer/Repositories/Firebase_Auth_Repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class PhoneSignInCubit extends Cubit<PhoneSignInState> {
  Timer _timer = Timer(Duration(seconds: 0), () {});

  AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();
  PhoneSignInCubit()
      : super(PhoneSignInState(
          dialogAlert: "",
          codeTimedOut: false,
          loginError: "",
          inputFieldError: "",
          verificationID: "",
          phoneNumberField: "",
          isPhoneValid: false,
          smsCodeField: "",
          status: PhoneSignInStatus.initialState,
        )) {
    print(
        "phone sign cubit is initialized!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  }

  void phoneChanded({required String phone}) {
    if (phone.isEmpty) {
      emit(state.copyWith(
          status: PhoneSignInStatus.initialState,
          inputFieldError: "",
          phoneNumberField: phone,
          isPhoneValid: false));
      return;
    }
    if (phone.length < 10) {
      emit(state.copyWith(
          status: PhoneSignInStatus.initialState,
          phoneNumberField: phone,
          isPhoneValid: false,
          inputFieldError: "Invalid Number"));
      return;
    }
    emit(state.copyWith(
        status: PhoneSignInStatus.initialState,
        phoneNumberField: phone,
        isPhoneValid: true,
        inputFieldError: ""));
  }

  void codeChanged({required String code}) {
    emit(state.copyWith(
        smsCodeField: code, status: PhoneSignInStatus.initialState));
  }

  Future<String> _getTokenForNotification() async {
    final _fireabseMessageing = FirebaseMessaging.instance;
    await _fireabseMessageing.requestPermission();
    final fCMToken = await _fireabseMessageing.getToken();
    print("Token is : $fCMToken");

    return fCMToken ?? "";
  }

  Future<void> signInWithPhoneNumber() async {
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(
          status: PhoneSignInStatus.codeVerifyError,
          loginError: "No Connection"));
      return;
    }

    try {
      emit(state.copyWith(status: PhoneSignInStatus.inProgressState));
      await _authenticationRepository.loginWithPhoneNumber(
          enteredCode: state.smsCodeField, sentCode: state.verificationID);
      stopTimer();
      emit(state.copyWith(status: PhoneSignInStatus.codeVerifySuccess));
      await _authenticationRepository.updateUserDataInFirestore(
          data: {"notifToken": await _getTokenForNotification()});
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: PhoneSignInStatus.codeVerifyError, loginError: e.code));
    } catch (e) {
      emit(state.copyWith(
          status: PhoneSignInStatus.codeVerifyError,
          loginError: "Could Not Sign In"));
    }
  }

  Future<void> sendOTPverificationCode() async {
    // phone page
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(
          status: PhoneSignInStatus.errorState, loginError: "No Connection"));
      return;
    }
    if (!state.isPhoneValid) {
      emit(state.copyWith(
          status: PhoneSignInStatus.errorState,
          loginError: "Invalid Phone Number"));
      return;
    }

    try {
      emit(state.copyWith(status: PhoneSignInStatus.inProgressState));
      await auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+964${state.phoneNumberField}',
        verificationCompleted: (auth.PhoneAuthCredential credential) {},
        verificationFailed: (auth.FirebaseAuthException e) async {
          emit(state.copyWith(
              status: PhoneSignInStatus.errorState, loginError: e.code));
        },
        codeSent: (String verificationId, int? resendToken) async {
          _startTimer();
          emit(state.copyWith(
              status: PhoneSignInStatus.codeSentSuccessState,
              verificationID: verificationId,
              codeTimedOut: false,
              loginError: ""));
        },
        codeAutoRetrievalTimeout: (String verificationId) async {},
        timeout: const Duration(minutes: 1),
      );
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: PhoneSignInStatus.errorState, loginError: e.code));
    } catch (e) {
      emit(state.copyWith(
          status: PhoneSignInStatus.errorState,
          loginError: "Could Not Sent Code"));
    }
  }

  Future<void> linkOrUpdatePhoneNumber() async {
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(
          status: PhoneSignInStatus.codeVerifyError,
          loginError: "No Connection"));
      return;
    }

    try {
      emit(state.copyWith(status: PhoneSignInStatus.inProgressState));
      await _authenticationRepository.updateOrSetPhoneNumber(
          userCode: state.smsCodeField, verificationID: state.verificationID);
      stopTimer();
      emit(state.copyWith(status: PhoneSignInStatus.codeVerifySuccess));
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: PhoneSignInStatus.codeVerifyError, loginError: e.code));
    } catch (e) {
      emit(state.copyWith(
          status: PhoneSignInStatus.codeVerifyError,
          loginError: "Could Not Add The PhoneNumber"));
    }
  }

  Future<void> closingDialog() async {
    emit(state.copyWith(
        status: PhoneSignInStatus.initialState, dialogAlert: ""));
  }

  Future<void> unlinkPhoneNumber() async {
    try {
      emit(state.copyWith(
          status: PhoneSignInStatus.dialogInProgress, dialogAlert: ""));
      await _authenticationRepository.unlinkPhoneNumber();
      emit(state.copyWith(
          status: PhoneSignInStatus.dialogSuccess, dialogAlert: "Success"));
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: PhoneSignInStatus.dialogError, dialogAlert: e.code));
    } catch (e) {
      emit(state.copyWith(
          status: PhoneSignInStatus.dialogError, dialogAlert: "UnSuccessfull"));
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (time) {
      if (time.tick == 60) {
        time.cancel();
        stopTimer();
        emit(state.copyWith(
            status: PhoneSignInStatus.codeVerifyError,
            codeTimedOut: true,
            loginError: "SMSCode Has Timed Out, Please Try Again"));
        return;
      }
    });
  }

  void stopTimer() {
    try {
      if (_timer.isActive) {
        _timer.cancel();
      }
    } catch (e) {}
  }
}
