import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class AppTheme {
  //
  AppTheme._();

  static final lightTheme = ThemeData(
    primaryColor: primaryColor,
    primarySwatch: createMaterialColor(primaryColor),
    scaffoldBackgroundColor: Colors.white,
    fontFamily: GoogleFonts.nunito().fontFamily,
    bottomNavigationBarTheme:  BottomNavigationBarThemeData(backgroundColor: Colors.white),
    textTheme:  TextTheme(titleLarge: TextStyle()),
    dialogBackgroundColor: Colors.white,
    unselectedWidgetColor: Colors.black,
    dividerColor: viewLineColor,
    cardColor: Colors.grey.shade100,
    dialogTheme: DialogTheme(shape: dialogShape()),
    appBarTheme:  AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(primaryColor),
      overlayColor: MaterialStateProperty.all(const Color(0xFF5D5F6E)),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(primaryColor),
      overlayColor: MaterialStateProperty.all(const Color(0xFF5D5F6E)),
    ),
    primaryIconTheme: const IconThemeData(color: Colors.black),
    iconTheme: const IconThemeData(color: Colors.black),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: primaryColor,
    primarySwatch: createMaterialColor(primaryColor),
    scaffoldBackgroundColor: scaffoldColorDark,
    fontFamily: GoogleFonts.nunito().fontFamily,
    bottomNavigationBarTheme:  BottomNavigationBarThemeData(backgroundColor: scaffoldDarkColor),
    iconTheme:  IconThemeData(color: Colors.white),
    textTheme:  TextTheme(titleLarge: TextStyle(color: textSecondaryColor)),
    dialogBackgroundColor: scaffoldDarkColor,
    unselectedWidgetColor: Colors.white60,
    dividerColor: Colors.white12,
    cardColor: cardDarkColor,
    dialogTheme: DialogTheme(shape: dialogShape()),
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.all(Colors.white),
      checkColor: MaterialStateProperty.all(Colors.black),
      overlayColor: MaterialStateProperty.all(const Color(0xFF5D5F6E)),
    ),
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(Colors.white),
      overlayColor: MaterialStateProperty.all(const Color(0xFF5D5F6E)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: scaffoldDarkColor,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
