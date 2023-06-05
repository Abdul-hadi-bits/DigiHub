import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:firebase_auth/firebase_auth.dart" as auth;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as network_connection;

import 'enter_code.dart';

class ChangePhoneNumberPage extends StatefulWidget {
  const ChangePhoneNumberPage({Key? key}) : super(key: key);

  @override
  SignInPhoneNumberPageState createState() => SignInPhoneNumberPageState();
}

class SignInPhoneNumberPageState extends State<ChangePhoneNumberPage> {
  static String errors = "";
  String code = "";
  String phoneError = "";
  bool isFieldError = false;

  static TextEditingController phoneNumberField = TextEditingController();

  late StreamSubscription<network_connection.ConnectivityResult> subscription;
  bool networkConnection = false;
  late FToast ftoast;

  @override
  void initState() {
    ftoast = FToast();
    ftoast.init(context);

    super.initState();

    subscription = network_connection.Connectivity()
        .onConnectivityChanged
        .listen((network_connection.ConnectivityResult result) {
      print(result.name);
      if (result != network_connection.ConnectivityResult.none) {
        print("has connection");
        networkConnection = true;
      } else {
        networkConnection = false;
        print("does not have connection");
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    phoneNumberField.clear();
    subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
          title: const Text(
            "Phone Number",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        body: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            SizedBox(
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
                        child: FittedBox(
                          child: SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: const Text(
                              "Update Or Link Phone Number",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
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
                              "An SMS Code will be sent to your number to verify",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.clip),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            if (networkConnection) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      BackdropFilter(
                                        filter: ImageFilter.blur(
                                          sigmaX: 10,
                                          sigmaY: 10,
                                        ),
                                        child: Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: SizedBox(
                                            height: 150,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const FittedBox(
                                                    child: Text(
                                                      "Unlink Phone Number?",
                                                      style: TextStyle(
                                                          fontSize: 27),
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      button(context),
                                                      button2()
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ));
                            } else {
                              _showToast(context, Colors.orange,
                                  "Please Check Your Connection");
                              Firebase;
                            }
                          },
                          child: const Text("Unlink Phone Number",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange)))
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
            )
          ],
        ));
  }

  _showToast(BuildContext context, Color color, String text) {
    ftoast = FToast();
    ftoast.init(context);

    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /*  Icon(FontAwesomeIcons.timesCircle),
          SizedBox(
            width: 12.0,
          ), */
          FittedBox(
            child: Text(
              text,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    ftoast.showToast(
      child: toast,
      fadeDuration: const Duration(seconds: 3),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Widget button(BuildContext mainContext) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          try {
            auth.User user = auth.FirebaseAuth.instance.currentUser!;

            await auth.FirebaseAuth.instance.currentUser!.unlink("phone");
            _showToast(mainContext, Colors.orange, "Unlink was successful");
            Navigator.pop(context);
            print("done");
          } on auth.FirebaseAuthException catch (e) {
            print(e.code);
          } catch (e) {
            print(e);
          }

          //await authPass.PasswordReset.resetPassword(emailAdress: emailAdress);
        },
        child: const FittedBox(
          child: Text(
            "unlink",
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

  Widget button2() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          Navigator.pop(context);
          //await authPass.PasswordReset.resetPassword(emailAdress: emailAdress);
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

  Widget sendOtpButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          if (phoneNumberField.text.isNotEmpty) {
            if (networkConnection) {
              print("try to send verification code");
              await sendPhoneNumberVerification(phoneNumberField.text);
            } else {
              setState(() {
                errors = "Please Check Your Connection";
              });
            }
          } else {
            setState(() {
              errors = "Phone Number is Empty";
            });
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
                isFieldError = false;
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
            errorText: isFieldError ? phoneError : null,
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

  Future<void> sendPhoneNumberVerification(String numb) async {
    try {
      //Rawait sfIn();

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
          phoneNumberField.clear();
          subscription.cancel();

          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: EnterCodePage(orignCode: verificationId)));
        },
        codeAutoRetrievalTimeout: (String verificationId) async {
          print(" code auto retrieval time out has ran");
        },
        timeout: const Duration(minutes: 2),
      );
    } on auth.FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }
}
