import 'dart:async';

import 'package:digi_hub/Business_Logic/Auth_Logic/Registeration/Cubit/LinkPhoneNumberState.dart';
import 'package:digi_hub/Business_Logic/Utility.dart';
import 'package:digi_hub/Data_Layer/Repositories/Firebase_Auth_Repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class LinkPhoneCubit extends Cubit<LinkPhoneState> {
  AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();
  Timer _timer = Timer(Duration(seconds: 0), () {});
  LinkPhoneCubit()
      : super(LinkPhoneState(
          verificationAlert: "",
          counter: 60,
          codeTimedOut: false,
          loginError: "",
          inputFieldError: "",
          verificationID: "",
          phoneNumberField: "",
          isPhoneValid: false,
          smsCodeField: "",
          status: LinkPhoneStatus.initialState,
        )) {
    print(
        "phone sign cubit is initialized!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
  }

  void phoneChanded({required String phone}) {
    if (phone.isEmpty) {
      emit(state.copyWith(
          status: LinkPhoneStatus.initialState,
          phoneNumberField: phone,
          inputFieldError: "",
          isPhoneValid: false));
      return;
    }
    if (phone.length < 10) {
      emit(state.copyWith(
        status: LinkPhoneStatus.initialState,
        phoneNumberField: phone,
        isPhoneValid: false,
        inputFieldError: "Invalid Number",
      ));
      return;
    }
    emit(state.copyWith(
        status: LinkPhoneStatus.initialState,
        phoneNumberField: phone,
        isPhoneValid: true,
        inputFieldError: ""));
  }

  void codeChanged({required String code}) {
    emit(state.copyWith(
      smsCodeField: code,
      status: LinkPhoneStatus.codeVerifyInitial,
      verficationAlert: "",
    ));
  }

  Future<void> liknWithPhoneNumber() async {
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(
          status: LinkPhoneStatus.codeVerifyError,
          loginError: "No Connection"));
      return;
    }

    try {
      emit(state.copyWith(status: LinkPhoneStatus.inProgressState));
      await _authenticationRepository.linkWithPhoneNumber(
          enteredCode: state.smsCodeField, sentCode: state.verificationID);
      emit(state.copyWith(status: LinkPhoneStatus.codeVerifySuccess));
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: LinkPhoneStatus.codeVerifyError, verficationAlert: e.code));
    } catch (e) {
      emit(state.copyWith(
          status: LinkPhoneStatus.codeVerifyError,
          verficationAlert: "Linking has failed"));
    }
  }

  Future<void> sendOTPverificationCode({required bool isResnd}) async {
    // phone page
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(
          status: LinkPhoneStatus.errorState, loginError: "No Connection"));
      return;
    }
    if (!state.isPhoneValid) {
      emit(state.copyWith(
          status: LinkPhoneStatus.errorState,
          loginError: "Invalid Phone Number"));
      return;
    }
    if (_timer.isActive) {
      emit(state.copyWith(status: LinkPhoneStatus.inProgressState));
      await Future.delayed(Duration(seconds: 1));
      emit(state.copyWith(
          status: LinkPhoneStatus.errorState,
          loginError:
              "You have to wait '${state.counter}' Seconds, before next SMScode"));
      return;
    }

    try {
      emit(state.copyWith(status: LinkPhoneStatus.inProgressState));

      await auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+964${state.phoneNumberField}',
        verificationCompleted: (auth.PhoneAuthCredential credential) {},
        verificationFailed: (auth.FirebaseAuthException e) async {
          emit(state.copyWith(
              status: LinkPhoneStatus.errorState, loginError: e.code));
        },
        codeSent: (String verificationId, int? resendToken) async {
          _startTimer();
          emit(state.copyWith(
              status: isResnd
                  ? LinkPhoneStatus.codeVerifyInitial
                  : LinkPhoneStatus.codeSentSuccessState,
              verificationID: verificationId,
              codeTimedOut: false,
              smsCodeField: "",
              verficationAlert: ""));
          emit(state.copyWith(
              status: LinkPhoneStatus.codeVerifyInitial,
              verificationID: verificationId,
              codeTimedOut: false,
              verficationAlert: ""));
        },
        codeAutoRetrievalTimeout: (String verificationId) async {},
        timeout: const Duration(minutes: 1),
      );
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: LinkPhoneStatus.errorState, loginError: e.code));
    } catch (e) {
      emit(state.copyWith(
          status: LinkPhoneStatus.errorState,
          loginError: "Could Not Sent Code"));
    }
  }

  void _startTimer() {
    emit(state.copyWith(counter: 60, codeTimedOut: false));

    _timer = Timer.periodic(const Duration(seconds: 1), (time) {
      emit(state.copyWith(
          counter: state.counter - 1,
          status: LinkPhoneStatus.codeVerifyInitial));
      if (state.counter == 0 || state.codeTimedOut) {
        time.cancel();
        stopTimer();
        emit(state.copyWith(
            codeTimedOut: true,
            status: LinkPhoneStatus.codeVerifyTimedOutState,
            verficationAlert: "SMScode has expired"));
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

void dispose() async {}
