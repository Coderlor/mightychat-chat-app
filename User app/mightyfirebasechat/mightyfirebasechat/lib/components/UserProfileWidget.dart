import 'package:chat/utils/Appwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../screens/PickupLayout.dart';
import '../../screens/SaveProfileScreen.dart';
import '../screens/QRScannerScreen.dart';

class UserProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      child: Observer(
        builder: (_) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  SaveProfileScreen(mIsShowBack: true, mIsFromLogin: false).launch(context);
                },
                child: Row(
                  children: [
                    loginStore.mPhotoUrl.validate().isNotEmpty
                        ? Hero(
                            tag: "profile_image",
                            child: cachedImage(
                              loginStore.mPhotoUrl.validate(),
                              height: 50,
                              width: 50,
                              radius: 25,
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(25),
                          )
                        : Hero(
                            tag: "profile_image",
                            child: CircleAvatar(
                              radius: 32.0,
                              child: Text(
                                loginStore.mDisplayName.validate()[0],
                                style: primaryTextStyle(size: 24, color: Colors.white),
                              ),
                            ),
                          ),
                    10.width,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loginStore.mDisplayName.validate().capitalizeEachWord(), style: boldTextStyle(size: 18)),
                        4.height,
                        Text(loginStore.mStatus.validate().capitalizeFirstLetter(), style: secondaryTextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ).expand(),
                  ],
                ).paddingAll(12),
              ).expand(),
              IconButton(
                icon: Icon(Icons.qr_code_scanner),
                onPressed: () {
                  QRScannerScreen().launch(context);
                },
              )
            ],
          );
        },
      ),
    );
  }
}
