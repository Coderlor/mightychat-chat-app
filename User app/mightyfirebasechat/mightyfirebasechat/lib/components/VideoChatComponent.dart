import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/ChatMessageModel.dart';
import '../../screens/VideoPlayScreen.dart';
import '../../utils/AppCommon.dart';
import '../main.dart';
import '../utils/AppColors.dart';

class VideoChatComponent extends StatelessWidget {
  final ChatMessageModel data;
  final String time;

  VideoChatComponent({required this.data, required this.time});

  @override
  Widget build(BuildContext context) {
    if (data.photoUrl.validate().isNotEmpty || data.photoUrl != null) {
      return InkWell(
        onTap: () {
          VideoPlayScreen(data.photoUrl.validate()).launch(context);
        },
        child: Container(
          height: 250,
          width: 250,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: radius(defaultInkWellRadius),
                child: videoThumbnailImage(path: data.photoUrl.validate(), height: 250, width: 250),
              ),
              Container(
                padding: EdgeInsets.all(6),
                decoration: boxDecorationWithShadow(backgroundColor: Colors.black38, boxShape: BoxShape.circle, spreadRadius: 0, blurRadius: 0),
                child: Icon(Icons.play_arrow, color: Colors.white),
              ).center(),
              Align(
                alignment: isRTL ? Alignment.bottomLeft : Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: primaryTextStyle(color: !data.isMe.validate() ? Colors.blueGrey.withOpacity(0.6) : whiteColor.withOpacity(0.6), size: 10),
                    ),
                    2.width,
                    data.isMe!
                        ? !data.isMessageRead!
                            ? Icon(Icons.done, size: 16, color: Colors.blueGrey.withOpacity(0.6))
                            : Icon(Icons.done_all, size: 16, color: appStore.isDarkMode ? textPrimaryColor : primaryColor)
                        : Offstage()
                  ],
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return SizedBox(child: Loader(), height: 250, width: 250);
    }
  }
}
