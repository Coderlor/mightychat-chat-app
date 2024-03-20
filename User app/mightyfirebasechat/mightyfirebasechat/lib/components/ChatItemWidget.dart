import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../components/AudioPlayComponent.dart';
import '../../components/ImageChatComponent.dart';
import '../../components/StickerChatComponent.dart';
import '../../components/TextChatComponent.dart';
import '../../components/VideoChatComponent.dart';
import '../../main.dart';
import '../../models/ChatMessageModel.dart';
import '../../models/UserModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';

class ChatItemWidget extends StatefulWidget {
  final ChatMessageModel? data;
  final bool isGroup;
  final String currentlySentAudioPath;

  ChatItemWidget({this.data, this.isGroup = false, this.currentlySentAudioPath = ""});

  @override
  _ChatItemWidgetState createState() => _ChatItemWidgetState();
}

class _ChatItemWidgetState extends State<ChatItemWidget> {
  String? images;
  UserModel userModel = UserModel();

  void initState() {
    super.initState();
    init();
  }

  init() async {
    print("=============== chatItem widget${widget.data!.photoUrl}");
    appStore.isLoading = true;
    await userService.getUserById(val: widget.data!.senderId).then((value) {
      userModel = value;
      appStore.isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String time;
    DateTime date = DateTime.fromMicrosecondsSinceEpoch(widget.data!.createdAt! * 1000);
    if (date.day == DateTime.now().day) {
      time = DateFormat('hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(widget.data!.createdAt! * 1000));
    } else {
      time = DateFormat('dd-MM-yyy hh:mm a').format(DateTime.fromMicrosecondsSinceEpoch(widget.data!.createdAt! * 1000));
    }

    EdgeInsetsGeometry customPadding(String? messageTypes) {
      switch (messageTypes) {
        case TEXT:
          return EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        case IMAGE:
        case VIDEO:
        case DOC:
        case LOCATION:
        case AUDIO:
          return EdgeInsets.symmetric(horizontal: 4, vertical: 4);
        default:
          return EdgeInsets.symmetric(horizontal: 4, vertical: 4);
      }
    }

    Widget chatItem(String? messageTypes) {
      switch (messageTypes) {
        case TEXT:
          return TextChatComponent(data: widget.data!, time: time);

        case IMAGE:
          return ImageChatComponent(data: widget.data!, time: time);

        case VOICE_NOTE:
          return AudioPlayComponent(
            data: widget.data,
            time: time,
          );

        case VIDEO:
          return VideoChatComponent(data: widget.data!, time: time);

        case DOC:
          return GestureDetector(
            onTap: () async {
              log(widget.data!.photoUrl);
              if (!widget.data!.photoUrl.validate().isEmptyOrNull) {
                await launchUrl(Uri.parse(widget.data!.photoUrl.validate()), mode: LaunchMode.externalApplication);
              } else {
                toast('Url Not Found');
              }
            },
            child: SizedBox(
              width: context.width() / 2 - 48,
              height: 90,
              child: Stack(
                alignment: isRTL ? Alignment.bottomLeft : Alignment.bottomRight,
                children: [
                  Container(
                    height: 60,
                    width: context.width() / 3 - 16,
                    child: Icon(Ionicons.document, color: scaffoldDarkColor.withOpacity(0.5), size: 30),
                  ).paddingAll(16),
                  Positioned(
                    bottom: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_circle_down_outlined, color: Colors.blue).paddingAll(4),
                        widget.data!.isMe!
                            ? !widget.data!.isMessageRead!
                                ? Icon(Icons.done, size: 16, color: textSecondaryColor).paddingOnly(top: 8, bottom: 8)
                                : Icon(Icons.done_all, size: 16, color: appStore.isDarkMode ? textPrimaryColor : primaryColor).paddingOnly(top: 8, bottom: 8)
                            : Offstage()
                      ],
                    ).paddingOnly(left: isRTL ? 4 : 0, right: isRTL ? 0 : 4),
                  ),

                  Positioned(
                    bottom: 0,
                    child: Align(
                      alignment: isRTL ? Alignment.bottomLeft : Alignment.bottomRight,
                      child: Text(
                        time,
                        style: primaryTextStyle(color: widget.data!.isMe.validate() ? Colors.blueGrey.withOpacity(0.6) : whiteColor.withOpacity(0.6), size: 10),
                      ).paddingOnly(left: isRTL ? 4 : 0, right: isRTL ? 0 : 4),
                    ),
                  ),
                  // widget.data!.isMe!
                  //     ? !widget.data!.isMessageRead!
                  //  ?

                  //     : Icon(Icons.done_all, size: 16, color: primaryColor)
                  // : Offstage()
                ],
              ),
            ),
          );

        case AUDIO:
          return AudioPlayComponent(data: widget.data, time: time);

        case LOCATION:
          return Container(
            height: 250,
            width: 250,
            child: Stack(
              children: [
                Image.asset('assets/map_image.jpeg', height: 245, width: 250, fit: BoxFit.cover).cornerRadiusWithClipRRect(12),
                Align(
                  alignment: isRTL ? Alignment.bottomLeft : Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(time, style: primaryTextStyle(color: Colors.blueGrey, size: 10)),
                      2.width,
                      widget.data!.isMe!
                          ? !widget.data!.isMessageRead!
                              ? Icon(Icons.done, size: 16, color: Colors.blueGrey)
                              : Icon(Icons.done_all, size: 16, color: appStore.isDarkMode ? textPrimaryColor : primaryColor)
                          : Offstage(),
                      8.width,
                    ],
                  ).paddingBottom(8),
                ),
              ],
            ).onTap(() async {
              final url = 'https://www.google.com/maps/search/?api=1&query=${widget.data!.currentLat},${widget.data!.currentLong}';
              if (!url.isEmptyOrNull) {
                await launchUrl(Uri.parse(url));
              } else {
                throw 'Could not launch $url';
              }
            }),
          );

        case STICKER:
          return StickerChatComponent(data: widget.data!, time: time, padding: customPadding(messageTypes));

        default:
          return Container();
      }
    }

    return GestureDetector(
      onLongPress: !widget.data!.isMe!
          ? null
          : () async {
              await showConfirmDialogCustom(context,
                  title: 'are_you_sure_want_to_delete_message'.translate, positiveText: 'lbl_yes'.translate, negativeText: 'lbl_no'.translate, primaryColor: primaryColor, onAccept: (v) {
                hideKeyboard(context);
                if (widget.isGroup) {
                  groupChatMessageService.deleteGrpSingleMessage(groupDocId: getStringAsync(CURRENT_GROUP_ID), messageDocId: widget.data!.id).then((value) {
                    //
                  }).catchError(
                    (e) {
                      log("Error:" + e.toString());
                    },
                  );
                } else {
                  chatMessageService.deleteSingleMessage(senderId: widget.data!.senderId, receiverId: widget.data!.receiverId!, documentId: widget.data!.id).then((value) {
                    //
                  }).catchError(
                    (e) {
                      log(e.toString());
                    },
                  );
                }
              });
            },
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.data!.isMe.validate() ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment: widget.data!.isMe! ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              // margin: widget.data!.isMe.validate()
              //     ? EdgeInsets.only(
              //         top: 0.0,
              //         bottom: 0.0,
              //         left: isRTL ? 0 : context.width() * 0.25,
              //         right: isRTL
              //             ? widget.data!.messageType == AUDIO
              //                 ? context.width() * 0.25
              //                 : 0
              //             : 0)
              //     : EdgeInsets.only(top: 2.0, bottom: 2.0, left: isRTL ? context.width() * 0.25 : 8, right: isRTL ? 0 : context.width() * 0.25),
              margin: widget.data!.isMe.validate()
                  ? EdgeInsets.only(top: 0.0, bottom: 0.0, left: isRTL ? 0 : context.width() * 0.25, right: 8)
                  //   ? EdgeInsets.only(top: 0.0, bottom: 0.0, left: isRTL ? 0 : context.width() * 0.25, right: 8)
                  : EdgeInsets.only(top: 2.0, bottom: 2.0, left: 8, right: isRTL ? 0 : context.width() * 0.25),

              padding: customPadding(widget.data!.messageType),
              decoration: widget.data!.messageType != MessageType.STICKER.name
                  ? BoxDecoration(
                      boxShadow: appStore.isDarkMode ? null : defaultBoxShadow(),
                      color: widget.data!.isMe.validate()
                          ? appStore.isDarkMode
                              ? primaryColor
                              : senderMessageColor
                          : context.cardColor,
                      borderRadius: widget.data!.isMe.validate()
                          ? radiusOnly(bottomLeft: chatMsgRadius, topLeft: chatMsgRadius, bottomRight: chatMsgRadius, topRight: 0)
                          : radiusOnly(bottomLeft: chatMsgRadius, topLeft: 0, bottomRight: chatMsgRadius, topRight: chatMsgRadius),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isGroup && userModel.name != null && !widget.data!.isMe.validate()) Text(userModel.name.validate(), style: boldTextStyle(size: 12, color: primaryColor)).paddingAll(1),
                  if (widget.isGroup && userModel.name != null && !widget.data!.isMe.validate()) 8.height,
                  chatItem(widget.data!.messageType),
                ],
              ),
            ),
          ],
        ),
        margin: EdgeInsets.only(top: 2, bottom: 2),
      ),
    );
  }
}
