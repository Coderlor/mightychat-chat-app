import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../main.dart';

class ForgotPasswordScreen extends StatefulWidget {
  static String tag = '/ForgotPasswordScreen';

  @override
  ForgotPasswordScreenState createState() => ForgotPasswordScreenState();
}

class ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController forgotEmailController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor),
      child: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('forgot_password'.translate, style: boldTextStyle(size: 20), textAlign: TextAlign.start),
                Icon(Icons.close).onTap(() {
                  finish(context);
                })
              ],
            ),
            22.height,
            Text('enter_your_email_address'.translate + '\n' + 'reset_password_link'.translate, style: primaryTextStyle(size: 14)),
            16.height,
            AppTextField(
              controller: forgotEmailController,
              textFieldType: TextFieldType.EMAIL,
              keyboardType: TextInputType.emailAddress,
              cursorColor: appStore.isDarkMode ? Colors.white : scaffoldColorDark,
              decoration: inputDecoration(context, labelText: 'email'.translate),
              errorThisFieldRequired: errorThisFieldRequired,
            ),
            16.height,
            Stack(
              children: [
                AppButton(
                  child: Text('reset_password'.translate.capitalizeEachWord(), style: boldTextStyle(color: Colors.white)),
                  color: primaryColor,
                  width: context.width(),
                  onTap: () {
                    hideKeyboard(context);
                    appStore.setLoading(true);
                    if (_formKey.currentState!.validate()) {
                      authService.forgotPassword(email: forgotEmailController.text.trim()).then((value) {
                        toast('resetPasswordLinkHasSentYourMail'.translate);
                        appStore.setLoading(false);

                        finish(context);
                      }).catchError((error) {
                        toast(error.toString());
                        appStore.setLoading(false);
                      });
                    }
                    //      toast("Loader false");
                    appStore.setLoading(false);
                  },
                ),
                Observer(
                  builder: (_) => Positioned.fill(child: Loader().visible(appStore.isLoading).center()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
