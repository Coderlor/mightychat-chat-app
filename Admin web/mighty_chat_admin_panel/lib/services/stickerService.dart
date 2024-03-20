import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:mighty_chat_admin_panel/services/base_service.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import '../model/StickerModel.dart';
import '../utils/config.dart';
import '../utils/constant.dart';

class StickerService extends BaseService {
  FirebaseStorage _storage = FirebaseStorage.instance;

  StickerService() {
    ref = fireStore.collection(collections.sticker);
  }

  Future<String> addStickerToStorage(Uint8List? image, String? filename) async {
    Reference storageRef = _storage.ref(STICKER).child(filename.validate());

    UploadTask uploadTask = storageRef.putData(image!, SettableMetadata(contentType: 'image/png'));
    return await uploadTask.then((e) async {
      log("Image Upload Success" + e.ref.name);
      return await e.ref.getDownloadURL().then((value) {
        log(value);
        return value;
      });
    }).catchError((e) {
      toast(e.toString());
      return e;
    });
  }

  Future<DocumentReference> addSticker(StickerModel data, {String? userId}) async {
    var doc = await ref!.add(data.toJson());
    doc.update({'id': doc.id});
    return doc;
  }

  Future<List<StickerModel>> getAllSticker() {
    List<StickerModel> list = [];
    return ref!.orderBy('createdAt', descending: true).get().then((value) {
      value.docs.forEach((element) {
        list.add(StickerModel.fromJson(element.data() as Map<String, dynamic>));
      });
      return list;
    });
  }

  Future<int> getTotalSticker() async {
    return await fireStore.collection(collections.sticker).get().then((value) => value.size);
  }
}
