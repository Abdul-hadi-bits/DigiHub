import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:my_project/UI/AUTH_pages/registeration/additional_user_infos.dart';
import 'package:my_project/UI/AUTH_pages/sign_in/email_sign_in.dart';
import 'package:my_project/UI/home_pages/home_page.dart';

class AddPhoneNumber extends StatefulWidget {
  const AddPhoneNumber({Key? key}) : super(key: key);

  @override
  _AddPhoneNumberState createState() => _AddPhoneNumberState();
}

class _AddPhoneNumberState extends State<AddPhoneNumber> {
  static TextEditingController phoneNumberField = TextEditingController();

  //TextEditingController codeField = TextEditingController();
  TextEditingController codeField = TextEditingController();

  String errors = "";
  int codeIsSend = 0;

  String code = "";
  String phoneError = "";
  bool isFieldError = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    errors = "";
    codeIsSend = 0;

    code = "";
    phoneError = "";
    isFieldError = false;
    codeField.clear();
    phoneNumberField.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            child: const Text(
              "Skip",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            onPressed: () {
              setState(() {
                errors = "";
                codeIsSend = 0;

                code = "";
                phoneError = "";
                isFieldError = false;
                codeField.clear();
                phoneNumberField.clear();
              });
              Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: const AdditionalUserData()));
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        backgroundColor: Colors.white,
        title: const FittedBox(
          child: Text(
            "Link With Phone Number?",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: SizedBox(
                      height: 30,
                      child: Center(
                        child: Text(
                          errors,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: inputField(
                        controller: phoneNumberField,
                        hintText: "750 xxxx xxx",
                        labelText: "Phone Number"),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 8.0,
                        left: MediaQuery.of(context).size.width * 0.05),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: const Text(
                          "Add a phone number for alternative login method",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip),
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: sendOtpButton(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget sendOtpButton() {
    setState(() {
      errors = "";
    });
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          if (phoneNumberField.text.isNotEmpty) {
            // this if satement is only for testing remove it later
            if (phoneNumberField.text.length > 9) {
              sendPhoneNumberVerification(phoneNumberField.text);
            } else {
              setState(() {
                errors = "Invalid Phone number";
              });
            }
          } else {
            setState(() {
              errors = "Phone number is empty";
            });

            print("phone number is empty");
          }
        },
        child: const Text("Continue"),
        style: ElevatedButton.styleFrom(
          elevation: 5,
          primary: const Color.fromARGB(255, 255, 160, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Future<void> sendPhoneNumberVerification(String numb) async {
    try {
      await auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+964$numb',
        verificationCompleted: (auth.PhoneAuthCredential credential) async {
          // we do nothing here
        },
        verificationFailed: (auth.FirebaseAuthException e) async {
          setState(() {
            errors = e.code;
          });
        },
        codeSent: (String verificationId, int? resendToken) async {
          print("codeSent has ran");
          otpVerificationPopUp(verificationId, numb);
        },
        codeAutoRetrievalTimeout: (String verificationId) async {
          print(" code auto retrieval time out has ran");
        },
        timeout: const Duration(minutes: 1),
      );
    } on auth.FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  otpVerificationPopUp(String orignCode, String numb) {
    return showDialog(
        barrierDismissible: false,
        barrierColor: Colors.transparent,
        useSafeArea: true,
        context: context,
        builder: (context) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10,
              sigmaY: 10,
            ),
            child: CodeVerify(orignCode: orignCode, numb: numb),
          );
        });
  }

  Widget inputField(
      {required TextEditingController controller,
      required String hintText,
      required String labelText}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextField(
          onTap: () {
            setState(() {
              errors = "";
            });
          },
          onSubmitted: (text) {
            if (text.isEmpty) {
              setState(() {
                isFieldError = true;
                phoneError = "";
              });
            }
          },
          onChanged: (text) {
            if (text.length < 10) {
              setState(() {
                phoneError = "Invalid Number";
                isFieldError = true;
              });
            } else {
              setState(() {
                isFieldError = false;

                phoneError = "";
              });
            }
          },
          keyboardType: TextInputType.phone,
          maxLength: 10,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          controller: controller,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 255, 160, 0),
              ),
            ),
            hintText: hintText,
            errorText: phoneError.isNotEmpty ? phoneError : null,
            prefixText: "+964 ",
            errorStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            prefixIcon: const Icon(Icons.phone),
            label: Text(labelText),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 255, 160, 0),
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}

class CodeVerify extends StatefulWidget {
  String orignCode = "";
  String numb = "";
  CodeVerify({
    required this.orignCode,
    required this.numb,
    Key? key,
  }) : super(key: key);
  @override
  _CodeVerifyState createState() => _CodeVerifyState(orignCode, numb);
}

class _CodeVerifyState extends State<CodeVerify> {
  String orignCode = "";
  String numb = "";
  int count = 60;
  bool isRegisterd = true;
  late Timer _timer;

  String alerts = "";
  TextEditingController codeField = TextEditingController();

  bool isVerified = false;

  _CodeVerifyState(this.orignCode, this.numb);
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer.isActive ? _timer.cancel() : false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
            "Verificaton",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade600),
          ),
        ),
        elevation: 10,
        contentPadding: const EdgeInsets.all(8),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 30,
                child: FittedBox(
                  child: RichText(
                    overflow: TextOverflow.visible,
                    text: TextSpan(
                      text: "Code is sent to ",
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: "+964$numb",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Text("$count",
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold)),
              Center(
                child: Text(
                  alerts,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: PinCodeTextField(
                  appContext: context,
                  pastedTextStyle: TextStyle(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                  length: 6,

                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    inactiveColor: Colors.orange,
                    borderWidth: 1,
                    inactiveFillColor: Colors.grey,
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(15),
                    fieldHeight: 40,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                  ),

                  cursorColor: Colors.black,
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,

                  controller: codeField,
                  keyboardType: TextInputType.number,
                  boxShadows: const [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                  onTap: () {
                    setState(() {
                      alerts = "";
                    });
                  },
                  onCompleted: (value) {
                    signInWithPhoneNumber(inputedCode: value);
                    print("Completed");
                  },
                  // onTap: () {
                  //   print("Pressed");
                  // },
                  onChanged: (value) {},
                  beforeTextPaste: (text) {
                    print("Allowing to paste $text");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return true;
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [button2(), button1()],
              ),
            ],
          )
        ]);
  }

  Widget button2() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const FittedBox(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          //  elevation: 5,
          primary: const Color.fromARGB(255, 255, 160, 0),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Widget button1() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: count == 0
            ? () {
                resendPhoneNumberVerification();
              }
            : () {},
        child: const FittedBox(
          child: Text(
            "Resend",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          //  elevation: 5,
          primary:
              count == 0 ? const Color.fromARGB(255, 255, 160, 0) : Colors.grey,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Future<void> resendPhoneNumberVerification() async {
    try {
      count = 60;
      await auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+964$numb',
        verificationCompleted: (auth.PhoneAuthCredential credential) async {
          // we do nothing here
        },
        verificationFailed: (auth.FirebaseAuthException e) async {
          setState(() {
            alerts = e.code;
          });
        },
        codeSent: (String verificationId, int? resendToken) async {
          setState(() {
            codeField.clear();
            orignCode = verificationId;
            alerts = "Code is Sent";
          });
          startTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) async {
          // when the code is nolonger is valid this functons will be triggered(run)
          // you can alert the user like the time out please resend or cancel
          setState(() {
            alerts = "Time is up, Resend or Cancel";
          });
        },
        timeout: const Duration(minutes: 1),
      );
    } on auth.FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  Future signInWithPhoneNumber({required inputedCode}) async {
    try {
      await auth.FirebaseAuth.instance.currentUser!.linkWithCredential(
          auth.PhoneAuthProvider.credential(
              verificationId: orignCode, smsCode: inputedCode));

      print('vertified');
      _timer.isActive ? _timer.cancel() : false;
      Navigator.pushReplacement(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: const AdditionalUserData()));
    } on auth.FirebaseAuthException catch (e) {
      setState(() {
        alerts = e.code.toString();
      });

      print('not vertified');
    } catch (e) {
      print('not vertified');
      print(e);
    }
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (time) {
      if (time.tick.toInt() >= 60) {
        time.cancel();
      }
      setState(() {
        count -= 1;
      });
    });
  }
}
