import 'package:chat/utils/Appwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/FullScreenImageWidget.dart';
import '../../components/Permissions.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../screens/ChatScreen.dart';
import '../../screens/UserProfileScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/CallFunctions.dart';

class UserProfileImageDialog extends StatefulWidget {
  final UserModel? data;

  UserProfileImageDialog({this.data});

  @override
  State<UserProfileImageDialog> createState() => _UserProfileImageDialogState();
}

class _UserProfileImageDialogState extends State<UserProfileImageDialog> {
  bool isBlocked = false;

  Widget noProfileImage() {
    return Container(
      height: context.height() * 0.4,
      width: context.width(),
      // padding: EdgeInsets.all(10),
      color: primaryColor,
      child: noProfileImageFound(height: 50, width: 50, isNoRadius: true),
    ).cornerRadiusWithClipRRect(4);
  }

  @override
  Widget build(BuildContext context) {
    isBlocked = widget.data!.blockedTo!.contains(userService.getUserReference(uid: widget.data!.uid!));
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          widget.data!.photoUrl == null || widget.data!.photoUrl!.isEmpty
              ? noProfileImage()
              : InkWell(
                  onTap: () {
                    finish(context);
                    FullScreenImageWidget(photoUrl: widget.data!.photoUrl, name: widget.data!.name).launch(context);
                  },
                  child: widget.data!.photoUrl.isEmptyOrNull
                      ? Hero(
                          tag: widget.data!.photoUrl.validate(),
                          child: noProfileImage(),
                        )
                      : Hero(
                          tag: widget.data!.photoUrl.validate(),
                          child: cachedImage(widget.data!.photoUrl.validate(), fit: BoxFit.cover, height: 350, width: context.width()),
                        ),
                ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(color: Colors.black26, backgroundBlendMode: BlendMode.luminosity),
            width: double.infinity,
            child: Text(widget.data!.name!, style: boldTextStyle(color: Colors.white, size: 20)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 45,
              color: context.scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      icon: Icon(Icons.message_rounded, size: 20),
                      onPressed: () {
                        finish(context);
                        ChatScreen(widget.data).launch(context);
                      }),
                  IconButton(
                      icon: Icon(FontAwesome.phone, size: 20),
                      onPressed: () async {
                        if (isBlocked) {
                          unblockDialog(context, receiver: widget.data!);
                          return;
                        }
                        if (await Permissions.cameraAndMicrophonePermissionsGranted()) CallFunctions.voiceDial(context: context, from: sender, to: widget.data!);
                      }),
                  IconButton(
                      icon: Icon(FontAwesome.video_camera, size: 19),
                      onPressed: () async {
                        if (isBlocked) {
                          unblockDialog(context, receiver: widget.data!);
                          return;
                        }
                        if (await Permissions.cameraAndMicrophonePermissionsGranted()) CallFunctions.dial(context: context, from: sender, to: widget.data!);
                      }),
                  IconButton(
                    icon: Icon(Icons.info, size: 20),
                    onPressed: () {
                      finish(context);
                      UserProfileScreen(uid: widget.data!.uid.validate()).launch(context, pageRouteAnimation: PageRouteAnimation.Scale);
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
