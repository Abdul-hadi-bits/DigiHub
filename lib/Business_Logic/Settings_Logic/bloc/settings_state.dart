part of 'settings_bloc.dart';

sealed class SettingsState extends Equatable {
  const SettingsState({required this.isNotificationOn});
  final bool isNotificationOn;

  @override
  List<Object> get props => [isNotificationOn];
}

final class SettingsInitial extends SettingsState {
  SettingsInitial({required super.isNotificationOn});
}

final class SettingsLoaded extends SettingsState {
  SettingsLoaded({required super.isNotificationOn});
}

final class SettingsUpdated extends SettingsState {
  SettingsUpdated({required super.isNotificationOn});
}
