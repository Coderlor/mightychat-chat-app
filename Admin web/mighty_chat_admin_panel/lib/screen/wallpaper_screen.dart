import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mighty_chat_admin_panel/main.dart';
import 'package:mighty_chat_admin_panel/model/WallpaperModel.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/add_wallpaper_component.dart';
import '../component/wallpaper_widget.dart';
import '../utils/colors.dart';

class WallpaperScreen extends StatefulWidget {
  @override
  _WallpaperScreenState createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  List<String> tabList = ['Dark Wallpaper', 'Bright Wallpaper', 'Solid Wallpaper'];

  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabList.length,
      child: Scaffold(
        floatingActionButton: AppButton(
          text: 'Add Wallpaper',
          shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
          onTap: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AddWallpaperComponent();
                }).whenComplete(() {
              setState(() {});
            });
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.15), borderRadius: radius(8)),
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              child: TabBar(
                indicatorColor: Colors.transparent,
                tabs: tabList.map((item) {
                  int index = tabList.indexOf(item);
                  return Container(
                    margin: EdgeInsets.only(right: index < tabList.length - 1 ? 30 : 0),
                    child: Text(item, style: boldTextStyle(color: selectedTab == index ? primaryColor : null)),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: selectedTab == index ? Theme.of(context).cardColor : Colors.transparent, borderRadius: radius(8)),
                    alignment: Alignment.center,
                  );
                }).toList(),
                onTap: (index) {
                  selectedTab = index;
                  setState(() {});
                },
              ),
            ),
            Stack(
              children: [
                SingleChildScrollView(
                  child: FutureBuilder<List<WallpaperModel>>(
                      future: wallpaperService.getAllWallpaper(),
                      builder: (context, snap) {
                        if (snap.hasData) {
                          List<WallpaperModel> darkWallpaper = [];
                          List<WallpaperModel> brightWallpaper = [];
                          List<WallpaperModel> solidWallpaper = [];

                          snap.data!.forEach((element) {
                            if (element.categoryId == 1) {
                              darkWallpaper.add(element);
                            } else if (element.categoryId == 2) {
                              brightWallpaper.add(element);
                            } else if (element.categoryId == 3) {
                              solidWallpaper.add(element);
                            }
                          });
                          return selectedTab == 0
                              ? Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: darkWallpaper.map((e) {
                                    return WallpaperWidget(e);
                                  }).toList(),
                                )
                              : selectedTab == 1
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.start,
                                      children: brightWallpaper.map((e) {
                                        return WallpaperWidget(e);
                                      }).toList())
                                  : Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      crossAxisAlignment: WrapCrossAlignment.start,
                                      children: solidWallpaper.map((e) {
                                        return WallpaperWidget(e);
                                      }).toList());
                        }
                        return snapWidgetHelper(snap);
                      }).paddingSymmetric(vertical: 16),
                ),
                Observer(builder: (context) {
                  return Positioned(child: Loader()).visible(appStore.isLoading);
                })
              ],
            ).expand(),
          ],
        ).paddingAll(16),
      ),
    );
  }
}
