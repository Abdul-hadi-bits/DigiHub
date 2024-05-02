part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class SettingsNotificationUpdated extends SettingsEvent {
  SettingsNotificationUpdated();
}

class SettingsLoadRequired extends SettingsEvent {
  SettingsLoadRequired();
}
