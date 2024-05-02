import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/phoneSignInCubit.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/phoneSignInState.dart';
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import "package:flutter/material.dart";

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class EnterCodePage extends StatelessWidget {
  EnterCodePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhoneSignInCubit, PhoneSignInState>(
        listener: (context, state) async {
          if (state.status == PhoneSignInStatus.codeVerifySuccess) {
            context.read<PhoneSignInCubit>().stopTimer();

            Navigator.pushReplacementNamed(context, "/DigiHubPage");
          }
          if (state.status == PhoneSignInStatus.codeVerifyError) {
            errorDialog(context, state.loginError);
            if (state.codeTimedOut) {
              context.read<PhoneSignInCubit>().stopTimer();

              await Future.delayed(Duration(seconds: 3));
              Navigator.pop(context);
              Navigator.pop(context);
            }
          }
        },
        child: Scaffold(
          appBar: MyAppBar(
            context: context,
            ttle: "Change Number",
            onPressed: () {
              context.read<PhoneSignInCubit>().stopTimer();

              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.white,
          body: ProgressHUD(
            inAsyncCall: context.watch<PhoneSignInCubit>().state.status ==
                PhoneSignInStatus.inProgressState,
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.87,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(
                          height: 50,
                        ),
                        const Text("Enter smsCode to Sign In",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 20,
                        ),
                        CodeEnterField(),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: LoginButton().marginOnly(bottom: 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyLongElevatedTextButton(
        onPressed: () =>
            context.read<PhoneSignInCubit>().signInWithPhoneNumber(),
        text: "Login");
  }
}

class CodeEnterField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: BlocBuilder<PhoneSignInCubit, PhoneSignInState>(
          buildWhen: (previous, current) =>
              previous.smsCodeField != current.smsCodeField,
          builder: (context, state) {
            return MyPinCodeTextField(
              onChanged: (value) {
                context.read<PhoneSignInCubit>().codeChanged(code: value);
              },
            );
          },
        ),
      ),
    );
  }
}
