import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import '../models/WallpaperServiceModel.dart';
import '../utils/AppConstants.dart';
import 'BaseService.dart';

class WallpaperService extends BaseService {
  FirebaseStorage storage = FirebaseStorage.instance;

  WallpaperService() {
    ref = fireStore.collection(WALLPAPER);
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

  Future<DocumentReference> addWallpaper(WallpaperServiceModel data, {String? userId}) async {
    var doc = await ref!.add(data.toJson());
    doc.update({'id': doc.id});
    return doc;
  }

  Future updateWallpaper(WallpaperServiceModel data, {String? userId}) async {
    return ref!.doc(data.id).update(data.toJson()).then((value) {});
  }

  Future<List<WallpaperServiceModel>> getAllWallpaper() {
    List<WallpaperServiceModel> list = [];
    return ref!.orderBy('createdAt', descending: true).get().then((value) {
      value.docs.forEach((element) {
        list.add(WallpaperServiceModel.fromJson(element.data() as Map<String, dynamic>));
      });
      return list;
    });
  }
}
