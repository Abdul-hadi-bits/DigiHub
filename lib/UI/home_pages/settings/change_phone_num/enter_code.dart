import 'dart:async';

import "package:flutter/material.dart";
import "package:firebase_auth/firebase_auth.dart" as auth;
import 'package:my_project/UI/AUTH_pages/sign_in/phone_number_signin/sign_in_with_phone_number.dart';
import 'package:otp_text_field/otp_text_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:my_project/UI/home_pages/home_page.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

class EnterCodePage extends StatefulWidget {
  String orignCode;
  EnterCodePage({
    Key? key,
    required this.orignCode,
  }) : super(key: key);
  static String signInError = "default1";

  @override
  _EnterCodePageState createState() => _EnterCodePageState(orignCode);
}

class _EnterCodePageState extends State<EnterCodePage> {
  TextEditingController codeField = TextEditingController();

  final String orignCode;
  String? error = "";
  String inputedCode = "xxxx";

  _EnterCodePageState(this.orignCode);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        backgroundColor: Colors.white,
        leadingWidth: 0,
        title: TextButton(
          child: const Text(
            "Change Number",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.orange),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: SizedBox(
                      height: 30,
                      child: Center(
                        child: Text(
                          "$error",
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                  const Text("Enter smsCode ",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  const SizedBox(
                    height: 20,
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
                        fieldHeight: 50,
                        fieldWidth: 50,
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
                      onCompleted: (v) {
                        print("Completed");
                      },
                      // onTap: () {
                      //   print("Pressed");
                      // },
                      onTap: () {
                        setState(() {
                          error = "";
                        });
                      },
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          inputedCode = value;
                        });
                      },

                      beforeTextPaste: (text) {
                        print("Allowing to paste $text");
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return true;
                      },
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: login(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget login() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          if (codeField.text.isNotEmpty) {
            await updateOrSetPhoneNumber(inputedCode: codeField.text);
          } else {
            setState(() {
              error = "Please Enter The Code Properly";
            });

            print(" the code Field is empty");
          }
        },
        child: const Text("update"),
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

  Future updateOrSetPhoneNumber({required inputedCode}) async {
    try {
      var user = auth.FirebaseAuth.instance.currentUser!;
      if (user.phoneNumber == null) {
        print('phone number not set, attempt to set it');
        await auth.FirebaseAuth.instance.currentUser!.linkWithCredential(
            auth.PhoneAuthProvider.credential(
                verificationId: orignCode, smsCode: inputedCode));
        print("phone number is set");
      } else {
        print("user's phone number has set, attempt to update it");
        await auth.FirebaseAuth.instance.currentUser!.updatePhoneNumber(
            auth.PhoneAuthProvider.credential(
                verificationId: orignCode, smsCode: inputedCode));
        print("phone number is updated");
      }
      Navigator.pop(context);

      /*  await auth.FirebaseAuth.instance.signInWithCredential(
          auth.PhoneAuthProvider.credential(
              verificationId: orignCode, smsCode: inputedCode));
      auth.User user = auth.FirebaseAuth.instance.currentUser!; */

// we check to if this phone number is linked with any email and whether
// the email is verified or not ....if it dose not then we will delete
// the the account
      /*  if (user.email != null && user.emailVerified) {
        print('vertified');
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DigiHub()),
            (Route<dynamic> route) => false);
      } else {
        await auth.FirebaseAuth.instance.currentUser!.delete();
        setState(() {
          error = "This Phone Number Is Not Linked With Any Account";
        });
      } */
    } on auth.FirebaseAuthException catch (e) {
      setState(() {
        error = e.code.toString();
      });

      print('not vertified');
    } catch (e) {
      print('not vertified');
      print(e);
    }
  }
}
