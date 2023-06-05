import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my_project/UI/AUTH_pages/registeration/register_page.dart';
import 'package:my_project/UI/AUTH_pages/sign_in/email_sign_in.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({Key? key}) : super(key: key);

  @override
  State<PasswordResetPage> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordResetPage> {
  String email = "";

  String passRestError = "";

  String error2 = "";
  String error1 = "";
  bool isReady2 = false;
  TextEditingController passwordField = TextEditingController();
  TextEditingController newPassField = TextEditingController();
  TextEditingController confirmNewPassField = TextEditingController();

  String error = "";

  bool isReady = false;

  @override
  void initState() {
    try {
      var user = firebase.FirebaseAuth.instance.currentUser;
      email = (user!.email!.isNotEmpty ? user.email : "")!;
    } on firebase.FirebaseAuthException catch (e) {
      print(e.code);
    } catch (e) {
      e.toString();
    }

    super.initState();
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
        title: const Text("Password Reset",
            style: TextStyle(color: Colors.black, fontSize: 25)),
        centerTitle: true,
        backgroundColor: Colors.white,
        //foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 13.0, right: 13.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                        child: SizedBox(
                            height: 20,
                            child: Text(passRestError,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)))),
                    FittedBox(
                      child: RichText(
                        text: TextSpan(
                          text: "Changing Password for ",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            TextSpan(
                                text: email,
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2.2,
                      child: const FittedBox(
                        child: Text("Please fill in the following",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    inputFieldCurrentPassword(
                        controller: passwordField,
                        hintText: "password",
                        labelText: "Current Password"),
                    inputFieldPass(
                        controller: newPassField,
                        hintText: "password",
                        labelText: "New Password"),
                    inputFieldPassCon(
                        controller: confirmNewPassField,
                        hintText: "password",
                        labelText: "Confirm Password"),
                    const SizedBox(height: 20),
                    const Text(
                      "Once the Password has changed you will be Logged Out!",
                      style: TextStyle(
                        fontSize: 16,
                        //  fontWeight: FontWeight.bold,
                      ),
                    ),
                    forgotPassword()
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget forgotPassword() {
    return TextButton(
        child: const Text(
          "Reset Password Using Email?",
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        onPressed: () {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 10,
                    sigmaY: 10,
                  ),
                  child: const PasswordResetPopUpDialog(),
                );
              });
        });
  }

  _prepareForPassUpdate() async {
    if (passwordField.text.isNotEmpty &&
        newPassField.text.isNotEmpty &&
        confirmNewPassField.text.isNotEmpty) {
      if (error.isEmpty && error1.isEmpty && error2.isEmpty) {
        if (newPassField.text == confirmNewPassField.text) {
          try {
            await firebase.FirebaseAuth.instance.signInWithEmailAndPassword(
                email: email, password: passwordField.text);
            print("password verified");
            firebase.FirebaseAuth.instance.currentUser!
                .updatePassword(newPassField.text);
            print("password update was succesful");

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
                (route) => false);
          } on firebase.FirebaseAuthException catch (e) {
            setState(() {
              passRestError = e.code;
            });

            print(e.code);
          } catch (e) {
            print(e);
          }
        } else {
          setState(() {
            passRestError = "Passwords do not match";
          });
        }
      } else {
        setState(() {
          passRestError = "Please fix all errors";
        });
      }
    } else {
      setState(() {
        passRestError = "Please fill in all fields";
      });
    }
  }

  Widget button() {
    setState(() {
      passRestError = "";
    });

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          _prepareForPassUpdate();
        },
        child: const Text("Change"),
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

  Widget inputFieldCurrentPassword(
      {required TextEditingController controller,
      required String hintText,
      required String labelText}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextField(
            onTap: () {
              passRestError = "";
            },
            onChanged: (text) {
              passRestError = "";
              if (text.length < 6) {
                error1 = "too short";

                setState(() {});
              } else {
                error1 = "";
                setState(() {});
              }
            },
            onSubmitted: (text) {
              if (text.isEmpty) {
                setState(() {
                  error1 = "";
                });
              }
            },
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              errorText: error1.isNotEmpty ? error : null,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 255, 160, 0),
                ),
              ),
              hintText: hintText,
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
      ),
    );
  }

  Widget inputFieldPass(
      {required TextEditingController controller,
      required String hintText,
      required String labelText}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextField(
            onTap: () {
              passRestError = "";
            },
            onChanged: (text) {
              passRestError = "";
              if (text.length < 6) {
                error = "too short";

                setState(() {});
              } else {
                error = "";
                setState(() {});
              }
            },
            onSubmitted: (text) {
              if (text.isEmpty) {
                setState(() {
                  error = "";
                });
              }
            },
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              errorText: error.isNotEmpty ? error : null,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 255, 160, 0),
                ),
              ),
              hintText: hintText,
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
      ),
    );
  }

  Widget inputFieldPassCon(
      {required TextEditingController controller,
      required String hintText,
      required String labelText}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextField(
            onTap: () {
              passRestError = "";
            },
            onChanged: (text) {
              passRestError = "";
              if (text != newPassField.text) {
                error2 = "passwords dont match";
                setState(() {});
              } else {
                error2 = "";
                setState(() {});
              }
            },
            onSubmitted: (text) {
              if (text.isEmpty) {
                setState(() {
                  error2 = "";
                });
              }
            },
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              errorText: error2.isNotEmpty ? error2 : null,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color.fromARGB(255, 255, 160, 0),
                ),
              ),
              hintText: hintText,
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
      ),
    );
  }
}

