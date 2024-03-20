import 'package:cloud_firestore/cloud_firestore.dart';

class OneSignalModel {
  String? appId;
  String? channelId;
  String? restApiKey;
  DateTime? createdAt;
  DateTime? updatedAt;

  OneSignalModel({this.appId, this.channelId, this.restApiKey,  this.createdAt, this.updatedAt});

  factory OneSignalModel.fromJson(Map<String, dynamic> json) {
    return OneSignalModel(
      appId:  json['appId'],
      channelId: json['channelId'],
      restApiKey:  json['restApiKey'],
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appId'] = this.appId;
    data['channelId'] = this.channelId;
    data['restApiKey'] = this.restApiKey;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}