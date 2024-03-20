import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../model/OneSignalModel.dart';
import '../utils/common.dart';
import '../utils/widget.dart';

class OneSignalConfigurationScreen extends StatefulWidget {
  @override
  _OneSignalConfigurationScreenState createState() => _OneSignalConfigurationScreenState();
}

class _OneSignalConfigurationScreenState extends State<OneSignalConfigurationScreen> {
  TextEditingController appIdCont = TextEditingController();
  TextEditingController restApiCont = TextEditingController();
  TextEditingController channelIdCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setIsLoading(true);
    if (!appStore.isTester) {
      settingsService.getOneSignalSettings().then((value) {
        appIdCont.text = value.appId.validate();
        restApiCont.text = value.restApiKey.validate();
        channelIdCont.text = value.channelId.validate();
      });
    } else {
      appIdCont.text = '****************************************';
      restApiCont.text = '****************************************';
      channelIdCont.text = '***************************************';
    }
    appStore.setIsLoading(false);
    setState(() {});
  }

  Future<void> save() async {
    if (appStore.isTester) return toast('mTesterNotAllowedMsg');
    OneSignalModel oneSignalModel = OneSignalModel();
    appStore.setIsLoading(true);
    oneSignalModel.appId = appIdCont.text.trim();
    oneSignalModel.restApiKey = restApiCont.text.trim();
    oneSignalModel.channelId = channelIdCont.text.trim();
    oneSignalModel.createdAt = DateTime.timestamp();
    oneSignalModel.updatedAt = DateTime.timestamp();

    settingsService.setOneSignalSettings(oneSignalModel: oneSignalModel).then((value) {
      toastWidget(context, 'Onesignal Updated successfully');
      appStore.setIsLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OneSignal App Id', style: primaryTextStyle(color: textPrimaryColorGlobal)),
                      6.height,
                      AppTextField(
                        controller: appIdCont,
                        textFieldType: TextFieldType.OTHER,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
                        readOnly: appStore.isTester,
                        minLines: 1,
                        decoration: inputDecoration(labelText: "OneSignal App Id"),
                      ),
                    ],
                  ).expand(),
                  20.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OneSignal Rest Api Key', style: primaryTextStyle(color: textPrimaryColorGlobal)),
                      6.height,
                      AppTextField(
                        controller: restApiCont,
                        textFieldType: TextFieldType.NAME,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
                        readOnly: appStore.isTester,
                        minLines: 1,
                        decoration: inputDecoration(labelText: 'OneSignal Rest Api Key'),
                      ),
                    ],
                  ).expand(),
                ],
              ),
              16.height,
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Onesignal Channel Id', style: primaryTextStyle(color: textPrimaryColorGlobal)),
                      6.height,
                      AppTextField(
                        controller: channelIdCont,
                        textFieldType: TextFieldType.NAME,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 2,
                        readOnly: appStore.isTester,
                        minLines: 1,
                        decoration: inputDecoration(labelText: 'Onesignal Channel Id'),
                      ),
                    ],
                  ).expand(),
                  20.width,
                  SizedBox().expand()
                ],
              ),
              30.height,
              Align(
                alignment: Alignment.bottomLeft,
                child: AppButton(
                  text: 'Save',
                  shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
                  onTap: () {
                    if (!appStore.isTester)
                      save();
                    else
                      toastWidget(context, 'Tester not allowed to Perform this action');
                  },
                ),
              ),
            ],
          ),
        ),
        Observer(builder: (context) => Loader().withSize(width: 50, height: 50).visible(appStore.isLoading))
      ],
    );
  }
}
