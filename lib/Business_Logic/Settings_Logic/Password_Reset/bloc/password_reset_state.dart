part of 'password_reset_bloc.dart';

enum PasswordResetStatus {
  initial,
  editingCurrentPassword,
  edittingNewPassword,
  editingConfirmPassword,
  inProgress,
  success,
  error,
  dialogInitial,
  dialogError,
  dialogInProgress,
  dialogSuccess
}

class PasswordResetState extends Equatable {
  PasswordResetState({
    required this.email,
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
    required this.hideCurrentPassword,
    required this.hideNewPassword,
    required this.hideConfrimNewPassword,
    required this.currentPasswordValid,
    required this.newPasswordValid,
    required this.confrimNewPasswordValid,
    required this.currentPasswordError,
    required this.newPasswordError,
    required this.confirmNewPasswordError,
    required this.error,
    required this.dialogAlertText,
    required this.status,
  });

  final String email;

  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  final bool hideCurrentPassword;
  final bool hideNewPassword;
  final bool hideConfrimNewPassword;

  final bool currentPasswordValid;
  final bool newPasswordValid;
  final bool confrimNewPasswordValid;

  final String currentPasswordError;
  final String newPasswordError;
  final String confirmNewPasswordError;

  final String error;
  final String dialogAlertText;
  final PasswordResetStatus status;

  @override
  List<Object> get props => [
        email,
        currentPassword,
        newPassword,
        confirmNewPassword,
        hideCurrentPassword,
        hideNewPassword,
        hideConfrimNewPassword,
        currentPasswordValid,
        newPasswordValid,
        confrimNewPasswordValid,
        currentPasswordError,
        newPasswordError,
        confirmNewPasswordError,
        error,
        dialogAlertText,
        status,
      ];

  PasswordResetState copyWith({
    String? email,
    String? currentPassword,
    String? newPassword,
    String? confirmNewPassword,
    bool? hideCurrentPassword,
    bool? hideNewPassword,
    bool? hideConfrimNewPassword,
    bool? currentPasswordValid,
    bool? newPasswordValid,
    bool? confrimNewPasswordValid,
    String? currentPasswordError,
    String? newPasswordError,
    String? confirmNewPasswordError,
    String? error,
    String? dialogAlertText,
    PasswordResetStatus? status,
  }) {
    return PasswordResetState(
      email: email ?? this.email,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword,
      hideCurrentPassword: hideCurrentPassword ?? this.hideCurrentPassword,
      hideNewPassword: hideNewPassword ?? this.hideNewPassword,
      hideConfrimNewPassword:
          hideConfrimNewPassword ?? this.hideConfrimNewPassword,
      currentPasswordValid: currentPasswordValid ?? this.currentPasswordValid,
      newPasswordValid: newPasswordValid ?? this.newPasswordValid,
      confrimNewPasswordValid:
          confrimNewPasswordValid ?? this.confrimNewPasswordValid,
      currentPasswordError: currentPasswordError ?? this.currentPasswordError,
      newPasswordError: newPasswordError ?? this.newPasswordError,
      confirmNewPasswordError:
          confirmNewPasswordError ?? this.confirmNewPasswordError,
      error: error ?? this.error,
      dialogAlertText: dialogAlertText ?? this.dialogAlertText,
      status: status ?? this.status,
    );
  }
}
