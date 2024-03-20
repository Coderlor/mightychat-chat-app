import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../models/WallpaperServiceModel.dart';
import '../screens/WallpaperChatPreviewScreen.dart';

class WallpaperListComponent extends StatefulWidget {
  final String? name;
  final bool? mIsIndividual;
  final List<WallpaperServiceModel>? wallpaperList;

  WallpaperListComponent({this.name, this.wallpaperList, this.mIsIndividual});

  @override
  _WallpaperListComponentState createState() => _WallpaperListComponentState();
}

class _WallpaperListComponentState extends State<WallpaperListComponent> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("${widget.name.validate()} Wallpaper", textColor: Colors.white),
      body: body(),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      child: Wrap(
        runSpacing: 4,
        spacing: 4,
        children: List.generate(
          widget.wallpaperList!.length,
          (index) {
            return Container(
              height: 200,
              width: (context.width() - 8) / 3,
              decoration: widget.wallpaperList![index].categoryId == 3
                  ? BoxDecoration(
                      color: Color(int.parse(widget.wallpaperList![index].wallpaperPath.validate().substring(1, 7), radix: 16) + 0xFF000000),
                    )
                  : BoxDecoration(
                      // image: DecorationImage(
                      //   fit: BoxFit.cover,
                      //   image: Image.network(
                      //     widget.wallpaperList![index].wallpaperPath!,
                      //
                      //   ).image,
                      // ),
                      ),
              child: Stack(
                children: [
                  if (widget.wallpaperList![index].categoryId != 3) Loader().center(),
                  Image.network(
                    widget.wallpaperList![index].wallpaperPath!,
                    height: 200,
                    width: (context.width() - 8) / 3,
                    fit: BoxFit.cover,
                  )
                ],
              ),
              alignment: Alignment.bottomRight,
            ).onTap(() {
              WallpaperChatPreviewScreen(index: index, wallpaperList: widget.wallpaperList, mIsIndividual: widget.mIsIndividual).launch(context);
            });
          },
        ),
      ),
    );
  }
}
