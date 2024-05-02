import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:digi_hub/Business_Logic/Chat_Logic/bloc/chat_bloc.dart';
import 'package:digi_hub/Data_Layer/Module/Cache_Memory_Module.dart';
import 'package:digi_hub/Data_Layer/Repositories/Firebase_Auth_Repository.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

part 'delete_acount_event.dart';
part 'delete_acount_state.dart';

class DeleteAcountBloc extends Bloc<DeleteAcountEvent, DeleteAcountState> {
  DeleteAcountBloc()
      : super(DeleteAcountInitial(
            isPasswordValid: false,
            deleteAcountError: "",
            password: "",
            passwordError: "",
            hidePassword: true)) {
    on<AcountDeletedEvent>(_deleteAcount);
    on<PasswordChangedEvent>(_passwordChanged);
    on<TogglePasswordEvent>(_togglePassword);
  }
  AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();
  FutureOr<void> _passwordChanged(
      PasswordChangedEvent event, Emitter<DeleteAcountState> emit) async {
    if (event.password.isEmpty) {
      emit(DeleteAcountInitial(
          isPasswordValid: false,
          deleteAcountError: state.deleteAcountError,
          password: "",
          passwordError: "",
          hidePassword: state.hidePassword));
    }
    String? error = FormzSubmission.validatePassword(password: event.password);

    if (error != null) {
      emit(DeleteAcountEditState(
          isPasswordValid: false,
          deleteAcountError: state.deleteAcountError,
          password: event.password,
          passwordError: error,
          hidePassword: state.hidePassword));
      return;
    }
    emit(DeleteAcountEditState(
        isPasswordValid: true,
        deleteAcountError: state.deleteAcountError,
        password: event.password,
        hidePassword: state.hidePassword,
        passwordError: ""));
  }

  FutureOr<void> _deleteAcount(
      AcountDeletedEvent event, Emitter<DeleteAcountState> emit) async {
    if (!state.isPasswordValid) {
      emit(DeleteAcountFailed(
          isPasswordValid: state.isPasswordValid,
          deleteAcountError: "Invalid Password",
          password: state.password,
          passwordError: state.passwordError,
          hidePassword: state.hidePassword));
      return;
    }
    try {
      emit(DeleteAcountInProgress(
          isPasswordValid: state.isPasswordValid,
          deleteAcountError: state.deleteAcountError,
          password: state.password,
          passwordError: state.passwordError,
          hidePassword: state.hidePassword));
      await _authenticationRepository.reauthenticateUser(
          password: state.password);

      await CacheMemory.cacheMemory.clear();
      // delete user rooms
      final rooms = event.chatState.rooms;
      rooms.forEach((room) async {
        await FirebaseChatCore.instance.deleteRoom(room.id);
      });
      // delete user from firestore
      await _authenticationRepository.deleteUserDataFromFirebaseFirestore();
      emit(DeleteAcountSuccess(
          isPasswordValid: state.isPasswordValid,
          deleteAcountError: state.deleteAcountError,
          password: state.password,
          passwordError: state.passwordError,
          hidePassword: state.hidePassword));
      print("delteing is done");
    } on FirebaseAuthException catch (e) {
      emit(DeleteAcountFailed(
          isPasswordValid: state.isPasswordValid,
          deleteAcountError: e.code,
          password: state.password,
          passwordError: state.passwordError,
          hidePassword: state.hidePassword));
    } on FirebaseException catch (e) {
      emit(DeleteAcountFailed(
          isPasswordValid: state.isPasswordValid,
          deleteAcountError: e.code,
          password: state.password,
          passwordError: state.passwordError,
          hidePassword: state.hidePassword));
    } catch (e) {
      emit(DeleteAcountFailed(
          isPasswordValid: state.isPasswordValid,
          deleteAcountError: "Deleting Failed",
          password: state.password,
          passwordError: state.passwordError,
          hidePassword: state.hidePassword));
    }
  }

  FutureOr<void> _togglePassword(
      TogglePasswordEvent event, Emitter<DeleteAcountState> emit) async {
    emit(DeleteAcountEditState(
        isPasswordValid: state.isPasswordValid,
        deleteAcountError: state.deleteAcountError,
        password: state.password,
        passwordError: state.passwordError,
        hidePassword: state.hidePassword ? false : true));
  }
}
