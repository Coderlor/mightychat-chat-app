import '../../models/ContactModel.dart';
import 'package:mobx/mobx.dart';
part 'MessageRequestStore.g.dart';

class MessageRequestStore = MessageRequestStoreBase with _$MessageRequestStore;

abstract class MessageRequestStoreBase with Store {
  @observable
  List<ContactModel> userContactList = ObservableList();

  @action
  void addContactData({required List<ContactModel> data, bool isClear = false}) async {
    if (isClear) {
      userContactList.clear();
    }
    userContactList.addAll(data);
  }
}
