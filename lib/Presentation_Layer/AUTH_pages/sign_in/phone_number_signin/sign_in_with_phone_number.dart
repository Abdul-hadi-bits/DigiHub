import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/phoneSignInCubit.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/phoneSignInState.dart';

import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/sign_in/phone_number_signin/enter_code_sign_in_page.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SignInPhoneNumberPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PhoneSignInCubit, PhoneSignInState>(
      listener: (context, state) {
        // errorDialog(context, "errro");
        if (state.status == PhoneSignInStatus.codeSentSuccessState) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<PhoneSignInCubit>(context),
                  child: EnterCodePage(),
                ),
              ));
        }
        if (state.status == PhoneSignInStatus.errorState) {
          errorDialog(context, state.loginError);
        }
      },
      child: Scaffold(
          appBar: MyAppBar(
              context: context,
              ttle: "Wellcome Back",
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Colors.white,
          body: ProgressHUD(
            inAsyncCall: context.watch<PhoneSignInCubit>().state.status ==
                PhoneSignInStatus.inProgressState,
            child: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 50),
                          LoginText(),
                          const SizedBox(height: 10),
                          Center(child: PhoneTextField()),
                          LoginTextMore(),
                        ],
                      ),
                      Column(
                        children: [
                          SendButton().paddingOnly(
                              bottom: MediaQuery.of(context).viewInsets.bottom *
                                  0.85),
                          EmailSignInText(),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}

class LoginText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.9,
        child: const Text(
          "Login to your account",
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}

class LoginTextMore extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          top: 8.0, left: MediaQuery.of(context).size.width * 0.05),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.7,
        child: const Text(
            "An SMS Code will be sent to your number to log you in",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            overflow: TextOverflow.clip),
      ),
    );
  }
}

class EmailSignInText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        child: Center(
          child: TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateColor.resolveWith(
                (states) => const Color.fromARGB(50, 255, 170, 0),
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
              Navigator.pushNamed(
                context,
                "/SignInWithEmailPage",
                /* PageTransition(
                                      type: PageTransitionType.rightToLeft,
                                      child: const SignInPage()), */
              );
            },
          ),
        ),
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyLongElevatedTextButton(
        onPressed: () async {
          await context.read<PhoneSignInCubit>().sendOTPverificationCode();
        },
        text: "Continue");
  }
}

class PhoneTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PhoneSignInCubit, PhoneSignInState>(
      buildWhen: (previous, current) =>
          current.phoneNumberField != previous.phoneNumberField,
      builder: (context, state) {
        return MyTextField(
          hintText: "750 xxxx xxx",
          obscureText: false,
          maxLength: 10,
          prefixText: "+964",
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          keyboardType: TextInputType.phone,
          errorMsg:
              state.inputFieldError.isNotEmpty ? state.inputFieldError : null,
          label: "Phone Number",
          prefixIcon: Icon(CupertinoIcons.phone_fill),
          onChanged: (text) {
            context.read<PhoneSignInCubit>().phoneChanded(phone: text);
          },
        );
      },
    );
  }
}
