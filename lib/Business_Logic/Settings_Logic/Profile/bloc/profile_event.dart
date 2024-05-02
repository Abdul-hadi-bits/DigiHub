// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoadedEvent extends ProfileEvent {
  final bool loadLocal;

  ProfileLoadedEvent({required this.loadLocal});
}

class ProfileNameEditEvent extends ProfileEvent {
  final String name;
  ProfileNameEditEvent({required this.name});
}

class ProfileLastNameEditEvent extends ProfileEvent {
  final String lastName;
  ProfileLastNameEditEvent({required this.lastName});
}

class ProfileLocationEditEvent extends ProfileEvent {
  final String location;
  ProfileLocationEditEvent({required this.location});
}

class ProfileNameUpdateEvent extends ProfileEvent {
  final String name;
  ProfileNameUpdateEvent({
    required this.name,
  });
}

class ProfileLastNameUpdateEvent extends ProfileEvent {
  final String lastName;
  ProfileLastNameUpdateEvent({
    required this.lastName,
  });
}

class ProfileLocationUpdateEvent extends ProfileEvent {
  final String locatoin;
  ProfileLocationUpdateEvent({
    required this.locatoin,
  });
}

class ProfileEnableEditingEvent extends ProfileEvent {
  final bool editingName;
  final bool editingLastName;
  final bool editingLocation;
  ProfileEnableEditingEvent({
    bool? editingName,
    bool? editingLastName,
    bool? editingLocation,
  })  : editingName = editingName ?? false,
        editingLastName = editingLastName ?? false,
        editingLocation = editingLocation ?? false;
}

class ProfileImageUpdateEvent extends ProfileEvent {
  ProfileImageUpdateEvent();
}