class PasswordResetPopUpDialog extends StatefulWidget {
  const PasswordResetPopUpDialog({Key? key}) : super(key: key);

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<PasswordResetPopUpDialog> {
  TextEditingController emailField = TextEditingController();
  TextEditingController codeField = TextEditingController();

  String resetPassAlert = "";
  String email = "";
  bool isSent = false;

  _MyDialogState();

  @override
  void initState() {
    try {
      email = firebase.FirebaseAuth.instance.currentUser!.email!;
    } on firebase.FirebaseAuthException catch (e) {
      print(e.code);
    } catch (e) {
      print(e);
    }

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    emailField.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          //height: 300,
          child: Center(
            child: Text(
              "Password Reset",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600),
            ),
          ),
        ),
        elevation: 10,
        contentPadding: const EdgeInsets.all(10),
        children: [
          Center(
            child: Text(
              "Send A Password Reset Email",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600,
                  overflow: TextOverflow.clip),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    resetPassAlert,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                FittedBox(
                  child: RichText(
                      text: TextSpan(
                          text: "Email Adress: ",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          children: [
                        TextSpan(
                            text: email,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ))
                      ])),
                ),
                // ignore: sized_box_for_whitespace
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [button1(email), button2()],
                ),
              ],
            ),
          )
        ]);
  }

  Widget button2() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          print(isSent);
          if (isSent == true) {
            print('true');
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInPage()),
                (route) => false);
          } else {
            Navigator.pop(context);
          }
        },
        child: const Text(
          "Cancel",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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

  Widget button1(String emailAdress) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await firebase.FirebaseAuth.instance
                .sendPasswordResetEmail(email: emailAdress);
            isSent = true;

            setState(() {
              resetPassAlert = "check you Email to reset password";
            });
          } on firebase.FirebaseAuthException catch (e) {
            setState(() {
              resetPassAlert = e.code;
            });

            print(e);
          } catch (e) {
            setState(() {
              resetPassAlert = "could not send resetPassword Email";
            });
            print(e);
          }
          //await authPass.PasswordReset.resetPassword(emailAdress: emailAdress);
        },
        child: const Text(
          "Send",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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

  Widget inputField(
      {required TextEditingController controller,
      required String hintText,
      required String labelText}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextField(
          onTap: () {
            setState(() {
              resetPassAlert = "";
            });
          },
          controller: controller,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 255, 160, 0),
              ),
            ),
            hintText: hintText,
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

  Widget sendEmail(String emailAdress) {
    return ElevatedButton(
      onPressed: () async {
        if (emailAdress.isNotEmpty) {
          try {
            await firebase.FirebaseAuth.instance
                .sendPasswordResetEmail(email: emailAdress);

            setState(() {
              resetPassAlert = "check ${emailField.text} to reset password";
            });
          } on firebase.FirebaseAuthException catch (e) {
            setState(() {
              resetPassAlert = e.code;
            });

            print(e);
          } catch (e) {
            setState(() {
              resetPassAlert = "could not send resetPassword Email";
            });
            print(e);
          }
          //await authPass.PasswordReset.resetPassword(emailAdress: emailAdress);
        } else {
          setState(() {
            resetPassAlert = 'email field is empty';
          });
        }
      },
      child: const Center(
          child: Text("Send Request", style: TextStyle(color: Colors.white))),
      style: ElevatedButton.styleFrom(
        elevation: 5,
        primary: Colors.lightBlue.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
      ),
    );
  }
}
