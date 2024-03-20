import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'ResponsiveWidget.dart';
import 'colors.dart';


getMenuWidth(BuildContext context) {
  return ResponsiveWidget.isSmallScreen(context) ? 50 : 230;
}

getBodyWidth(BuildContext context) {
  return MediaQuery.of(context).size.width - getMenuWidth(context);
}

Future<void> launchUrl(String url, {bool forceWebView = false}) async {
  await launchUrl(url, forceWebView: forceWebView).catchError((e) {
    toast('Invalid URL: $url');
  });
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', subTitle: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: languageImages.icUs),
    LanguageDataModel(id: 2, name: 'Hindi', subTitle: 'हिंदी', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: languageImages.icIndia),
    LanguageDataModel(id: 3, name: 'Arabic', subTitle: 'عربي', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: languageImages.icAr),
  ];
}

List<String> setSearchParam(String caseNumber) {
  List<String> caseSearchList = [];
  String temp = "";
  for (int i = 0; i < caseNumber.length; i++) {
    temp = temp + caseNumber[i];
    caseSearchList.add(temp.toLowerCase());
  }
  return caseSearchList;
}

Widget outlineActionIcon(IconData icon, Color color, String message, Function() onTap, {String? title}) {
  return GestureDetector(
    child: Tooltip(
      message: message,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)),
          child: Icon(icon, color: color, size: 16),
        ),
      ),
    ),
    onTap: onTap,
  );
}

toastWidget(BuildContext context, String title) {
  toasty(
    context,
    title,
    borderRadius: radius(),
    textColor: primaryColor,
    bgColor: context.cardColor,
    gravity: ToastGravity.TOP,
  );
}


String timeAgo(Timestamp date) {
  DateTime d=DateTime.parse(date.toDate().toString());

  DateTime currentDate = DateTime.now();

  var different = currentDate.difference(d);

  if (different.inDays > 365)
    return "${(different.inDays / 365).floor()} ${(different.inDays / 365).floor() == 1 ? "year" : "years"} ago";
  if (different.inDays > 30)
    return "${(different.inDays / 30).floor()} ${(different.inDays / 30).floor() == 1 ? "month" : "months"} ago";
  if (different.inDays > 7)
    return "${(different.inDays / 7).floor()} ${(different.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
  if (different.inDays > 0)
    return "${different.inDays} ${different.inDays == 1 ? "day" : "days"} ago";
  if (different.inHours > 0)
    return "${different.inHours} ${different.inHours == 1 ? "hour" : "hours"} ago";
  if (different.inMinutes > 0)
    return "${different.inMinutes} ${different.inMinutes == 1 ? "minute" : "minutes"} ago";
  if (different.inMinutes == 0) return 'Just Now';

  return d.toString();
}