import 'package:digi_hub/Business_Logic/Settings_Logic/Password_Reset/bloc/password_reset_bloc.dart';
import 'package:digi_hub/Data_Layer/Module/Cache_Memory_Module.dart';
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class PasswordResetPage extends StatelessWidget {
  const PasswordResetPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
          context: context,
          ttle: "Password Reset",
          statusBarDark: false,
          onPressed: () => Navigator.pop(context)),
      backgroundColor: Colors.white,
      body: BlocListener<PasswordResetBloc, PasswordResetState>(
        listener: (context, state) async {
          if (state.status == PasswordResetStatus.error) {
            errorDialog(context, state.error);
          }
          if (state.status == PasswordResetStatus.success) {
            await CacheMemory.cacheMemory.clear();

            Navigator.pushNamedAndRemoveUntil(
                context,
                "/SignInPhoneNumberPage",
                // MaterialPageRoute(builder: (context) => const SignInPage()),
                (route) => false);
          }
        },
        child: ProgressHUD(
          inAsyncCall: context.watch<PasswordResetBloc>().state.status ==
              PasswordResetStatus.inProgress,
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.87,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  NoticeText(),
                  const SizedBox(height: 20),
                  PasswordField(),
                  const SizedBox(height: 20),
                  NewPasswordField(),
                  const SizedBox(height: 20),
                  PasswordConfirmField(),
                  const SizedBox(height: 20),
                  LogoutAlertText(),
                  PasswordResetText(),
                  Spacer(),
                  UpdateButton().paddingOnly(
                      //bottom: MediaQuery.of(context).viewInsets.bottom +
                      bottom: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogoutAlertText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20),
      child: const Text(
        "Once the Password has changed you will be Logged Out!",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class NoticeText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, left: 20),
      child: FittedBox(
        child: RichText(
          text: TextSpan(
            text: "Changing Password for ",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                  text: context.read<PasswordResetBloc>().state.email,
                  style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<PasswordResetBloc, PasswordResetState>(
        buildWhen: (previous, current) =>
            (current.currentPassword != previous.currentPassword ||
                current.hideCurrentPassword != previous.hideCurrentPassword),
        builder: (context, state) {
          return MyTextField(
            hintText: "Current Password",
            label: "Current Password",
            textInputAction: TextInputAction.next,
            obscureText: state.hideCurrentPassword,
            prefixIcon: Icon(state.hideCurrentPassword
                ? CupertinoIcons.lock_fill
                : CupertinoIcons.lock_open_fill),
            suffixIcon: IconButton(
              onPressed: () {
                context
                    .read<PasswordResetBloc>()
                    .add(PasswordResetTogglePasswords(currentPassword: true));
              },
              icon: Icon(state.hideCurrentPassword
                  ? CupertinoIcons.eye_slash_fill
                  : CupertinoIcons.eye_fill),
            ),
            keyboardType: TextInputType.text,
            errorMsg: state.currentPasswordError.isNotEmpty
                ? state.currentPasswordError
                : null,
            onChanged: (text) {
              context.read<PasswordResetBloc>().add(
                  PasswordResetEdittedCurrentPasswordEvent(password: text));
            },
          );
        },
      ),
    );
  }
}

class NewPasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<PasswordResetBloc, PasswordResetState>(
        buildWhen: (previous, current) =>
            (current.newPassword != previous.newPassword ||
                current.hideNewPassword != previous.hideNewPassword),
        builder: (context, state) {
          return MyTextField(
            hintText: "New Password",
            label: "New Password",
            textInputAction: TextInputAction.next,
            obscureText: state.hideNewPassword,
            prefixIcon: Icon(state.hideNewPassword
                ? CupertinoIcons.lock_fill
                : CupertinoIcons.lock_open_fill),
            suffixIcon: IconButton(
              onPressed: () {
                context
                    .read<PasswordResetBloc>()
                    .add(PasswordResetTogglePasswords(newPassword: true));
              },
              icon: Icon(state.hideNewPassword
                  ? CupertinoIcons.eye_slash_fill
                  : CupertinoIcons.eye_fill),
            ),
            keyboardType: TextInputType.text,
            errorMsg: state.newPasswordError.isNotEmpty
                ? state.newPasswordError
                : null,
            onChanged: (text) {
              context
                  .read<PasswordResetBloc>()
                  .add(PasswordResetEdittedNewPasswordEvent(newPassword: text));
            },
          );
        },
      ),
    );
  }
}

