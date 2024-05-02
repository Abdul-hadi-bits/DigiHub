enum LinkPhoneStatus {
  initialState,
  inProgressState,
  errorState,
  codeSentSuccessState,
  codeVerifyInitial,
  codeVerifyError,
  codeVerifyTimedOutState,
  codeVerifySuccess
}

class LinkPhoneState {
  late String loginError;
  late String inputFieldError;
  late bool isPhoneValid;
  late String verificationID;
  late String phoneNumberField;
  late String smsCodeField;
  late int counter;
  late String verificationAlert;
  late bool codeTimedOut;
  late LinkPhoneStatus status;

  LinkPhoneState(
      {required this.loginError,
      required this.verificationAlert,
      required this.inputFieldError,
      required this.verificationID,
      required this.phoneNumberField,
      required this.isPhoneValid,
      required this.counter,
      required this.smsCodeField,
      required this.codeTimedOut,
      required this.status});

  LinkPhoneState copyWith({
    String? loginError,
    String? verficationAlert,
    String? inputFieldError,
    int? counter,
    String? verificationID,
    String? phoneNumberField,
    bool? isPhoneValid,
    bool? codeTimedOut,
    String? smsCodeField,
    LinkPhoneStatus? status,
  }) {
    return LinkPhoneState(
      verificationAlert: verficationAlert ?? this.verificationAlert,
      counter: counter ?? this.counter,
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
