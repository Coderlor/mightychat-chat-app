import 'package:async/async.dart';
import 'package:chat/components/Permissions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:location/location.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../main.dart';
import '../../models/UserModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../screens/ChatScreen.dart';
import '../screens/GroupChat/GroupChatScreen.dart';
import 'AppImages.dart';

Color getPrimaryColor() => appStore.isDarkMode ? scaffoldSecondaryDark : primaryColor;

extension SExt on String {
  String get translate => appLocalizations!.translate(this);
}

Future<void> appLaunchUrl(String url, {bool forceWebView = false}) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication).catchError((e) {
    toast('Invalid URL: $url');
    return e;
  });
}

bool get isRTL => rtlLanguage.contains(appStore.selectedLanguageCode);

InputDecoration inputDecoration(BuildContext context, {required String labelText, String? hintText, Widget? prefix}) => InputDecoration(
      labelText: labelText,
      labelStyle: secondaryTextStyle(),
      alignLabelWithHint: true,
      hintText: hintText,
      hintStyle: primaryTextStyle(size: 14),
      isDense: true,
      suffixIconColor: context.iconColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      prefixIcon: prefix,
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: Colors.red, width: 1.0),
      ),
      errorMaxLines: 2,
      errorStyle: primaryTextStyle(color: Colors.red, size: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(width: 1.0, color: context.dividerColor),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(width: 1.0, color: context.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: context.dividerColor, width: 1.0),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: context.dividerColor, width: 1.0),
      ),
    );

List<String> setSearchParam(String caseNumber) {
  List<String> caseSearchList = [];
  String temp = "";
  for (int i = 0; i < caseNumber.length; i++) {
    temp = temp + caseNumber[i];
    caseSearchList.add(temp.toLowerCase());
  }
  return caseSearchList;
}

String getThemeModeString(int value) {
  if (value == 0) {
    return 'light_mode'.translate;
  } else if (value == 1) {
    return 'dark_mode'.translate;
  } else if (value == 2) {
    return 'system_default'.translate;
  }
  return '';
}

String getFontSizeString(int value) {
  if (value == 0) {
    return 'small'.translate;
  } else if (value == 1) {
    return 'medium'.translate;
  } else if (value == 2) {
    return 'large'.translate;
  }
  return '';
}

void appSetting() {
  mChatFontSize = getIntAsync(FONT_SIZE_PREF, defaultValue: 16);
  mIsEnterKey = getBoolAsync(IS_ENTER_KEY, defaultValue: false);
  mSelectedImage = getStringAsync(SELECTED_WALLPAPER, defaultValue: "assets/default_wallpaper.png");
  appSettingStore.setReportCount(aReportCount: getIntAsync(reportCount));
}

void loginData() {
  loginStore.setPhotoUrl(aPhotoUrl: getStringAsync(userPhotoUrl));
  loginStore.setDisplayName(aDisplayName: getStringAsync(userDisplayName));
  loginStore.setEmail(aEmail: getStringAsync(userEmail));
  loginStore.setMobileNumber(aMobileNumber: getStringAsync(userMobileNumber));
  loginStore.setId(aId: getStringAsync(userId));
  loginStore.setIsEmailLogin(aIsEmailLogin: getBoolAsync(isEmailLogin));
  loginStore.setStatus(aStatus: getStringAsync(userStatus));
}

