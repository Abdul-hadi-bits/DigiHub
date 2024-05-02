// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:digi_hub/Presentation_Layer/AUTH_pages/registeration/userModule.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

class SignUpWithEmailAndPasswordFailure implements Exception {
  const SignUpWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  factory SignUpWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const SignUpWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const SignUpWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'email-already-in-use':
        return const SignUpWithEmailAndPasswordFailure(
          'An account already exists for that email.',
        );
      case 'operation-not-allowed':
        return const SignUpWithEmailAndPasswordFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'weak-password':
        return const SignUpWithEmailAndPasswordFailure(
          'Please enter a stronger password.',
        );
      default:
        return const SignUpWithEmailAndPasswordFailure();
    }
  }

  final String message;
}

//translates firebase email login exceptions to more undrestandable messeges
class LogInWithEmailAndPasswordFailure implements Exception {
  const LogInWithEmailAndPasswordFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  factory LogInWithEmailAndPasswordFailure.fromCode(String code) {
    switch (code) {
      case 'invalid-email':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-disabled':
        return const LogInWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithEmailAndPasswordFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-credential':
        return const LogInWithEmailAndPasswordFailure(
          'Incorrect password or email, please try again.',
        );
      case 'user-not-verified':
        return const LogInWithEmailAndPasswordFailure(
          'User is not verified, you can not login.',
        );
      default:
        return const LogInWithEmailAndPasswordFailure();
    }
  }

  /// The associated error message.
  final String message;
}

class LogInWithGoogleFailure implements Exception {
  const LogInWithGoogleFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  factory LogInWithGoogleFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const LogInWithGoogleFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const LogInWithGoogleFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const LogInWithGoogleFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const LogInWithGoogleFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const LogInWithGoogleFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const LogInWithGoogleFailure();
    }
  }

  /// The associated error message.
  final String message;
}

class LogOutFailure implements Exception {}

class PasswordResetEmailFailure implements Exception {
  final String message;
  PasswordResetEmailFailure([this.message = "Unkown Exception"]);
}

class FormzSubmission {
  /// returns a String if password was not Valid, returns null if password was valid
  static String? validatePassword({required String password}) {
    if (password.isEmpty) {
      return "Password is Required";
    } else if (password.length < 6) {
      return "Password is too Short";
    } else if (password.length > 15) {
      return "Password is too Long";
    } else {
      return null;
    }
  }

  static String? validateNames({required String name}) {
    if (name.isEmpty) {
      return "Name is Required";
    } else if (name.length < 3) {
      return "Name Too Short";
    } else {
      return null;
    }
  }

  static String? validatePasswordConfirm(
      {required String password, required String passwordConfirm}) {
    if (passwordConfirm.isEmpty) {
      return "Password is Required";
    } else if (password != passwordConfirm) {
      return "Passwords Don't Match";
    } else {
      return null;
    }
  }

  /// returns a String if email was not Valid, returns null if email was valid
  static String? validateEmail({required String email}) {
    if (email.isEmpty) {
      return "Email is Required";
    } else {
      return null;
    }
  }
}

/// a repository for user Authentication that has all the necessary functions and utilities needed
class AuthenticationRepository {
  AuthenticationRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  final firebase_auth.FirebaseAuth _firebaseAuth;
//gets user
  firebase_auth.User get currentUser {
    return _firebaseAuth.currentUser!;

    /*   return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser;
    }); */
  }

