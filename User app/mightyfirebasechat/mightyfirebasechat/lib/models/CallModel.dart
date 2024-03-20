import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  String? uid;
  String? callerId;
  String? callerName;
  String? callType;
  String? callerPhotoUrl;
  String? receiverId;
  String? receiverName;
  String? receiverPhotoUrl;
  String? channelId;
  String? callStatus;
  Timestamp? timestamp;
  bool? hasDialed;
  bool? isVoice;

  CallModel({
    this.uid,
    this.callerId,
    this.callerName,
    this.callerPhotoUrl,
    this.receiverId,
    this.receiverName,
    this.receiverPhotoUrl,
    this.channelId,
    this.hasDialed,
    this.callStatus,
    this.isVoice,
    this.callType,
    this.timestamp,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      uid: json['uid'],
      callerId: json['callerId'],
      callerName: json['callerName'],
      callerPhotoUrl: json['callerPhotoUrl'],
      receiverId: json['receiverId'],
      receiverName: json['receiverName'],
      receiverPhotoUrl: json['receiverPhotoUrl'],
      channelId: json['channelId'],
      hasDialed: json['hasDialed'],
      callStatus: json['callStatus'],
      isVoice: json['isVoice'],
      callType: json['callType'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['callerId'] = this.callerId;
    data['callerName'] = this.callerName;
    data['callerPhotoUrl'] = this.callerPhotoUrl;
    data['receiverId'] = this.receiverId;
    data['receiverName'] = this.receiverName;
    data['receiverPhotoUrl'] = this.receiverPhotoUrl;
    data['channelId'] = this.channelId;
    data['hasDialed'] = this.hasDialed;
    data['callStatus'] = this.callStatus;
    data['isVoice'] = this.isVoice;
    data['callType'] = this.callType;
    data['timestamp'] = this.timestamp;
    return data;
  }
}
