import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/ChatRequestModel.dart';
import '../../services/BaseService.dart';
import '../../utils/AppConstants.dart';
import '../../utils/providers/ChatRequestProvider.dart';

class ChatRequestService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  ChatRequestService() {
    ref = fireStore.collection(USER_COLLECTION).doc(getStringAsync(userId)).collection(CHAT_REQUEST);
  }

  Future<DocumentReference> addChatWithCustomId(String id, Map<String, dynamic> data, String receiverId) async {
    CollectionReference receiverRef = fireStore.collection(USER_COLLECTION).doc(receiverId).collection(CHAT_REQUEST);

    var doc = receiverRef.doc(id);

    return await doc.set(data).then((value) {
      //
      return doc;
    }).catchError((e) {
      log(e);
      throw e;
    });
  }

  Future<bool> isRequestUserExist(String? val, String receiverId) async {
    CollectionReference receiverRef = fireStore.collection(USER_COLLECTION).doc(receiverId).collection(CHAT_REQUEST);
    Query query = receiverRef.limit(1).where('uid', isEqualTo: val);
    var res = await query.get();

    return res.docs.isNotEmpty;
  }

  Future<bool> isRequestsUserExist(String? val) async {
    CollectionReference receiverRef = fireStore.collection(USER_COLLECTION).doc(getStringAsync(userId)).collection(CHAT_REQUEST);
    Query query = receiverRef.limit(1).where('uid', isEqualTo: val).where('requestStatus', isEqualTo: RequestStatus.Pending.index);
    var res = await query.get();
    print(res.docs);
    print(res.docs.isNotEmpty);

    return res.docs.isNotEmpty;
  }

  Stream<List<ChatRequestModel>> getChatRequestList() {
    return fireStore.collection(USER_COLLECTION).doc(getStringAsync(userId)).collection(CHAT_REQUEST).where('requestStatus', isEqualTo: RequestStatus.Pending.index).snapshots().map((event) {
      return event.docs.map((e) => ChatRequestModel.fromJson(e.data())).toList();
    });
  }

  Stream<int> getRequestLength() {
    return ref!.where('requestStatus', isEqualTo: RequestStatus.Pending.index).snapshots().map((documentSnapshot) => documentSnapshot.docs.length).handleError((e) => 0);
  }
}
