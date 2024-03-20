import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import '../../components/OTPDialog.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../screens/SignInScreen.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

final GoogleSignIn googleSignIn = GoogleSignIn();

class AuthService {
  Future signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn().catchError((e) {
      log(e);
      return e;
    });

    if (googleSignInAccount != null) {
      setValue(IS_LOGGED_IN, true);

      //Authentication
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User user = authResult.user!;
      setValue(isSocialLogin, true);
      assert(!user.isAnonymous);
      // ignore: unnecessary_null_comparison
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      await googleSignIn.signOut();
      await loginFromFirebaseUser(user);
    } else {
      throw errorSomethingWentWrong;
    }
  }

  Future<void> updateUserData(UserModel user) async {
    log('Player id ${getStringAsync(playerId)}');
    userService.updateDocument({
      'oneSignalPlayerId': getStringAsync(playerId),
      'updatedAt': Timestamp.now(),
    }, user.uid);
  }

  Future<void> setUserDetailPreference(UserModel user) async {
    setValue(userId, user.uid.validate());
    setValue(userDisplayName, user.name.validate());
    setValue(userEmail, user.email.validate());
    setValue(userPhotoUrl, user.photoUrl.validate());
    setValue(userMobileNumber, user.phoneNumber.validate());
    setValue(userStatus, user.userStatus.validate());
    setValue(isEmailLogin, user.isEmailLogin.validate());
    setValue(playerId, user.oneSignalPlayerId.validate());

    appStore.setLoggedIn(true);
    loginStore.setPhotoUrl(aPhotoUrl: user.photoUrl.validate());
    loginStore.setDisplayName(aDisplayName: user.name.validate());
    loginStore.setEmail(aEmail: user.email.validate());
    loginStore.setIsEmailLogin(aIsEmailLogin: true);
    loginStore.setMobileNumber(aMobileNumber: user.phoneNumber.validate());
    loginStore.setId(aId: user.uid.validate());
    loginStore.setStatus(aStatus: user.userStatus.validate());
  }

  Future<void> signUpWithEmailPassword({String? name, required String email, required String password, String? mobileNumber}) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    // ignore: unnecessary_null_comparison
    if (userCredential != null && userCredential.user != null) {
      User currentUser = userCredential.user!;
      UserModel userModel = UserModel();

      /// Create user
      userModel.uid = currentUser.uid;
      userModel.email = currentUser.email;
      userModel.name = name;
      userModel.createdAt = Timestamp.now();
      userModel.updatedAt = Timestamp.now();
      userModel.photoUrl = "";
      userModel.isEmailLogin = true;
      userModel.phoneNumber = mobileNumber;
      userModel.isPresence = true;
      userModel.isActive = true;
      userModel.userStatus = "Hey there! i am using MightyChat";
      userModel.lastSeen = DateTime.now().millisecondsSinceEpoch;
      userModel.caseSearch = setSearchParam(name!);
      userModel.oneSignalPlayerId = getStringAsync(playerId);
      setValue(isSocialLogin, false);
      await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) async {
        setUserDetailPreference(userModel);
        await signInWithEmailPassword(email: email, password: password).then((value) {
          //
        });
      }).catchError((e) {
        log(e);
        throw e;
      });
    } else {
      throw errorSomethingWentWrong;
    }
  }

  Future<void> signInWithEmailPassword({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password).then((value) async {
      final User user = value.user!;

      UserModel userModel = await userService.getUser(email: user.email);
      await updateUserData(userModel);
      setUserDetailPreference(userModel);
    }).catchError((error) async {
      if (!await isNetworkAvailable()) {
        throw 'Please check network connection';
      }
      throw 'Enter valid email and password';
    });
  }

  Future<void> loginFromFirebaseUser(User currentUser, {String? fullName}) async {
    UserModel userModel = UserModel();

    if (await userService.isUserExist(currentUser.email)) {
      //
      ///Return user data
      await userService.userByEmail(currentUser.email).then((user) async {
        userModel = user;

        await updateUserData(user);
      }).catchError((e) {
        log(e);
        throw e;
      });
    } else {
      log("currentUser$currentUser");
      log(fullName);

      /// Create user
      userModel.uid = currentUser.uid.validate();
      userModel.email = currentUser.email.validate();
      if (isIOS) {
        userModel.name = fullName;
      } else {
        userModel.name = currentUser.displayName.validate();
      }

      userModel.phoneNumber = currentUser.phoneNumber.validate();
      userModel.photoUrl = currentUser.photoURL.validate();
      userModel.createdAt = Timestamp.now();
      userModel.updatedAt = Timestamp.now();
      userModel.isEmailLogin = false;
      userModel.isPresence = true;
      userModel.userStatus = "Hey there! i am using MightyChat";
      userModel.lastSeen = DateTime.now().millisecondsSinceEpoch;
      userModel.caseSearch = setSearchParam((currentUser.displayName) ?? fullName!);

      userModel.oneSignalPlayerId = getStringAsync(playerId);

      log(userModel.toJson());

      await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) {
        //
      }).catchError((e) {
        throw e;
      });
    }

    await setUserDetailPreference(userModel);
  }

  /// Sign-In with Apple.
  Future<void> appleLogIn() async {
    if (await TheAppleSignIn.isAvailable()) {
      AuthorizationResult result = await TheAppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);
      switch (result.status) {
        case AuthorizationStatus.authorized:
          final appleIdCredential = result.credential!;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken!),
            accessToken: String.fromCharCodes(appleIdCredential.authorizationCode!),
          );
          final authResult = await _auth.signInWithCredential(credential);
          final user = authResult.user!;

          if (result.credential!.email != null) {
            await saveAppleData(result);
          }

          await loginFromFirebaseUser(user, fullName: '${getStringAsync('appleGivenName')} ${getStringAsync('appleFamilyName')}');
          break;
        case AuthorizationStatus.error:
          throw ("Sign in failed: ${result.error!.localizedDescription}");
        case AuthorizationStatus.cancelled:
          throw ('User cancelled');
      }
    } else {
      throw ('Apple SignIn is not available for your device');
    }
  }

  /// UserData provided only 1st time..

  Future<void> saveAppleData(AuthorizationResult result) async {
    await setValue('appleEmail', result.credential!.email);
    await setValue('appleGivenName', result.credential!.fullName!.givenName);
    await setValue('appleFamilyName', result.credential!.fullName!.familyName);
  }

  Future<void> logout(BuildContext context) async {
    if (!getBoolAsync(isRemember) || getBoolAsync(isSocialLogin)) {
      removeKey(userEmail);
      removeKey(userPassword);
      removeKey(isRemember);
    }
    removeKey(userId);
    removeKey(userDisplayName);
    removeKey(userPhotoUrl);
    removeKey(userMobileNumber);
    removeKey(isEmailLogin);
    removeKey(IS_LOGGED_IN);
    removeKey(SELECTED_WALLPAPER);

    appStore.setLoggedIn(false);

    SignInScreen().launch(context, isNewTask: true);
  }

  Future<void> loginWithOTP(BuildContext context, String phoneNumber) async {
    return await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          appStore.setLoading(false);
          toast('The provided phone number is not valid.');
          throw 'The provided phone number is not valid.';
        } else {
          appStore.setLoading(false);
          toast(e.toString());
          throw e.toString();
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        finish(context);
        await showInDialog(
          context,
          builder: (_) {
            appStore.setLoading(false);
            return OTPDialog(verificationId: verificationId, isCodeSent: true, phoneNumber: phoneNumber);
          },
          barrierDismissible: false,
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        //
      },
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email).then((value) {
      //
    }).catchError((error) {
      throw error.toString();
    });
  }

  Future<void> resetPassword({required String newPassword}) async {
    await _auth.currentUser!.updatePassword(newPassword).then((value) {
      _auth.authStateChanges();
    }).catchError((error) {
      throw error.toString();
    });
  }

  Future deleteUserPermanent({String? uid}) async {
    await userService.removeDocument(uid).then((value) async {}).catchError((e) {
      log(e);
    });
  }
}
