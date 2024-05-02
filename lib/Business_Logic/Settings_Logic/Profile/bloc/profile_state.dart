// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

enum ProfileStatus {
  initial,
  loaded,
  editingLocationState,
  editingNameState,
  editingLastNameState,
  error,
  inProgress,
  updatingNameInProgress,
  updatingLastNameInProgress,
  updatingLocationInProgress,
  updatingProfileImageInProgress,
  updateSuccess
}

class ProfileState extends Equatable {
  ProfileState(
      {required this.nameEdit,
      required this.lastNameEdit,
      required this.locationEdit,
      required this.name,
      required this.lastName,
      required this.location,
      required this.profileUrl,
      required this.email,
      required this.phone,
      required this.isNameValid,
      required this.isLastnameValid,
      required this.isLocationValid,
      required this.nameError,
      required this.lastNameError,
      required this.locationError,
      required this.profileError,
      required this.status});

  final String profileError;
  final ProfileStatus status;
  final String name;
  final String lastName;
  final String location;
  final String profileUrl;
  final String email;
  final String phone;

  final String nameEdit;
  final String lastNameEdit;
  final String locationEdit;

  final bool isNameValid;
  final bool isLastnameValid;
  final bool isLocationValid;

  final String nameError;
  final String lastNameError;
  final String locationError;

  ProfileState copyWith({
    String? nameEdit,
    String? lastNameEdit,
    String? locationEdit,
    String? profileError,
    String? name,
    String? lastName,
    String? location,
    String? profileUrl,
    String? email,
    String? phone,
    bool? isNameValid,
    bool? isLastnameValid,
    bool? isLocationValid,
    String? nameError,
    String? lastNameError,
    String? locationError,
    ProfileStatus? status,
  }) {
    return ProfileState(
      lastNameEdit: lastNameEdit ?? this.lastNameEdit,
      locationEdit: locationEdit ?? this.locationEdit,
      nameEdit: nameEdit ?? this.nameEdit,
      profileError: profileError ?? this.profileError,
      status: status ?? this.status,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      location: location ?? this.location,
      profileUrl: profileUrl ?? this.profileUrl,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isNameValid: isNameValid ?? this.isNameValid,
      isLastnameValid: isLastnameValid ?? this.isLastnameValid,
      isLocationValid: isLocationValid ?? this.isLocationValid,
      nameError: nameError ?? this.nameError,
      lastNameError: lastNameError ?? this.lastNameError,
      locationError: locationError ?? this.locationError,
    );
  }

  @override
  List<Object> get props => [
        nameEdit,
        lastNameEdit,
        locationEdit,
        profileError,
        name,
        lastName,
        location,
        profileUrl,
        email,
        phone,
        isNameValid,
        isLastnameValid,
        isLocationValid,
        nameError,
        lastNameError,
        locationError,
        status
      ];
}
