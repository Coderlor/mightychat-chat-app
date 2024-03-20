import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/ChatWidget.dart';
import '../../screens/WallpaperSelectionScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../utils/AppImages.dart';

class WallpaperScreen extends StatefulWidget {
  @override
  _WallpaperScreenState createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  String image = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    image = getStringAsync(SELECTED_WALLPAPER, defaultValue: "assets/default_wallpaper.png");
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("wallpaper".translate, textColor: Colors.white),
      body: body(),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: context.height() * 0.55,
            width: 250,
            decoration: getIntAsync(SELECTED_WALLPAPER_CATEGORY) == 3
                ? BoxDecoration(
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(Color(int.parse(image.substring(1, 7), radix: 16) + 0xFF000000), BlendMode.color),
                      fit: BoxFit.cover,
                      image: Image.asset(ic_solid_wallpaper).image,
                    ),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: getIntAsync(SELECTED_WALLPAPER_CATEGORY) == 0 ? Image.asset(image).image : Image.network(image).image,
                    ),
                  ),
            padding: EdgeInsets.only(top: 20),
            child: Column(
              children: [
                ChatWidget(createdAt: 20, isMe: false, message: ""),
                ChatWidget(createdAt: 20, isMe: true, message: ""),
              ],
            ),
          ).center(),
          32.height,
          TextButton(
              child: Text('change'.translate, style: primaryTextStyle(color: primaryColor)),
              onPressed: () async {
                String? data = await WallpaperSelectionScreen().launch(context);
                if (data != null) {
                  image = data;
                  setState(() {});
                }
              }),
        ],
      ),
    );
  }
}
