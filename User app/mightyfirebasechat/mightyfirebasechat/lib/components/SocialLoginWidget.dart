import 'package:chat/utils/AppCommon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../components/OTPDialog.dart';
import '../../main.dart';
import '../../utils/AppConstants.dart';

class SocialLoginWidget extends StatelessWidget {
  final VoidCallback? voidCallback;

  SocialLoginWidget({this.voidCallback});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          height: 45,
          width: isIOS ? (context.width() - 48) / 3 : (context.width() - 40) / 2,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: radius(8), color: context.scaffoldBackgroundColor, border: Border.all(color: context.dividerColor)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GoogleLogoWidget(size: 16),
              8.width,
              Text('google'.translate, style: primaryTextStyle()),
            ],
          ),
        ).onTap(
          () async {
            hideKeyboard(context);

            appStore.setLoading(true);
            // ignore: unnecessary_null_comparison
            if (getStringAsync(playerId).isEmpty || getStringAsync(playerId) == null) {
              // OneSignal.Debug.getDeviceState().then((deviceState) {
              //   print("OneSignal: device state: ${deviceState.jsonRepresentation()}");
              // });

              //   await OneSignal.getDeviceState().then((value) async {
              setValue(playerId, OneSignal.User.pushSubscription.id.validate());
              await authService.signInWithGoogle().then((user) {
                voidCallback?.call();
              }).catchError((e) {
                toast(e.toString());
              });
              //    });
            } else {
              await authService.signInWithGoogle().then((user) {
                voidCallback?.call();
              }).catchError((e) {
                toast(e.toString());
              });
            }

            appStore.setLoading(false);
          },
        ),
        Container(
          width: isIOS ? (context.width() - 48) / 3 : (context.width() - 40) / 2,
          padding: EdgeInsets.all(12),
          height: 45,
          decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: radius(8), color: context.scaffoldBackgroundColor, border: Border.all(color: context.dividerColor)),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Feather.phone, color: context.iconColor, size: 20),
              8.width,
              Text('mobile'.translate, style: primaryTextStyle()),
            ],
          ),
        ).onTap(() async {
          hideKeyboard(context);
          await showInDialog(context, dialogAnimation: DialogAnimation.SCALE, builder: (context) => OTPDialog(), barrierDismissible: false).catchError((e) {
            toast(e.toString());
          });

          appStore.setLoading(false);
          // voidCallback?.call();
        }),
        if (isIOS)
          Container(
            width: isIOS ? (context.width() - 48) / 3 : (context.width() - 40) / 2,
            padding: EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: radius(8), color: context.scaffoldBackgroundColor, border: Border.all(color: context.dividerColor)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(AntDesign.apple1, color: appStore.isDarkMode ? white : black, size: 20),
                8.width,
                Text('Apple', style: primaryTextStyle()),
              ],
            ),
          ).onTap(() async {
            hideKeyboard(context);
            appStore.setLoading(true);

            await authService.appleLogIn().then((value) {
              voidCallback?.call();
            }).catchError((e) {
              toast(e.toString());
            });
            appStore.setLoading(false);
          }),
      ],
    );
  }
}
