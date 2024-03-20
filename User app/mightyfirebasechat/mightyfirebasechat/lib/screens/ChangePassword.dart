import 'package:chat/utils/AppColors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import '../utils/AppCommon.dart';
import '../utils/AppConstants.dart';

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  var formKey = GlobalKey<FormState>();

  var oldPassCont = TextEditingController();
  var newPassCont = TextEditingController();
  var confNewPassCont = TextEditingController();

  var newPassFocus = FocusNode();
  var confPassFocus = FocusNode();

  bool oldPasswordVisible = false;
  bool newPasswordVisible = false;
  bool confPasswordVisible = false;

  Future<void> submit() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      if (oldPassCont.text.toString() != getStringAsync(userPassword)) {
        toast('lbl_old_pwd_wrong'.translate);
      } else {
        appStore.setLoading(true);
        User? user = FirebaseAuth.instance.currentUser;
        await user!.updatePassword(newPassCont.text.trim()).then((value) async {
          Map<String, dynamic> data = {
            'password': newPassCont.text.trim(),
          };
          userService.updateUserInfo(data, getStringAsync(userId), profileImage: null).then((value) {
            setValue(userPassword, newPassCont.text);
            print("done");
          }).catchError((e) {
            log(e.toString());
            toast(e.toString());
          });
          finish(context);
          print('password_successfully_changed');
          toast('password_successfully_changed'.translate);
        }).catchError((e) {
          toast(e.toString());
          print("errro${e.toString()}");
        });
        // });
        appStore.setLoading(false);

      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('change_password'.translate, showBack: true, elevation: 5, color: primaryColor, systemUiOverlayStyle: SystemUiOverlayStyle.light, textColor: Colors.white),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    AppTextField(
                      controller: oldPassCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(context, labelText: 'old_password'.translate),
                      nextFocus: newPassFocus,
                      textInputAction: TextInputAction.go,
                      textStyle: primaryTextStyle(),
                      autoFillHints: [AutofillHints.password],
                      validator: (s) {
                        if (s!.isEmpty) return 'field_required'.translate;
                        return null;
                      },
                    ),
                    16.height,
                    AppTextField(
                      controller: newPassCont,
                      textFieldType: TextFieldType.PASSWORD,
                      decoration: inputDecoration(context, labelText: 'new_password'.translate),
                      focus: newPassFocus,
                      textInputAction: TextInputAction.go,
                      nextFocus: confPassFocus,
                      textStyle: primaryTextStyle(),
                      autoFillHints: [AutofillHints.newPassword],
                      validator: (s) {
                        if (s!.isEmpty) return 'field_required'.translate;
                        return null;
                      },
                    ),
                    16.height,
                    AppTextField(
                      controller: confNewPassCont,
                      textFieldType: TextFieldType.PASSWORD,
                      textInputAction: TextInputAction.go,
                      decoration: inputDecoration(context, labelText: 'confirm_password'.translate),
                      focus: confPassFocus,
                      validator: (String? value) {
                        if (value!.isEmpty) return 'field_required'.translate;

                        if (value.trim().isEmpty) return 'field_required'.translate;
                        if (value.trim().length < passwordLengthGlobal) return 'password_length_should_be_more_than_six'.translate;
                        if (value.trim() == oldPassCont.text.trim()) return 'old_password_should_not_be_same_as_new_password'.translate;
                        return newPassCont.text == value.trim() ? null : 'password_does_not_match'.translate;
                      },
                      onFieldSubmitted: (s) {
                        submit();
                      },
                      textStyle: primaryTextStyle(),
                      autoFillHints: [AutofillHints.newPassword],
                    ),
                    30.height,
                    AppButton(
                      onTap: () {
                        submit();
                      },
                      text: 'save'.translate,
                      width: context.width(),
                      color: primaryColor,
                      textStyle: boldTextStyle(color: white),
                    ),
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => Loader().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
