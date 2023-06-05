import 'dart:async';
import 'dart:ui';
/*  */
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_project/UI/AUTH_pages/signin_or_register.dart';
import 'package:my_project/UI/home_pages/settings/password_reset.dart';
import 'package:my_project/UI/home_pages/settings/profile.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart' as network_connection;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  late FToast ftoast;
  bool notifCheck = true;
  /*  bool networkConnection = false;
  late StreamSubscription<network_connection.ConnectivityResult> subscription;
 */
  late SharedPreferences pref;
  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      pref = value;
      setState(() {
        notifCheck = pref.getString('notif') != 'true' ? false : true;
      });
    });
    /*  subscription = network_connection.Connectivity()
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
    }); */
    ftoast = FToast();
    //ftoast.init(context);
    super.initState();
  }

  @override
  void dispose() {
    // subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
              fontSize: 30,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        centerTitle: false,
        titleSpacing: 70,
        backgroundColor: Colors.white,
        //foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            subscriptionBanner(),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 10),
              child: Text(
                "Acount",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            profile(),
            settingTilesPassword(
                const FaIcon(FontAwesomeIcons.lock), "Password"),
            settingTileNotif(
                const FaIcon(FontAwesomeIcons.bell), "Notifications"),
            settingTileDeleteAccount(
                const FaIcon(Icons.no_accounts_outlined), "Delete Account"),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            const Padding(
              padding: EdgeInsets.only(
                left: 15.0,
              ),
              child: Text(
                "More",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
            settingTiles(
                const FaIcon(FontAwesomeIcons.star), "Rating & Feedback"),
            settingTiles(const FaIcon(FontAwesomeIcons.questionCircle), "Help"),
            const Spacer(),
            Center(
                child: InkWell(
              splashColor: Colors.orange.withOpacity(0.4),
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.height * 0.07,
                child: const Center(
                  child: FittedBox(
                    child: Text(
                      "Log Out",
                      style: TextStyle(
                          fontSize: 25,
                          color: Color.fromARGB(255, 255, 160, 0),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              onTap: () {
                _showToast("LongPress To LogOut");
              },
              onLongPress: () async {
                //show a pop up dialog to make sure the user wants to go out
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.setString('pofileImageUrl', '');
                auth.FirebaseAuth.instance.signOut();
                print("signed out");
                // subscription.cancel();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const WellcomePage()),
                    (Route<dynamic> route) => false);
              },
            ))
          ],
        ),
      ),
    );
  }

  Widget subscriptionBanner() {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: ListTile(
          title: const Center(
            child: Text("Subscription",
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          subtitle: const Center(child: Text("Upgrade to Premium Version")),
          tileColor: const Color.fromARGB(255, 255, 161, 0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
    );
  }

  Widget settingTilesPassword(FaIcon icon, String text) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 15),
          leading: icon,
          title: Text(text),
          trailing: const FaIcon(FontAwesomeIcons.arrowRight),
        ),
      ),
      splashColor: Colors.amber.shade600,
      onTap: () {
        // subscription.cancel();
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: const PasswordResetPage()));
      },
    );
  }

  Widget settingTileNotif(FaIcon icon, String text) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: ListTile(
            contentPadding: const EdgeInsets.only(left: 15),
            leading: icon,
            title: Text(text),
            trailing: IconButton(
              icon: notifCheck
                  ? const FaIcon(Icons.notifications_on_sharp,
                      color: Colors.orange)
                  : const FaIcon(Icons.notifications_off_sharp,
                      color: Colors.grey),
              onPressed: () async {
                setState(() {
                  notifCheck = notifCheck == true ? false : true;
                });
                await pref.setString('notif', '$notifCheck');
              },
            )),
      ),
      splashColor: Colors.amber.shade600,
      onTap: () {},
    );
  }

  Widget settingTiles(FaIcon icon, String text) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 15),
          leading: icon,
          title: Text(text),
          /* trailing: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowRight),
              onPressed: () {},
            ) */
        ),
      ),
      splashColor: Colors.amber.shade600,
      onTap: () {},
    );
  }

  Widget settingTileDeleteAccount(FaIcon icon, String text) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 15),
          leading: icon,
          title: Text(text),
          /* trailing: IconButton(
              icon: const FaIcon(FontAwesomeIcons.arrowRight),
              onPressed: () {},
            ) */
        ),
      ),
      splashColor: Colors.amber.shade600,
      onTap: () async {
        if (network_connection.ConnectivityResult.none !=
            await network_connection.Connectivity().checkConnectivity()) {
          showDialog(
              context: context,
              builder: (BuildContext context) => BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 10,
                      sigmaY: 10,
                    ),
                    child: Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: SizedBox(
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FittedBox(
                                child: Text(
                                  "Are You Sure Want To DELETE Your Account?",
                                  style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade900),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [button(context), button2()],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ));
        } else {
          _showToast("Please Check Your Connection");
        }
      },
    );
  }

  Widget button(BuildContext mainContext) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          try {
            // delete account and user related date in firebase
            SharedPreferences prefMemory =
                await SharedPreferences.getInstance();
            String? url = prefMemory.getString('pofileImageUrl');
            String id = auth.FirebaseAuth.instance.currentUser!.uid;
            await prefMemory.setString('pofileImageUrl', '');
            await FirebaseFirestore.instance
                .collection("Participant")
                .doc(id)
                .collection('MoreUserInfo')
                .doc('info')
                .delete();
            print('info deleted');
            await FirebaseFirestore.instance
                .collection("Participant")
                .doc(id)
                .delete();
            print('id  deleted');
            print('user data deleted');
            if (url != null) {
              if (url.isNotEmpty) {
                await storage.FirebaseStorage.instance.refFromURL(url).delete();
                print('user image Deleted');
              }
            }
            await auth.FirebaseAuth.instance.currentUser!.delete();
            print("account deleted");

//subscription.cancel();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WellcomePage()),
                (route) => false);
          } on auth.FirebaseAuthException catch (e) {
            print(e.code);
          } on storage.FirebaseException catch (e) {
            // subscription.cancel();
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WellcomePage()),
                (route) => false);
            print(e.code);
          } catch (e) {
            print(e);
          }

          //await authPass.PasswordReset.resetPassword(emailAdress: emailAdress);
        },
        child: const Text(
          "Delete",
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

  Widget button2() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          //subscription.cancel();
          Navigator.pop(context);
          //await authPass.PasswordReset.resetPassword(emailAdress: emailAdress);
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

  Widget settingTileProfile(FaIcon icon, String text) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 15),
          leading: icon,
          title: Text(text),
          trailing: const FaIcon(FontAwesomeIcons.arrowRight),
        ),
      ),
      splashColor: Colors.amber.shade600,
      onTap: () async {
        // await subscription.cancel();
        Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const Profile()))
            .then((value) {
          setState(() {});
        });
      },
    );
  }

  _showToast(String text) {
    ftoast.init(context);
    Widget toast = Card(
        elevation: 10,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: Colors.white,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FontAwesomeIcons.timesCircle),
              const SizedBox(
                width: 12.0,
              ),
              FittedBox(
                child: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ));

    ftoast.showToast(
      child: toast,
      fadeDuration: const Duration(seconds: 2),
      gravity: ToastGravity.TOP,
      toastDuration: const Duration(seconds: 2),
    );
  }

  Widget profile() {
    return settingTileProfile(const FaIcon(FontAwesomeIcons.user), "Profile");
  }
}