  Future updateOrSetPhoneNumber(
      {required String userCode, required String verificationID}) async {
    try {
      var user = _firebaseAuth.currentUser!;
      if (user.phoneNumber == null) {
        await _firebaseAuth.currentUser!.linkWithCredential(
            firebase_auth.PhoneAuthProvider.credential(
                verificationId: verificationID, smsCode: userCode));
        await _firebaseAuth.currentUser!.reload();
      } else {
        await _firebaseAuth.currentUser!.updatePhoneNumber(
            firebase_auth.PhoneAuthProvider.credential(
                verificationId: verificationID, smsCode: userCode));
        await _firebaseAuth.currentUser!.reload();

        print("phone number is updated");
      }
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlinkPhoneNumber() async {
    try {
      await _firebaseAuth.currentUser!.unlink("phone");
      await _firebaseAuth.currentUser!.reload();
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  Future<void> linkWithPhoneNumber({
    required String enteredCode,
    required String sentCode,
  }) async {
    try {
      await _firebaseAuth.currentUser!.linkWithCredential(
          firebase_auth.PhoneAuthProvider.credential(
              verificationId: sentCode, smsCode: enteredCode));
      await _firebaseAuth.currentUser!.reload();
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser!.sendEmailVerification();
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkUserVerification() async {
    try {
      await _firebaseAuth.currentUser!.reload();

      if (_firebaseAuth.currentUser!.emailVerified) {
        return true;
      }
      return false;
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(
      {required String email, bool? currentUserEmail}) async {
    try {
      if (currentUserEmail != null && currentUserEmail) {
        await _firebaseAuth.sendPasswordResetEmail(
            email: _firebaseAuth.currentUser!.email!);

        return;
      }
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw firebase_auth.FirebaseAuthException(code: e.code);
    } catch (e) {
      throw PasswordResetEmailFailure();
    }
  }

  Future<void> updateUserPassword({required String newPassword}) async {
    try {
      await _firebaseAuth.currentUser!.updatePassword(newPassword);
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
    bool? currentUserEmail,
  }) async {
    try {
      if (currentUserEmail != null && currentUserEmail) {
        await _firebaseAuth.signInWithEmailAndPassword(
          email: _firebaseAuth.currentUser!.email!,
          password: password,
        );
        return;
      }
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!_firebaseAuth.currentUser!.emailVerified) {
        throw firebase_auth.FirebaseAuthException(code: "user-not-verified");
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("erorrrrrrrrrrrrrrrrrrrrrrrrr   ${e.code}");
      throw LogInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  Future<void> loginWithPhoneNumber({
    required String enteredCode,
    required String sentCode,
  }) async {
    try {
      await _firebaseAuth.signInWithCredential(
          firebase_auth.PhoneAuthProvider.credential(
              verificationId: sentCode, smsCode: enteredCode));

      firebase_auth.User user = _firebaseAuth.currentUser!;
      // we check to if this phone number is linked with any email and whether
      // the email is verified or not ....if it dose not then we will delete
      // the the account
      if (user.email == null || !user.emailVerified) {
        await _firebaseAuth.currentUser!.delete();
        throw firebase_auth.FirebaseAuthException(
            code: "This Phone Number is Not Linked With Any Account");
      }
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        // _googleSignIn
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }

  Future<void> addUserDataToFirbaseFirestore(
      {required String name,
      required String lastName,
      required String notificationToken}) async {
    try {
      String id = _firebaseAuth.currentUser!.uid;

      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: name,
          id: id, // UID from Firebase Authentication
          imageUrl:
              "https://firebasestorage.googleapis.com/v0/b/digihub-62cfa.appspot.com/o/defaultProfileImage%2Fmale-profile-picture-silhouette-avatar-260nw-149293406.png?alt=media&token=43cdfc43-0635-42bf-88ed-07ba8e55a2b6",
          lastName: lastName,
          notifToken: notificationToken,
        ),
      );
    } on firebase_auth.FirebaseException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserDataInFirestore(
      {required Map<String, dynamic> data}) async {
    try {
      String id = _firebaseAuth.currentUser!.uid;

      await FirebaseFirestore.instance.collection("users").doc(id).update(data);
      print("user Data is added");
    } on firebase_auth.FirebaseException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> updateUserImage({required File image}) async {
    try {
      String id = _firebaseAuth.currentUser!.uid;
      Reference reference =
          FirebaseStorage.instance.ref().child('profileImage/$id/userImage');
      // upload the image
      UploadTask uploads = reference.putFile(image);
      // get a snapshot of the uploaded image
      TaskSnapshot snapshot = await uploads;
      //get the url of the uploaded image using the snapshot
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    } on FirebaseException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUserDataFromFirebaseFirestore() async {
    try {
      String id = _firebaseAuth.currentUser!.uid;
      //deleting profile image
      print("deleting image");
      try {
        await FirebaseStorage.instance
            .ref('profileImage/$id/userImage')
            .delete();
      } on FirebaseException catch (e) {
        print("image not deleted , myabe it doese not exist");
        print(e.code);
      }

      //deleting user data
      print("deleting data");
      await FirebaseChatCore.instance.deleteUserFromFirestore(id);
      // deleting user itself
      print("deleting user");
      await _firebaseAuth.currentUser!.delete();
    } on firebase_auth.FirebaseException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> reauthenticateUser({required String password}) async {
    try {
      // create user cridentials
      firebase_auth.AuthCredential credential =
          firebase_auth.EmailAuthProvider.credential(
        email: _firebaseAuth.currentUser!.email!,
        password: password,
      );

      // reauthenticate with created Credentials
      await _firebaseAuth.currentUser!.reauthenticateWithCredential(credential);
    } on firebase_auth.FirebaseAuthException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<FireUser> fetchUserData() async {
    try {
      String id = _firebaseAuth.currentUser!.uid;

      DocumentSnapshot<Map<String, dynamic>> snpashot =
          await FirebaseFirestore.instance.collection("users").doc(id).get();

      return FireUser.fromMap(snpashot.data()!);
    } on firebase_auth.FirebaseException catch (e) {
      print(e.code);
      rethrow;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
