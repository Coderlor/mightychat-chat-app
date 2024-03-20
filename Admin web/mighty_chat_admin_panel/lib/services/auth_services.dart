import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../model/user_model.dart';
import '../screen/login_screen.dart';
import '../utils/constant.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class AuthService {
  Future<void> loginFromFirebaseUser(User currentUser,
      {String? fullName}) async {
    UserModel userModel = UserModel();

    if (await userService.isUserExist(currentUser.email)) {
      ///Return user data
      await userService.userByEmail(currentUser.email).then((user) async {
        userModel = user;

        await updateUserData(user);
      }).catchError((e) {
        log(e);
        throw e;
      });
    } else {
      /// Create user
      userModel.email = currentUser.email;
      userModel.uid = currentUser.uid;
      userModel.photoUrl = currentUser.photoURL;
      log(currentUser.photoURL);
      userModel.isEmailLogin = false;

      userModel.createdAt = Timestamp.now();
      userModel.updatedAt = Timestamp.now();
      if (Platform.isIOS) {
        userModel.name = fullName;
      } else {
        userModel.name = currentUser.displayName.validate();
      }

      log(userModel.toJson());

      await userService
          .addDocumentWithCustomId(currentUser.uid, userModel)
          .then((value) {
        log("New User Added");
      }).catchError((e) {
        throw e;
      });
    }

    await setUserDetailPreference(userModel);
  }

  Future<void> updateUserData(UserModel user) async {
    userService.updateDocument({
      'updatedAt': Timestamp.now(),
    }, user.uid.validate());
  }

  Future<void> setUserDetailPreference(UserModel user) async {
    appStore.setLoggedIn(true, isInitializing: true);
    appStore.setFirstName(user.name.validate(), isInitializing: true);
    appStore.setEmail(user.email.validate(), isInitializing: true);
    appStore.setPhotoUrl(user.photoUrl.validate(), isInitializing: true);
    appStore.setUid(user.uid.validate(), isInitializing: true);
    appStore.setEmailLogin(user.isEmailLogin.validate(), isInitializing: true);
    appStore.setTester(user.isTester.validate(), isInitializing: true);
  }

  Future<void> signUpWithEmailPassword(
      {required Map<String, dynamic> userData}) async {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: userData[userKeys.email], password: userData[userKeys.password]);
    if (userCredential.user != null) {
      User currentUser = userCredential.user!;
      UserModel userModel = UserModel();

      userModel.email = currentUser.email;
      userModel.name = userData[userKeys.name];
      userModel.uid = currentUser.uid;
      userModel.isEmailLogin = userData[userKeys.isEmailLogin];
      userModel.photoUrl = userData[userKeys.photoUrl];
      userModel.isTester = userData[userKeys.isTester];
      userModel.userRole = userData[userKeys.userRole];
      userModel.createdAt = Timestamp.now();
      userModel.phoneNumber = userData[userKeys.phoneNumber];
      userModel.updatedAt = Timestamp.now();

      await userService
          .addDocumentWithCustomId(currentUser.uid, userModel)
          .then((value) async {})
          .catchError((e) {
        log(e);
        throw e;
      });
    } else {
      throw errorSomethingWentWrong;
    }
  }

  Future<void> signInWithEmailPassword(
      {required String email, required String password}) async {
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      final User user = value.user!;
      UserModel userModel = await userService.getUser(email: user.email);
      setValue(sharePrefKey.password, password);
      await updateUserData(userModel);
      await setUserDetailPreference(userModel);
    }).catchError((error) async {
      if (!await isNetworkAvailable()) {
        throw 'Please check network connection';
      }
      if (error.toString() == accessDenied) {
        throw "You are not allowed to login in please contact admin to get access";
      }
      throw 'Enter valid email and password';
    });
  }

  Future<void> changePassword(String newPassword) async {
    await FirebaseAuth.instance.currentUser!
        .updatePassword(newPassword)
        .then((value) async {
      await setValue(sharePrefKey.password, newPassword);
    });
  }

  Future<void> logout(BuildContext context) async {
    removeKey(sharePrefKey.isLoggedIn);
    removeKey(sharePrefKey.isEmailLogin);
    removeKey(sharePrefKey.firstName);
    removeKey(sharePrefKey.email);
    removeKey(sharePrefKey.photoUrl);
    removeKey(sharePrefKey.uid);
    removeKey(sharePrefKey.password);

    appStore.setLoggedIn(false);

    LoginScreen().launch(context,
        pageRouteAnimation: PageRouteAnimation.Scale,
        isNewTask: true,
        duration: 450.milliseconds);
  }

  Future<void> forgotPassword({required String email}) async {
    await auth.sendPasswordResetEmail(email: email).then((value) {
      //
    }).catchError((error) {
      throw error.toString();
    });
  }
}
