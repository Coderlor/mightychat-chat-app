import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRequestModel {
  String? uid;
  // String? userName;
  String? profilePic;
  int? requestStatus;
  DocumentReference? senderIdRef;
  int? createdAt;
  int? updatedAt;

  ChatRequestModel({
    this.createdAt,
    this.profilePic,
    this.requestStatus,
    this.senderIdRef,
    this.uid,
    this.updatedAt,
    // this.userName,
  });

  factory ChatRequestModel.fromJson(Map<String, dynamic> json) {
    return ChatRequestModel(
      createdAt: json['createdAt'],
      profilePic: json['profilePic'],
      requestStatus: json['requestStatus'],
      senderIdRef: json['senderIdRef'],
      uid: json['uid'],
      updatedAt: json['updatedAt'],
      // userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['profilePic'] = this.profilePic;
    data['requestStatus'] = this.requestStatus;
    data['senderIdRef'] = this.senderIdRef;
    data['uid'] = this.uid;
    data['updatedAt'] = this.updatedAt;
    // data['userName'] = this.userName;
    return data;
  }
}