Future<void> oneSignalData() async {
  await Permissions.notificationPermissions();
  settingsService.getOneSignalSettings().then((value) {
    appSettingStore.oneSignalAppId = value.appId.validate();
    appSettingStore.oneSignalRestApi = value.restApiKey.validate();
    appSettingStore.oneSignalChannelId = value.channelId.validate();

    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    OneSignal.consentRequired(false);
    OneSignal.Notifications.addPermissionObserver((state) {
      print("Has permission " + state.toString());
    });
    OneSignal.Notifications.requestPermission(true);

    OneSignal.initialize(value.appId.validate());

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print('NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
      event.preventDefault();
      event.notification.display();
      chatMessageService.fetchForMessageCount(loginStore.mId);
    });

    OneSignal.User.pushSubscription.addObserver((state) async {
      print(OneSignal.User.pushSubscription.optedIn);
      print(OneSignal.User.pushSubscription.id);
      print(OneSignal.User.pushSubscription.token);
      //  await setValue(playerId, OneSignal.User.pushSubscription.id);
      if (!OneSignal.User.pushSubscription.id.isEmptyOrNull) await setValue(playerId, OneSignal.User.pushSubscription.id.validate());
    });
    if (getBoolAsync(IS_LOGGED_IN)) {
      userService.updateDocument({
        'oneSignalPlayerId': getStringAsync(playerId).validate(),
        'updatedAt': Timestamp.now(),
      }, getStringAsync(userId)).then((value) {
        log("Updated");
      }).catchError((e) {
        log(e.toString());
      });
    }
    appStore.setLoading(false);
  });
  print("Valuee->" + appSettingStore.oneSignalAppId.validate());
  print("Valuee->" + getStringAsync(playerId).validate());
  OneSignal.Notifications.addClickListener((notification) async {
    var notId = notification.notification.additionalData!["id"];
    bool isGrpId = notification.notification.additionalData!["isGrp"];
    if (notId != null && isGrpId != null) {
      if (isGrpId == true) {
        GroupChatScreen(groupChatId: notId, groupName: "").launch(getContext);
      } else {
        await userService.getUserById(val: notId!).then((value) {
          ChatScreen(value).launch(getContext);
        });
      }
    }
  });
}

getCallStatusIcon(String? callStatus) {
  Icon _icon;
  double _iconSize = 15;

  switch (callStatus) {
    case CALLED_STATUS_DIALLED:
      _icon = Icon(Icons.call_made, size: _iconSize, color: Colors.green);
      break;

    case CALLED_STATUS_MISSED:
      _icon = Icon(Icons.call_missed, size: _iconSize, color: Colors.red);
      break;

    default:
      _icon = Icon(Icons.call_received, size: _iconSize, color: Colors.grey);
      break;
  }

  return Container(margin: EdgeInsets.only(right: 5), child: _icon);
}

String formatDateString(String dateString) {
  DateTime dateTime = DateTime.parse(dateString);

  return dateTime.timeAgo;
}

UserModel sender = UserModel(
  name: getStringAsync(userDisplayName),
  photoUrl: getStringAsync(userPhotoUrl),
  uid: getStringAsync(userId),
  oneSignalPlayerId: getStringAsync(playerId),
);

void unblockDialog(BuildContext context, {required UserModel receiver}) async {
  await showConfirmDialogCustom(
    context,
    dialogType: DialogType.CONFIRMATION,
    primaryColor: primaryColor,
    title: 'Unblock ${receiver.name} to send a message',
    dialogAnimation: DialogAnimation.SCALE,
    positiveText: "Unblock".translate.capitalizeFirstLetter(),
    negativeText: 'cancel'.translate.capitalizeFirstLetter(),
    onAccept: (v) async {
      List<DocumentReference> temp = [];

      temp = await userService.userByEmail(getStringAsync(userEmail)).then((value) => value.blockedTo!);

      if (temp.contains(userService.getUserReference(uid: receiver.uid.validate()))) {
        temp.removeWhere((element) => element == userService.getUserReference(uid: receiver.uid.validate()));
      }

      userService.unBlockUser({"blockedTo": temp}).then((value) {
        finish(context);
      }).catchError((e) {
        //
      });
    },
    // actions: [
    //   TextButton(
    //     onPressed: () {
    //       finish(context);
    //     },
    //     child: Text(
    //       "cancel".translate,
    //       style: TextStyle(color: secondaryColor),
    //     ),
    //   ),
    //   TextButton(
    //     onPressed: () async {
    //       List<DocumentReference> temp = [];
    //
    //       temp = await userService.userByEmail(getStringAsync(userEmail)).then((value) => value.blockedTo!);
    //
    //       if (temp.contains(userService.getUserReference(uid: receiver.uid.validate()))) {
    //         temp.removeWhere((element) => element == userService.getUserReference(uid: receiver.uid.validate()));
    //       }
    //
    //       userService.unBlockUser({"blockedTo": temp}).then((value) {
    //         finish(context);
    //         finish(context);
    //         finish(context);
    //       }).catchError((e) {
    //         //
    //       });
    //     },
    //     child: Text(
    //       "Unblock".toUpperCase(),
    //       style: TextStyle(color: secondaryColor),
    //     ),
    //   ),
    // ],
  );
}

