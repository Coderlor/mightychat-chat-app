import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/config.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constant.dart';
part 'app_store.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isDarkMode = false;

  @observable
  bool isLoggedIn = false;

  @observable
  bool isLoading = false;

  @observable
  String firstName = '';

  @observable
  String email = '';

  @observable
  String photoUrl = '';

  @observable
  String uid = '';

  @observable
  String searchString = '';

  @observable
  bool isEmailLogin = false;

  @observable
  bool isTester = false;

  @observable
  bool isMenuExpanded = false;

  @action
  void setExpandedMenu(bool val) {
    isMenuExpanded = val;
  }

  @action
  Future<void> setFirstName(String value, {bool isInitializing = false}) async {
    firstName = value;
    if (isInitializing) await setValue(sharePrefKey.firstName, value);
  }

  @action
  Future<void> setEmail(String value, {bool isInitializing = false}) async {
    email = value;
    if (isInitializing) await setValue(sharePrefKey.email, value);
  }

  @action
  Future<void> setPhotoUrl(String value, {bool isInitializing = false}) async {
    photoUrl = value;
    if (isInitializing) await setValue(sharePrefKey.photoUrl, value);
  }

  @action
  Future<void> setUid(String value, {bool isInitializing = false}) async {
    uid = value;
    if (isInitializing) await setValue(sharePrefKey.uid, value);
  }

  @action
  Future<void> setEmailLogin(bool value, {bool isInitializing = false}) async {
    isEmailLogin = value;
    if (isInitializing) await setValue(sharePrefKey.isEmailLogin, value);
  }

  @action
  Future<void> setTester(bool value, {bool isInitializing = false}) async {
    isTester = value;
    if (isInitializing) await setValue(sharePrefKey.isTester, value);
  }

  @action
  Future<void> setLoggedIn(bool val, {bool isInitializing = false}) async {
    isLoggedIn = val;
    if (isInitializing) await setValue(sharePrefKey.isLoggedIn, val);
  }

  @action
  Future<void> setSearchString(String val, {bool isClear = false}) async {
    if (isClear) searchString = "";

    searchString = val;
  }

  @action
  Future<void> setIsLoading(bool val) async {
    isLoading = val;
  }

  @action
  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkMode = aIsDarkMode;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = viewLineColor;
      appBarBackgroundColorGlobal = scaffoldDarkColor;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = Colors.white;
      defaultAppButtonTextColorGlobal = Colors.black;

      shadowColorGlobal = Colors.white12;

      setStatusBarColor(scaffoldDarkColor);
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      appBarBackgroundColorGlobal = Colors.white;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = primaryColor;
      shadowColorGlobal = Colors.black12;
      defaultAppButtonTextColorGlobal = Colors.white;

      setStatusBarColor(Colors.white);
    }
  }
}
