import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/phoneSignInCubit.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Registeration/Cubit/LinkPhoneNumberCubit.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Registeration/Cubit/RegisterationCubit.dart';
import 'package:digi_hub/Business_Logic/Settings_Logic/Password_Reset/bloc/password_reset_bloc.dart';
import 'package:digi_hub/Business_Logic/Settings_Logic/Profile/bloc/profile_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:digi_hub/Business_Logic/Auth_Logic/Authenticate/Cubits/emailSiginInCubit.dart';
import 'package:digi_hub/Business_Logic/Global_States/internetCubit.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/registeration/additional_user_infos.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/registeration/choose_business_type.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/registeration/link_with_phone_number.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/registeration/register_page.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/registeration/why_use_digihub.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/sign_in/email_sign_in.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/sign_in/phone_number_signin/sign_in_with_phone_number.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/signin_or_register.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/home_page.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/settings/change_phone_num/change_phone_num.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/settings/password_reset.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/settings/profile.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/todo/add_todo.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/todo/missed_tasks.dart';
import 'package:digi_hub/Presentation_Layer/Home_pages/wallet/wallet_page.dart';

class AppRouter {
  InternetCubit internetCubit;
  // creating an instance of the bloc and providing it to the screens
  // that way we will only have one instance through out the entire app.
  //EmailSignInCubit _emailSignInCubit = EmailSignInCubit();

  AppRouter({required this.internetCubit});
  MaterialPageRoute? onGeneratedRoutes(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (context) => wrapper()
              ? DigiHub(
                  internetCubit: internetCubit,
                )
              : WellcomePage(),
        );

      case '/WellcomePage':
        return MaterialPageRoute(builder: (context) => WellcomePage());

      case '/SignInPhoneNumberPage':
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => PhoneSignInCubit(),
                  child: SignInPhoneNumberPage(),
                ));

      case '/SignInWithEmailPage':
        return MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => EmailSignInCubit(
                          internetCubit:
                              BlocProvider.of<InternetCubit>(context)),
                    )
                  ],
                  child: SignInPage(),
                ));

      case '/DigiHubPage':
        return MaterialPageRoute(
            builder: (context) => DigiHub(
                  internetCubit: internetCubit,
                ));

      case '/RegisterationPage':
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => RegisterationCubit(),
                  child: RegisterationPage(),
                ));

      case '/AddPhoneNumberPage':
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => LinkPhoneCubit(),
                  child: AddPhoneNumber(),
                ));

      case '/AdditionalUserDataPage':
        return MaterialPageRoute(
            builder: (context) => const AdditionalUserData());

      case '/BussinessSelectionPage':
        return MaterialPageRoute(
            builder: (context) => const BusinessSelection());

      case '/WhyUseDigiHubPage':
        return MaterialPageRoute(builder: (context) => const WhyUseDigihub());

      case '/MissedTasksPage':
        return MaterialPageRoute(builder: (context) => const MissedTaskPage());

      case '/AddTodoTaskPage':
        return MaterialPageRoute(builder: (context) => const AddTodoTask());

      case '/ExpenseDetailPage':
        return MaterialPageRoute(builder: (context) => const ExpenseDetails());

      case '/PasswordResetPage':
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => PasswordResetBloc(),
                  child: PasswordResetPage(),
                ));

      case '/ProfilePage':
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => ProfileBloc(),
                  child: Profile(),
                ));

      case '/ChagenPhoneNumberPage':
        return MaterialPageRoute(
            builder: (context) => BlocProvider(
                  create: (context) => PhoneSignInCubit(),
                  child: ChangePhoneNumberPage(),
                ));

      default:
        return null;
    }
  }

  bool wrapper() {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        if (kDebugMode) {
          print(FirebaseAuth.instance.currentUser!.email);
        }
        return true;
      }
      if (kDebugMode) {
        print("not signed in");
      }
      return false;
    } on FirebaseAuthException {
      return false;
    } catch (e) {
      return false;
    }
  }

  void disposeEmailSignInCubit() {
    // _emailSignInCubit.close();
  }
}
