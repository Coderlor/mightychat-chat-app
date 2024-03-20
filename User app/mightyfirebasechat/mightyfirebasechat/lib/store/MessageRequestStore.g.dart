// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'MessageRequestStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MessageRequestStore on MessageRequestStoreBase, Store {
  final _$userContactListAtom =
      Atom(name: 'MessageRequestStoreBase.userContactList');

  @override
  List<ContactModel> get userContactList {
    _$userContactListAtom.reportRead();
    return super.userContactList;
  }

  @override
  set userContactList(List<ContactModel> value) {
    _$userContactListAtom.reportWrite(value, super.userContactList, () {
      super.userContactList = value;
    });
  }

  final _$MessageRequestStoreBaseActionController =
      ActionController(name: 'MessageRequestStoreBase');

  @override
  void addContactData({required List<ContactModel> data, bool isClear = true}) {
    final _$actionInfo = _$MessageRequestStoreBaseActionController.startAction(
        name: 'MessageRequestStoreBase.addContactData');
    try {
      return super.addContactData(data: data, isClear: isClear);
    } finally {
      _$MessageRequestStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
userContactList: ${userContactList}
    ''';
  }
}
