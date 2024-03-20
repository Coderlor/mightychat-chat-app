import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid;
  String? name;
  String? email;
  String? photoUrl;
  String? phoneNumber;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  bool? isTester;
  bool? active;
  String? userRole;
  bool? isEmailLogin;
  num? reportUserCount;

  UserModel({
    this.uid,
    this.name,
    this.email,
    this.photoUrl,
    this.phoneNumber,
    this.createdAt,
    this.updatedAt,
    this.isEmailLogin,
    this.isTester,
    this.userRole,
    this.active,
    this.reportUserCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      photoUrl: json['photoUrl'],
      isEmailLogin: json['isEmailLogin'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isTester: json['isTester'],
      active: json['isActive'],
      reportUserCount: json['reportUserCount'],
      userRole: json['userRole'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['uid'] = this.uid;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    data['photoUrl'] = this.photoUrl;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['isTester'] = this.isTester;
    data['isActive'] = this.active;
    data['reportUserCount'] = this.reportUserCount;
    data['userRole'] = this.userRole;
    data['isEmailLogin'] = this.isEmailLogin;

    return data;
  }
}
