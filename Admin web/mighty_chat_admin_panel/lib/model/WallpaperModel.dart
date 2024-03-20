import 'package:cloud_firestore/cloud_firestore.dart';

class WallpaperModel {
  String? id;
  String? wallpaperPath;
  String? category;
  int? categoryId;
  DateTime? createdAt;
  DateTime? updatedAt;

  WallpaperModel({this.id, this.wallpaperPath, this.createdAt, this.updatedAt, this.category, this.categoryId});

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'],
      wallpaperPath: json['wallpaperPath'],
      category: json['category'],
      categoryId: json['categoryId'],
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['wallpaperPath'] = this.wallpaperPath;
    data['category'] = this.category;
    data['categoryId'] = this.categoryId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

