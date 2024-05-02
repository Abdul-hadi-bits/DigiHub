import 'package:digi_hub/Business_Logic/Chat_Logic/bloc/chat_bloc.dart';
import 'package:digi_hub/Business_Logic/Settings_Logic/Delete_Acount_Logic/bloc/delete_acount_bloc.dart';
import 'package:digi_hub/Data_Layer/Module/Cache_Memory_Module.dart';
import 'package:digi_hub/Data_Layer/Module/Local_noSql_Module.dart';
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/settings/deleteAcount/delete_acount.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../Business_Logic/Settings_Logic/bloc/settings_bloc.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<SettingsBloc>().add(SettingsLoadRequired());

    return Scaffold(
      appBar: MyAppBar(
        ttle: "Settings",
        context: context,
        titleSpacing: 70,
        fitTitle: true,
        italikTitle: true,
        showLeading: false,
        statusBarDark: false,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubscriptionBanner(),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 10),
              child: Text(
                "Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ProfileTile(),
            SettingsPasswordTile(),
            SettingsDeleteAccountTile(),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 10),
              child: Text(
                "Global",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SettingNotificationTile(),
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
            SettingsRatingAndFeedBackTile(),
            SettingsHelpTile(),
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
                onTap: () async {
                  confirmDialog(
                    context: context,
                    alertText: "Logout ?",
                    confirmButton: TextButton(
                      onPressed: () async {
                        CacheMemory.cacheMemory.clear();

                        /// delete local database which stores chat stuff.!!!!!!!!!!!!1
                        await LocalMemory.deleteDb;
                        await LocalMemory.initializeDb;

                        auth.FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            "/WellcomePage", (Route<dynamic> route) => false);
                      },
                      child: Text(
                        "Yes",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    cancelButton: TextButton(
                      onPressed: () {
                        /*  if (context.read<ChatBloc>().state.status !=
                            ChatStatus.deleteConversationInProgress) */
                        Navigator.pop(context);
                      },
                      child: Text(
                        "No",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                  //show a pop up dialog to make sure the user wants to go out
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SubscriptionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

class ProfileTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 15),
          leading: Icon(CupertinoIcons.profile_circled),
          title: Text("Profile"),
          trailing: const Icon(Icons.chevron_right_rounded, size: 40),
        ),
      ),
      splashColor: Colors.amber.shade50,
      onTap: () async {
        // await subscription.cancel();
        Navigator.pushNamed(
          context,
          "/ProfilePage",
          /*  PageTransition(
              type: PageTransitionType.rightToLeft, child: const Profile()), */
        );
      },
    );
  }
}

class SettingsPasswordTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 15),
          leading: Icon(FontAwesomeIcons.lock),
          title: Text("Password"),
          trailing: const Icon(Icons.chevron_right_rounded, size: 40),
        ),
      ),
      splashColor: Colors.amber.shade50,
      onTap: () {
        // subscription.cancel();
        Navigator.pushNamed(
          context,
          "/PasswordResetPage",
          /* PageTransition(
                type: PageTransitionType.rightToLeft,
                child: const PasswordResetPage()), */
        );
      },
    );
  }
}

class SettingNotificationTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (previous, current) {
          print(current);

          if (current.isNotificationOn != previous.isNotificationOn) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          return ListTile(
              contentPadding: const EdgeInsets.only(left: 15),
              leading: Icon(FontAwesomeIcons.bell),
              title: Text("Notification"),
              trailing: IconButton(
                icon: state.isNotificationOn
                    ? const FaIcon(Icons.notifications_on_sharp,
                        color: Colors.orange)
                    : const FaIcon(Icons.notifications_off_sharp,
                        color: Colors.grey),
                onPressed: () async {
                  context
                      .read<SettingsBloc>()
                      .add(SettingsNotificationUpdated());
                },
              ));
        },
      ),
    );
  }
}

class SettingsRatingAndFeedBackTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 15),
          leading: Icon(FontAwesomeIcons.star),
          title: Text("Rating & Feedback"),
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
}

class SettingsHelpTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 15),
          leading: Icon(CupertinoIcons.question_circle_fill),
          title: Text("Help"),
        ),
      ),
      splashColor: Colors.amber.shade600,
      onTap: () {},
    );
  }
}

class SettingsDeleteAccountTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: SizedBox(
        height: 50,
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 15),
          leading: Icon(CupertinoIcons.delete),
          title: Text("Delete Acount"),
          trailing: const Icon(Icons.chevron_right_rounded, size: 40),
        ),
      ),
      splashColor: Colors.amber.shade50,
      onTap: () async {
        // go to delete acount page
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => MultiBlocProvider(providers: [
                      BlocProvider(
                        create: (context) => DeleteAcountBloc(),
                      ),
                      BlocProvider.value(value: context.read<ChatBloc>())
                    ], child: DeleteAcountPage())));
      },
    );
  }
}
