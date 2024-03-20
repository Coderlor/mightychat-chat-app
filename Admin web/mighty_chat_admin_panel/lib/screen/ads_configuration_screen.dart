import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_chat_admin_panel/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../model/AdsModel.dart';
import '../utils/widget.dart';

class AdsConfigurationScreen extends StatefulWidget {
  @override
  _AdsConfigurationScreenState createState() => _AdsConfigurationScreenState();
}

class _AdsConfigurationScreenState extends State<AdsConfigurationScreen> {
  bool isUpdate = false;
  var formKey = GlobalKey<FormState>();

  TextEditingController adMobBannerAdCont = TextEditingController();
  TextEditingController adMobInterstitialAdCont = TextEditingController();
  TextEditingController adMobBannerIosCont = TextEditingController();
  TextEditingController adMobInterstitialIosCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setIsLoading(true);
    settingsService.getAdmobSettings().then((value) {
      adMobBannerAdCont.text = value.adMobBannerAd.validate();
      adMobInterstitialAdCont.text = value.adMobInterstitialAd.validate();
      adMobBannerIosCont.text = value.adMobBannerIos.validate();
      adMobInterstitialIosCont.text = value.adMobInterstitialIos.validate();
    });
    appStore.setIsLoading(false);
    setState(() {});
  }

  Future<void> save() async {
    appStore.setIsLoading(true);
    if (appStore.isTester) return toast('mTesterNotAllowedMsg');
    AdMobAdsModel adMobAdsModel = AdMobAdsModel();

    adMobAdsModel.adMobBannerAd = adMobBannerAdCont.text.trim();
    adMobAdsModel.adMobBannerIos = adMobBannerIosCont.text.trim();
    adMobAdsModel.adMobInterstitialAd = adMobInterstitialAdCont.text.trim();
    adMobAdsModel.adMobInterstitialIos = adMobInterstitialIosCont.text.trim();
    adMobAdsModel.createdAt = DateTime.timestamp();
    adMobAdsModel.updatedAt = DateTime.timestamp();

    settingsService.setAdmobSettings(adsModel: adMobAdsModel).then((value) {
      appStore.setIsLoading(false);
      toastWidget(context, 'Ads Id Updated successfully');
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          admobAdsWidget(),
          Observer(
              builder: (context) => Loader()
                  .withSize(width: 50, height: 50)
                  .visible(appStore.isLoading))
        ],
      ),
    );
  }

  Widget admobAdsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admob Id For Android', style: boldTextStyle()),
        16.height,
        Row(
          children: [
            AppTextField(
              controller: adMobBannerAdCont,
              textFieldType: TextFieldType.OTHER,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              readOnly: appStore.isTester,
              decoration:
                  inputDecoration(labelText: "Admob BannerId for Android"),
            ).expand(),
            20.width,
            AppTextField(
              controller: adMobInterstitialAdCont,
              textFieldType: TextFieldType.NAME,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              readOnly: appStore.isTester,
              decoration: inputDecoration(
                  labelText: 'Admob Interstitial Id for Android'),
            ).expand(),
          ],
        ),
        20.height,
        Text('Admob Id For IOS', style: boldTextStyle()),
        16.height,
        Row(
          children: [
            AppTextField(
              controller: adMobBannerIosCont,
              textFieldType: TextFieldType.NAME,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              readOnly: appStore.isTester,
              decoration: inputDecoration(labelText: 'Admob Banner Id for Ios'),
            ).expand(),
            20.width,
            AppTextField(
              controller: adMobInterstitialIosCont,
              textFieldType: TextFieldType.OTHER,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              readOnly: appStore.isTester,
              decoration:
                  inputDecoration(labelText: "Admob Interstitial Id for Ios"),
            ).expand(),
          ],
        ),
        30.height,
        Align(
          alignment: Alignment.bottomLeft,
          child: AppButton(
            text: 'Save',
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
            onTap: () {
              if (!appStore.isTester) {
                save();
              } else {
                toastWidget(context, 'Test user cannot perform this action');
              }
            },
          ),
        ),
      ],
    ).paddingAll(16);
  }
}
