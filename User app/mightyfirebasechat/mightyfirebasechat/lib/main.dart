import 'dart:async';

import 'package:chat/services/DeviceService.dart';
import 'package:chat/services/StickerService.dart';
import 'package:chat/services/WallpaperService.dart';
import 'package:chat/services/settingService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/FileModel.dart';
import '../../models/Language.dart';
import '../../screens/SplashScreen.dart';
import '../../services/AuthService.dart';
import '../../services/CallService.dart';
import '../../services/ChatMessageService.dart';
import '../../services/ChatRequestService.dart';
import '../../services/GroupChatMessageService.dart';
import '../../services/NotificationService.dart';
import '../../services/StoryService.dart';
import '../../services/UserService.dart';
import '../../store/AppSettingStore.dart';
import '../../store/AppStore.dart';
import '../../store/LoginStore.dart';
import '../../store/MessageRequestStore.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/AppLocalizations.dart';
import '../../utils/AppTheme.dart';
import 'components/NoInternetScreen.dart';

//region Services Objects
UserService userService = UserService();
AuthService authService = AuthService();
DeviceService deviceService = DeviceService();
ChatMessageService chatMessageService = ChatMessageService();
CallService callService = CallService();
NotificationService notificationService = NotificationService();
StoryService storyService = StoryService();
ChatRequestService chatRequestService = ChatRequestService();
WallpaperService wallpaperService = WallpaperService();
StickerService stickerService = StickerService();
GroupChatMessageService groupChatMessageService = GroupChatMessageService();
SettingsService settingsService = SettingsService();
//endregion

final navigatorKey = GlobalKey<NavigatorState>();
get getContext1 => navigatorKey.currentState?.overlay?.context;

FirebaseFirestore fireStore = FirebaseFirestore.instance;
late AppLocalizations? appLocalizations;
late Language? language;
List<Language> languages = Language.getLanguages();
late List<FileModel> fileList = [];
OneSignal oneSignal = OneSignal();

//region MobX Objects
AppStore appStore = AppStore();
LoginStore loginStore = LoginStore();
AppSettingStore appSettingStore = AppSettingStore();
MessageRequestStore messageRequestStore = MessageRequestStore();
//endregion

late MessageType? messageType;

//region Default Settings
int mChatFontSize = 16;
int mAdShowCount = 0;

String mSelectedImage = appStore.isDarkMode ? mSelectedImageDark : "assets/default_wallpaper.png";
String mSelectedImageDark = "assets/default_wallpaper_dark.jpg";

bool mIsEnterKey = false;
List<String?> postViewedList = [];

Database? localDbInstance;
Color defaultLoaderAccentColorGlobal = primaryColor;
//endregion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  Function? originalOnError = FlutterError.onError;

  FlutterError.onError = (FlutterErrorDetails errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    originalOnError!(errorDetails);
  };
  await initialize();

  appSetting();

  appButtonBackgroundColorGlobal = primaryColor;
  defaultAppButtonTextColorGlobal = Colors.white;
  appBarBackgroundColorGlobal = primaryColor;
  defaultLoaderBgColorGlobal = chatColor;
  appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: defaultLanguage));

  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == ThemeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == ThemeModeDark) {
    appStore.setDarkMode(true);
  }
  if (getBoolAsync(IS_LOGGED_IN)) {
    loginData();
  }
  oneSignalData();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool isCurrentlyOnNoInternet = false;
  ConnectivityResult connectionStatus = ConnectivityResult.none;
  final Connectivity connectivity = Connectivity();
  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen((e) async {
        if (e == ConnectivityResult.none) {
          log('not connected');
          isCurrentlyOnNoInternet = true;
          Navigator.of(getContext1).push(buildPageRoute(NoInternetScreen(), pageRouteAnimationGlobal, Duration(seconds: 1)));
        } else {
          if (isCurrentlyOnNoInternet) {
            Navigator.of(getContext1).pop();
            isCurrentlyOnNoInternet = false;
            toast('Internet is connected.');
          }
        }
      });
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
    _connectivitySubscription.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: navigatorKey,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        supportedLocales: Language.languagesLocale(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          CountryLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguageCode),
        home: SplashScreen(),
        builder: scrollBehaviour(),
      ),
    );
  }
}
