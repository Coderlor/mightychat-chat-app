import 'package:chat/utils/AppImages.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/WallpaperListComponent.dart';
import '../../models/WallpaperModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../main.dart';
import '../models/WallpaperServiceModel.dart';

class WallpaperSelectionScreen extends StatefulWidget {
  final bool? mIsIndividual;

  WallpaperSelectionScreen({this.mIsIndividual});

  @override
  _WallpaperSelectionScreenState createState() => _WallpaperSelectionScreenState();
}

class _WallpaperSelectionScreenState extends State<WallpaperSelectionScreen> {
  List<WallpaperModel> wallpaperList = [];
  List<WallpaperServiceModel> darkWallpaper = [];
  List<WallpaperServiceModel> brightWallpaper = [];
  List<WallpaperServiceModel> solidWallpaper = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    appStore.setLoading(true);
    setState(() {});
    await getWallPaper().then((value) {
      wallpaperList.add(WallpaperModel(name: "Bright", categoryId: 1, isSelected: false, path: brightWallpaper.first.wallpaperPath, sublist: brightWallpaper));
      wallpaperList.add(WallpaperModel(name: "Dark", categoryId: 2, isSelected: false, path: darkWallpaper.first.wallpaperPath, sublist: darkWallpaper));
      wallpaperList.add(WallpaperModel(name: "Solid colors", categoryId: 3, isSelected: false, path: solidWallpaper.first.wallpaperPath, sublist: solidWallpaper));
    });
  }

  Future getWallPaper() async {
    await wallpaperService.getAllWallpaper().then((value) {
      value.forEach((element) {
        if (element.categoryId == 1) {
          darkWallpaper.add(element);
        } else if (element.categoryId == 2) {
          brightWallpaper.add(element);
        } else if (element.categoryId == 3) {
          solidWallpaper.add(element);
        }
      });
      appStore.setLoading(false);
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(
              wallpaperList.length,
              (index) {
                WallpaperModel data = wallpaperList[index];
                return Container(
                  decoration: data.categoryId == 3
                      ? boxDecorationWithShadow(
                          blurRadius: 0,
                          spreadRadius: 0,
                          border: Border.all(color: viewLineColor),
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: Color(int.parse(data.sublist!.first.wallpaperPath.validate().substring(1, 7), radix: 16) + 0xFF000000))
                      : boxDecorationWithShadow(
                          blurRadius: 0,
                          spreadRadius: 0,
                          border: Border.all(color: viewLineColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                  width: (context.width() - 44) / 2,
                  height: 160,
                  child: Stack(
                    children: [
                      if (data.categoryId != 3) Loader().center(),
                      if (data.categoryId != 3)
                        Image.network(
                          width: (context.width() - 44) / 2,
                          height: 160,
                          "${data.path}",
                          fit: BoxFit.cover,
                        ).cornerRadiusWithClipRRect(defaultRadius),
                      Text("${data.name.validate()}", style: boldTextStyle(color: Colors.white)).center(),
                    ],
                  ),
                ).onTap(() {
                  WallpaperListComponent(
                    mIsIndividual: widget.mIsIndividual,
                    name: data.name.validate(),
                    wallpaperList: data.sublist.validate(),
                  ).launch(context);
                });
              },
            ),
          ).paddingOnly(top: 16).visible(!appStore.isLoading),
          16.height,
          Container(
            child: SettingItemWidget(
              title: "default_wallpaper".translate,
              leading: Icon(Icons.wallpaper),
              onTap: () async {
                bool? res = await showConfirmDialog(context, "are_you_sure_you_want_to_change_to_default_wallpaper".translate, buttonColor: secondaryColor);
                if (res ?? false) {
                  setValue(SELECTED_WALLPAPER_CATEGORY, 0);
                  setValue(SELECTED_WALLPAPER, ic_default_wallpaper);
                  finish(context, ic_default_wallpaper);
                }
              },
            ),
          ).visible(!appStore.isLoading),
          Container(width: context.width(), height: context.height(), child: Loader().center().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
