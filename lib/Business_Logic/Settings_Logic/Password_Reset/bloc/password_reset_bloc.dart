import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:digi_hub/Business_Logic/Utility.dart';
import 'package:digi_hub/Data_Layer/Repositories/Firebase_Auth_Repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'password_reset_event.dart';
part 'password_reset_state.dart';

class PasswordResetBloc extends Bloc<PasswordResetEvent, PasswordResetState> {
  AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  PasswordResetBloc()
      : super(
          PasswordResetState(
              email: "",
              currentPassword: "",
              newPassword: "",
              confirmNewPassword: "",
              hideCurrentPassword: true,
              hideNewPassword: true,
              hideConfrimNewPassword: true,
              currentPasswordValid: false,
              newPasswordValid: false,
              confrimNewPasswordValid: false,
              newPasswordError: "",
              currentPasswordError: "",
              confirmNewPasswordError: "",
              dialogAlertText: "",
              error: "",
              status: PasswordResetStatus.initial),
        ) {
    //to initialize right away.

    on<PasswordResetInitialized>(_initialize);
    on<PasswordResetEdittedCurrentPasswordEvent>(_currentPasswordEdited);
    on<PasswordResetEdittedNewPasswordEvent>(_newPasswordEdited);
    on<PasswordResetEdittedConfirmNewPasswordEvent>(_confirmNewPasswordEdited);
    on<PasswordResetUsedEmailEvent>(_emailPasswordResetUsed);
    on<PasswordResetUpdatedEvent>(_passwordUpdated);
    on<PasswordResetEmailSentEvent>(_passwordResetEmailSent);
    on<PasswordResetTogglePasswords>(_togglePasswords);

    add(PasswordResetInitialized());
  }

  FutureOr<void> _initialize(
      PasswordResetInitialized event, Emitter<PasswordResetState> emit) async {
    print(_authenticationRepository.currentUser.email);
    emit(state.copyWith(email: _authenticationRepository.currentUser.email));
  }

  FutureOr<void> _togglePasswords(PasswordResetTogglePasswords event,
      Emitter<PasswordResetState> emit) async {
    if (event.currentPassword != null && event.currentPassword == true) {
      emit(state.copyWith(
          status: PasswordResetStatus.initial,
          hideCurrentPassword: state.hideCurrentPassword ? false : true));
      return;
    }
    if (event.newPassword != null && event.newPassword == true) {
      emit(state.copyWith(
          status: PasswordResetStatus.initial,
          hideNewPassword: state.hideNewPassword ? false : true));
      return;
    }
    if (event.confirmPassword != null && event.confirmPassword == true) {
      emit(state.copyWith(
          status: PasswordResetStatus.initial,
          hideConfrimNewPassword: state.hideConfrimNewPassword ? false : true));
      return;
    }
  }

  FutureOr<void> _currentPasswordEdited(
      PasswordResetEdittedCurrentPasswordEvent event,
      Emitter<PasswordResetState> emit) async {
    if (event.password.isEmpty) {
      emit(state.copyWith(
        currentPassword: event.password,
        currentPasswordValid: false,
        currentPasswordError: "",
        status: PasswordResetStatus.editingCurrentPassword,
      ));
      return;
    }
    String? error = FormzSubmission.validatePassword(password: event.password);
    if (error != null) {
      emit(state.copyWith(
        currentPassword: event.password,
        currentPasswordValid: false,
        currentPasswordError: error,
        status: PasswordResetStatus.editingCurrentPassword,
      ));
      return;
    }
    emit(state.copyWith(
      currentPassword: event.password,
      currentPasswordValid: true,
      currentPasswordError: "",
      status: PasswordResetStatus.editingCurrentPassword,
    ));
  }

