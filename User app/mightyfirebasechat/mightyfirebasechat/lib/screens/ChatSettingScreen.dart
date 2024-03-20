import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/AppLanguageDialog.dart';
import '../../components/FontSelectionDialog.dart';
import '../../components/ThemeSelectionDialog.dart';
import '../../main.dart';
import '../../screens/PickupLayout.dart';
import '../../screens/WallpaperScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/AppLocalizations.dart';
import '../utils/AppImages.dart';

class ChatSettingScreen extends StatefulWidget {
  @override
  _ChatSettingScreenState createState() => _ChatSettingScreenState();
}

class _ChatSettingScreenState extends State<ChatSettingScreen> {
  bool _isEnterKey = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    _isEnterKey = getBoolAsync(IS_ENTER_KEY);
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context);

    return PickupLayout(
      child: Scaffold(
        appBar: appBarWidget('chats'.translate, textColor: Colors.white),
        body: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: EdgeInsets.all(18.0),
              child: Text('display'.translate, style: boldTextStyle()),
            ),
            SettingItemWidget(
              leading: Image.asset(ic_theme, height: 20, width: 20, color: context.iconColor),
              title: 'theme'.translate,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              subTitleTextStyle: secondaryTextStyle(size: 12),
              subTitle: getThemeModeString(getIntAsync(THEME_MODE_INDEX)),
              onTap: () async {
                await showInDialog(
                  context,
                  builder: (_) {
                    return ThemeSelectionDialog();
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text("select_theme".translate, style: boldTextStyle(size: 20)),
                );
                setState(() {});
              },
            ),
            SettingItemWidget(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              subTitleTextStyle: secondaryTextStyle(size: 12),
              leading: Image.asset(ic_language, height: 20, width: 20, color: context.iconColor),
              title: 'app_language'.translate,
              onTap: () {
                return showInDialog(
                  context,
                  builder: (_) {
                    return AppLanguageDialog();
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text("app_language".translate, style: boldTextStyle(size: 20)),
                );
              },
              subTitle: "${language!.name.validate()}",
            ),
            SettingItemWidget(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              subTitleTextStyle: secondaryTextStyle(size: 12),
              leading: Image.asset(ic_wallpaper, height: 20, width: 20, color: context.iconColor),
              title: 'wallpaper'.translate,
              subTitle: "choose_wallpaper".translate,
              onTap: () {
                WallpaperScreen().launch(context);
              },
            ),
            16.height,
            Text('chat_settings'.translate, style: boldTextStyle()).paddingAll(16),
            SwitchListTile(
              title: Row(
                children: [
                  Image.asset(ic_send, height: 20, width: 20, color: context.iconColor),
                  Text('enter_is_send'.translate, style: boldTextStyle()).paddingOnly(left: isRTL ? 0 : 16, right: isRTL ? 12 : 4),
                ],
              ),
              subtitle: Text('enter_key_will_send_your_message'.translate, style: secondaryTextStyle()).paddingOnly(left: isRTL ? 0 : 37, right: isRTL ? 30 : 0),
              value: _isEnterKey,
              activeColor: secondaryColor,
              inactiveTrackColor: Colors.grey,
              onChanged: (v) {
                _isEnterKey = v;
                setValue(IS_ENTER_KEY, v);
                setState(() {});
              },
            ),
            SettingItemWidget(
              title: 'font_size'.translate,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              subTitleTextStyle: secondaryTextStyle(size: 12),
              subTitle: getFontSizeString(getIntAsync(FONT_SIZE_INDEX, defaultValue: 1)),
              leading: Image.asset(ic_font_size, height: 20, width: 20, color: context.iconColor),
              onTap: () async {
                await showInDialog(
                  context,
                  builder: (_) {
                    return FontSelectionDialog();
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text("font_size".translate, style: boldTextStyle(size: 20)),
                );
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
