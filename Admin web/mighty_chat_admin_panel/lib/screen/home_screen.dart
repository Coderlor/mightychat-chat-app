import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/change_password_dialogue.dart';
import '../component/edit_profile_dialogue.dart';
import '../main.dart';
import '../model/MenuModel.dart';
import '../screen/settings_screen.dart';
import '../screen/sticker_screen.dart';
import '../screen/total_users_screen.dart';
import '../screen/wallpaper_screen.dart';
import '../utils/ResponsiveWidget.dart';
import '../utils/cached_network_image.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/config.dart';
import '../utils/constant.dart';
import '../utils/images.dart';
import 'ads_configuration_screen.dart';
import 'dashboard_screen.dart';
import 'one_signal_configuration_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? currentIndex = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    LiveStream().on(LightModeLive, (p0) {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Widget view() {
      if (currentIndex == 1)
        return Container(
            width: getBodyWidth(context),
            height: context.height(),
            child: DashboardScreen());
      else if (currentIndex == 2)
        return Container(
            width: getBodyWidth(context),
            height: context.height(),
            child: TotalUserScreen());
      else if (currentIndex == 3)
        return Container(
            width: getBodyWidth(context),
            height: context.height(),
            child: StickerScreen());
      else if (currentIndex == 4)
        return Container(
            width: getBodyWidth(context),
            height: context.height(),
            child: WallpaperScreen());
      else if (currentIndex == 5)
        return Container(
            width: getBodyWidth(context),
            height: context.height(),
            child: AdsConfigurationScreen());
      else if (currentIndex == 6)
        return Container(
            width: getBodyWidth(context),
            height: context.height(),
            child: OneSignalConfigurationScreen());
      else if (currentIndex == 7)
        return Container(
            width: getBodyWidth(context),
            height: context.height(),
            child: SettingsScreen());
      else
        return Container(
            width: getBodyWidth(context),
            height: context.height(),
            child: DashboardScreen());
    }

    Widget getTitle() {
      if (currentIndex == 1)
        return Text('Dashboard', style: boldTextStyle());
      else if (currentIndex == 2)
        return Text('All Users', style: boldTextStyle());
      else if (currentIndex == 3)
        return Text('All Sticker', style: boldTextStyle());
      else if (currentIndex == 4)
        return Text('All Wallpaper', style: boldTextStyle());
      else if (currentIndex == 5)
        return Text('Ads Configurations', style: boldTextStyle());
      else if (currentIndex == 6)
        return Text('OneSignal Configurations', style: boldTextStyle());
      else if (currentIndex == 7)
        return Text('General Settings', style: boldTextStyle());
      else
        return Text('Dashboard', style: boldTextStyle());
    }

    return Scaffold(
      body: Observer(builder: (context) {
        return Row(
          children: [
            Container(
              width: getMenuWidth(context),
              height: context.height(),
              padding: EdgeInsets.only(top: 8, bottom: 8, left: 8),
              decoration: BoxDecoration(color: primaryColor),
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(appImages.appIcon, width: 40, height: 40),
                      if (!ResponsiveWidget.isSmallScreen(context)) 8.width,
                      if (!ResponsiveWidget.isSmallScreen(context))
                        Text(appName, style: boldTextStyle(color: Colors.white))
                            .expand(),
                    ],
                  ),
                  24.height,
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: getMenuItems.length,
                      itemBuilder: (context, i) {
                        return HoverWidget(builder: (context, isHovering) {
                          return Container(
                            decoration: currentIndex == getMenuItems[i].index ||
                                isHovering
                                ? BoxDecoration(
                                border: Border.all(
                                    width: 1, color: Colors.white),
                                borderRadius:
                                radiusOnly(topLeft: 8, bottomLeft: 8),
                                color: Colors.white.withOpacity(0.2))
                                : BoxDecoration(),
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 8, top: 8, bottom: 8),
                                  child: Row(
                                    children: [
                                      Image.network(
                                          getMenuItems[i].imagePath.validate(),
                                          width: getMenuItems[i].size,
                                          height: getMenuItems[i].size,
                                          color: Colors.white,
                                          fit: BoxFit.cover),
                                      if (!ResponsiveWidget.isSmallScreen(
                                          context))
                                        8.width,
                                      if (!ResponsiveWidget.isSmallScreen(
                                          context))
                                        Text(getMenuItems[i].title.validate(),
                                            style: primaryTextStyle(
                                                color: Colors.white, size: 14))
                                    ],
                                  ).onTap(() {
                                    currentIndex = getMenuItems[i].index;
                                    setState(() {});
                                  }),
                                ).expand(),
                                if (currentIndex == getMenuItems[i].index)
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius: radiusOnly(
                                              topRight: 0, bottomRight: 0),
                                          color: Colors.white),
                                      height: 40,
                                      width: 6)
                              ],
                            ),
                          );
                        });
                      }),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      getTitle(),
                      Row(
                        children: [
                          Observer(
                            builder: (_) =>
                                Row(
                                  children: [
                                    if (!ResponsiveWidget.isSmallScreen(context))
                                      Text(
                                          '${appStore.isDarkMode ? 'Light' : 'Dark'} Mode',
                                          style: secondaryTextStyle()),
                                    if (!ResponsiveWidget.isSmallScreen(context))
                                      6.width,
                                    Transform.scale(
                                      scale: 0.7,
                                      child: CupertinoSwitch(
                                        value: appStore.isDarkMode,
                                        onChanged: (value) {
                                          appStore.setDarkMode(value);
                                          LiveStream().emit(LightModeLive);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                          ),
                          Theme(
                            data: Theme.of(context).copyWith(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent
                            ),
                            child: PopupMenuButton(
                              elevation: 1,
                              color: context.scaffoldBackgroundColor,
                              padding: EdgeInsets.only(top: 10, bottom: 0),
                              position: PopupMenuPosition.under,
                              constraints:
                              BoxConstraints(minWidth: 150, maxWidth: 180),
                              child: Row(
                                children: [
                                  if (!ResponsiveWidget.isSmallScreen(context))
                                    16.width,
                                  if (!ResponsiveWidget.isSmallScreen(context))
                                    Observer(
                                        builder: (_) =>
                                            Text(
                                                appStore.firstName.validate(),
                                                style: boldTextStyle())),
                                  if (!ResponsiveWidget.isSmallScreen(context))
                                    16.width,
                                  CachedImageWidget(
                                      url: appStore.photoUrl,
                                      fit: BoxFit.cover,
                                      height: 46,
                                      width: 46)
                                      .cornerRadiusWithClipRRect(100),
                                  16.width,
                                ],
                              ),
                              onSelected: (i) {
                                switch (i) {
                                  case 1:
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditProfileDialogue();
                                        });
                                    break;
                                  case 2:
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ChangePasswordDialogue();
                                        });
                                    break;
                                  case 3:
                                    showConfirmDialogCustom(
                                      context,
                                      dialogType: DialogType.CONFIRMATION,
                                      primaryColor: context.primaryColor,
                                      title:
                                      "Are you sure you want to logout ?",
                                      onAccept: (c) {
                                        authService.logout(context);
                                      },
                                    );
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                              [
                                PopupMenuItem(
                                  value: 1,
                                  padding: EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.person_outline_sharp,
                                          size: 20,
                                          color: appStore.isDarkMode
                                              ? Colors.white
                                              : Colors.grey),
                                      SizedBox(width: 6),
                                      Text('Edit Profile',
                                          style: primaryTextStyle(size: 14)),
                                    ],
                                  ),
                                  textStyle: primaryTextStyle(),
                                  height: 35,
                                ),
                                PopupMenuItem(
                                    value: 2,
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.lock_outline,
                                            size: 20,
                                            color: appStore.isDarkMode
                                                ? Colors.white
                                                : Colors.grey),
                                        SizedBox(width: 6),
                                        Text('Change Password',
                                            style:
                                            primaryTextStyle(size: 14))
                                            .expand(),
                                      ],
                                    ),
                                    textStyle: primaryTextStyle(),
                                    height: 35),
                                PopupMenuItem(
                                    value: 0,
                                    enabled: false,
                                    child: Divider(),
                                    textStyle: primaryTextStyle(),
                                    height: 0),
                                PopupMenuItem(
                                  value: 3,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      Icon(Icons.logout,
                                          size: 20, color: Colors.red),
                                      SizedBox(width: 4),
                                      Text('Logout',
                                          style: primaryTextStyle(
                                              size: 14, color: Colors.red)),
                                    ],
                                  ),
                                  height: 35,
                                  textStyle: primaryTextStyle(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                view().expand(),
              ],
            ).expand()
          ],
        );
      }),
    );
  }
}
