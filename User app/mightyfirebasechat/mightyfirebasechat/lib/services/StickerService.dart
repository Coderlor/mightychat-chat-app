import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../models/StickerModel.dart';
import '../utils/AppConstants.dart';
import 'BaseService.dart';

class StickerService extends BaseService {
  StickerService() {
    ref = fireStore.collection(STICKER_COLLECTION);
  }

  Future<List<StickerModel>> getAllSticker() {
    List<StickerModel> list = [];
    return ref!.orderBy('createdAt', descending: true).get().then((value) {
      log("value--" + value.docs.toString());
      value.docs.forEach((element) {
        list.add(StickerModel.fromJson(element.data() as Map<String, dynamic>));
      });
      return list;
    });
  }
}
