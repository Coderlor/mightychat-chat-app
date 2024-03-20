import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  String? uid;
  Timestamp? addedOn;
  int? lastMessageTime;
  String? groupRefUrl;

  ContactModel({this.uid, this.addedOn, this.lastMessageTime,this.groupRefUrl=''});

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      uid: json['uid'],
      addedOn: json['addedOn'],
      lastMessageTime: json['lastMessageTime'],
        groupRefUrl:json['groupRefUrl']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['addedOn'] = this.addedOn;
    data['lastMessageTime'] = this.lastMessageTime;
    data['groupRefUrl'] = this.groupRefUrl;

    return data;
  }
}
