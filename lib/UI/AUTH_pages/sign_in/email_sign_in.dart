// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';

import "package:flutter/material.dart";

import 'package:my_project/UI/home_pages/home_page.dart';

/* import 'package:data_connection_checker_tv/data_connection_checker.dart'
    as data_connection; */

import 'package:my_project/UI/AUTH_pages/registeration/register_page.dart';

import 'phone_number_signin/sign_in_with_phone_number.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as network_connection;

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String signInError = "";
  bool isNotSignedIn = true;
  Future<bool>? showAlert;
  String error = "";

  bool networkConnection = false;

  TextEditingController emailField = TextEditingController();
  TextEditingController passwordField = TextEditingController();
  late StreamSubscription<network_connection.ConnectivityResult> subscription;

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
    subscription.cancel();
    cleanUp();
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
          title: const Text(
            "Loggin In",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          //titleSpacing: MediaQuery.of(context).size.width ,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.87,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          color: Colors.white,
                          height: MediaQuery.of(context).size.height / 20,
                          child: Center(
                            child: Text(
                              signInError,
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
                            controller: emailField,
                            hintText: "Example@Email.com",
                            labelText: "Email Adresss"),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: inputFieldPass(
                            controller: passwordField,
                            hintText: "password",
                            labelText: "Password"),
                      ),
                      const SizedBox(height: 0),
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: forgotPassword()),
                    ],
                  ),
                ),

                Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: signInButton(),
                  ),
                ),
                // toRegisterPage(),
                // toPhoneSignInPage(),
              ],
            ),
          ),
        ));
  }

  Widget inputField(
      {required TextEditingController controller,
      required String hintText,
      required String labelText}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextField(
          onTap: () {
            signInError = "";
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

  Widget inputFieldPass(
      {required TextEditingController controller,
      required String hintText,
      required String labelText}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: TextField(
          onTap: () {
            signInError = "";
          },
          onChanged: (text) {
            signInError = "";
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
    );
  }

  ///***************** returns the sign button as a widget ************* */
  Widget signInButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          prepareToSignIn();
        },
        child: const Text("Sign In"),
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

  Widget toRegisterPage() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Don't have an Account ?"),
          TextButton(
              child: const Text("Register"),
              onPressed: () {
                leaveSignInPage();
              })
        ]);
  }

  Widget toPhoneSignInPage() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Sign in with "),
          TextButton(
              child: const Text("Phone Number"),
              onPressed: () {
                leavePhoneSignToPage();
              })
        ]);
  }

  Widget forgotPassword() {
    return TextButton(
        child: const Text(
          "Forgot Password?",
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
                  child: const PasswordResetPopUp(),
                );
              });
        });
  }

  ///**********************handeling what needs to be done to sign in the user************* */
  void prepareToSignIn() async {
    bool hasConnection = networkConnection;
    bool passwordNotEmpty = passwordField.text.isNotEmpty;
    bool emailNotEmpty = emailField.text.isNotEmpty;

    if (passwordNotEmpty && emailNotEmpty && hasConnection) {
      signIN();
    } else if (hasConnection == false) {
      setState(() {
        signInError = "Please Check Your Connection";
      });
    } else {
      setState(() {
        signInError = "Please fill out properly";
      });
    }
  }

  void leaveSignInPage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const RegisterationPage()));
  }

  void leavePhoneSignToPage() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const SignInPhoneNumberPage()));
  }

  String determineUserAlert() {
    switch (isNotSignedIn) {
      case true:
        return signInError;

      case false:
        return "";

      default:
        return "";
    }
  }

  void cleanUp() {
    emailField.clear();
    passwordField.clear();
    debugPrint("fields cleared");
  }

  Future<void> signIN() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailField.text, password: passwordField.text);
      // we will delete any account with  unverified email
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
        cleanUp();
        subscription.cancel();
        //SharedPreferences pref = await SharedPreferences.getInstance();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const DigiHub()),
            (Route<dynamic> route) => false);
      } else {
        FirebaseAuth.instance.currentUser!.delete();
        setState(() {
          signInError = "user was not verified, Deleted";
        });
      }

      // time to navigate

    } on FirebaseAuthException catch (e) {
      setState(() {
        signInError = e.code;
      });
    } catch (e) {
      setState(() {
        signInError = "Could Not Sign In";
      });
      print(e);
    }
  }
}

///****************password reset teritory *********/

class PasswordResetPopUp extends StatefulWidget {
  const PasswordResetPopUp({Key? key}) : super(key: key);

  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<PasswordResetPopUp> {
  TextEditingController emailField = TextEditingController();
  TextEditingController codeField = TextEditingController();

  String resetPassAlert = "";

  _MyDialogState();

  @override
  void initState() {
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
            height: MediaQuery.of(context).size.height * 0.3,
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
                inputField(
                    controller: emailField,
                    hintText: "Example@email.com",
                    labelText: "Email Adress"),
                // ignore: sized_box_for_whitespace
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [button1(emailField.text), button2()],
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
          Navigator.pop(context);
        },
        child: const Text(
          "Done",
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
          if (emailAdress.isNotEmpty) {
            try {
              await FirebaseAuth.instance
                  .sendPasswordResetEmail(email: emailAdress);
              setState(() {
                resetPassAlert = "check ${emailField.text} to reset password";
              });
            } on FirebaseAuthException catch (e) {
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
            await FirebaseAuth.instance
                .sendPasswordResetEmail(email: emailAdress);
            setState(() {
              resetPassAlert = "check ${emailField.text} to reset password";
            });
          } on FirebaseAuthException catch (e) {
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
