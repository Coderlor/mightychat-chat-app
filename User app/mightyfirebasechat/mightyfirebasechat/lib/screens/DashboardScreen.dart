import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/UserModel.dart';
import '../../screens/CallLogScreen.dart';
import '../../screens/ChatListScreen.dart';
import '../../screens/NewChatScreen.dart';
import '../../screens/PickupLayout.dart';
import '../../screens/SettingScreen.dart';
import '../../services/localDB/LogRepository.dart';
import '../../services/localDB/SqliteMethods.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/providers/AppDataProvider.dart';
import 'GroupChat/NewGroupScreen.dart';
import 'QRScannerScreen.dart';
import 'StoriesScreen.dart';

bool isSearch = false;

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  TabController? tabController;
  TextEditingController searchCont = TextEditingController();

  FocusNode searchFocus = FocusNode();
  int tabIndex = 0;
  bool autoFocus = false;

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, initialIndex: 0, length: 3);

    init();
  }

  init() async {
    afterBuildCreated(() {
      chatMessageService.fetchForMessageCount(loginStore.mId);
      setState(() {});
    });

    settingsService.getAdmobSettings().then((value) {
      appSettingStore.adMobBannerAd = value.adMobBannerAd.validate();
      appSettingStore.adMobInterstitialAd = value.adMobInterstitialAd.validate();
      appSettingStore.adMobBannerIos = value.adMobBannerIos.validate();
      appSettingStore.adMobInterstitialIos = value.adMobInterstitialIos.validate();

      appStore.setLoading(false);
    });
    settingsService.getSettings().then((value) {
      appSettingStore.agoraCallId = value.agoraCallId.validate();
      appSettingStore.termsCond = value.termsCondition.validate();
      appSettingStore.privacyPolicy = value.privacyPolicy.validate();
      appSettingStore.mail = value.mail.validate();
      appSettingStore.copyRight = value.copyRightText.validate();
      appStore.setLoading(false);
    });
    tabController!.addListener(() {
      setState(() {
        isSearch = false;
        tabIndex = tabController!.index;
      });
    });

    PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
      if (getIntAsync(THEME_MODE_INDEX) == ThemeModeSystem) {
        appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.light);
      }
    };

    LogRepository.init(dbName: getStringAsync(userId));

    localDbInstance = await SqliteMethods.initInstance();
    UserModel admin = UserModel();
    await fireStore.collection(ADMIN).get().then((value) {
      admin = UserModel.fromJson(value.docs.first.data());
      return admin;
    }).catchError((e) {
      log(e.toString());
      return admin;
    });
    appSettingStore.setReportCount(aReportCount: admin.reportUserCount.validate(value: 0), isInitialize: true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      child: Scaffold(
        appBar: AppBar(
          actions: [
            AnimatedContainer(
              duration: Duration(milliseconds: 100),
              curve: Curves.decelerate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isSearch)
                    TextField(
                      textAlignVertical: TextAlignVertical.center,
                      cursorColor: Colors.white,
                      onChanged: (s) {
                        LiveStream().emit(SEARCH_KEY, s);
                      },
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      controller: searchCont,
                      focusNode: searchFocus,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'search_here'.translate,
                        hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ).expand(),
                  if (tabIndex == 0)
                    IconButton(
                      icon: isSearch ? Icon(Icons.close) : Icon(Icons.search),
                      onPressed: () async {
                        isSearch = !isSearch;
                        searchCont.clear();
                        LiveStream().emit(SEARCH_KEY, '');
                        setState(() {});
                        if (isSearch) {
                          300.milliseconds.delay.then((value) {
                            context.requestFocus(searchFocus);
                          });
                        }
                      },
                      color: Colors.white,
                    )
                ],
              ),
              width: isSearch ? context.width() - 86 : 50,
            ),
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              color: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
              onSelected: (dynamic value) async {
                if (tabIndex == 0) {
                  if (value == 1) {
                    NewChatScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                  } else if (value == 4) {
                    SettingScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                  } else if (value == 3) {
                    QRScannerScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                  } else if (value == 2) {
                    NewGroupScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                  }
                } else if (tabIndex == 1) {
                  if (value == 1) {
                    SettingScreen().launch(context);
                  }
                } else {
                  if (value == 1) {
                    await showConfirmDialogCustom(context,
                        dialogAnimation: DialogAnimation.SCALE,
                        primaryColor: primaryColor,
                        title: "log_confirmation".translate,
                        positiveText: 'lbl_yes'.translate,
                        negativeText: 'lbl_no'.translate, onAccept: (v) {
                      LogRepository.deleteAllLogs();
                      setState(() {});
                    });
                  }
                }
              },
              itemBuilder: (context) {
                if (tabIndex == 0)
                  return dashboardPopUpMenuItem;
                else if (tabIndex == 1)
                  return statusPopUpMenuItem;
                else
                  return chatLogPopUpMenuItem;
              },
            )
          ],
          bottom: TabBar(
            overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
            indicatorWeight: 7,
            indicatorColor: primaryColor,
            unselectedLabelColor: Colors.grey,
            unselectedLabelStyle: secondaryTextStyle(),
            labelColor: primaryColor,
            labelStyle: boldTextStyle(),
            controller: tabController,
            onTap: (index) {
              setState(() {});
              isSearch = false;
              tabIndex = index;
            },
            tabs: [
              Tab(child: Text('chats'.translate, style: boldTextStyle(color: Colors.white), textAlign: TextAlign.center)),
              Tab(child: Text('status'.translate, style: boldTextStyle(color: Colors.white), textAlign: TextAlign.center)),
              Tab(child: Text('calls'.translate, style: boldTextStyle(color: Colors.white), textAlign: TextAlign.center)),
            ],
          ),
          backgroundColor: context.primaryColor,
          title: Text(AppName, style: boldTextStyle(color: Colors.white, size: 20)),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            ChatListScreen(),
            StoriesScreen(),
            CallLogScreen(),
          ],
        ),
      ),
    );
  }
}