  FutureOr<void> _newPasswordEdited(PasswordResetEdittedNewPasswordEvent event,
      Emitter<PasswordResetState> emit) async {
    if (event.newPassword.isEmpty) {
      emit(state.copyWith(
        newPassword: event.newPassword,
        newPasswordValid: false,
        newPasswordError: "",
        status: PasswordResetStatus.edittingNewPassword,
      ));
      return;
    }
    String? error =
        FormzSubmission.validatePassword(password: event.newPassword);
    if (error != null) {
      emit(state.copyWith(
        newPassword: event.newPassword,
        newPasswordValid: false,
        newPasswordError: error,
        status: PasswordResetStatus.edittingNewPassword,
      ));
      return;
    }
    emit(state.copyWith(
      newPassword: event.newPassword,
      newPasswordValid: true,
      newPasswordError: "",
      status: PasswordResetStatus.edittingNewPassword,
    ));
  }

  FutureOr<void> _confirmNewPasswordEdited(
      PasswordResetEdittedConfirmNewPasswordEvent event,
      Emitter<PasswordResetState> emit) async {
    if (event.confirmNewPassword.isEmpty) {
      emit(state.copyWith(
        confirmNewPassword: event.confirmNewPassword,
        confrimNewPasswordValid: false,
        confirmNewPasswordError: "",
        status: PasswordResetStatus.editingConfirmPassword,
      ));
      return;
    }
    String? error = FormzSubmission.validatePasswordConfirm(
        passwordConfirm: event.confirmNewPassword, password: state.newPassword);
    if (error != null) {
      emit(state.copyWith(
        confirmNewPassword: event.confirmNewPassword,
        confrimNewPasswordValid: false,
        confirmNewPasswordError: error,
        status: PasswordResetStatus.editingConfirmPassword,
      ));
      return;
    }
    emit(state.copyWith(
      confirmNewPassword: event.confirmNewPassword,
      confrimNewPasswordValid: true,
      confirmNewPasswordError: "",
      status: PasswordResetStatus.editingConfirmPassword,
    ));
  }

  FutureOr<void> _passwordResetEmailSent(PasswordResetEmailSentEvent event,
      Emitter<PasswordResetState> emit) async {
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(
          status: PasswordResetStatus.dialogError,
          dialogAlertText: "Please Check Your Connection"));
      return;
    }
    try {
      emit(state.copyWith(status: PasswordResetStatus.dialogInProgress));
      await _authenticationRepository.sendPasswordResetEmail(
          currentUserEmail: true, email: "");
      emit(state.copyWith(
          status: PasswordResetStatus.dialogSuccess,
          dialogAlertText: "Success"));
    } on FirebaseException catch (e) {
      emit(state.copyWith(
          status: PasswordResetStatus.dialogError, dialogAlertText: e.code));
    } catch (e) {
      emit(state.copyWith(
          status: PasswordResetStatus.dialogError,
          dialogAlertText: "UnSuccessful"));
    }
  }

  FutureOr<void> _emailPasswordResetUsed(PasswordResetUsedEmailEvent event,
      Emitter<PasswordResetState> emit) async {
    emit(state.copyWith(
      status: PasswordResetStatus.dialogInitial,
      dialogAlertText: "",
    ));
  }

  FutureOr<void> _passwordUpdated(
      PasswordResetUpdatedEvent event, Emitter<PasswordResetState> emit) async {
    if (!NetworkConnection.isConnected) {
      emit(state.copyWith(
          status: PasswordResetStatus.error,
          error: "Please Check Your Connection"));
      return;
    }
    if (!state.currentPasswordValid ||
        !state.confrimNewPasswordValid ||
        !state.newPasswordValid) {
      emit(state.copyWith(
          status: PasswordResetStatus.error,
          error: "Please Fill Out Correctly"));
      return;
    }
    try {
      // step one sign in
      emit(state.copyWith(status: PasswordResetStatus.inProgress));

      await _authenticationRepository.logInWithEmailAndPassword(
          currentUserEmail: true, password: state.currentPassword, email: "");

      // step two reset passowrd

      await _authenticationRepository.updateUserPassword(
          newPassword: state.newPassword);

      emit(state.copyWith(status: PasswordResetStatus.success));
      await _authenticationRepository.logOut();
    } on FirebaseAuthException catch (e) {
      emit(state.copyWith(status: PasswordResetStatus.error, error: e.code));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(state.copyWith(status: PasswordResetStatus.error, error: e.message));
    } catch (e) {
      emit(state.copyWith(
          status: PasswordResetStatus.error,
          error: "Could not update password"));
    }
  }
}
