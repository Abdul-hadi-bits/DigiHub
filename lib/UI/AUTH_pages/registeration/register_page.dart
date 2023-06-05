// ignore_for_file: avoid_unnecessary_containers

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
/* import 'package:data_connection_checker_tv/data_connection_checker.dart'
    as data_connection; */
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:my_project/UI/AUTH_pages/registeration/link_with_phone_number.dart';

import 'package:my_project/UI/AUTH_pages/sign_in/email_sign_in.dart';

import 'package:my_project/UI/home_pages/home_page.dart';
import 'package:page_transition/page_transition.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as network_connection;

import 'package:crypto/crypto.dart' as encrypt;

class RegisterationPage extends StatefulWidget {
  const RegisterationPage({Key? key}) : super(key: key);

  @override
  _RegisterationPageState createState() => _RegisterationPageState();
}

class _RegisterationPageState extends State<RegisterationPage> {
  static String selectedGender = "not specified";

  static String registrationError = "";

  int counter = 0;
  String error = "";
  String error2 = "";
  bool isReady = false;

  static TextEditingController emailField = TextEditingController();
  static TextEditingController passwordField = TextEditingController();
  static TextEditingController confirmPasswordField = TextEditingController();
  static TextEditingController userNameField = TextEditingController();
  //static TextEditingController phoneNumberField = TextEditingController();
  static TextEditingController birthDateField = TextEditingController();

  bool networkConnection = false;
  static late StreamSubscription<network_connection.ConnectivityResult>
      subscription;

  @override
  void initState() {
    super.initState();
    subscription = network_connection.Connectivity()
        .onConnectivityChanged
        .listen((network_connection.ConnectivityResult result) {
      print(result.name);
      if (result != network_connection.ConnectivityResult.none) {
        networkConnection = true;
      } else {
        networkConnection = false;
      }
    });

    // ... any code here ...
  }

