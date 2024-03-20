import 'package:cloud_firestore/cloud_firestore.dart';

class RecentStoryModel {
  List<StoryModel>? list;
  String? userName;
  String? userId;
  String? userImgPath;
  Timestamp? createAt;
  Timestamp? updatedAt;
  List<String>? seenUserList;
  String? caption;

  RecentStoryModel({this.list, this.userId, this.userName, this.userImgPath, this.caption, this.createAt, this.updatedAt, this.seenUserList});
}

class StoryModel {
  String? userId;
  String? userName;
  String? userImgPath;
  String? id;
  String? caption;
  Timestamp? createAt;
  Timestamp? updatedAt;
  List<String>? seenUserList;
  String? imagePath;
  String? extension;
  bool? shown;

  StoryModel({this.userId, this.userName, this.userImgPath, this.id, this.caption, this.createAt, this.updatedAt, this.seenUserList, this.imagePath, this.extension, this.shown});

  StoryModel.fromJson(dynamic json) {
    userId = json['userId'];
    userName = json['userName'];
    userImgPath = json['userImgPath'];
    id = json['id'];
    caption = json['caption'];
    createAt = json['createAt'];
    updatedAt = json['updatedAt'];
    seenUserList = json['seenUserList'] != null ? json['seenUserList'].cast<String>() : [];
    imagePath = json['imagePath'];
    extension = json['extension'];
    shown = json['shown'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userId'] = userId;
    map['userImgPath'] = userImgPath;
    map['userName'] = userName;
    map['id'] = id;
    map['caption'] = caption;
    map['createAt'] = createAt;
    map['updatedAt'] = updatedAt;
    map['seenUserList'] = seenUserList;
    map['imagePath'] = imagePath;
    map['extension'] = extension;
    map['shown'] = shown;
    return map;
  }
}
