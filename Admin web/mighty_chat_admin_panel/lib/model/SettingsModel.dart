import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  String? agoraCallId;
  String? termsCondition;
  String? privacyPolicy;
  String? mail;
  String? copyRightText;
  DateTime? createdAt;
  DateTime? updatedAt;

  SettingsModel({this.agoraCallId, this.termsCondition, this.privacyPolicy, this.copyRightText, this.mail, this.createdAt, this.updatedAt});

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      agoraCallId: json['agoraCallId'],
      termsCondition: json['termsCondition'],
      privacyPolicy: json['privacyPolicy'],
      mail: json['mail'],
      copyRightText: json['copyRightText'],
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['agoraCallId'] = this.agoraCallId;
    data['termsCondition'] = this.termsCondition;
    data['privacyPolicy'] = this.privacyPolicy;
    data['mail'] = this.mail;
    data['copyRightText'] = this.copyRightText;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