  @override
  void dispose() {
    registrationError = "";

    emailField.clear();
    passwordField.clear();
    userNameField.clear();
    selectedGender = 'not specified';
    confirmPasswordField.clear();
    subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.1,
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
          "Registeration",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        //titleSpacing: MediaQuery.of(context).size.width ,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: userAlert(),
                  ),
                  inputField(
                      controller: emailField,
                      hintText: "Example@email.com",
                      labelText: "Email Adress"),
                  //  const SizedBox(height: 20),
                  inputFieldPass(
                      controller: passwordField,
                      hintText: "Password",
                      labelText: "Password"),
                  // const SizedBox(height: 20),
                  inputFieldPassCon(
                      controller: confirmPasswordField,
                      hintText: "Password",
                      labelText: "Confirm Password"),
                  // const SizedBox(height: 20),
                  inputField(
                      controller: userNameField,
                      hintText: "Your Name",
                      labelText: "Name"),
                  //  const SizedBox(height: 20),
                  genderField(),
                  userAgreement(),
                ],
              ),
              SizedBox(
                child: button(),
              ),
              // const SizedBox(height: 0),
              //  userAgreement(),
              //  const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget button() {
    setState(() {
      registrationError = "";
    });

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          prepareForRegisteration();
        },
        child: const Text("Register"),
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

  Widget userAgreement() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: const Text(
        "By creating an account you will agree to our terms and sevices",
        overflow: TextOverflow.clip,
        style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black), //Color.fromARGB(255, 255, 160, 0)),
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
              registrationError = "";
            },
            onChanged: (text) {
              registrationError = "";
              if (text.length < 6) {
                error = "too short";
                isReady = false;
                setState(() {});
              } else {
                error = "";
                setState(() {});
                isReady = true;
              }
            },
            onSubmitted: (text) {
              if (text.isEmpty) {
                setState(() {
                  error = "";
                  isReady = false;
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
              registrationError = "";
            },
            onChanged: (text) {
              registrationError = "";
              if (text != passwordField.text) {
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

  Widget genderField() {
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Container(
        //
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.grey,
          ),
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.09,
        child: DropdownButton(
            dropdownColor: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(15),
            enableFeedback: true,
            isExpanded: true,
            value: selectedGender,
            icon: const Icon(Icons.keyboard_arrow_down),
            items: [
              const DropdownMenuItem(
                child: Text(
                  "Gender",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                value: "not specified",
              ),
              DropdownMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.man_rounded),
                    Text(
                      "Male",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                value: "male",
              ),
              DropdownMenuItem(
                child: Row(
                  children: const [
                    Icon(Icons.woman_rounded),
                    Text(
                      "Female",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                value: "female",
              )
            ],
            onChanged: (String? newGend) {
              selectedGender = newGend!;
              setState(() {});
            }),
      ),
    );
  }

  Widget inputField(
      {required TextEditingController controller,
      required String hintText,
      required String labelText}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: TextField(
            onTap: () {
              setState(() {
                registrationError = "";
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
      ),
    );
  }

  ///***********************Widgets use in this page ********************************/

  Widget toSignInPage() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Already have an Account ?"),
          TextButton(
              child: const Text("Sign In"),
              onPressed: () {
                leaveRegisterPage();
              })
        ]);
  }

  Widget userAlert() {
    return Center(
      child: Text(
        registrationError,
        style: const TextStyle(
            fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),
      ),
    );
  }

  ///**************** Actions while pressing Register Button ********************/
  void leaveRegisterPage() async {
    try {
      emailField.clear();
      passwordField.clear();
      confirmPasswordField.clear();

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const SignInPage()));
    } catch (e) {
      print(e);
    }
  }

  String determineUserAlert() {
    return registrationError;
  }

  prepareForRegisteration() async {
    bool hasConnection = networkConnection;
    bool passwordNotEmpty = passwordField.text.isNotEmpty;
    bool emailNotEmpty = emailField.text.isNotEmpty;
    bool confirmPasswordNotEmpty = confirmPasswordField.text.isNotEmpty;

    hasConnection
        ? emailNotEmpty
            ? passwordNotEmpty
                ? isReady
                    ? confirmPasswordNotEmpty
                        ? confirmPasswordField.text == passwordField.text
                            // ignore: unnecessary_statements
                            ? {registerUsingEmail()}
                            // ignore: unnecessary_statements
                            : {
                                setState(() {
                                  registrationError = "passwords don't match";
                                })
                              }
                        // ignore: unnecessary_statements
                        : {
                            setState(() {
                              registrationError = "confirm password is empty";
                            })
                          }
                    // ignore: unnecessary_statements
                    : {
                        setState(() {
                          registrationError = "please fix the error";
                        })
                      }
                // ignore: unnecessary_statements
                : {
                    setState(() {
                      registrationError = "password is empty";
                    })
                  }
            // ignore: unnecessary_statements
            : {
                setState(() {
                  registrationError = "Email is empty";
                })
              }
        // ignore: unnecessary_statements
        : {
            setState(() {
              registrationError = "Please check Your connecetion";
            })
          };
  }

  Future<void> registerUsingEmail() async {
    try {
      //await auth.FirebaseAuth.instance.signOut();
      await auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailField.text, password: passwordField.text)
          .then((value) async {
        print('added user :' +
            auth.FirebaseAuth.instance.currentUser!.email.toString());

        verificationPopUpDialog();
      });

      // show pop up verify
    } on auth.FirebaseAuthException catch (e) {
      setState(() {
        registrationError = e.code;
      });
      print(e.code);
    } catch (e) {
      setState(() {
        registrationError = "Could Not Register";
      });
      print(e);
    }
  }

  verificationPopUpDialog() {
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
            child: const MyDialog(),
          );
        });
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog({
    Key? key,
  }) : super(key: key);
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  String verificationAlerts = "Please Verify It";
  int count = 120;

  var _timer;
  String emailText = "";

  bool isVertificationDone = false;

  @override
  void initState() {
    super.initState();
    sendVertificationEmail();
  }

  @override
  void dispose() {
    super.dispose();

    cleanUp();
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
              "Verificaton",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600),
            ),
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
                height: 200,
                child: Center(
                  child: SizedBox(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height: 30,
                              child: FittedBox(
                                child: RichText(
                                  overflow: TextOverflow.visible,
                                  text: TextSpan(
                                    text: "An Email is sent to ",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: emailText,
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
                            Visibility(
                              visible: emailText.isNotEmpty,
                              child: Text(
                                verificationAlerts,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.clip),
                              ),
                            ),
                          ],
                        ),
                        Text("$count",
                            style: const TextStyle(
                                fontSize: 35, fontWeight: FontWeight.bold)),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [button2(), button3(), button1()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              /* ElevatedButton(
                onPressed: isVertificationDone
                    ? () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const AddPhoneNumber();
                        }));
                      }
                    : () {},
                style: ElevatedButton.styleFrom(
                    primary: isVertificationDone ? Colors.blue : Colors.grey),
                child: Text("done",
                    style: TextStyle(
                        color:
                            isVertificationDone ? Colors.white : Colors.black)),
              ), */
            ],
          )
        ]);
  }

  Widget button2() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          await canceldRegisteration();
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
        onPressed: isVertificationDone
            ? () {
                _RegisterationPageState.subscription.cancel;
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: const AddPhoneNumber()));
              }
            : () {},
        child: const FittedBox(
          child: Text(
            "Done",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        style: ElevatedButton.styleFrom(
          //  elevation: 5,
          primary: isVertificationDone
              ? const Color.fromARGB(255, 255, 160, 0)
              : Colors.grey,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Widget button3() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: count == 0
            ? () {
                setState(() {
                  count = 120;
                });
                sendVertificationEmail();
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

  Future<void> addToRealTimeDatabase() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("Participants/");
      DatabaseReference refTwo = FirebaseDatabase.instance.ref("UserData/");
      var user = auth.FirebaseAuth.instance.currentUser!;
      String id = auth.FirebaseAuth.instance.currentUser!.uid;
      String name = "";

      String emailAddress = user.email.toString();
      String hashedEmailAddress =
          encrypt.sha256.convert(utf8.encode(emailAddress)).toString();

      print(hashedEmailAddress);

      await FirebaseFirestore.instance
          .collection("Participant")
          .doc(id)
          .get()
          .then((response) async {
        Map<String, dynamic> data = response.data()!;
        name = data['firstName'];
        print(name);

        await ref.set({
          hashedEmailAddress: {
            "EmailAddress": emailAddress,
            "Name": name,
            "ImageLink": "",
            "Status": "",
            "Requests": {},
          }
        }).then((value) => print("data was added to realtime database"));

        await refTwo.set({
          hashedEmailAddress: {
            "Conversations": {},
            "Messages": {},
          }
        }).then((value) => print("second data was added to realtime database"));
      });
    } on auth.FirebaseException catch (e) {
      print("firebase exception " + e.code);
      print("second data not added to database real");
    } catch (e) {
      print(e.toString());
      print("second data not added to database real");
    }
  }

  void sendVertificationEmail() async {
    try {
      String? email = auth.FirebaseAuth.instance.currentUser!.email;
      print(email);
      await auth.FirebaseAuth.instance.currentUser!.reload();
      await auth.FirebaseAuth.instance.currentUser!
          .sendEmailVerification()
          .then((value) {
        setState(() {
          if (email != null) {
            emailText = email;
          }
          verificationAlerts = "Please Verify It";
        });
        verificationListener();
      });
      //  then alert user and start listner

      print("email is sent $email");
    } on auth.FirebaseAuthException catch (e) {
      setState(() {
        verificationAlerts = e.code;
      });
    } catch (e) {
      setState(() {
        verificationAlerts = "Could not Send Vertification Email ";
      });
    }
  }

  void verificationListener() {
    Future(() {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        setState(() {
          count -= 1;
        });

        count == 0 ? timer.cancel() : false;

        auth.User? user = auth.FirebaseAuth.instance.currentUser;
        try {
          await user!.reload();
          if (auth.FirebaseAuth.instance.currentUser!.emailVerified) {
            addUserData();
            timer.cancel();
            setState(() {
              verificationAlerts = "User is Verified";
              isVertificationDone = true;
            });
            print("verified");
          }
        } on auth.FirebaseAuthException catch (e) {
          setState(() {
            verificationAlerts = e.code;
          });

          print(e);
        } catch (e) {
          print(e);
          setState(() {
            verificationAlerts = "User is Not Valid";
          });
        }
      });
    });
  }

  Future<void> cleanUp() async {
    if (_timer != null) {
      print(" timer canceled");
      _timer!.cancel();
      print("timer canceled");
    }
  }

  Future<void> canceldRegisteration() async {
    try {
      auth.User user = auth.FirebaseAuth.instance.currentUser!;

      await FirebaseFirestore.instance
          .collection("Participant")
          .doc(user.uid)
          .delete();
      print("user data is deleted");

      await user.delete();

      print("user is deleted");
    } on auth.FirebaseAuthException catch (e) {
      verificationAlerts = e.code;
      Navigator.pop(context);

      print(e);
    } catch (e) {
      print(e);
    }
  }

  void addUserData() async {
    try {
      String name = _RegisterationPageState.userNameField.text;

      String gender = _RegisterationPageState.selectedGender;
      String id = auth.FirebaseAuth.instance.currentUser!.uid;
      Map<String, dynamic> userData = {'firstName': name, 'gender': gender};
      await FirebaseFirestore.instance
          .collection("Participant")
          .doc(id)
          .set(userData);
      print("user Data is added");
      await addToRealTimeDatabase();
    } on auth.FirebaseException catch (e) {
      setState(() {
        verificationAlerts = e.code;
      });
      verificationAlerts = e.code;
      print(e.code);
    } catch (e) {
      print(e);
    }
  }
}
