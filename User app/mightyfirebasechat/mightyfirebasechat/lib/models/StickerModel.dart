// class StickerModel {
//   String? path;
//   String? name;
//   bool? isSelected;
//
//   StickerModel({this.path, this.name, this.isSelected});
//
//   List<StickerModel> stickerList() {
//     List<StickerModel> stickerList = [];
//     stickerList.add(StickerModel(name: "Sticker_01", isSelected: false, path: "assets/sticker/sticker_1.jpeg"));
//     stickerList.add(StickerModel(name: "Sticker_02", isSelected: false, path: "assets/sticker/sticker_2.jpeg"));
//     stickerList.add(StickerModel(name: "Sticker_03", isSelected: false, path: "assets/sticker/sticker_3.jpeg"));
//     stickerList.add(StickerModel(name: "Sticker_04", isSelected: false, path: "assets/sticker/sticker_4.jpeg"));
//     stickerList.add(StickerModel(name: "Sticker_05", isSelected: false, path: "assets/sticker/sticker_5.png"));
//     stickerList.add(StickerModel(name: "Sticker_06", isSelected: false, path: "assets/sticker/sticker_6.png"));
//     stickerList.add(StickerModel(name: "Sticker_07", isSelected: false, path: "assets/sticker/sticker_7.png"));
//     stickerList.add(StickerModel(name: "Sticker_08", isSelected: false, path: "assets/sticker/sticker_8.png"));
//     stickerList.add(StickerModel(name: "Sticker_09", isSelected: false, path: "assets/sticker/sticker_9.jpeg"));
//     stickerList.add(StickerModel(name: "Sticker_01", isSelected: false, path: "assets/sticker/sticker_1.jpeg"));
//     stickerList.add(StickerModel(name: "Sticker_02", isSelected: false, path: "assets/sticker/sticker_2.jpeg"));
//     stickerList.add(StickerModel(name: "Sticker_03", isSelected: false, path: "assets/sticker/sticker_3.jpeg"));
//     return stickerList;
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class StickerModel {
  String? id;
  String? stickerPath;
  DateTime? createdAt;
  DateTime? updatedAt;

  StickerModel({this.id, this.stickerPath, this.createdAt, this.updatedAt});

  factory StickerModel.fromJson(Map<String, dynamic> json) {
    return StickerModel(
      id: json['id'],
      stickerPath: json['stickerPath'],
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['stickerPath'] = this.stickerPath;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
