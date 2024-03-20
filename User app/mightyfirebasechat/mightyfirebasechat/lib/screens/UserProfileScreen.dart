import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/FullScreenImageWidget.dart';
import '../../components/Permissions.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../../utils/CallFunctions.dart';
import '../utils/AppImages.dart';

class UserProfileScreen extends StatefulWidget {
  final String uid;
  final String? heroId;

  UserProfileScreen({required this.uid, this.heroId = ''});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late UserModel currentUser;
  bool isBlocked = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isBlocked = await userService.userByEmail(getStringAsync(userEmail)).then((value) => value.blockedTo!.contains(userService.ref!.doc(widget.uid)));
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildImageIconWidget({double? height, double? width, double? roundRadius}) {
    if (currentUser.photoUrl.validate().isNotEmpty) {
      return Hero(
        tag: widget.uid,
        child: cachedImage(currentUser.photoUrl.validate(), radius: 50, height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(50).onTap(() {
          FullScreenImageWidget(photoUrl: currentUser.photoUrl.validate(), isFromChat: true, name: currentUser.name.validate()).launch(context);
        }),
      );
    }
    return noProfileImageFound(height: 100, width: 100).onTap(() {
      //
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<UserModel>(
        stream: userService.singleUser(widget.uid),
        builder: (context, snap) {
          if (snap.hasData) {
            currentUser = snap.data!;
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    forceMaterialTransparency: true,
                    automaticallyImplyLeading: true,
                    expandedHeight: innerBoxIsScrolled ? 50 : 310.0,
                    leading: BackButton(color: context.iconColor).onTap(() {
                      finish(context);
                    }),
                    backgroundColor: context.cardColor,
                    floating: true,
                    pinned: true,
                    snap: true,
                    stretch: true,
                    stretchTriggerOffset: 120.0,
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.parallax,
                      stretchModes: [StretchMode.zoomBackground],
                      titlePadding: EdgeInsetsDirectional.only(start: 50.0, bottom: 20.0),
                      background: Container(
                        //     margin: EdgeInsets.only(bottom: 3),
                        padding: EdgeInsets.all(16),
                        decoration: boxDecorationWithShadow(borderRadius: radius(0), backgroundColor: context.cardColor),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            32.height,
                            buildImageIconWidget(),
                            aboutDetail(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                height: context.height(),
                color: context.scaffoldBackgroundColor,
                child: Column(
                  children: [
                    statusWidget(),
                    buildBlockMSG(),
                    buildReport(),
                  ],
                ),
              ),
            );
          }
          return snapWidgetHelper(snap);
        },
      ),
    );
  }

  Widget aboutDetail() {
    return Container(
      color: context.cardColor,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: context.width(),
      child: Column(
        children: [
          16.height,
          Text("${currentUser.name}", style: boldTextStyle(letterSpacing: 0.5)),
          8.height,
          Text('+91' + '*' * (currentUser.phoneNumber!.length - 3), style: secondaryTextStyle()),
          8.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  IconButton(
                    icon: Image.asset(ic_messages, height: 25, width: 25, color: appStore.isDarkMode ? Colors.white : primaryColor),
                    onPressed: () {
                      finish(context);
                    },
                  ),
                  Text('lblMessage'.translate, style: boldTextStyle(size: 12, letterSpacing: 0.5, color: appStore.isDarkMode ? Colors.white : primaryColor)),
                ],
              ),
              16.width,
              Column(
                children: [
                  IconButton(
                    icon: Image.asset('assets/Icons/ic_call.png', height: 25, width: 25, color: appStore.isDarkMode ? Colors.white : primaryColor),
                    onPressed: () async {
                      if (await userService.isUserBlocked(currentUser.uid.validate())) {
                        unblockDialog(context, receiver: currentUser);
                        return;
                      }
                      return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.voiceDial(context: context, from: sender, to: currentUser) : {};
                    },
                  ),
                  Text('call'.translate, style: boldTextStyle(size: 12, letterSpacing: 0.5, color: appStore.isDarkMode ? Colors.white : primaryColor)),
                ],
              ),
              16.width,
              Column(
                children: [
                  IconButton(
                    icon: Image.asset('assets/Icons/ic_video_call.png', height: 25, width: 25, color: appStore.isDarkMode ? Colors.white : primaryColor),
                    onPressed: () async {
                      if (await userService.isUserBlocked(currentUser.uid.validate())) {
                        unblockDialog(context, receiver: currentUser);
                        return;
                      }
                      return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.dial(context: context, from: sender, to: currentUser) : {};
                    },
                  ),
                  Text("video_call".translate, style: boldTextStyle(size: 12, letterSpacing: 0.5, color: appStore.isDarkMode ? Colors.white : primaryColor)),
                ],
              ),
            ],
          ),
          //     16.height,
        ],
      ),
    );
  }

  Widget statusWidget() {
    return Container(
      color: context.cardColor,
      margin: EdgeInsets.symmetric(vertical: 16),
      padding: EdgeInsets.all(16),
      width: context.width(),
      child: SettingItemWidget(
        title: currentUser.userStatus.validate(),
        titleTextStyle: primaryTextStyle(),
        padding: EdgeInsets.all(0),
        subTitle: currentUser.updatedAt!.toDate().timeAgo,
      ),
    );
  }

  void blockMessage() async {
    List<DocumentReference> temp = [];
    await userService.userByEmail(getStringAsync(userEmail)).then((value) {
      temp = value.blockedTo!;
    });
    if (!temp.contains(userService.ref!.doc(widget.uid))) {
      temp.add(userService.getUserReference(uid: currentUser.uid.validate()));
    }

    userService.blockUser({"blockedTo": temp}).then((value) {
      finish(context);
      finish(context);
      finish(context);
    }).catchError((e) {
      //
    });
  }

  Widget buildBlockMSG() {
    return SettingItemWidget(
      decoration: BoxDecoration(color: context.cardColor),
      title: isBlocked ? "${"Unblock".translate}${' ' + currentUser.name.validate()}" : "${"block".translate}${' ' + currentUser.name.validate()}",
      leading: Icon(Icons.block, color: Colors.red[800]),
      titleTextStyle: primaryTextStyle(color: Colors.red[800]),
      onTap: () {
        if (isBlocked) {
          unblockDialog(context, receiver: currentUser);
        } else {
          showConfirmDialogCustom(
            context,
            dialogAnimation: DialogAnimation.SCALE,
            title: "${"block".translate}" + " ${currentUser.name.validate()}? ",
            subTitle: "blocked_contact_will_no_longer_be_able_to_call_you_or_send_you_message".translate,
            onAccept: (v) {
              blockMessage();
            },
            primaryColor: primaryColor,
            positiveText: "block".translate,
            negativeText: "cancel".translate,
          );
        }
      },
    );
  }

  void reportBy() async {
    List<DocumentReference> temp = [];
    temp = await userService.userByEmail(currentUser.email).then((value) => value.reportedBy!);
    if (!temp.contains(userService.ref!.doc(getStringAsync(userId)))) {
      temp.add(userService.getUserReference(uid: getStringAsync(userId)));
    }

    if (temp.length >= appSettingStore.mReportCount) {
      userService.reportUser({"isActive": false}, currentUser.uid.validate()).then((value) {
        finish(context);
        finish(context);
        finish(context);
        toast("${"UserAccountIsDeactivatedByAdminToRestorePleaseContactAdmin".translate}");
        toast(value.toString());
      }).catchError((e) {
        //
      });
    } else {
      userService.reportUser({"reportedBy": temp}, currentUser.uid.validate()).then((value) {
        finish(context);
        finish(context);
        finish(context);
        toast(value.toString());
      }).catchError((e) {
        //
      });
    }
  }

  Widget buildReport() {
    return SettingItemWidget(
      title: "report_contact".translate,
      decoration: BoxDecoration(color: context.cardColor),
      leading: Icon(Icons.thumb_down, color: Colors.red[800]),
      titleTextStyle: primaryTextStyle(color: Colors.red[800]),
      onTap: () {
        showConfirmDialogCustom(
          context,
          dialogAnimation: DialogAnimation.SCALE,
          title: "${"report".translate} ${currentUser.name.validate()} ?",
          positiveText: "report".translate,
          negativeText: "cancel".translate,
          primaryColor: primaryColor,
          onAccept: (v) {
            reportBy();
          },
        );
      },
    );
  }
}
