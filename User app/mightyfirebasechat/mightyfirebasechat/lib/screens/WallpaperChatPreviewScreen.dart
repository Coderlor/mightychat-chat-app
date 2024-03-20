import 'package:chat/utils/AppImages.dart';
import '../../components/ChatWidget.dart';
import '../../utils/AppConstants.dart';
import '../../utils/AppCommon.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../models/WallpaperServiceModel.dart';

class WallpaperChatPreviewScreen extends StatefulWidget {
  final int? index;
  final List<WallpaperServiceModel>? wallpaperList;
  final bool? mIsIndividual;

  WallpaperChatPreviewScreen({this.index, this.wallpaperList, this.mIsIndividual});

  @override
  _WallpaperChatPreviewScreenState createState() => _WallpaperChatPreviewScreenState();
}

class _WallpaperChatPreviewScreenState extends State<WallpaperChatPreviewScreen> {
  PageController? pageController;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    pageController = PageController(initialPage: widget.index!, keepPage: true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("preview".translate, textColor: Colors.white),
      body: PageView.builder(
        controller: pageController,
        itemCount: widget.wallpaperList!.length,
        itemBuilder: (context, index) {
          WallpaperServiceModel data = widget.wallpaperList![index];
          return Container(
            decoration: data.categoryId == 3
                ? BoxDecoration(
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(Color(int.parse(widget.wallpaperList![index].wallpaperPath.validate().substring(1, 7), radix: 16) + 0xFF000000), BlendMode.color),
                      fit: BoxFit.cover,
                      image: Image.asset(ic_solid_wallpaper).image,
                    ),
                  )
                : BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.network(data.wallpaperPath!).image,
                    ),
                  ),
            padding: EdgeInsets.only(top: 20),
            child: Stack(
              children: [
                Column(
                  children: [
                    ChatWidget(createdAt: 20, isMe: false, message: "swipe_left_or_right_to_preview_more_wallpapers".translate),
                    ChatWidget(createdAt: 20, isMe: true, message: "set_wallpaper_for_this_theme".translate),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30),
                        topLeft: Radius.circular(30),
                      ),
                    ),
                    child: AppButton(
                      color: Colors.black54,
                      shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      text: "set_wallpaper".translate,
                      onTap: () {
                        finish(context);
                        finish(context);
                        finish(context, data.wallpaperPath);
                        setValue(SELECTED_WALLPAPER_CATEGORY, data.categoryId);
                        setValue(SELECTED_WALLPAPER, data.wallpaperPath!);
                      },
                    ).center(),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
