import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/FullScreenImageWidget.dart';
import '../../models/ChatMessageModel.dart';
import '../../utils/Appwidgets.dart';
import '../main.dart';
import '../utils/AppColors.dart';
import '../utils/AppCommon.dart';

class ImageChatComponent extends StatelessWidget {
  final ChatMessageModel data;
  final String time;

  ImageChatComponent({required this.data, required this.time});

  @override
  Widget build(BuildContext context) {
    if (data.photoUrl.validate().isNotEmpty || data.photoUrl != null) {
      return Container(
        width: 250,
        height: 250,
        child: Stack(
          children: [
            cachedImage(data.photoUrl.validate(), fit: BoxFit.cover, width: 250, height: 250).cornerRadiusWithClipRRect(10),
            Align(
              alignment: isRTL ? Alignment.bottomLeft : Alignment.bottomRight,
              child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(time, style: primaryTextStyle(color: !data.isMe.validate() ? Colors.blueGrey.withOpacity(0.6) : whiteColor.withOpacity(0.6), size: 10)),
                    2.width,
                    data.isMe!
                        ? !data.isMessageRead!
                            ? Icon(Icons.done, size: 16, color: Colors.blueGrey.withOpacity(0.6))
                            : Icon(Icons.done_all, size: 16, color: appStore.isDarkMode ? textPrimaryColor : primaryColor)
                        : Offstage()
                  ],
                ),
              ).paddingAll(6),
            )
          ],
        ).onTap(
          () {
            log("value" + data.id.toString());
            FullScreenImageWidget(photoUrl: data.photoUrl, heroId: data.id, isFromChat: true).launch(context);
          },
        ),
      );
    } else {
      return Container(child: Loader(), height: 250, width: 250);
    }
  }
}
