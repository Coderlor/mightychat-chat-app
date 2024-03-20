import 'package:flutter/material.dart';
import 'package:mighty_chat_admin_panel/model/WallpaperModel.dart';
import 'package:mighty_chat_admin_panel/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/cached_network_image.dart';
import '../utils/common.dart';

class WallpaperWidget extends StatefulWidget {
  final WallpaperModel? wallpaperModel;

  WallpaperWidget(this.wallpaperModel);

  @override
  _WallpaperWidgetState createState() => _WallpaperWidgetState();
}

class _WallpaperWidgetState extends State<WallpaperWidget> {
  double height = 250;
  double width = 154;

  @override
  Widget build(BuildContext context) {
    return HoverWidget(builder: (context, isHovering) {
      return Stack(
        alignment: Alignment.topRight,
        children: [
          widget.wallpaperModel!.categoryId == 3
              ? Stack(
                  children: [
                    Image.asset(appImages.icSolidWallpaper,
                        height: height, width: width, fit: BoxFit.cover),
                    Container(
                        height: height,
                        width: width,
                        color: Color(int.parse(
                                widget.wallpaperModel!.wallpaperPath
                                    .validate()
                                    .substring(1, 7),
                                radix: 16) +
                            0xFF000000))
                  ],
                )
              : CachedImageWidget(
                  url: widget.wallpaperModel!.wallpaperPath.validate(),
                  height: height,
                  width: width,
                  fit: BoxFit.cover),
          if (isHovering)
            outlineActionIcon(Icons.delete, redColor, 'Delete', () {
              if (!appStore.isTester) {
                showConfirmDialogCustom(context,
                    subTitle: 'Are you sure want to delete this wallpaper?',
                    primaryColor: Colors.red,
                    dialogType: DialogType.DELETE, onAccept: (v) {
                  appStore.setIsLoading(true);
                  wallpaperService
                      .removeDocument(widget.wallpaperModel!.id.validate())
                      .then((value) {
                    wallpaperService.deleteImage(
                        widget.wallpaperModel!.wallpaperPath.validate());
                    toastWidget(context, 'Wallpaper deleted successfully');
                    appStore.setIsLoading(false);
                    setState(() {});
                  });
                });
              } else {
                toastWidget(context, 'Test user cannot perform this action');
              }
            }).paddingAll(8),
        ],
      );
    });
  }
}
