enum EmailSignInStatus {
  initialState,
  progressState,
  errorState,
  successfulState,
  emailPasswordResetErrorState,
  emailPasswordResetSuccessState
}

class EmailSignInState {
  EmailSignInState(
      {required this.password,
      required this.email,
      required this.passwordError,
      required this.emailError,
      required this.signInError,
      required this.passwordResetAlert,
      required this.isEmailValid,
      required this.isPasswordValid,
      required this.status,
      required this.hidePassword});

  late EmailSignInStatus status;
  late bool hidePassword;
  late String password;
  late String email;
  late String passwordError;
  late String emailError;
  late String signInError;
  late String passwordResetAlert;
  late bool isPasswordValid;
  late bool isEmailValid;

  EmailSignInState copyWith({
    String? password,
    bool? hidePassword,
    String? email,
    String? passwordError,
    String? emailError,
    String? signInError,
    String? passwordResetAlert,
    bool? isPasswordValid,
    bool? isEmailValid,
    EmailSignInStatus? status,
  }) {
    return EmailSignInState(
      hidePassword: hidePassword ?? this.hidePassword,
      password: password ?? this.password,
      email: email ?? this.email,
      passwordError: passwordError ?? this.passwordError,
      emailError: emailError ?? this.emailError,
      signInError: signInError ?? this.signInError,
      passwordResetAlert: passwordResetAlert ?? this.passwordResetAlert,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      status: status ?? this.status,
    );
  }
}
