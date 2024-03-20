import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:mighty_chat_admin_panel/services/base_service.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import '../model/WallpaperModel.dart';
import '../utils/config.dart';
import '../utils/constant.dart';

class WallpaperService extends BaseService {
  FirebaseStorage storage = FirebaseStorage.instance;

  WallpaperService() {
    ref = fireStore.collection(collections.wallpaper);
  }

  Future<String> addWallPaperToStorage(Uint8List? image, String? filename, String? category) async {
    Reference storageRef = storage.ref(WALLPAPER + '/' + category.validate()).child(filename.validate());
    UploadTask uploadTask = storageRef.putData(image!, SettableMetadata(contentType: 'image/png'));
    return await uploadTask.then((e) async {
      return await e.ref.getDownloadURL().then((value) {
        log(value);
        return value;
      });
    }).catchError((e) {
      toast(e.toString());
      return e;
    });
  }

  Future<DocumentReference> addWallpaper(WallpaperModel data, {String? userId}) async {
    var doc = await ref!.add(data.toJson());
    doc.update({'id': doc.id});
    return doc;
  }

  Future updateWallpaper(WallpaperModel data, {String? userId}) async {
    return ref!.doc(data.id).update(data.toJson()).then((value) {});
  }

  Future<List<WallpaperModel>> getAllWallpaper() {
    List<WallpaperModel> list = [];
    return ref!.orderBy('createdAt', descending: true).get().then((value) {
      value.docs.forEach((element) {
        list.add(WallpaperModel.fromJson(element.data() as Map<String, dynamic>));
      });
      return list;
    });
  }

  Future<int> getTotalWallpaper() async {
    return await fireStore.collection('Wallpaper').get().then((value) => value.size);
  }
}
