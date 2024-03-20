import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/Permissions.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../screens/UserProfileScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/CallFunctions.dart';
import '../utils/Appwidgets.dart';
import 'FullScreenImageWidget.dart';

class ChatAppBarWidget extends StatefulWidget {
  final UserModel? receiverUser;
  final bool? isFromRequest;

  ChatAppBarWidget({required this.receiverUser, this.isFromRequest});

  @override
  ChatAppBarWidgetState createState() => ChatAppBarWidgetState();
}

class ChatAppBarWidgetState extends State<ChatAppBarWidget> {
  bool isRequestAccept = false;
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isBlocked = await userService.userByEmail(getStringAsync(userEmail)).then((value) => value.blockedTo!.contains(userService.ref!.doc(widget.receiverUser!.uid)));

    // await chatRequestService.isRequestsUserExist(widget.receiverUser!.uid!).then((value) {
    //   isRequestAccept = !value;
    //   setState(() {});
    // });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    String getTime(int val) {
      String? time;
      DateTime date = DateTime.fromMicrosecondsSinceEpoch(val * 1000);
      if (date.day == DateTime.now().day) {
        time = "at ${DateFormat('hh:mm a').format(date)}";
      } else {
        time = date.timeAgo;
      }
      return time;
    }

    return AppBar(
      automaticallyImplyLeading: false,
      title: StreamBuilder<UserModel>(
        stream: userService.singleUser(widget.receiverUser!.uid),
        builder: (context, snap) {
          if (snap.hasError) {
            return Container();
          }
          if (snap.hasData) {
            UserModel data = snap.data!;

            return Row(
              children: [
                InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    if (widget.isFromRequest!) {
                      finish(context, true);
                    } else {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: Icon(Icons.arrow_back, color: whiteColor),
                ),
                8.width,
                InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    FullScreenImageWidget(photoUrl: data.photoUrl, heroId: data.uid, name: data.name).launch(context);
                  },
                  child: Row(
                    children: [
                      data.photoUrl!.isEmpty
                          ? Hero(tag: data.uid.validate(), child: noProfileImageFound(height: 35, width: 35))
                          : Hero(tag: data.uid!, child: cachedImage(data.photoUrl.validate(), height: 35, width: 35, fit: BoxFit.cover).cornerRadiusWithClipRRect(50)),
                    ],
                  ).paddingSymmetric(vertical: 16),
                ),
                8.width,
                InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    UserProfileScreen(uid: data.uid.validate()).launch(context, pageRouteAnimation: PageRouteAnimation.Scale, duration: 300.milliseconds);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.name!, style: boldTextStyle(color: whiteColor)),
                      4.height,
                      data.isPresence!
                          ? Text('online'.translate, style: secondaryTextStyle(color: Colors.white70))
                          : Marquee(
                              direction: Axis.horizontal, child: Text('last_seen'.translate + " ${getTime(data.lastSeen!.validate())}", style: secondaryTextStyle(size: 12, color: Colors.white70))),
                    ],
                  ).paddingSymmetric(vertical: 16),
                ).expand(),
              ],
            );
          }

          return snapWidgetHelper(snap, loadingWidget: Container());
        },
      ),
      actions: [
        IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(FontAwesome.video_camera, size: 20, color: whiteColor),
            onPressed: () async {
              if (isBlocked) {
                unblockDialog(context, receiver: widget.receiverUser!);
                return;
              }
              return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.dial(context: context, from: sender, to: widget.receiverUser!) : {};
            }),
        IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(FontAwesome.phone, size: 20, color: whiteColor),
            onPressed: () async {
              if (isBlocked) {
                unblockDialog(context, receiver: widget.receiverUser!);
                return;
              }
              log("Sender--" + sender.toJson().toString());
              log("Receiver---" + widget.receiverUser!.toJson().toString());
              return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.voiceDial(context: context, from: sender, to: widget.receiverUser!) : {};
            }),
        PopupMenuButton(
          padding: EdgeInsets.zero,
          offset: Offset(10, -40),
          icon: Icon(Icons.more_vert, color: whiteColor),
          color: appStore.isDarkMode ? scaffoldSecondaryDark : white,
          //   color: context.cardColor,
          onSelected: (dynamic value) async {
            if (value == 1) {
              UserProfileScreen(uid: widget.receiverUser!.uid.validate()).launch(context, pageRouteAnimation: PageRouteAnimation.Scale, duration: 300.milliseconds);
            } else if (value == 2) {
              showConfirmDialogCustom(
                context,
                dialogAnimation: DialogAnimation.SCALE,
                title: "report".translate + " ${widget.receiverUser!.name.validate()} ?",
                negativeText: "cancel".translate,
                positiveText: "report".translate,
                primaryColor: primaryColor,
                onAccept: (V) {
                  reportBy();
                },
              );
            } else if (value == 3) {
              if (isBlocked) {
                unblockDialog(context, receiver: widget.receiverUser!);
              } else {
                showConfirmDialogCustom(
                  context,
                  dialogAnimation: DialogAnimation.SCALE,
                  title: "block".translate + " ${widget.receiverUser!.name.validate()}?",
                  subTitle: "blocked_contact_will_no_longer_be_able_to_call_you_or_send_you_message".translate,
                  onAccept: (v) {
                    blockMessage();
                  },
                  positiveText: "block".translate,
                  negativeText: "cancel".translate,
                  primaryColor: primaryColor,
                );
              }
            } else if (value == 4) {
              showConfirmDialogCustom(context,
                  dialogAnimation: DialogAnimation.SCALE,
                  title: "clear_chats".translate + '?',
                  positiveText: 'lbl_yes'.translate,
                  negativeText: 'lbl_no'.translate,
                  primaryColor: primaryColor, onAccept: (v) {
                chatMessageService.clearAllMessages(senderId: sender.uid, receiverId: widget.receiverUser!.uid!).then((value) {
                  toast("chat_clear".translate);
                  hideKeyboard(context);
                }).catchError((e) {
                  toast(e);
                });
              });
            }
          },
          itemBuilder: (context) {
            List<PopupMenuItem> list = [];
            list.add(PopupMenuItem(value: 1, child: Text('view_Contact'.translate, style: primaryTextStyle())));
            list.add(PopupMenuItem(value: 2, child: Text('report'.translate, style: primaryTextStyle())));
            list.add(PopupMenuItem(value: 3, child: Text(isBlocked ? 'unblock'.translate : 'block'.translate, style: primaryTextStyle())));
            list.add(PopupMenuItem(value: 4, child: Text('clear_Chat'.translate, style: primaryTextStyle())));

            return list;
          },
        ),
      ],
      backgroundColor: context.primaryColor,
    );
  }

  void blockMessage() async {
    List<DocumentReference> temp = [];
    await userService.userByEmail(getStringAsync(userEmail)).then((value) {
      temp = value.blockedTo!;
    });
    if (!temp.contains(userService.ref!.doc(widget.receiverUser!.uid))) {
      temp.add(userService.getUserReference(uid: widget.receiverUser!.uid.validate()));
    }

    userService.blockUser({"blockedTo": temp}).then((value) {
      finish(context);
      finish(context);
      finish(context);
    }).catchError((e) {
      //
    });
  }

  void reportBy() async {
    List<DocumentReference> temp = [];
    temp = await userService.userByEmail(widget.receiverUser!.email).then((value) => value.reportedBy!);

    if (!temp.contains(userService.ref!.doc(getStringAsync(userId)))) {
      temp.add(userService.getUserReference(uid: getStringAsync(userId)));
    }

    if (temp.length >= appSettingStore.mReportCount) {
      userService.reportUser({"isActive": false}, widget.receiverUser!.uid.validate()).then((value) {
        finish(context);
        finish(context);
        finish(context);
        toast("UserAccountIsDeactivatedByAdminToRestorePleaseContactAdmin".translate);
        toast(value.toString());
      }).catchError((e) {
        //
      });
    } else {
      userService.reportUser({"reportedBy": temp}, widget.receiverUser!.uid.validate()).then((value) {
        finish(context);
        finish(context);
        finish(context);
        toast(value.toString());
      }).catchError((e) {
        //
      });
    }
  }
}
