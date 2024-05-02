// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/emailSiginInCubit.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/emailSignInState.dart';
import 'package:get/get.dart';

class SignInPage extends StatelessWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmailSignInCubit, EmailSignInState>(
      listener: (context, state) {
        print(state.status);
        if (state.status == EmailSignInStatus.successfulState) {
          Navigator.pushNamedAndRemoveUntil(
              context, "/DigiHubPage", (route) => false);
        }
        if (state.status == EmailSignInStatus.errorState) {
          errorDialog(context, state.signInError);
        }
      },
      child: ProgressHUD(
        inAsyncCall: context.watch<EmailSignInCubit>().state.status ==
            EmailSignInStatus.progressState,
        opacity: 0.0,
        child: Scaffold(
            appBar: MyAppBar(
              context: context,
              ttle: "Login",
              onPressed: () => Navigator.pop(context),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Container(
                  color: Colors.white,
                  height: (MediaQuery.of(context).size.height * 0.877),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 50),
                          Center(child: EmailField()),
                          const SizedBox(height: 20),
                          Center(child: PasswordField()),
                          const SizedBox(height: 0),
                          ForgotPasswordText(),
                        ],
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: MyLongElevatedTextButton(
                            text: "Sign In",
                            onPressed: () async {
                              context.read<EmailSignInCubit>().signIN();
                            },
                          ).marginOnly(bottom: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}

class PasswordResetPopUp extends StatelessWidget {
  const PasswordResetPopUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MySimpleDialog(
      titleChild: Text(
        "Password Reset",
        style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade600),
      ),
      children: [
        Text(
          "Send A Password Reset Email",
          style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade600,
              overflow: TextOverflow.clip),
        ).paddingOnly(left: 15),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AlertText(),
            EmailField(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  MySmallElevatedTextButton(
                    text: "Send",
                    onPressed: () async {
                      context.read<EmailSignInCubit>().sendPassResetEmail();
                    },
                  ),
                  MySmallElevatedTextButton(
                    text: "Done",
                    onPressed: () async {
                      Navigator.pop(context);
                      context.read<EmailSignInCubit>().popUpDialogClosed();
                    },
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

class AlertText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<EmailSignInCubit, EmailSignInState>(
        buildWhen: (previous, current) =>
            current.status == EmailSignInStatus.emailPasswordResetErrorState ||
            current.status == EmailSignInStatus.emailPasswordResetSuccessState,
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Text(
              state.passwordResetAlert,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmailSignInCubit, EmailSignInState>(
      buildWhen: (previous, current) => current.email != previous.email,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: MyTextField(
            obscureText: false,
            onChanged: (value) {
              context.read<EmailSignInCubit>().emailChanged(email: value);
            },
            hintText: "Example@Email.com",
            prefixIcon: const Icon(CupertinoIcons.mail_solid),
            label: "Email Address",
            keyboardType: TextInputType.emailAddress,
          ),
        );
      },
    );
  }
}

class PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmailSignInCubit, EmailSignInState>(
      buildWhen: (previous, current) =>
          previous.password != current.password ||
          previous.hidePassword != current.hidePassword,
      builder: (context, state) {
        return MyTextField(
          onChanged: (text) {
            context.read<EmailSignInCubit>().passwordChanged(password: text);
          },
          label: "Password",
          obscureText: state.hidePassword,
          prefixIcon: Icon(state.hidePassword
              ? CupertinoIcons.lock_fill
              : CupertinoIcons.lock_open_fill),
          suffixIcon: IconButton(
            onPressed: () {
              context.read<EmailSignInCubit>().toggleObsecurePassword();
            },
            icon: Icon(state.hidePassword
                ? CupertinoIcons.eye_slash_fill
                : CupertinoIcons.eye_fill),
          ),
          errorMsg: state.passwordError.isEmpty || state.password.isEmpty
              ? null
              : state.passwordError,
          hintText: "Password",
          keyboardType: TextInputType.visiblePassword,
        );
      },
    );
  }
}

class ForgotPasswordText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        onPressed: () {
          myCustomShowDialog(
            context: context,
            child: BlocProvider.value(
              value: BlocProvider.of<EmailSignInCubit>(context),
              child: PasswordResetPopUp(),
            ),
          );
        },
      ),
    );
  }
}
