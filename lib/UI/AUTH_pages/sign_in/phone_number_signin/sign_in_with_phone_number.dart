import 'dart:async';

import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_project/UI/AUTH_pages/registeration/link_with_phone_number.dart';
import 'package:my_project/UI/AUTH_pages/sign_in/email_sign_in.dart';
import "package:firebase_auth/firebase_auth.dart" as auth;
import 'package:safetynet_attestation/models/jws_payload_model.dart';
import 'package:safetynet_attestation/safetynet_attestation.dart';
import 'package:page_transition/page_transition.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as network_connection;

import 'enter_code_sign_in_page.dart';

class SignInPhoneNumberPage extends StatefulWidget {
  const SignInPhoneNumberPage({Key? key}) : super(key: key);

  @override
  SignInPhoneNumberPageState createState() => SignInPhoneNumberPageState();
}

class SignInPhoneNumberPageState extends State<SignInPhoneNumberPage> {
  static String errors = "";
  String code = "";
  String phoneError = "";
  bool isFieldError = false;

  static TextEditingController phoneNumberField = TextEditingController();

  late StreamSubscription<network_connection.ConnectivityResult> subscription;
  bool networkConnection = false;

  @override
  void initState() {
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
            "Wellcome Back",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        body: ListView(
          physics: BouncingScrollPhysics(),
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
                        child: SizedBox(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: const Text(
                            "Login to your account",
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
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
                              "An SMS Code will be sent to your number to log you in",
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
                          bottom:
                              MediaQuery.of(context).viewInsets.bottom * 0.85,
                        ),
                        child: sendOtpButton(),
                      ),
                      Center(
                        child: SizedBox(
                          // height: 30,
                          child: Center(
                            child: TextButton(
                              style: ButtonStyle(
                                overlayColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      const Color.fromARGB(50, 255, 170, 0),
                                ),
                              ),
                              child: const Text(
                                "Use Email Instead",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange),
                              ),
                              onPressed: () {
                                subscription.cancel();
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: const SignInPage()));
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
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
