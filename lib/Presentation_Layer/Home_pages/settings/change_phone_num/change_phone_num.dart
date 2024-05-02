import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/phoneSignInCubit.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/phoneSignInState.dart';

import 'package:digi_hub/Presentation_Layer/UI_elements/components.dart';

import 'package:digi_hub/Presentation_Layer/Home_pages/settings/change_phone_num/enter_code.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class ChangePhoneNumberPage extends StatelessWidget {
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
                  child: EnterCodeToAddPhonePage(),
                ),
              ));
        }
        if (state.status == PhoneSignInStatus.errorState) {
          errorDialog(context, state.loginError);
        }
      },
      child: Scaffold(
          appBar: MyAppBar(
              statusBarDark: false,
              context: context,
              ttle: "Phone Number",
              onPressed: () {
                context.read<PhoneSignInCubit>().stopTimer();
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
                      SizedBox(height: 50),
                      PromtText(),
                      const SizedBox(height: 10),
                      Center(child: PhoneTextField()),
                      LoginTextMore(),
                      UnlinkPhoneText(),
                      Spacer(),
                      SendButton().paddingOnly(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}

class PromtText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.9,
        child: const Text(
          "Update Or Link Phone Number",
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
        child: const Text("An SMS Code will be sent to your number to verify",
            textAlign: TextAlign.start,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            overflow: TextOverflow.clip),
      ),
    );
  }
}

class UnlinkPhoneText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SizedBox(
        child: TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateColor.resolveWith(
              (states) => const Color.fromARGB(50, 255, 170, 0),
            ),
          ),
          child: const Text(
            "Unlink Phone Number",
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.orange),
          ),
          onPressed: () {
            myCustomShowDialog(
                context: context,
                child: BlocProvider.value(
                    value: context.read<PhoneSignInCubit>(),
                    child: MySimpleDialog(
                      titleChild: Text("Unlink Phone Number?"),
                      children: [
                        AlertText(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [UnlinkButton(), CancelButton()],
                        ),
                      ],
                    )));
            /* 
            Navigator.pushNamed(
              context,
              "/SignInWithEmailPage",
              /* PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: const SignInPage()), */
            ); */
          },
        ),
      ),
    );
  }
}

class AlertText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
        child: BlocBuilder<PhoneSignInCubit, PhoneSignInState>(
          buildWhen: (previous, current) =>
              previous.dialogAlert != current.dialogAlert,
          builder: (context, state) {
            return context.read<PhoneSignInCubit>().state.status ==
                    PhoneSignInStatus.dialogInProgress
                ? LinearProgressIndicator()
                : Text(
                    state.dialogAlert.isEmpty ? "You Sure?" : state.dialogAlert,
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: state.status == PhoneSignInStatus.dialogError
                            ? Colors.red
                            : state.status == PhoneSignInStatus.dialogSuccess
                                ? Colors.green
                                : Colors.black),
                  );
          },
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
            await context.read<PhoneSignInCubit>().sendOTPverificationCode();
          },
          text: "Continue"),
    );
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

class UnlinkButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MySmallElevatedTextButton(
      width: MediaQuery.of(context).size.width * 0.22,
      text: "Unlink",
      onPressed: () async {
        await context.read<PhoneSignInCubit>().unlinkPhoneNumber();
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
        await context.read<PhoneSignInCubit>().closingDialog();
        Navigator.pop(context);
      },
    );
  }
}
