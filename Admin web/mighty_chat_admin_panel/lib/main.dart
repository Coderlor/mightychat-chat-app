import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_chat_admin_panel/services/settingService.dart';
import 'package:mighty_chat_admin_panel/utils/constant.dart';
import '../app_theme.dart';
import '../screen/splash_screen.dart';
import '../services/auth_services.dart';
import '../services/stickerService.dart';
import '../services/user_services.dart';
import '../services/wallpaperService.dart';
import '../store/app_store.dart';
import '../utils/colors.dart';
import '../utils/config.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_strategy/url_strategy.dart';

AppStore appStore = AppStore();
FirebaseFirestore fireStore = FirebaseFirestore.instance;

UserService userService = UserService();
AuthService authService = AuthService();
StickerService stickerService = StickerService();
WallpaperService wallpaperService = WallpaperService();
SettingsService settingsService = SettingsService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyA5T0-lYhRuTkw99b7JLGCKwPOf_nZ7oJ8",
        authDomain: "mighty-chat-app.firebaseapp.com",
        databaseURL: "https://mighty-chat-app-default-rtdb.firebaseio.com",
        projectId: "mighty-chat-app",
        storageBucket: "mighty-chat-app.appspot.com",
        messagingSenderId: "983996196721",
        appId: "1:983996196721:web:41cd288eea69e37c4ef8d0",
        measurementId: "G-55ZXS1T4Y8"),
  );

  defaultRadius = 16.0;
  defaultAppButtonRadius = 30.0;
  defaultLoaderAccentColorGlobal = primaryColor;
  appButtonBackgroundColorGlobal = appButtonColor;
  defaultAppButtonTextColorGlobal = Colors.white;
  passwordLengthGlobal = 6;

  await initialize();

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == appTheme.themeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == appTheme.themeModeDark) {
    appStore.setDarkMode(true);
  }

  appStore.setLoggedIn(getBoolAsync(sharePrefKey.isLoggedIn));
  appStore.setFirstName(getStringAsync(sharePrefKey.firstName));
  appStore.setEmail(getStringAsync(sharePrefKey.email));
  appStore.setPhotoUrl(getStringAsync(sharePrefKey.photoUrl));
  appStore.setUid(getStringAsync(sharePrefKey.uid));
  appStore.setEmailLogin(getBoolAsync(sharePrefKey.isEmailLogin));
  appStore.setTester(getBoolAsync(sharePrefKey.isTester));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) =>
          MaterialApp(
            title: appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: SplashScreen(),
            navigatorKey: navigatorKey,
          ),
    );
  }
}
