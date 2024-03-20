import 'package:cloud_firestore/cloud_firestore.dart';

class AdMobAdsModel {
  String? adMobBannerAd;
  String? adMobInterstitialAd;
  String? adMobBannerIos;
  String? adMobInterstitialIos;
  DateTime? createdAt;
  DateTime? updatedAt;

  AdMobAdsModel({this.adMobBannerAd, this.adMobBannerIos, this.adMobInterstitialAd, this.adMobInterstitialIos, this.createdAt, this.updatedAt});

  factory AdMobAdsModel.fromJson(Map<String, dynamic> json) {
    return AdMobAdsModel(
      adMobBannerAd: json['adMobBannerAd'],
      adMobBannerIos: json['adMobBannerIos'],
      adMobInterstitialAd: json['adMobInterstitialAd'],
      adMobInterstitialIos: json['adMobInterstitialIos'],
      createdAt: json['createdAt'] != null ? (json['createdAt'] as Timestamp).toDate() : null,
      updatedAt: json['updatedAt'] != null ? (json['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['adMobBannerAd'] = this.adMobBannerAd;
    data['adMobBannerIos'] = this.adMobBannerIos;
    data['adMobInterstitialAd'] = this.adMobInterstitialAd;
    data['adMobInterstitialIos'] = this.adMobInterstitialIos;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}


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
