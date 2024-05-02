part of 'delete_acount_bloc.dart';

sealed class DeleteAcountState extends Equatable {
  late final String password;
  late final String passwordError;
  late final bool isPasswordValid;
  late final bool hidePassword;
  late final String deleteAcountError;

  DeleteAcountState(
      {required this.password,
      required this.passwordError,
      required this.isPasswordValid,
      required this.hidePassword,
      required this.deleteAcountError});

  @override
  List<Object> get props => [password, passwordError, hidePassword];
}

final class DeleteAcountInitial extends DeleteAcountState {
  DeleteAcountInitial(
      {required super.password,
      required super.passwordError,
      required super.isPasswordValid,
      required super.hidePassword,
      required super.deleteAcountError});
}

final class DeleteAcountInProgress extends DeleteAcountState {
  DeleteAcountInProgress(
      {required super.password,
      required super.isPasswordValid,
      required super.passwordError,
      required super.hidePassword,
      required super.deleteAcountError});
}

final class DeleteAcountEditState extends DeleteAcountState {
  DeleteAcountEditState(
      {required super.password,
      required super.passwordError,
      required super.hidePassword,
      required super.isPasswordValid,
      required super.deleteAcountError});
}

final class DeleteAcountSuccess extends DeleteAcountState {
  DeleteAcountSuccess(
      {required super.password,
      required super.passwordError,
      required super.hidePassword,
      required super.isPasswordValid,
      required super.deleteAcountError});
}

final class DeleteAcountFailed extends DeleteAcountState {
  DeleteAcountFailed(
      {required super.password,
      required super.passwordError,
      required super.isPasswordValid,
      required super.hidePassword,
      required super.deleteAcountError});
}
