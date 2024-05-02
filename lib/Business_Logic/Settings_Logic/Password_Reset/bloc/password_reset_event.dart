// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'password_reset_bloc.dart';

sealed class PasswordResetEvent extends Equatable {
  const PasswordResetEvent();

  @override
  List<Object> get props => [];
}

class PasswordResetEdittedCurrentPasswordEvent extends PasswordResetEvent {
  final String password;
  PasswordResetEdittedCurrentPasswordEvent({
    required this.password,
  });
}

class PasswordResetEdittedNewPasswordEvent extends PasswordResetEvent {
  final String newPassword;
  PasswordResetEdittedNewPasswordEvent({
    required this.newPassword,
  });
}

class PasswordResetEdittedConfirmNewPasswordEvent extends PasswordResetEvent {
  final String confirmNewPassword;
  PasswordResetEdittedConfirmNewPasswordEvent({
    required this.confirmNewPassword,
  });
}

class PasswordResetUpdatedEvent extends PasswordResetEvent {}

class PasswordResetUsedEmailEvent extends PasswordResetEvent {}

class PasswordResetEmailSentEvent extends PasswordResetEvent {}

class PasswordResetInitialized extends PasswordResetEvent {}

class PasswordResetTogglePasswords extends PasswordResetEvent {
  final bool? currentPassword;
  final bool? newPassword;
  final bool? confirmPassword;
  PasswordResetTogglePasswords({
    this.currentPassword,
    this.newPassword,
    this.confirmPassword,
  });
}
