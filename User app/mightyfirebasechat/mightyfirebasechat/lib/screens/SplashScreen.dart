import '../../main.dart';
import '../../screens/DashboardScreen.dart';
import '../../screens/SaveProfileScreen.dart';
import '../../utils/AppConstants.dart';
import '../../utils/AppLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../utils/AppImages.dart';
import 'SignInScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    setStatusBarColor(Colors.black.withOpacity(0.3));
    await Future.delayed(Duration(seconds: 2));
    appLocalizations = AppLocalizations.of(context);

    finish(context);

    int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
    if (themeModeIndex == ThemeModeSystem) {
      appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
    }

    if (getBoolAsync(IS_LOGGED_IN)) {
      if (getStringAsync(userMobileNumber).isEmpty) {
        SaveProfileScreen(mIsShowBack: false, mIsFromLogin: true).launch(context, isNewTask: true);
      } else {
        DashboardScreen().launch(context, isNewTask: true);
      }
    } else {
      SignInScreen().launch(context, isNewTask: true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: !appStore.isDarkMode?Colors.white:Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(ic_app_logo, height: 150, width: 150),
          16.height,
          Text(AppName, style: boldTextStyle(color: !appStore.isDarkMode?Colors.black:Colors.white)),
        ],
      ).center(),
    );
  }
}
