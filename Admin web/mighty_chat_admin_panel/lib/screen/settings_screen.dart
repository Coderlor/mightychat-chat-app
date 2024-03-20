import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../model/SettingsModel.dart';
import '../utils/common.dart';
import '../utils/widget.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController agoraCallId = TextEditingController();
  TextEditingController termsCondCount = TextEditingController();
  TextEditingController privacyPolicyCount = TextEditingController();
  TextEditingController mailCont = TextEditingController();
  TextEditingController copyRight = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setIsLoading(true);
    settingsService.getSettings().then((value) {
      if (!appStore.isTester) {
        agoraCallId.text = value.agoraCallId.validate();
      } else {
        agoraCallId.text = '****************************************';
      }
      termsCondCount.text = value.termsCondition.validate();
      privacyPolicyCount.text = value.privacyPolicy.validate();
      mailCont.text = value.mail.validate();
      copyRight.text = value.copyRightText.validate();
    });
    appStore.setIsLoading(false);
    setState(() {});
  }

  Future<void> save() async {
    if (appStore.isTester) return toast('mTesterNotAllowedMsg');
    SettingsModel settingsModel = SettingsModel();
    appStore.setIsLoading(true);
    settingsModel.agoraCallId = agoraCallId.text.trim();
    settingsModel.termsCondition = termsCondCount.text.trim();
    settingsModel.privacyPolicy = privacyPolicyCount.text.trim();
    settingsModel.mail = mailCont.text.trim();
    settingsModel.copyRightText = copyRight.text.trim();
    settingsModel.createdAt = DateTime.timestamp();
    settingsModel.updatedAt = DateTime.timestamp();

    settingsService.setSettings(settingsModel: settingsModel).then((value) {
      toastWidget(context, 'Settings Updated successfully');
      appStore.setIsLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agora Call', style: boldTextStyle()),
            16.height,
            Text('Agora Call Id', style: primaryTextStyle()),
            6.height,
            AppTextField(
              controller: agoraCallId,
              textFieldType: TextFieldType.NAME,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              minLines: 1,
              readOnly: appStore.isTester,
              decoration: inputDecoration(labelText: 'Agora Call Id'),
            ),
            30.height,
            Text('Settings', style: boldTextStyle()),
            16.height,
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terms & Condition', style: primaryTextStyle()),
                    6.height,
                    AppTextField(
                      controller: termsCondCount,
                      textFieldType: TextFieldType.NAME,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      minLines: 1,
                      readOnly: appStore.isTester,
                      decoration: inputDecoration(labelText: 'Terms & Condition'),
                    ),
                  ],
                ).expand(),
                8.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Privacy Policy', style: primaryTextStyle()),
                    6.height,
                    AppTextField(
                      controller: privacyPolicyCount,
                      textFieldType: TextFieldType.EMAIL,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      minLines: 1,
                      readOnly: appStore.isTester,
                      decoration: inputDecoration(labelText: 'Privacy Policy'),
                    ),
                  ],
                ).expand(),
              ],
            ),
            12.height,
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mail', style: primaryTextStyle()),
                    6.height,
                    AppTextField(
                      controller: mailCont,
                      textFieldType: TextFieldType.EMAIL,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      minLines: 1,
                      readOnly: appStore.isTester,
                      decoration: inputDecoration(labelText: 'Mail'),
                    ),
                  ],
                ).expand(),
                8.width,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Copyright Text', style: primaryTextStyle()),
                    6.height,
                    AppTextField(
                      controller: copyRight,
                      textFieldType: TextFieldType.NAME,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      readOnly: appStore.isTester,
                      minLines: 1,
                      decoration: inputDecoration(labelText: 'Copyright Text'),
                    ),
                  ],
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
        ).paddingAll(16),
        Observer(builder: (context) => Loader().withSize(width: 50, height: 50).visible(appStore.isLoading))
      ],
    );
  }
}
