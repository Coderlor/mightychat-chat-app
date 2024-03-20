import 'package:flutter/material.dart';
import '../main.dart';
import '../screen/home_screen.dart';
import '../screen/login_screen.dart';
import '../utils/config.dart';
import '../utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await Future.delayed(Duration(seconds: 2));
    if (appStore.isLoggedIn) {
      push(HomeScreen(), pageRouteAnimation: PageRouteAnimation.Fade, isNewTask: true);
    } else {
      push(LoginScreen(), pageRouteAnimation: PageRouteAnimation.Fade, isNewTask: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(appImages.appIcon, fit: BoxFit.cover, height: 140),
              26.height,
              Text(appName, style: boldTextStyle(size: 22)),
            ],
          ).center(),
        ],
      ),
    );
  }
}
