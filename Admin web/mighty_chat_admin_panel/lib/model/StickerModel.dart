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
