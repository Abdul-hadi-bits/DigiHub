import 'package:digi_hub/Business_Logic/Chat_Logic/bloc/chat_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../../Business_Logic/Settings_Logic/Delete_Acount_Logic/bloc/delete_acount_bloc.dart';
import '../../../UI_elements/components.dart';

class DeleteAcountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        context: context,
        statusBarDark: false,
        ttle: "Acount Deletion",
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.white,
      body: BlocListener<DeleteAcountBloc, DeleteAcountState>(
        listener: (context, state) {
          if (state is DeleteAcountFailed) {
            errorDialog(context, state.deleteAcountError);
          }
          if (state is DeleteAcountSuccess) {
            Navigator.of(context).pushNamedAndRemoveUntil(
                "/WellcomePage", (Route<dynamic> route) => false);
          }
        },
        child: ProgressHUD(
          inAsyncCall:
              context.watch<DeleteAcountBloc>().state is DeleteAcountInProgress,
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 50),
                  AcountDeletionWarnning(),
                  PasswordField(),
                  Spacer(),
                  ConfrimButton().paddingOnly(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AcountDeletionWarnning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 50),
      child: Wrap(
        children: [
          Center(
            child: Icon(
              Icons.warning_rounded,
              color: Colors.red,
              size: 90,
            ),
          ),
          Text(
            "By deleting your account you will also delete all data acociated with It",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          )
        ],
      ),
    );
  }
}

class ConfrimButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyLongElevatedTextButton(
      text: "confirm",
      onPressed: () async {
        context
            .read<DeleteAcountBloc>()
            .add(AcountDeletedEvent(context.read<ChatBloc>().state));
      },
    );
  }
}

class PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteAcountBloc, DeleteAcountState>(
      buildWhen: (previous, current) =>
          (current.password != previous.password ||
              current.hidePassword != previous.hidePassword),
      builder: (context, state) {
        return MyTextField(
          hintText: "Password",
          label: "Password",
          textInputAction: TextInputAction.next,
          obscureText: state.hidePassword,
          prefixIcon: Icon(state.hidePassword
              ? CupertinoIcons.lock_fill
              : CupertinoIcons.lock_open_fill),
          suffixIcon: IconButton(
            onPressed: () {
              context.read<DeleteAcountBloc>().add(TogglePasswordEvent());
            },
            icon: Icon(state.hidePassword
                ? CupertinoIcons.eye_slash_fill
                : CupertinoIcons.eye_fill),
          ),
          keyboardType: TextInputType.text,
          errorMsg: state.passwordError.isNotEmpty ? state.passwordError : null,
          onChanged: (text) {
            context
                .read<DeleteAcountBloc>()
                .add(PasswordChangedEvent(password: text));
          },
        );
      },
    );
  }
}
/* 
class MyDialog extends StatefulWidget {
  const MyDialog({super.key});

  @override
  State<MyDialog> createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  String pass = "";
  TextEditingController passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 250,
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
              Padding(
                padding: EdgeInsets.only(right: 10, left: 10),
                child: TextField(
                    onChanged: (value) {
                      // passController.text = value;
                    },
                    controller: passController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 255, 160, 0),
                        ),
                      ),
                      hintText: "password",
                      label: Text("enter password"),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [button(context, pass), button2()],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget button(BuildContext mainContext, String password) {
    print(password);
    return SizedBox(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: () async {
          try {
            await reauthenticateUser(
                emailAddress: auth.FirebaseAuth.instance.currentUser!.email!,
                password: password,
                user: auth.FirebaseAuth.instance.currentUser!);
            // delete account and user related date in firebase
            SharedPreferences prefMemory =
                await SharedPreferences.getInstance();
            String? url = prefMemory.getString('pofileImageUrl');
            prefMemory.clear();

            String id = auth.FirebaseAuth.instance.currentUser!.uid;

            // await prefMemory.setString('pofileImageUrl', '');
            await FirebaseFirestore.instance
                .collection("users")
                .doc(id)
                .delete();
            print('user data  deleted');
            // print('user data deleted');
            if (url != null) {
              if (url.isNotEmpty) {
                await storage.FirebaseStorage.instance.refFromURL(url).delete();
                print('user image Deleted');
              }
            }

            await auth.FirebaseAuth.instance.currentUser!.delete();
            print("account deleted");

//subscription.cancel();
            Navigator.pushNamedAndRemoveUntil(
                context,
                "/",
                // MaterialPageRoute(builder: (context) => const WellcomePage()),
                (route) => false);
          } on auth.FirebaseAuthException catch (e) {
            print(e.code);
          } on storage.FirebaseException catch (e) {
            // subscription.cancel();
            Navigator.pushNamedAndRemoveUntil(
                context,
                "/",
                // MaterialPageRoute(builder: (context) => const WellcomePage()),
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
          backgroundColor: const Color.fromARGB(255, 255, 160, 0),

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
          passController.clear();
          //await authPass.PasswordReset.resetPassword(emailAdress: emailAdress);
        },
        child: const Text(
          "Cancel",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          //  elevation: 5,
          backgroundColor: const Color.fromARGB(255, 255, 160, 0),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  
}
 */
