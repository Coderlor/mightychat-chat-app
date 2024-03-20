import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/FullScreenImageWidget.dart';
import '../../main.dart';
import '../../models/ChatMessageModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../utils/Appwidgets.dart';

class StickerChatComponent extends StatelessWidget {
  final ChatMessageModel data;
  final String time;
  final EdgeInsetsGeometry padding;

  StickerChatComponent({required this.data, required this.time, required this.padding});

  @override
  Widget build(BuildContext context) {
    if (data.stickerPath.validate().isNotEmpty) {
      return Stack(
        children: [
          cachedImage(data.stickerPath.validate(), fit: BoxFit.fill, width: 110).paddingBottom(10),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              margin: data.isMe.validate()
                  ? EdgeInsets.only(top: 0.0, bottom: 0.0, left: isRTL ? 0 : context.width() * 0.25, right: 8)
                  : EdgeInsets.only(top: 2.0, bottom: 2.0, left: 8, right: isRTL ? 0 : context.width() * 0.25),
              padding: padding,
              decoration: BoxDecoration(
                boxShadow: appStore.isDarkMode ? null : defaultBoxShadow(),
                color: data.isMe.validate() ? primaryColor : context.cardColor,
                borderRadius: data.isMe.validate()
                    ? radiusOnly(bottomLeft: chatMsgRadius, topLeft: chatMsgRadius, bottomRight: chatMsgRadius, topRight: chatMsgRadius)
                    : radiusOnly(bottomLeft: chatMsgRadius, topLeft: chatMsgRadius, bottomRight: chatMsgRadius, topRight: chatMsgRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: primaryTextStyle(
                      color: !data.isMe.validate() ? Colors.blueGrey.withOpacity(0.6) : whiteColor.withOpacity(0.6),
                      size: 10,
                    ),
                  ),
                  2.width,
                  data.isMe!
                      ? !data.isMessageRead!
                          ? Icon(Icons.done, size: 16, color: Colors.blueGrey.withOpacity(0.6))
                          : Icon(Icons.done_all, size: 16, color: appStore.isDarkMode ? textPrimaryColor : primaryColor)
                      : Offstage()
                ],
              ),
            ),
          )
        ],
      ).onTap(() {
        FullScreenImageWidget(photoUrl: data.stickerPath, isFromChat: true, name: data.messageType).launch(context);
      });
    } else {
      return Container(
        child: Loader(),
        height: 120,
        width: 120,
      );
    }
  }
}
