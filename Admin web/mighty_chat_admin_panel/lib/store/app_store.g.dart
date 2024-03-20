// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppStore on _AppStore, Store {
  final _$isDarkModeAtom = Atom(name: '_AppStore.isDarkMode');

  @override
  bool get isDarkMode {
    _$isDarkModeAtom.reportRead();
    return super.isDarkMode;
  }

  @override
  set isDarkMode(bool value) {
    _$isDarkModeAtom.reportWrite(value, super.isDarkMode, () {
      super.isDarkMode = value;
    });
  }

  final _$isLoggedInAtom = Atom(name: '_AppStore.isLoggedIn');

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  final _$isLoadingAtom = Atom(name: '_AppStore.isLoading');

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  final _$firstNameAtom = Atom(name: '_AppStore.firstName');

  @override
  String get firstName {
    _$firstNameAtom.reportRead();
    return super.firstName;
  }

  @override
  set firstName(String value) {
    _$firstNameAtom.reportWrite(value, super.firstName, () {
      super.firstName = value;
    });
  }

  final _$emailAtom = Atom(name: '_AppStore.email');

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  final _$photoUrlAtom = Atom(name: '_AppStore.photoUrl');

  @override
  String get photoUrl {
    _$photoUrlAtom.reportRead();
    return super.photoUrl;
  }

  @override
  set photoUrl(String value) {
    _$photoUrlAtom.reportWrite(value, super.photoUrl, () {
      super.photoUrl = value;
    });
  }

  final _$uidAtom = Atom(name: '_AppStore.uid');

  @override
  String get uid {
    _$uidAtom.reportRead();
    return super.uid;
  }

  @override
  set uid(String value) {
    _$uidAtom.reportWrite(value, super.uid, () {
      super.uid = value;
    });
  }

  final _$searchStringAtom = Atom(name: '_AppStore.searchString');

  @override
  String get searchString {
    _$searchStringAtom.reportRead();
    return super.searchString;
  }

  @override
  set searchString(String value) {
    _$searchStringAtom.reportWrite(value, super.searchString, () {
      super.searchString = value;
    });
  }

  final _$isEmailLoginAtom = Atom(name: '_AppStore.isEmailLogin');

  @override
  bool get isEmailLogin {
    _$isEmailLoginAtom.reportRead();
    return super.isEmailLogin;
  }

  @override
  set isEmailLogin(bool value) {
    _$isEmailLoginAtom.reportWrite(value, super.isEmailLogin, () {
      super.isEmailLogin = value;
    });
  }

  final _$setFirstNameAsyncAction = AsyncAction('_AppStore.setFirstName');

  @override
  Future<void> setFirstName(String value, {bool isInitializing = false}) {
    return _$setFirstNameAsyncAction
        .run(() => super.setFirstName(value, isInitializing: isInitializing));
  }

  final _$setEmailAsyncAction = AsyncAction('_AppStore.setEmail');

  @override
  Future<void> setEmail(String value, {bool isInitializing = false}) {
    return _$setEmailAsyncAction
        .run(() => super.setEmail(value, isInitializing: isInitializing));
  }

  final _$setPhotoUrlAsyncAction = AsyncAction('_AppStore.setPhotoUrl');

  @override
  Future<void> setPhotoUrl(String value, {bool isInitializing = false}) {
    return _$setPhotoUrlAsyncAction
        .run(() => super.setPhotoUrl(value, isInitializing: isInitializing));
  }

  final _$setUidAsyncAction = AsyncAction('_AppStore.setUid');

  @override
  Future<void> setUid(String value, {bool isInitializing = false}) {
    return _$setUidAsyncAction
        .run(() => super.setUid(value, isInitializing: isInitializing));
  }

  final _$setEmailLoginAsyncAction = AsyncAction('_AppStore.setEmailLogin');

  @override
  Future<void> setEmailLogin(bool value, {bool isInitializing = false}) {
    return _$setEmailLoginAsyncAction
        .run(() => super.setEmailLogin(value, isInitializing: isInitializing));
  }

  final _$setLoggedInAsyncAction = AsyncAction('_AppStore.setLoggedIn');

  @override
  Future<void> setLoggedIn(bool val, {bool isInitializing = false}) {
    return _$setLoggedInAsyncAction
        .run(() => super.setLoggedIn(val, isInitializing: isInitializing));
  }

  final _$setSearchStringAsyncAction = AsyncAction('_AppStore.setSearchString');

  @override
  Future<void> setSearchString(String val, {bool isClear = false}) {
    return _$setSearchStringAsyncAction
        .run(() => super.setSearchString(val, isClear: isClear));
  }

  final _$setIsLoadingAsyncAction = AsyncAction('_AppStore.setIsLoading');

  @override
  Future<void> setIsLoading(bool val) {
    return _$setIsLoadingAsyncAction.run(() => super.setIsLoading(val));
  }

  final _$setDarkModeAsyncAction = AsyncAction('_AppStore.setDarkMode');

  @override
  Future<void> setDarkMode(bool aIsDarkMode) {
    return _$setDarkModeAsyncAction.run(() => super.setDarkMode(aIsDarkMode));
  }

  @override
  String toString() {
    return '''
isDarkMode: ${isDarkMode},
isLoggedIn: ${isLoggedIn},
isLoading: ${isLoading},
firstName: ${firstName},
email: ${email},
photoUrl: ${photoUrl},
uid: ${uid},
searchString: ${searchString},
isEmailLogin: ${isEmailLogin}
    ''';
  }
}