class PasswordConfirmField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<PasswordResetBloc, PasswordResetState>(
        buildWhen: (previous, current) => (current.confirmNewPassword !=
                previous.confirmNewPassword ||
            current.hideConfrimNewPassword != previous.hideConfrimNewPassword),
        builder: (context, state) {
          return MyTextField(
            hintText: "Confirm Password",
            label: "Confirmed Password",
            textInputAction: TextInputAction.next,
            obscureText: state.hideConfrimNewPassword,
            prefixIcon: Icon(state.hideConfrimNewPassword
                ? CupertinoIcons.lock_fill
                : CupertinoIcons.lock_open_fill),
            suffixIcon: IconButton(
              onPressed: () {
                context
                    .read<PasswordResetBloc>()
                    .add(PasswordResetTogglePasswords(confirmPassword: true));
              },
              icon: Icon(state.hideConfrimNewPassword
                  ? CupertinoIcons.eye_slash_fill
                  : CupertinoIcons.eye_fill),
            ),
            keyboardType: TextInputType.text,
            errorMsg: state.confirmNewPasswordError.isNotEmpty
                ? state.confirmNewPasswordError
                : null,
            onChanged: (text) {
              context.read<PasswordResetBloc>().add(
                  PasswordResetEdittedConfirmNewPasswordEvent(
                      confirmNewPassword: text));
            },
          );
        },
      ),
    );
  }
}

class UpdateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: MyLongElevatedTextButton(
          onPressed: () {
            context.read<PasswordResetBloc>().add(PasswordResetUpdatedEvent());
          },
          text: "Confirm"),
    );
  }
}

class PasswordResetText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: TextButton(
          child: const Text(
            "Reset Password Using Email?",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.orange),
          ),
          onPressed: () {
            context
                .read<PasswordResetBloc>()
                .add(PasswordResetUsedEmailEvent());
            myCustomShowDialog(
                context: context,
                child: BlocProvider.value(
                    value: context.read<PasswordResetBloc>(),
                    child: MySimpleDialog(
                      titleChild: Text("Password Rest"),
                      children: [
                        AlertText(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [SendButton(), CancelButton()],
                        ),
                      ],
                    )));
          }),
    );
  }
}

class SendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MySmallElevatedTextButton(
      width: MediaQuery.of(context).size.width * 0.22,
      text: "Send",
      onPressed: () {
        context.read<PasswordResetBloc>().add(PasswordResetEmailSentEvent());
      },
    );
  }
}

class CancelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MySmallElevatedTextButton(
      width: MediaQuery.of(context).size.width * 0.22,
      text: "Cancel",
      onPressed: () async {
        Navigator.pop(context);
      },
    );
  }
}

class AlertText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: BlocBuilder<PasswordResetBloc, PasswordResetState>(
          buildWhen: (previous, current) =>
              previous.dialogAlertText != current.dialogAlertText,
          builder: (context, state) {
            return context.read<PasswordResetBloc>().state.status ==
                    PasswordResetStatus.dialogInProgress
                ? LinearProgressIndicator()
                : Text(
                    state.dialogAlertText.isEmpty
                        ? "You Sure?"
                        : state.dialogAlertText,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: state.status == PasswordResetStatus.dialogError
                            ? Colors.red
                            : state.status == PasswordResetStatus.dialogSuccess
                                ? Colors.green
                                : Colors.black),
                  );
          },
        ),
      ),
    );
  }
}
