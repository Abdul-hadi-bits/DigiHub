import 'dart:async';
import 'package:digi_hub/Business_Logic/Utility.dart';
import 'package:digi_hub/Data_Layer/Repositories/Firebase_Auth_Repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/emailSignInState.dart';
import 'package:digi_hub/Business_Logic/Global_States/internetCubit.dart';

class EmailSignInCubit extends Cubit<EmailSignInState> {
  AuthenticationRepository _authenticationRepository =
      AuthenticationRepository(firebaseAuth: FirebaseAuth.instance);

  EmailSignInCubit({required InternetCubit internetCubit})
      : super(
          EmailSignInState(
              hidePassword: true,
              emailError: "",
              signInError: "",
              passwordResetAlert: "",
              email: "",
              isEmailValid: false,
              isPasswordValid: false,
              password: "",
              passwordError: "",
              status: EmailSignInStatus.initialState),
        ) {
    print("email cubit is initilized****************************************");
  }

  void toggleObsecurePassword() {
    emit(state.copyWith(
        hidePassword: state.hidePassword == true ? false : true,
        status: EmailSignInStatus.initialState));
  }

  void emailChanged({required String email}) {
    final isEmailValid =
        FormzSubmission.validateEmail(email: email) == null ? true : false;
    if (!isEmailValid) {
      emit(state.copyWith(
          email: email,
          isEmailValid: false,
          emailError: FormzSubmission.validateEmail(email: email),
          status: EmailSignInStatus.initialState));
      return;
    }
    emit(state.copyWith(
        email: email,
        isEmailValid: true,
        status: EmailSignInStatus.initialState));
  }

  void passwordChanged({required String password}) {
    final isPasswordValid =
        FormzSubmission.validatePassword(password: password) == null
            ? true
            : false;
    if (!isPasswordValid) {
      emit(state.copyWith(
        password: password,
        isPasswordValid: false,
        passwordError: FormzSubmission.validatePassword(password: password),
        status: EmailSignInStatus.initialState,
      ));
      return;
    }
    emit(state.copyWith(
      password: password,
      isPasswordValid: true,
      passwordError: "",
      status: EmailSignInStatus.initialState,
    ));
  }

  void popUpDialogClosed() {
    emit(state.copyWith(
        status: EmailSignInStatus.initialState, passwordResetAlert: ""));
  }

  Future signIN() async {
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(
          signInError: "No Connection", status: EmailSignInStatus.errorState));

      return;
    }
    if (!state.isEmailValid || !state.isPasswordValid) {
      emit(state.copyWith(
          signInError: "Pasword Or Email is not valid",
          status: EmailSignInStatus.errorState));
      return;
    }

    try {
      emit(state.copyWith(status: EmailSignInStatus.progressState));

      await _authenticationRepository.logInWithEmailAndPassword(
          email: state.email, password: state.password);

      emit(state.copyWith(status: EmailSignInStatus.successfulState));
      await _authenticationRepository.updateUserDataInFirestore(
          data: {"notifToken": await _getTokenForNotification()});
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(
          signInError: e.message, status: EmailSignInStatus.errorState));
    } catch (e) {
      emit(state.copyWith(status: EmailSignInStatus.errorState));
    }
  }

  Future<String> _getTokenForNotification() async {
    final _fireabseMessageing = FirebaseMessaging.instance;
    await _fireabseMessageing.requestPermission();
    final fCMToken = await _fireabseMessageing.getToken();
    print("Token is : $fCMToken");

    return fCMToken ?? "";
  }

  Future sendPassResetEmail() async {
    bool isEmailValid =
        FormzSubmission.validateEmail(email: state.email) == null
            ? true
            : false;

    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(
          passwordResetAlert: "No Connection",
          status: EmailSignInStatus.emailPasswordResetErrorState));
    }

    if (!isEmailValid) {
      emit(state.copyWith(
          passwordResetAlert: "Invalid Email",
          status: EmailSignInStatus.emailPasswordResetErrorState));
      return;
    }

    try {
      await _authenticationRepository.sendPasswordResetEmail(
          email: state.email);
      emit(state.copyWith(
          status: EmailSignInStatus.emailPasswordResetSuccessState,
          passwordResetAlert: "Email Sent to ${state.email} Please Check"));
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(
          passwordResetAlert: e.code,
          status: EmailSignInStatus.emailPasswordResetErrorState));
    } on PasswordResetEmailFailure catch (e) {
      emit(state.copyWith(
          passwordResetAlert: e.message,
          status: EmailSignInStatus.emailPasswordResetErrorState));
    }
  }
}
