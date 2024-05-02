import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Registeration/Cubit/RegisterationState.dart';
import 'package:digi_hub/Business_Logic/Utility.dart';
import 'package:digi_hub/Data_Layer/Repositories/Firebase_Auth_Repository.dart';
import 'package:digi_hub/Utillity/firebaes_api.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class RegisterationCubit extends Cubit<RegisterationState> {
  AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  late Timer _timer;
  RegisterationCubit()
      : super(RegisterationState(
            isFormValid: false,
            isEmailValid: false,
            isPasswordValid: false,
            isConfirmPasswordValid: false,
            isNameValid: false,
            isLastNameValid: false,
            hidePassword: true,
            hidePasswordConfirm: true,
            status: RegisterationStatus.initialState,
            passwordError: "",
            nameError: "",
            lastNameError: "",
            emailError: "",
            passwordConfirmError: "",
            registerationError: "",
            firstNameFieldText: "",
            lastNameFieldText: "",
            passwordConfirmFieldText: "",
            passwordFieldText: "",
            emailAddressFieldText: "",
            verificationAlert: "",
            isVerified: false,
            counter: 120));

  void emailChanged({required String email}) {
    if (email.isEmpty) {
      emit(state.copyWith(
          emailAddressFieldText: email,
          status: RegisterationStatus.initialState,
          isEmailValid: false,
          emailError: ""));
      return;
    }

    String? error = FormzSubmission.validateEmail(email: email);

    if (error != null) {
      emit(state.copyWith(
          emailAddressFieldText: email,
          status: RegisterationStatus.editingState,
          isEmailValid: false,
          emailError: error));
      return;
    }

    emit(state.copyWith(
        emailAddressFieldText: email,
        status: RegisterationStatus.editingState,
        isEmailValid: true,
        emailError: ""));
  }

  void passwordChanged({required String password}) {
    if (password.isEmpty) {
      emit(state.copyWith(
          passwordFieldText: password,
          status: RegisterationStatus.initialState,
          isPasswordValid: false,
          passwordError: ""));
      return;
    }

    String? error = FormzSubmission.validatePassword(password: password);

    if (error != null) {
      emit(state.copyWith(
          passwordFieldText: password,
          status: RegisterationStatus.editingState,
          isPasswordValid: false,
          passwordError: error));

      return;
    }

    emit(state.copyWith(
        passwordFieldText: password,
        status: RegisterationStatus.editingState,
        isPasswordValid: true,
        passwordError: ""));
  }

  void passwordConfirmedChanged({required String passwordConfirmed}) {
    if (passwordConfirmed.isEmpty) {
      emit(state.copyWith(
          passwordConfirmFieldText: passwordConfirmed,
          status: RegisterationStatus.initialState,
          isPasswordConfirmValid: false,
          passwordConfirmError: ""));
      return;
    }

    String? error = FormzSubmission.validatePasswordConfirm(
        password: state.passwordFieldText, passwordConfirm: passwordConfirmed);

    if (error != null) {
      emit(state.copyWith(
          passwordConfirmFieldText: passwordConfirmed,
          status: RegisterationStatus.editingState,
          isPasswordConfirmValid: false,
          passwordConfirmError: error));
      return;
    }

    emit(state.copyWith(
        passwordConfirmFieldText: passwordConfirmed,
        status: RegisterationStatus.editingState,
        isPasswordConfirmValid: true,
        passwordConfirmError: ""));
  }

  void nameChanged({required String name}) {
    if (name.isEmpty) {
      emit(state.copyWith(
          firstNameFieldText: name,
          status: RegisterationStatus.initialState,
          isNameValid: false,
          emailError: ""));
      return;
    }

    String? error = FormzSubmission.validateNames(name: name);

    if (error != null) {
      emit(state.copyWith(
          firstNameFieldText: name,
          status: RegisterationStatus.editingState,
          isNameValid: false,
          nameError: error));
      return;
    }

    emit(state.copyWith(
        firstNameFieldText: name,
        status: RegisterationStatus.editingState,
        isNameValid: true,
        nameError: ""));
  }

  void lastNameChanged({required String lastName}) {
    if (lastName.isEmpty) {
      emit(state.copyWith(
          lastNameFieldText: lastName,
          status: RegisterationStatus.initialState,
          isLastNameValid: false,
          lastNameError: ""));
      return;
    }

    String? error = FormzSubmission.validateNames(name: lastName);

    if (error != null) {
      emit(state.copyWith(
          lastNameFieldText: lastName,
          status: RegisterationStatus.editingState,
          isLastNameValid: false,
          lastNameError: error));
      return;
    }

    emit(state.copyWith(
        lastNameFieldText: lastName,
        status: RegisterationStatus.editingState,
        isLastNameValid: true,
        lastNameError: ""));
  }

  bool _isFormValid() {
    if (state.isEmailValid &&
        state.isPasswordValid &&
        state.isConfirmPasswordValid &&
        state.isNameValid &&
        state.isLastNameValid) return true;

    return false;
  }

  void togglePassword() {
    emit(state.copyWith(hidePassword: state.hidePassword ? false : true));
  }

  void togleConfirmPassword() {
    emit(state.copyWith(
        hideConfirmPassword: state.hidePasswordConfirm ? false : true));
  }

  Future<void> registerUsingEmail() async {
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(
          status: RegisterationStatus.errorState,
          registerationError: "Please Check Your Connection"));
      return;
    }
    if (!_isFormValid()) {
      emit(state.copyWith(
          status: RegisterationStatus.errorState,
          registerationError: "Please Fill Out the Form Correctly"));
      return;
    }
    try {
      emit(state.copyWith(status: RegisterationStatus.inProgressSate));
      await _authenticationRepository.signUpWithEmailAndPassword(
          email: state.emailAddressFieldText,
          password: state.passwordFieldText);
      await sendVertificationEmail();
    } on SignUpWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(
          status: RegisterationStatus.errorState,
          registerationError: e.message));
    } catch (e) {
      emit(state.copyWith(
          status: RegisterationStatus.errorState,
          registerationError: "Unable To Sign UP"));
    }
  }

  Future<void> sendVertificationEmail() async {
    try {
      await _authenticationRepository.sendEmailVerification();
      emit(state.copyWith(
        status: RegisterationStatus.emailSentSuccessfulState,
      ));
      emit(state.copyWith(
          status: RegisterationStatus.verifyInitialState,
          verificationAlert: "Please Verify",
          counter: 120));
      _verificationListener();
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: RegisterationStatus.emailSentFailedState,
          registerationError: e.code));
    } catch (e) {
      emit(state.copyWith(
          status: RegisterationStatus.emailSentFailedState,
          registerationError: "Could Not Send Verification Email"));
    }
  }

  Future<void> resendVertificationEmail() async {
    try {
      emit(state.copyWith(
        status: RegisterationStatus.emailReSendInProgress,
      ));
      await _authenticationRepository.sendEmailVerification();
      emit(state.copyWith(
        status: RegisterationStatus.emailReSentSuccessfulState,
      ));
      emit(state.copyWith(
          status: RegisterationStatus.verifyInitialState,
          verificationAlert: "Please Verify",
          counter: 120));
      _verificationListener();
    } on auth.FirebaseAuthException catch (e) {
      emit(state.copyWith(
          status: RegisterationStatus.emailSentFailedState,
          registerationError: e.code));
    } catch (e) {
      emit(state.copyWith(
          status: RegisterationStatus.emailSentFailedState,
          registerationError: "Could Not Send Verification Email"));
    }
  }

  void _verificationListener() {
    Future(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (state.counter == 0) {
          timer.cancel();
          emit(state.copyWith(
              status: RegisterationStatus.emailSentTimedOut,
              verificationAlert: "Verification has Expired, Please Resend"));
          return;
        }

        try {
          _authenticationRepository.checkUserVerification().then((value) async {
            if (value) {
              timer.cancel();
              await addUserData();
              emit(state.copyWith(
                  status: RegisterationStatus.verifySuccessState,
                  verificationAlert: "User Verified"));
            }
          });
        } on auth.FirebaseAuthException catch (e) {
          emit(state.copyWith(
              status: RegisterationStatus.verifyFailState,
              verificationAlert: e.code));
        } catch (e) {
          emit(state.copyWith(
              status: RegisterationStatus.verifyFailState,
              verificationAlert: "Verification Process Has Failed"));
        }
        emit(state.copyWith(counter: (state.counter - 1)));
      });
    });
  }

  Future<void> addUserData() async {
    try {
      // reinitalize notification config
      await FirebaseApi().initNotifications();

      await _authenticationRepository.addUserDataToFirbaseFirestore(
          name: state.firstNameFieldText,
          lastName: state.lastNameFieldText,
          notificationToken: await getTokenForNotification());
    } on FirebaseException {
      emit(state.copyWith(
          status: RegisterationStatus.errorState,
          registerationError: "Could Not Fully Register the User"));
    } catch (e) {
      emit(state.copyWith(
          status: RegisterationStatus.errorState,
          registerationError: "User Registeration Failed"));
    }
  }

  Future<String> getTokenForNotification() async {
    final _fireabseMessageing = FirebaseMessaging.instance;
    await _fireabseMessageing.requestPermission();
    final fCMToken = await _fireabseMessageing.getToken();
    print("Token is : $fCMToken");

    return fCMToken ?? "";
  }

  Future<void> canceldRegisteration() async {
    try {
      _authenticationRepository.deleteUserDataFromFirebaseFirestore();
      if (_timer.isActive) {
        _timer.cancel();
      }
    } on auth.FirebaseAuthException {
    } catch (e) {
      print(e);
    }
  }
}
