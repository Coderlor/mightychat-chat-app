import 'package:chat/services/BaseService.dart';
import 'package:chat/utils/AppConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:nb_utils/nb_utils.dart';
import '../models/DeviceModel.dart';

class DeviceService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  late CollectionReference userRef;

  DeviceService() {
    ref = fireStore.collection(DEVICE_COLLECTION);
    userRef = fireStore.collection(USER_COLLECTION);
  }

  Future<DocumentReference> addDeviceData(DeviceModel data, {String? userId}) async {
    var doc = await ref!.add(data.toJson());
    doc.update({'id': doc.id});
    return doc;
  }

  Future<DocumentReference> addDeviceData1(String id, Map<String, dynamic> data) async {
    var doc = ref!.doc(id);

    return await doc.set(data).then((value) {
      log('Added: $data');
      return doc;
    }).catchError((e) {
      log(e);
      throw e;
    });
  }

  Future<void> removeUser({String? uid, required BuildContext context}) {
    return ref!.where("uid", isEqualTo: uid).get().then((value) {
      value.docs.forEach((element) {
        ref!.doc(element.id).delete().then((value) async {
          print("Success!");
        });
      });
    });
  }
}
