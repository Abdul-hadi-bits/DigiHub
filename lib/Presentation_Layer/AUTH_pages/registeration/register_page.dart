import 'package:digi_hub/Business_Logic/Auth_Logic/Registeration/Cubit/RegisterationCubit.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Registeration/Cubit/RegisterationState.dart';
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class RegisterationPage extends StatelessWidget {
  const RegisterationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterationCubit, RegisterationState>(
      listener: (_, state) {
        if (state.status == RegisterationStatus.errorState) {
          errorDialog(context, state.registerationError);
        }
        if (state.status == RegisterationStatus.emailSentSuccessfulState) {
          myCustomShowDialog(
              context: context,
              child: BlocProvider.value(
                  value: BlocProvider.of<RegisterationCubit>(context),
                  child: MyDialog()));
        }
      },
      child: Scaffold(
        appBar: MyAppBar(
          context: context,
          ttle: "Registeration",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        body: ProgressHUD(
          inAsyncCall: context.watch<RegisterationCubit>().state.status ==
              RegisterationStatus.inProgressSate,
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.86,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 30),
                      EmailField(),
                      const SizedBox(height: 20),
                      PasswordField(),
                      const SizedBox(height: 20),
                      PasswordConfirmField(),
                      const SizedBox(height: 20),
                      NameField(),
                      const SizedBox(height: 20),
                      LastNameField(),
                      const SizedBox(height: 20),
                      UserAgreementText(),
                    ],
                  ),
                  RegisterButton().marginOnly(bottom: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserAgreementText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: const Text(
          "By creating an account you will agree to our terms and sevices",
          overflow: TextOverflow.clip,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black), //Color.fromARGB(255, 255, 160, 0)),
        ),
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterationCubit, RegisterationState>(
      buildWhen: (previous, current) =>
          (current.emailAddressFieldText != previous.emailAddressFieldText),
      builder: (context, state) {
        return MyTextField(
          hintText: "Example@email.com",
          label: "Email Address",
          textInputAction: TextInputAction.next,
          obscureText: false,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icon(CupertinoIcons.mail_solid),
          errorMsg: state.emailError.isNotEmpty ? state.emailError : null,
          onChanged: (text) {
            context.read<RegisterationCubit>().emailChanged(email: text);
          },
        );
      },
    );
  }
}

class PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterationCubit, RegisterationState>(
      buildWhen: (previous, current) =>
          (current.passwordFieldText != previous.passwordFieldText ||
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
              context.read<RegisterationCubit>().togglePassword();
            },
            icon: Icon(state.hidePassword
                ? CupertinoIcons.eye_slash_fill
                : CupertinoIcons.eye_fill),
          ),
          keyboardType: TextInputType.text,
          errorMsg: state.passwordError.isNotEmpty ? state.passwordError : null,
          onChanged: (text) {
            context.read<RegisterationCubit>().passwordChanged(password: text);
          },
        );
      },
    );
  }
}

class PasswordConfirmField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterationCubit, RegisterationState>(
      buildWhen: (previous, current) => (current.passwordConfirmFieldText !=
              previous.passwordConfirmFieldText ||
          current.hidePasswordConfirm != previous.hidePasswordConfirm),
      builder: (context, state) {
        return MyTextField(
          hintText: "Confirm Password",
          label: "Confirmed Password",
          textInputAction: TextInputAction.next,
          obscureText: state.hidePasswordConfirm,
          prefixIcon: Icon(state.hidePasswordConfirm
              ? CupertinoIcons.lock_fill
              : CupertinoIcons.lock_open_fill),
          suffixIcon: IconButton(
            onPressed: () {
              context.read<RegisterationCubit>().togleConfirmPassword();
            },
            icon: Icon(state.hidePasswordConfirm
                ? CupertinoIcons.eye_slash_fill
                : CupertinoIcons.eye_fill),
          ),
          keyboardType: TextInputType.text,
          errorMsg: state.passwordConfirmError.isNotEmpty
              ? state.passwordConfirmError
              : null,
          onChanged: (text) {
            context
                .read<RegisterationCubit>()
                .passwordConfirmedChanged(passwordConfirmed: text);
          },
        );
      },
    );
  }
}

class NameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterationCubit, RegisterationState>(
      buildWhen: (previous, current) =>
          (current.firstNameFieldText != previous.firstNameFieldText),
      builder: (context, state) {
        return MyTextField(
          hintText: "Name",
          label: "Name",
          obscureText: false,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.name,
          errorMsg: state.nameError.isNotEmpty ? state.nameError : null,
          onChanged: (text) {
            context.read<RegisterationCubit>().nameChanged(name: text);
          },
        );
      },
    );
  }
}

class LastNameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterationCubit, RegisterationState>(
      buildWhen: (previous, current) =>
          (current.lastNameFieldText != previous.lastNameFieldText),
      builder: (context, state) {
        return MyTextField(
          hintText: "Last Name",
          label: "Last Name",
          obscureText: false,
          textInputAction: TextInputAction.done,
          keyboardType: TextInputType.name,
          errorMsg: state.lastNameError.isNotEmpty ? state.lastNameError : null,
          onChanged: (text) {
            context.read<RegisterationCubit>().lastNameChanged(lastName: text);
          },
        );
      },
    );
  }
}

class RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyLongElevatedTextButton(
        onPressed: () async {
          context.read<RegisterationCubit>().registerUsingEmail();
        },
        text: "Register");
  }
}

class MyDialog extends StatelessWidget {
  const MyDialog({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      title: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Center(
          child: Text(
            "Verificaton",
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade600),
          ),
        ),
      ),
      elevation: 10,
      contentPadding: const EdgeInsets.all(8),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      NoteText(),
                      VerificationAlertText(),
                    ],
                  ),
                  TimeCounter(),
                  BlocBuilder<RegisterationCubit, RegisterationState>(
                    builder: (context, state) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            child: CancelButton(),
                            visible: state.status !=
                                RegisterationStatus.verifySuccessState,
                          ),
                          Visibility(
                            child: Spacer(),
                            visible: (state.status ==
                                        RegisterationStatus.emailSentTimedOut ||
                                    state.status ==
                                        RegisterationStatus
                                            .emailReSendInProgress) &&
                                state.status !=
                                    RegisterationStatus.verifySuccessState,
                          ),
                          Visibility(
                            child: ResendButton(),
                            visible: (state.status ==
                                        RegisterationStatus.emailSentTimedOut ||
                                    state.status ==
                                        RegisterationStatus
                                            .emailReSendInProgress) &&
                                state.status !=
                                    RegisterationStatus.verifySuccessState,
                          ),
                          Visibility(
                            child: DoneButton(),
                            visible: state.status ==
                                RegisterationStatus.verifySuccessState,
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ).marginAll(15)
      ],
    );
  }
}

class DoneButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterationCubit, RegisterationState>(
      buildWhen: (previous, current) =>
          (current.status == RegisterationStatus.verifySuccessState),
      builder: (context, state) {
        return MySmallElevatedTextButton(
          disableColor: state.status != RegisterationStatus.verifySuccessState
              ? Colors.grey
              : null,
          text: "Done",
          color: Colors.green,
          width: 90,
          onPressed: () {
            if (state.status == RegisterationStatus.verifySuccessState) {
              Navigator.pushReplacementNamed(
                context,
                "/AddPhoneNumberPage",
                /*  PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: const AddPhoneNumber()), */
              );
            }
          },
        );
      },
    );
  }
}

class CancelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MySmallElevatedTextButton(
      text: "Cancel",
      width: 90,
      onPressed: () async {
        await context.read<RegisterationCubit>().canceldRegisteration();
        Navigator.pop(context);
      },
    );
  }
}

class ResendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterationCubit, RegisterationState>(
      buildWhen: (previous, current) =>
          (current.status == RegisterationStatus.verifyFailState ||
              current.status == RegisterationStatus.emailReSendInProgress),
      builder: (context, state) {
        return MySmallElevatedTextButton(
          text: state.status == RegisterationStatus.emailReSendInProgress
              ? "Wait..."
              : "Resend",
          width: 90,
          onPressed: () async {
            if (state.status != RegisterationStatus.emailReSendInProgress)
              await context
                  .read<RegisterationCubit>()
                  .resendVertificationEmail();
          },
        );
      },
    );
  }
}

class TimeCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterationCubit, RegisterationState>(
      // buildWhen: (previous, current) => current.counter != previous.counter,
      builder: (context, state) {
        return Text(
            ((state.counter).seconds)
                .toString()
                .replaceRange(0, 3, "")
                .replaceRange(4, null, ""),
            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold));
      },
    );
  }
}

class VerificationAlertText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterationCubit, RegisterationState>(
      buildWhen: (previous, current) =>
          (current.verificationAlert != previous.verificationAlert),
      builder: (context, state) {
        return Visibility(
          visible: context
              .watch<RegisterationCubit>()
              .state
              .verificationAlert
              .isNotEmpty,
          child: Text(
            state.verificationAlert,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.clip),
          ),
        );
      },
    );
  }
}

class NoteText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                text: context
                    .read<RegisterationCubit>()
                    .state
                    .emailAddressFieldText,
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
