// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppSettingStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppSettingStore on AppSettingStoreBase, Store {
  late final _$mFontSizeAtom =
      Atom(name: 'AppSettingStoreBase.mFontSize', context: context);

  @override
  int? get mFontSize {
    _$mFontSizeAtom.reportRead();
    return super.mFontSize;
  }

  @override
  set mFontSize(int? value) {
    _$mFontSizeAtom.reportWrite(value, super.mFontSize, () {
      super.mFontSize = value;
    });
  }

  late final _$mReportCountAtom =
      Atom(name: 'AppSettingStoreBase.mReportCount', context: context);

  @override
  int get mReportCount {
    _$mReportCountAtom.reportRead();
    return super.mReportCount;
  }

  @override
  set mReportCount(int value) {
    _$mReportCountAtom.reportWrite(value, super.mReportCount, () {
      super.mReportCount = value;
    });
  }

  late final _$mEnterKeyAtom =
      Atom(name: 'AppSettingStoreBase.mEnterKey', context: context);

  @override
  bool? get mEnterKey {
    _$mEnterKeyAtom.reportRead();
    return super.mEnterKey;
  }

  @override
  set mEnterKey(bool? value) {
    _$mEnterKeyAtom.reportWrite(value, super.mEnterKey, () {
      super.mEnterKey = value;
    });
  }

  final _$AppSettingStoreBaseActionController =
      ActionController(name: 'AppSettingStoreBase');

  @override
  void setFontSize({int? aFontSize}) {
    final _$actionInfo = _$AppSettingStoreBaseActionController.startAction(
        name: 'AppSettingStoreBase.setFontSize');
    try {
      return super.setFontSize(aFontSize: aFontSize);
    } finally {
      _$AppSettingStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setReportCount({required int aReportCount, bool isInitialize = false}) {
    final _$actionInfo = _$AppSettingStoreBaseActionController.startAction(
        name: 'AppSettingStoreBase.setReportCount');
    try {
      return super.setReportCount(
          aReportCount: aReportCount, isInitialize: isInitialize);
    } finally {
      _$AppSettingStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEnterKey({bool? aEnterKey}) {
    final _$actionInfo = _$AppSettingStoreBaseActionController.startAction(
        name: 'AppSettingStoreBase.setEnterKey');
    try {
      return super.setEnterKey(aEnterKey: aEnterKey);
    } finally {
      _$AppSettingStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
mFontSize: ${mFontSize},
mReportCount: ${mReportCount},
mEnterKey: ${mEnterKey}
    ''';
  }
}
