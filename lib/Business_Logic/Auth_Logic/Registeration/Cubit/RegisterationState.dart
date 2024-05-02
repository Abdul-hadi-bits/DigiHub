// ignore_for_file: public_member_api_docs, sort_constructors_first

enum RegisterationStatus {
  initialState,
  editingState,
  inProgressSate,
  errorState,
  emailSentSuccessfulState,
  emailReSendInProgress,
  emailReSentSuccessfulState,
  emailSentFailedState,
  emailSentTimedOut,
  verifySuccessState,
  verifyFailState,
  verifyInitialState,
}

class RegisterationState {
  RegisterationState(
      {required this.status,
      required this.hidePassword,
      required this.hidePasswordConfirm,
      required this.nameError,
      required this.lastNameError,
      required this.isFormValid,
      required this.isEmailValid,
      required this.isPasswordValid,
      required this.isConfirmPasswordValid,
      required this.isNameValid,
      required this.isLastNameValid,
      required this.passwordError,
      required this.passwordConfirmError,
      required this.registerationError,
      required this.counter,
      required this.firstNameFieldText,
      required this.lastNameFieldText,
      required this.passwordConfirmFieldText,
      required this.passwordFieldText,
      required this.emailAddressFieldText,
      required this.verificationAlert,
      required this.emailError,
      required this.isVerified});
  late String passwordError;
  late String passwordConfirmError;
  late String registerationError;
  late String nameError;
  late String lastNameError;
  late bool isNameValid;
  late bool isLastNameValid;
  late int counter;
  late String emailError;
  late String passwordFieldText;
  late String passwordConfirmFieldText;
  late String firstNameFieldText;
  late String lastNameFieldText;
  late String emailAddressFieldText;
  late String verificationAlert;
  late bool isFormValid;
  late bool isEmailValid;
  late bool isPasswordValid;
  late bool isConfirmPasswordValid;
  late bool hidePassword;
  late bool hidePasswordConfirm;

  late bool isVerified;
  late RegisterationStatus status;

  RegisterationState copyWith({
    String? nameError,
    String? lastNameError,
    String? passwordError,
    String? passwordConfirmError,
    String? emailError,
    String? registerationError,
    int? counter,
    String? passwordFieldText,
    String? passwordConfirmFieldText,
    String? firstNameFieldText,
    String? lastNameFieldText,
    String? emailAddressFieldText,
    String? verificationAlert,
    bool? isFormValid,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isPasswordConfirmValid,
    bool? isNameValid,
    bool? isLastNameValid,
    bool? isVerified,
    bool? hidePassword,
    bool? hideConfirmPassword,
    RegisterationStatus? status,
  }) {
    return RegisterationState(
      hidePassword: hidePassword ?? this.hidePassword,
      hidePasswordConfirm: hideConfirmPassword ?? this.hidePasswordConfirm,
      nameError: nameError ?? this.nameError,
      lastNameError: lastNameError ?? this.lastNameError,
      emailError: emailError ?? this.emailError,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isConfirmPasswordValid:
          isPasswordConfirmValid ?? this.isConfirmPasswordValid,
      isNameValid: isNameValid ?? this.isNameValid,
      isLastNameValid: isLastNameValid ?? this.isLastNameValid,
      passwordError: passwordError ?? this.passwordError,
      passwordConfirmError: passwordConfirmError ?? this.passwordConfirmError,
      registerationError: registerationError ?? this.registerationError,
      counter: counter ?? this.counter,
      passwordFieldText: passwordFieldText ?? this.passwordFieldText,
      passwordConfirmFieldText:
          passwordConfirmFieldText ?? this.passwordConfirmFieldText,
      firstNameFieldText: firstNameFieldText ?? this.firstNameFieldText,
      lastNameFieldText: lastNameFieldText ?? this.lastNameFieldText,
      emailAddressFieldText:
          emailAddressFieldText ?? this.emailAddressFieldText,
      verificationAlert: verificationAlert ?? this.verificationAlert,
      isFormValid: isFormValid ?? this.isFormValid,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
    );
  }
}