videoThumbnailImage({String? path, double? width, double? height}) {
  AsyncMemoizer<Widget> _memoizer = AsyncMemoizer<Widget>();

  return FutureBuilder<Widget>(
      future: _memoizer.runOnce(() => getVideoThumb(path: path, width: width, height: height)),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!; //get a red underline here
        } else {
          return cachedImage('', width: width, height: height.validate());
        }
      });
}

Future<Widget> getVideoThumb({String? path, double? width, double? height}) async {
  final thumbnail = await VideoThumbnail.thumbnailData(
    video: path!,
    imageFormat: ImageFormat.JPEG,
    quality: 25,
  );
  return Image.memory(thumbnail!, width: width, height: height, fit: BoxFit.cover);
}

Widget noProfileImageFound({double? height, double? width, bool isNoRadius = false, bool isGroup = false}) {
  return Image.asset(isGroup ? 'assets/group_user.jpg' : 'assets/user.jpg', height: height, width: width, fit: BoxFit.cover).cornerRadiusWithClipRRect(isNoRadius ? 0 : height! / 2);
}

Future<bool> setupLocation() async {
  Location? location;
  location = Location();

  var _serviceEnabled = await location.serviceEnabled();

  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();

    if (!_serviceEnabled) {
      return false;
    }
  }

  var _permissionGranted = await location.hasPermission();

  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();

    if (_permissionGranted != PermissionStatus.granted) {
      return false;
    }
  }

  return true;
}

Future<Position?> determinePosition() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location Not Available');
    }
  } else {
    //throw Exception('Error');
  }
  return await Geolocator.getCurrentPosition();
}

Future<bool> checkPermission() async {
  // Request app level location permission
  LocationPermission locationPermission = await Geolocator.requestPermission();

  if (locationPermission == LocationPermission.whileInUse || locationPermission == LocationPermission.always) {
    // Check system level location permission
    if (!await Geolocator.isLocationServiceEnabled()) {
      return await Geolocator.openLocationSettings().then((value) => false).catchError((e) => false);
    } else {
      return true;
    }
  } else {
    toast('Please enable your device location');
    await Geolocator.openAppSettings();

    return false;
  }
}

// ignore: body_might_complete_normally_nullable
InterstitialAd? buildInterstitialAd() {
  InterstitialAd.load(
    adUnitId: isAndroid ? appSettingStore.adMobInterstitialAd.validate() : appSettingStore.adMobInterstitialIos.validate(),
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(onAdFailedToLoad: (LoadAdError error) {
      throw error.message;
    }, onAdLoaded: (InterstitialAd ad) {
      ad.show();
    }),
  );
}

backgroundImage() {
  return Container(
    decoration: getIntAsync(SELECTED_WALLPAPER_CATEGORY) == 3
        ? BoxDecoration(
            image: DecorationImage(
              colorFilter: ColorFilter.mode(Color(int.parse(mSelectedImage.substring(1, 7), radix: 16) + 0xFF000000), BlendMode.color),
              fit: BoxFit.cover,
              image: Image.asset(ic_solid_wallpaper).image,
            ),
          )
        : BoxDecoration(
            image: DecorationImage(
              image: getIntAsync(SELECTED_WALLPAPER_CATEGORY) == 0 ? Image.asset(mSelectedImage).image : Image.network(mSelectedImage).image,
              fit: BoxFit.cover,
              colorFilter: appStore.isDarkMode ? ColorFilter.mode(Colors.black54, BlendMode.luminosity) : null,
            ),
          ),
  );
}
