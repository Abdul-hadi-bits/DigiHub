import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:digi_hub/Business_Logic/Utility.dart';
import 'package:digi_hub/Data_Layer/Module/Cache_Memory_Module.dart';
import 'package:digi_hub/Data_Layer/Repositories/Firebase_Auth_Repository.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/registeration/userModule.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();
  ProfileBloc()
      : super(ProfileState(
            lastNameEdit: "",
            locationEdit: "",
            nameEdit: "",
            profileError: "",
            name: "",
            lastName: "",
            location: "",
            profileUrl: "",
            email: "",
            phone: "",
            isNameValid: false,
            isLastnameValid: false,
            isLocationValid: false,
            nameError: "",
            lastNameError: "",
            locationError: "",
            status: ProfileStatus.initial)) {
    on<ProfileLoadedEvent>(_loadProfile);
    on<ProfileNameUpdateEvent>(_updateName);
    on<ProfileLastNameUpdateEvent>(_updateLastName);
    on<ProfileLocationUpdateEvent>(_updateLocation);
    on<ProfileImageUpdateEvent>(_updateProfileImage);
    on<ProfileNameEditEvent>(_editName);
    on<ProfileLastNameEditEvent>(_editLastName);
    on<ProfileLocationEditEvent>(_editLocation);
    on<ProfileEnableEditingEvent>(_enableEditing);
  }

  FutureOr<void> _enableEditing(
      ProfileEnableEditingEvent event, Emitter<ProfileState> emit) async {
    if (event.editingName) {
      emit(state.copyWith(
          status: ProfileStatus.editingNameState,
          nameEdit: "",
          isNameValid: false));
      return;
    }
    if (event.editingLastName) {
      emit(state.copyWith(
          status: ProfileStatus.editingLastNameState,
          lastNameEdit: "",
          isLastnameValid: false));
      return;
    }
    if (event.editingLocation) {
      emit(state.copyWith(
          status: ProfileStatus.editingLocationState,
          locationEdit: "",
          isLocationValid: false));
    }
  }

  FutureOr<void> _editName(
      ProfileNameEditEvent event, Emitter<ProfileState> emit) async {
    print(event.name);
    if (event.name.isEmpty) {
      emit(state.copyWith(
          nameEdit: event.name,
          isNameValid: false,
          nameError: "",
          status: ProfileStatus.editingNameState));
      return;
    }
    if (event.name.length < 3) {
      emit(state.copyWith(
          nameEdit: event.name,
          isNameValid: false,
          nameError: "Too Short",
          status: ProfileStatus.editingNameState));
      return;
    }

    emit(state.copyWith(
        nameEdit: event.name,
        isNameValid: true,
        nameError: "",
        status: ProfileStatus.editingNameState));
    print(state.nameEdit);
  }

  FutureOr<void> _editLastName(
      ProfileLastNameEditEvent event, Emitter<ProfileState> emit) async {
    if (event.lastName.isEmpty) {
      emit(state.copyWith(
          lastNameEdit: event.lastName,
          isLastnameValid: false,
          lastNameError: "",
          status: ProfileStatus.editingLastNameState));
      return;
    }
    if (event.lastName.length < 3) {
      emit(state.copyWith(
          lastNameEdit: event.lastName,
          isLastnameValid: false,
          lastNameError: "Too Short",
          status: ProfileStatus.editingLastNameState));
      return;
    }
    emit(state.copyWith(
        lastNameEdit: event.lastName,
        isLastnameValid: true,
        lastNameError: "",
        status: ProfileStatus.editingLastNameState));
  }

  FutureOr<void> _editLocation(
      ProfileLocationEditEvent event, Emitter<ProfileState> emit) async {
    if (event.location.isEmpty) {
      emit(state.copyWith(
          locationEdit: event.location,
          isLocationValid: false,
          locationError: "",
          status: ProfileStatus.editingLocationState));
      return;
    }
    if (event.location.length < 3) {
      emit(state.copyWith(
          locationEdit: event.location,
          isLocationValid: false,
          locationError: "Too Short",
          status: ProfileStatus.editingLocationState));
      return;
    }
    emit(state.copyWith(
        locationEdit: event.location,
        isLocationValid: true,
        locationError: "",
        status: ProfileStatus.editingLocationState));
  }

  FutureOr<void> _updateProfileImage(
      ProfileImageUpdateEvent event, Emitter<ProfileState> emit) async {
    try {
      if (!NetworkConnection.isConnected) {
        emit(state.copyWith(
            profileError: "Check Your Connection",
            status: ProfileStatus.error));
        return;
      }
      emit(state.copyWith(
        status: ProfileStatus.updatingProfileImageInProgress,
      ));

      String url = await _setImage();
      await CacheMemory.cacheMemory.setString('imageUrl', url);

      emit(
          state.copyWith(status: ProfileStatus.updateSuccess, profileUrl: url));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, profileError: e.code));
    } catch (e) {
      emit(state.copyWith(
          profileError: "could not upload image", status: ProfileStatus.error));
    }
  }

  FutureOr<void> _updateLocation(
      ProfileLocationUpdateEvent event, Emitter<ProfileState> emit) async {
    try {
      if (!NetworkConnection.isConnected) {
        emit(state.copyWith(
            profileError: "Check Your Connection",
            status: ProfileStatus.error));
        return;
      }
      emit(state.copyWith(status: ProfileStatus.updatingLocationInProgress));
      await _authenticationRepository
          .updateUserDataInFirestore(data: {"location": event.locatoin});

      await CacheMemory.cacheMemory.setString('location', event.locatoin);
      emit(state.copyWith(
          status: ProfileStatus.updateSuccess, location: event.locatoin));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, profileError: e.code));
    } catch (e) {
      emit(state.copyWith(
          profileError: "could not update", status: ProfileStatus.error));
    }
  }

  FutureOr<void> _updateLastName(
      ProfileLastNameUpdateEvent event, Emitter<ProfileState> emit) async {
    try {
      if (!NetworkConnection.isConnected) {
        emit(state.copyWith(
            profileError: "Check Your Connection",
            status: ProfileStatus.error));
        return;
      }
      emit(state.copyWith(status: ProfileStatus.updatingLastNameInProgress));
      await _authenticationRepository
          .updateUserDataInFirestore(data: {"lastName": event.lastName});

      await CacheMemory.cacheMemory.setString('lastName', event.lastName);

      emit(state.copyWith(
          status: ProfileStatus.updateSuccess, lastName: event.lastName));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, profileError: e.code));
    } catch (e) {
      emit(state.copyWith(
          profileError: "could not update", status: ProfileStatus.error));
    }
  }

  FutureOr<void> _updateName(
      ProfileNameUpdateEvent event, Emitter<ProfileState> emit) async {
    print(event.name);
    try {
      if (!NetworkConnection.isConnected) {
        emit(state.copyWith(
            profileError: "Check Your Connection",
            status: ProfileStatus.error));
        return;
      }
      emit(state.copyWith(status: ProfileStatus.updatingNameInProgress));
      await _authenticationRepository
          .updateUserDataInFirestore(data: {"firstName": event.name});
      await CacheMemory.cacheMemory.setString('name', event.name);

      emit(state.copyWith(
          status: ProfileStatus.updateSuccess, name: event.name));
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, profileError: e.code));
    } catch (e) {
      emit(state.copyWith(
          profileError: "could not update", status: ProfileStatus.error));
    }
  }

  FutureOr<void> _loadProfile(
      ProfileLoadedEvent event, Emitter<ProfileState> emit) async {
    print("loaded event");
    try {
      User user = _authenticationRepository.currentUser;
      emit(state.copyWith(
          status: ProfileStatus.loaded,
          email: user.email ?? "",
          phone: user.phoneNumber ?? "Not Set",
          profileUrl: CacheMemory.cacheMemory.getString('imageUrl') ?? "",
          name: CacheMemory.cacheMemory.getString('name') ?? "",
          lastName: CacheMemory.cacheMemory.getString('lastName') ?? "",
          location:
              CacheMemory.cacheMemory.getString('location') ?? "Not Set"));

      if (NetworkConnection.isConnected && !event.loadLocal) {
        FireUser _fireUser = await _authenticationRepository.fetchUserData();
        print("user phone is ${user.phoneNumber}");
        emit(state.copyWith(
            status: ProfileStatus.loaded,
            email: user.email ?? "empty",
            phone: user.phoneNumber == null
                ? "Not Set"
                : user.phoneNumber!.isEmpty
                    ? "Not Set"
                    : user.phoneNumber,
            profileUrl: _fireUser.profilePicture ?? "empty",
            name: _fireUser.firstName ?? "empty",
            lastName: _fireUser.lastName ?? "empty",
            location: _fireUser.location ?? "Not Set"));

        //sync with cachMeomory

        CacheMemory.cacheMemory
            .setString('name', _fireUser.firstName ?? "Not Set");
        CacheMemory.cacheMemory
            .setString('lastName', _fireUser.lastName ?? "Not Set");

        CacheMemory.cacheMemory
            .setString('location', _fireUser.location ?? "Not Set");
        CacheMemory.cacheMemory
            .setString('imageUrl', _fireUser.profilePicture.toString());
        CacheMemory.cacheMemory.setString(
            'phone',
            user.phoneNumber == null
                ? "Not Set"
                : user.phoneNumber!.isEmpty
                    ? "Not Set"
                    : user.phoneNumber!);
        CacheMemory.cacheMemory.setString('email', user.email.toString());
      }
    } on FirebaseException catch (e) {
      emit(state.copyWith(status: ProfileStatus.error, profileError: e.code));
    } catch (e) {
      print(e);
      emit(state.copyWith(
          profileError: "could not load data", status: ProfileStatus.error));
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////
  Future<String> _setImage() async {
    final ImagePicker _picker = ImagePicker();
    try {
      // pick an image
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      File image = File(pickedFile!.path);
      return await _uploadImage(image);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _uploadImage(File image) async {
    try {
      String imageUrl =
          await _authenticationRepository.updateUserImage(image: image);
      print("image Url is $imageUrl");

      _authenticationRepository
          .updateUserDataInFirestore(data: {"imageUrl": imageUrl});
      return imageUrl;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
