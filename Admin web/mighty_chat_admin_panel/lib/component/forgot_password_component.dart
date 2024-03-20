import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../main.dart';
import '../utils/colors.dart';
import '../utils/widget.dart';
import 'package:nb_utils/nb_utils.dart';

class ForgotPasswordComponent extends StatefulWidget {
  @override
  _ForgotPasswordComponentState createState() => _ForgotPasswordComponentState();
}

class _ForgotPasswordComponentState extends State<ForgotPasswordComponent> {
  final formKey = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController();

  void submit() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setIsLoading(true);
      authService.forgotPassword(email: emailCont.text).then((value) {
        toasty(
          context,
          "Email has been sent to your mail ",
          borderRadius: radius(),
          bgColor: appButtonColor,
          textColor: primaryColor,
          gravity: ToastGravity.TOP,
        );
        finish(context);
      }).catchError((e) {
        toast(e.toString());
        log("Forgot Password Error : ${e.toString()}");
      }).whenComplete(() => appStore.setIsLoading(false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: context.width() * 0.30,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Forgot Password?', style: boldTextStyle()),
              Text('A reset password link will be sent to the above entered email address.', style: primaryTextStyle()),
              16.height,
              Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: AppTextField(
                  textFieldType: TextFieldType.EMAIL,
                  autoFocus: true,
                  controller: emailCont,
                  decoration: inputDecoration(labelText: 'Email', icon: Icon(Icons.email)),
                  onFieldSubmitted: (s) {
                    submit();
                  },
                ),
              ),
              24.height,
              AppButton(
                width: context.width(),
                text: 'Send',
                onTap: () {
                  submit();
                },
                shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
              ),
            ],
          ),
        ),
        Observer(builder: (context) => Loader().withSize(width: 50, height: 50).visible(appStore.isLoading))
      ],
    );
  }
}
