import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';
import '../../models/ChatMessageModel.dart';
import '../../models/GroupModel.dart';
import '../../models/UserModel.dart';
import '../../services/BaseService.dart';
import '../../utils/AppConstants.dart';

class GroupChatMessageService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  late CollectionReference userRef;
  late CollectionReference grpRef;

  GroupChatMessageService() {
    userRef = fireStore.collection(USER_COLLECTION);
    grpRef = fireStore.collection(GROUPS_COLLECTION);
  }

  Future<DocumentReference> addGroup(GroupModel data) async {
    var doc = await grpRef.add(data.toJson());
    doc.update({'id': doc.id});

    return doc;
  }

  Stream<List<dynamic>> group({String? searchText}) {
    return grpRef.where('searchCase', arrayContains: searchText.validate().isEmpty ? null : searchText!.toLowerCase()).snapshots().map((x) {
      return x.docs.map((y) {
        return y.data();
      }).toList();
    });
  }

  Future<DocumentReference> addMessage(ChatMessageModel data, String docId) async {
    var doc = await grpRef.doc(docId).collection(GROUP_CHATS).add(data.toJson());
    doc.update({'id': doc.id});
    return doc;
  }

  Query chatMessagesWithPagination({String? currentUserId, required String groupDocId}) {
    return grpRef.doc(groupDocId).collection(GROUP_CHATS).orderBy('createdAt', descending: true);
  }

  Future<void> addMessageToDb({required DocumentReference senderDoc, ChatMessageModel? data, UserModel? sender, UserModel? user, File? image, bool isRequest = false}) async {
    String imageUrl = '';

    if (image != null) {
      String fileName = basename(image.path);
      Reference storageRef = _storage.ref().child("$GROUP_PROFILE_IMAGES/${getStringAsync(userId)}/$fileName");
      UploadTask uploadTask = storageRef.putFile(image);

      await uploadTask.then((e) async {
        await e.ref.getDownloadURL().then((value) async {
          imageUrl = value;
          log(imageUrl);
        }).catchError((e) {
          toast(e.toString());
        });
      }).catchError((e) {
        toast(e.toString());
      });
    }
    userRef.doc(getStringAsync(userId)).update({"lastMessageTime": DateTime.now().millisecondsSinceEpoch});
    updateChatDocument(senderDoc, image: image, imageUrl: imageUrl);
  }

  // ignore: body_might_complete_normally_nullable
  DocumentReference? updateChatDocument(DocumentReference data, {File? image, String? imageUrl}) {
    Map<String, dynamic> sendData = {'id': data.id};

    if (image != null) {
      sendData.putIfAbsent('photoUrl', () => imageUrl);
    }
    data.update(sendData);
  }

  addLatLong(ChatMessageModel data, {String? lat, String? long, String? groupId}) {
    Map<String, dynamic> sendData = {'id': data.id};
    grpRef.doc(groupId).collection(GROUP_CHATS).doc(data.id).set({'currentLat': lat, 'currentLong': long}, SetOptions(merge: true)).then((value) {
      //
    });

    sendData.putIfAbsent('current_lat', () => lat);
    sendData.putIfAbsent('current_lat', () => long);
  }

  addIsEncrypt(ChatMessageModel data) {
    Map<String, dynamic> sendData = {'id': data.id};
    sendData.putIfAbsent("isEncrypt", () => true);
  }

  Future<void> deleteGrpSingleMessage({String? groupDocId, String? messageDocId}) async {
    try {
      grpRef.doc(groupDocId).collection(GROUP_CHATS).doc(messageDocId).delete();
    } on Exception catch (e) {
      log(e);
      throw 'Something went wrong';
    }
  }

  Future<void> clearAllMessages({String? groupDocId}) async {
    final WriteBatch _batch = fireStore.batch();

    grpRef.doc(groupDocId).collection(GROUP_CHATS).get().then((value) async {
      value.docs.forEach((document) {
        _batch.delete(document.reference);
      });

      return _batch.commit();
    }).catchError(log);
  }

  Future<void> deleteChat({String? groupDocId}) async {
    final WriteBatch _batch = fireStore.batch();
    await grpRef.doc(groupDocId).collection(GROUP_CHATS).get().then((value) {
      value.docs.forEach((document) {
        _batch.delete(document.reference);
      });
    });
    grpRef.doc(groupDocId).delete();

    return await _batch.commit();
  }

  Stream<QuerySnapshot<Object?>> fetchLastMessageBetween({required String groupDocId}) {
    return grpRef.doc(groupDocId).collection(GROUP_CHATS).orderBy('createdAt', descending: false).snapshots();
  }

  Stream<int> getUnReadCount({required String? currentUser, required String groupDocId}) {
    return grpRef.doc(groupDocId).collection(GROUP_CHATS).where('readBy.$currentUser', isEqualTo: false).snapshots().map((event) => event.docs.length);
  }

  Future<void> removeUserFromReadyByOnLeavingGroup({required String userId, required String groupId}) async {
    await grpRef.doc(groupId).collection(GROUP_CHATS).get().then((value) {
      value.docs.forEach((document) {
        Map<String, dynamic> readBy = document.get("readBy");
        if (readBy.containsKey(userId)) {
          readBy.remove(userId);
        }
        grpRef.doc(groupId).collection(GROUP_CHATS).doc(document.id).update({"readBy": readBy}).then((value) {}).catchError((e) {
              toast(e.toString());
            });
      });
    });
  }

  Future<void> makeUserAdmin({required String userId, required String groupId}) async {
    List<dynamic> ids = [];
    await grpRef.doc(groupId).get().then((doc) {
      ids = doc.get("adminIds");
      if (!ids.contains(userId)) ids.add(userId);
    });
    await grpRef.doc(groupId).update({"adminIds": ids}).then((value) {}).catchError((e) {
          toast(e.toString());
        });
  }

  Future<void> removeUserAsAdmin({required String userId, required String groupId}) async {
    List<dynamic> adminIds = [];
    List<dynamic> memberIds = [];
    String admin = '';
    await grpRef.doc(groupId).get().then((doc) async {
      adminIds = doc.get("adminIds");
      memberIds = doc.get("membersList");
      admin = doc.get("adminId");
      if (adminIds.contains(userId)) adminIds.remove(userId);
      (doc.get("adminId") == userId)
          ? adminIds.length > 0
              ? admin = adminIds.first
              : admin = memberIds.first
          : admin;
    });
    await grpRef.doc(groupId).update({"adminIds": adminIds, "adminId": admin}).then((value) {}).catchError((e) {
          toast(e.toString());
        });
  }

  Future<void> setUnReadStatusToTrue({required String groupDocId}) async {
    List<dynamic> members = [];
    await grpRef.doc(groupDocId).get().then((value) {
      members.addAll(value.get("membersList"));
    });
    await grpRef.doc(groupDocId).collection(GROUP_CHATS).get().then((value) {
      value.docs.forEach((document) {
        int count = 0;
        Map<String, dynamic> readBy = document.get("readBy");
        if (readBy.containsKey(getStringAsync(userId))) {
          readBy[getStringAsync(userId)] = true;
        }
        readBy.forEach((key, value) {
          if (value == true) count++;
        });
        grpRef
            .doc(groupDocId)
            .collection(GROUP_CHATS)
            .doc(document.id)
            .set({"readBy": readBy, "isMessageRead": count == members.length ? true : false}, SetOptions(merge: true))
            .then((value) {})
            .catchError((e) {
              toast(e.toString());
            });
      });
    });
  }

  Future<void> addNewParticipantToReadyBy({required String groupDocId, required List<String> newParticipantsUserIds}) async {
    await grpRef.doc(groupDocId).collection(GROUP_CHATS).get().then((value) {
      value.docs.forEach((document) {
        Map<String, dynamic> readBy = document.get("readBy");
        newParticipantsUserIds.forEach((element) {
          if (!readBy.containsKey(element)) {
            readBy[element] = true;
          }
        });
        grpRef.doc(groupDocId).collection(GROUP_CHATS).doc(document.id).update({"readBy": readBy}).then((value) {}).catchError((e) {
              toast(e.toString());
            });
      });
    });
  }

  Future<void> deleteGroup({String? groupDocId}) async {
    await grpRef.doc(groupDocId).delete();
  }
}
