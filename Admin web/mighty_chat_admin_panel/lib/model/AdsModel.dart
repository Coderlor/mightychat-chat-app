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
