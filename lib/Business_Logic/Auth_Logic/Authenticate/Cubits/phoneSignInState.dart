enum PhoneSignInStatus {
  initialState,
  inProgressState,
  errorState,
  codeSentSuccessState,
  codeVerifyError,
  codeVerifySuccess,
  dialogInitial,
  dialogInProgress,
  dialogError,
  dialogSuccess,
}

class PhoneSignInState {
  late String loginError;
  late String dialogAlert;
  late String inputFieldError;
  late bool isPhoneValid;
  late String verificationID;
  late String phoneNumberField;
  late String smsCodeField;
  late bool codeTimedOut;
  late PhoneSignInStatus status;

  PhoneSignInState(
      {required this.loginError,
      required this.inputFieldError,
      required this.verificationID,
      required this.dialogAlert,
      required this.phoneNumberField,
      required this.isPhoneValid,
      required this.smsCodeField,
      required this.codeTimedOut,
      required this.status});

  PhoneSignInState copyWith({
    String? loginError,
    String? inputFieldError,
    String? verificationID,
    String? dialogAlert,
    String? phoneNumberField,
    bool? isPhoneValid,
    bool? codeTimedOut,
    String? smsCodeField,
    PhoneSignInStatus? status,
  }) {
    return PhoneSignInState(
      dialogAlert: dialogAlert ?? this.dialogAlert,
      codeTimedOut: codeTimedOut ?? this.codeTimedOut,
      isPhoneValid: isPhoneValid ?? this.isPhoneValid,
      loginError: loginError ?? this.loginError,
      inputFieldError: inputFieldError ?? this.inputFieldError,
      verificationID: verificationID ?? this.verificationID,
      phoneNumberField: phoneNumberField ?? this.phoneNumberField,
      smsCodeField: smsCodeField ?? this.smsCodeField,
      status: status ?? this.status,
    );
  }
}
