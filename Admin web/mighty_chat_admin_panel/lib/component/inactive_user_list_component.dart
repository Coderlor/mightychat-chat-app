import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../model/user_model.dart';
import '../utils/cached_network_image.dart';
import '../utils/colors.dart';
import '../utils/common.dart';

class InactiveUserListComponent extends StatelessWidget {
  final UserModel currentUser;

  InactiveUserListComponent({required this.currentUser});

  @override
  Widget build(BuildContext context) {
    void activeUser() {
      showConfirmDialogCustom(
        context,
        title:
            "Are you sure you want to Grant permission to ${currentUser.name}?",
        dialogAnimation: DialogAnimation.SCALE,
        dialogType: DialogType.CONFIRMATION,
        primaryColor: context.primaryColor,
        onAccept: (c) {
          if (appStore.isTester) {
            toast("Test user cannot perform this action");
            return;
          }
          userService.setActiveUser(
              uid: currentUser.uid.validate(), isActive: true);
        },
      );
    }

    void inActiveUser() {
      showConfirmDialogCustom(
        context,
        title:
            "Are you sure you want to revoke permission from ${currentUser.name} ?",
        dialogAnimation: DialogAnimation.SCALE,
        dialogType: DialogType.CONFIRMATION,
        primaryColor: context.primaryColor,
        onAccept: (c) {
          if (appStore.isTester) {
            toast("Test user cannot perform this action");
            return;
          }
          userService.setActiveUser(
              uid: currentUser.uid.validate(), isActive: false);
        },
      );
    }

    Widget buildImageIconWidget() {
      if (currentUser.photoUrl!.validate().isNotEmpty) {
        return CachedImageWidget(
                url: currentUser.photoUrl.validate(),
                height: 40,
                width: 40,
                fit: BoxFit.cover)
            .cornerRadiusWithClipRRect(100);
      }
      return Container(
        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
        height: 40,
        width: 40,
        child: Text(currentUser.name![0].validate().toUpperCase(),
                style: boldTextStyle(color: Colors.white, size: 20))
            .center(),
      );
    }

    Widget builtActivateButton() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Last Update ' + timeAgo(currentUser.updatedAt!),
              style: secondaryTextStyle(size: 12), textAlign: TextAlign.end),
          Transform.scale(
            scale: 0.7,
            child: CupertinoSwitch(
              value: currentUser.active.validate(value: true),
              onChanged: (value) {
                if (!appStore.isTester) {
                  if (value) {
                    activeUser();
                  } else {
                    inActiveUser();
                  }
                } else {
                  print("is tester false");
                  toastWidget(
                      context, 'Tester not allowed to Perform this action');
                }
              },
            ),
          ),
        ],
      ).expand();
    }

    return SettingItemWidget(
      leading: buildImageIconWidget(),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      title: currentUser.name.validate().capitalizeFirstLetter(),
      subTitle: currentUser.email.validate(),
      trailing: builtActivateButton(),
    );
  }
}
