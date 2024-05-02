import 'package:digi_hub/Business_Logic/Auth_Logic/Registeration/Cubit/LinkPhoneNumberCubit.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Registeration/Cubit/LinkPhoneNumberState.dart';
import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class AddPhoneNumber extends StatelessWidget {
  const AddPhoneNumber({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        context: context,
        fitTitle: true,
        ttle: "Link With Phone Number?",
        onPressed: () {
          context.read<LinkPhoneCubit>().stopTimer();
          Navigator.pop(context);
        },
        actions: [
          TextButton(
            child: const Text(
              "Skip",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange),
            ),
            onPressed: () {
              context.read<LinkPhoneCubit>().stopTimer();

              Navigator.pushNamedAndRemoveUntil(
                context,
                "/DigiHubPage",
                (route) => false,
                /* PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: const AdditionalUserData()), */
              );
            },
          )
        ],
      ),
      body: BlocListener<LinkPhoneCubit, LinkPhoneState>(
        listener: (context, state) {
          if (state.status == LinkPhoneStatus.errorState) {
            errorDialog(context, state.loginError);
          }
          if (state.status == LinkPhoneStatus.codeSentSuccessState) {
            myCustomShowDialog(
                context: context,
                child: BlocProvider.value(
                    value: context.read<LinkPhoneCubit>(),
                    child: CodeVerify()));
          }
        },
        child: ProgressHUD(
          inAsyncCall: context.watch<LinkPhoneCubit>().state.status ==
              LinkPhoneStatus.inProgressState,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 50),
                        const SizedBox(height: 10),
                        Center(child: PhoneTextField()),
                        LoginTextMore(),
                      ],
                    ),
                    SendButton().paddingOnly(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class CodeVerify extends StatelessWidget {
  CodeVerify({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<LinkPhoneCubit, LinkPhoneState>(
      listener: (context, state) {
        if (state.status == LinkPhoneStatus.codeVerifySuccess) {
          context.read<LinkPhoneCubit>().stopTimer();
          Navigator.pushNamedAndRemoveUntil(
              context, "/DigiHubPage", (route) => false);
        }
      },
      child: SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: Center(
            child: Text(
              "Verificaton",
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade600),
            ),
          ),
          elevation: 0,
          contentPadding: const EdgeInsets.all(8),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                VerificationNote(),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: 30,
                    child: VerificationAlertText()),
                TimeCounter(),
                CodeTextField(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [CancelButton(), ResendButton()],
                ),
              ],
            ).marginAll(8)
          ]),
    );
  }
}

class VerificationNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: RichText(
        overflow: TextOverflow.visible,
        text: TextSpan(
          text: "Code is sent to ",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          children: [
            TextSpan(
              text:
                  "+964${context.read<LinkPhoneCubit>().state.phoneNumberField}",
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerificationAlertText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<LinkPhoneCubit, LinkPhoneState>(
        buildWhen: (previous, current) =>
            current.verificationAlert != previous.verificationAlert,
        builder: (context, state) {
          return Text(
            state.verificationAlert,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),
          );
        },
      ),
    );
  }
}

class CodeTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LinkPhoneCubit, LinkPhoneState>(
      buildWhen: (previous, current) =>
          (current.smsCodeField != previous.smsCodeField),
      builder: (context, state) {
        return PinCodeTextField(
          appContext: context,
          pastedTextStyle: TextStyle(
            color: Colors.green.shade600,
            fontWeight: FontWeight.bold,
          ),
          length: 6,
          readOnly: state.codeTimedOut,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            inactiveColor: Colors.orange,
            borderWidth: 1,
            inactiveFillColor: Colors.grey,
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(15),
            fieldHeight: 40,
            fieldWidth: 40,
            activeFillColor: Colors.white,
          ),
          cursorColor: Colors.black,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          keyboardType: TextInputType.number,
          boxShadows: const [
            BoxShadow(
              offset: Offset(0, 1),
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
          onCompleted: (value) async {
            if (!state.codeTimedOut)
              await context.read<LinkPhoneCubit>().liknWithPhoneNumber();
          },
          onChanged: (value) {
            if (!state.codeTimedOut)
              context.read<LinkPhoneCubit>().codeChanged(code: value);
          },
          beforeTextPaste: (text) {
            print("Allowing to paste $text");
            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
            //but you can show anything you want here, like your pop up saying wrong paste format or etc
            return true;
          },
        );
      },
    );
  }
}

class TimeCounter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LinkPhoneCubit, LinkPhoneState>(
      buildWhen: (previous, current) => current.counter != previous.counter,
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

class CancelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MySmallElevatedTextButton(
      text: "Cancel",
      width: 90,
      onPressed: () async {
        Navigator.pop(context);
      },
    );
  }
}

class ResendButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LinkPhoneCubit, LinkPhoneState>(
      buildWhen: (previous, current) => (current.status != previous.status),
      builder: (context, state) {
        return MySmallElevatedTextButton(
          disableColor: state.codeTimedOut ? null : Colors.grey,
          text: "Resend",
          width: 90,
          onPressed: () async {
            if (state.codeTimedOut)
              await context
                  .read<LinkPhoneCubit>()
                  .sendOTPverificationCode(isResnd: true);
          },
        );
      },
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
        child: const Text("Add a phone number for alternative login method",
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
    return Center(
      child: MyLongElevatedTextButton(
          onPressed: () async {
            await context
                .read<LinkPhoneCubit>()
                .sendOTPverificationCode(isResnd: false);
          },
          text: "Continue"),
    );
  }
}

class PhoneTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LinkPhoneCubit, LinkPhoneState>(
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
            context.read<LinkPhoneCubit>().phoneChanded(phone: text);
          },
        );
      },
    );
  }
}
