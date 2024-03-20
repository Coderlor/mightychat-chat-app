import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/constant.dart';
import '../utils/images.dart';
import '../utils/widget.dart';
import 'package:nb_utils/nb_utils.dart';

class ChangePasswordDialogue extends StatefulWidget {
  @override
  _ChangePasswordDialogueState createState() => _ChangePasswordDialogueState();
}

class _ChangePasswordDialogueState extends State<ChangePasswordDialogue> {
  final formKey = GlobalKey<FormState>();

  TextEditingController oldPasswordCont = TextEditingController();
  TextEditingController newPasswordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();

  FocusNode oldPassNode = FocusNode();
  FocusNode newPasswordNode = FocusNode();
  FocusNode confirmPasswordNode = FocusNode();

  void submit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (appStore.isTester) {
        toast("Test user cannot perform this action");
        return;
      }
      appStore.setIsLoading(true);
      authService.changePassword(newPasswordCont.text).then((value) {
        finish(context);
        toast('Your new password has been changed');
      })
        ..catchError((e) {
          log(e.toString());
        }).whenComplete(() => appStore.setIsLoading(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: context.width() * 0.4,
        padding: EdgeInsets.all(16),
        decoration: boxDecorationDefault(color: context.cardColor),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(alignment: Alignment.topRight, child: CloseButton()),
              Image.asset(appImages.appIcon, height: 100, fit: BoxFit.cover).center(),
              16.height,
              Text('Change Password', style: boldTextStyle()),
              16.height,
              AppTextField(
                controller: oldPasswordCont,
                focus: oldPassNode,
                textFieldType: TextFieldType.PASSWORD,
                validator: (s) {
                  if (s!.trim().isEmpty) return errorThisFieldRequired;
                  if (s.trim() != getStringAsync(sharePrefKey.password)) return "Old password is wrong";
                  return null;
                },
                nextFocus: newPasswordNode,
                decoration: inputDecoration(labelText: 'Old Password', icon: Icon(Icons.lock, color: context.iconColor)),
              ),
              16.height,
              AppTextField(
                controller: newPasswordCont,
                focus: newPasswordNode,
                textFieldType: TextFieldType.PASSWORD,
                nextFocus: confirmPasswordNode,
                decoration: inputDecoration(labelText: 'New Password', icon: Icon(Icons.lock, color: context.iconColor)),
              ),
              16.height,
              AppTextField(
                controller: confirmPasswordCont,
                textFieldType: TextFieldType.PASSWORD,
                focus: confirmPasswordNode,
                validator: (s) {
                  if (s!.trim().isEmpty) return errorThisFieldRequired;
                  if (s.trim() != newPasswordCont.text) return "Confirm password must be as new password";
                  return null;
                },
                onFieldSubmitted: (s) {
                  submit();
                },
                decoration: inputDecoration(labelText: 'Confirm Password', icon: Icon(Icons.lock, color: context.iconColor)),
              ),
              32.height,
              AppButton(
                width: context.width(),
                text: 'Submit',
                shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
                onTap: () {
                  submit();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
