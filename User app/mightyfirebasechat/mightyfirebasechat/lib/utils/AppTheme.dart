import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/AppColors.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    splashColor: Colors.transparent,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: primaryColor,
      surfaceVariant: Colors.transparent, // Your accent color
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: GoogleFonts.roboto().fontFamily,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.white),
    iconTheme: IconThemeData(color: scaffoldSecondaryDark),
    textTheme: TextTheme(titleLarge: TextStyle()),
    dialogBackgroundColor: Colors.white,
    unselectedWidgetColor: Colors.black,
    dividerColor: viewLineColor,
    cardColor: Colors.white,
    appBarTheme: AppBarTheme(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent),
    ),
    // appBarTheme: appStore.appBarTheme,
    dialogTheme: DialogTheme(shape: dialogShape()),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    splashColor: Colors.transparent,
    useMaterial3: true,
    hoverColor: Colors.transparent,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: primaryColor,
      surfaceVariant: Colors.transparent, // Your accent color
    ),
    scaffoldBackgroundColor: scaffoldColorDark,
    fontFamily: GoogleFonts.roboto().fontFamily,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: scaffoldSecondaryDark),
    iconTheme: IconThemeData(color: Colors.white),
    textTheme: TextTheme(titleLarge: TextStyle(color: textSecondaryColor)),
    dialogBackgroundColor: scaffoldSecondaryDark,
    unselectedWidgetColor: Colors.white60,
    dividerColor: Colors.white38,
    cardColor: scaffoldSecondaryDark,
    appBarTheme: AppBarTheme(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent),
    ),
    dialogTheme: DialogTheme(shape: dialogShape()),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
