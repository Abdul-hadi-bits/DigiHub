

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';

import 'package:my_project/UI/AUTH_pages/signin_or_register.dart';
import 'package:my_project/UI/home_pages/home_page.dart';

import 'package:safetynet_attestation/models/jws_payload_model.dart';
import 'package:safetynet_attestation/safetynet_attestation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // systemNavigationBarColor: Colors.transparent, // navigation bar color
    statusBarColor: Colors.transparent,
    // systemNavigationBarContrastEnforced: true // status bar color
  ));
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,

      home: wrapper() ? const DigiHub() : const WellcomePage(),
      // home: DigiHub(),

      // home: await wrapper() ? const DigiHub() : const SignInPage(),
    ),
  );
}

Future<void> initializationsForNotificaions() async {}

bool wrapper() {
  if (FirebaseAuth.instance.currentUser != null) {
    if (kDebugMode) {
      print(FirebaseAuth.instance.currentUser!.email);
    }
    return true;
  }
  if (kDebugMode) {
    print("not signed in");
  }
  return false; /* 
  SharedPreferences user = await SharedPreferences.getInstance();

  String? email = user.getString('email');
  String? password = user.getString('password');
  String? userStats = user.getString('userStats');
  if (userStats == "signedIn") {}
  return false; */

  //return SignIn.signIn(email!, password!);
}

// Future<void> sfIn() async {
//   try {
//     JWSPayloadModel rers =
//         await SafetynetAttestation.safetyNetAttestationPayload('nonce');

//     if (kDebugMode) {
//       print(rers.basicIntegrity);
//     }
//     if (kDebugMode) {
//       print('basic intergrity ${rers.basicIntegrity}');
//     }
//     if (kDebugMode) {
//       print('apk cerficate ${rers.apkCertificateDigestSha256}');
//     }
//     if (kDebugMode) {
//       print('profilematch ${rers.ctsProfileMatch}');
//     }
//     if (kDebugMode) {
//       print('nonce ${rers.nonce}');
//     }
//     if (kDebugMode) {
//       print('apk pakage name${rers.apkPackageName}');
//     }
//     JWSPayloadModel res =
//         await SafetynetAttestation.safetyNetAttestationPayload(rers.nonce);

//     if (kDebugMode) {
//       print(res.basicIntegrity);
//     }
//     if (kDebugMode) {
//       print('basic intergrity ${rers.basicIntegrity}');
//     }
//     if (kDebugMode) {
//       print(' apk cerficate ${rers.apkCertificateDigestSha256}');
//     }
//     if (kDebugMode) {
//       print('profilematch ${rers.ctsProfileMatch}');
//     }
//     if (kDebugMode) {
//       print('nonce ${rers.nonce}');
//     }
//     if (kDebugMode) {
//       print('apk pakage name${rers.apkPackageName}');
//     }
//   } on PlatformException catch (e) {
//     if (kDebugMode) {
//       print(e);
//     }
//   }
// }
