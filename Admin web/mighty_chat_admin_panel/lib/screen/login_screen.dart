import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../component/forgot_password_component.dart';
import '../main.dart';
import '../screen/home_screen.dart';
import '../utils/colors.dart';
import '../utils/common.dart';
import '../utils/config.dart';
import '../utils/constant.dart';
import '../utils/images.dart';
import '../utils/widget.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController(text: testEmail);
  TextEditingController passCont = TextEditingController(text: testPassword);

  FocusNode userNameFocus = FocusNode();
  FocusNode passFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    fireStore.collection(collections.admin).get().then((value) {
      log(value.docs.length);
      if (value.docs.length == 0) {
        addAdmin();
      }
    });
  }

  void submit() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      Map<String, dynamic> data = {
        userKeys.email: emailCont.text,
        userKeys.password: passCont.text,
      };

      appStore.setIsLoading(true);
      authService.signInWithEmailPassword(email: data[userKeys.email], password: data[userKeys.password]).then((value) {
        toastWidget(context, "Welcome Back ${appStore.firstName}");
        push(HomeScreen(), pageRouteAnimation: PageRouteAnimation.Fade, isNewTask: true);
      }).catchError((e) {
        toast(e.toString());
      }).whenComplete(() => appStore.setIsLoading(false));
    }
  }

  void addAdmin() async {
    Map<String, dynamic> data = {
      userKeys.name: NAME,
      userKeys.email: EMAIL,
      userKeys.photoUrl: "",
      userKeys.isEmailLogin: true,
      userKeys.phoneNumber: CONTACT_NUMBER,
      userKeys.password: PASSWORD,
      userKeys.isTester: false,
      userKeys.userRole: "admin",
      userKeys.reportUserCount: 0,
      userKeys.createdAt: Timestamp.now(),
      userKeys.updatedAt: Timestamp.now(),
      userKeys.caseSearch: setSearchParam('Admin'),
    };
    log('Admin =======${data.toString()}');
    authService.signUpWithEmailPassword(userData: data).then((value) {
      finish(context);
    }).catchError((e) {
      toast(e.toString(), print: true);
    }).whenComplete(() => appStore.setIsLoading(false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      body: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            width: context.width() * 0.3,
            decoration: boxDecorationDefault(color: context.cardColor),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(appImages.appIcon, height: 50, fit: BoxFit.cover).center(),
                    16.width,
                    Text(appName, style: boldTextStyle(size: 22)),
                  ],
                ),
                16.height,
                Text("Welcome! Let's get started", style: secondaryTextStyle()),
                32.height,
                AppTextField(
                    textFieldType: TextFieldType.NAME,
                    keyboardType: TextInputType.name,
                    controller: emailCont,
                    autoFocus: true,
                    nextFocus: passFocus,
                    decoration: inputDecoration(labelText: 'Email', icon: Icon(Icons.person, color: context.iconColor))),
                16.height,
                AppTextField(
                  controller: passCont,
                  textFieldType: TextFieldType.PASSWORD,
                  focus: passFocus,
                  decoration: inputDecoration(labelText: 'Password', icon: Icon(Icons.lock, color: context.iconColor)),
                  onFieldSubmitted: (p0) {
                    submit();
                  },
                ),
                16.height,
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: Text('Forgot Password?', style: boldTextStyle(color: primaryColor, size: 12)),
                    onPressed: () {
                      showInDialog(
                        context,
                        builder: (_) => ForgotPasswordComponent(),
                        dialogAnimation: DialogAnimation.SLIDE_BOTTOM_TOP,
                      );
                    },
                  ),
                ),
                24.height,
                AppButton(
                  width: context.width(),
                  text: 'Sign In',
                  shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
                  onTap: () {
                    submit();
                  },
                ),
                8.height,
              ],
            ),
          ).center()),
    );
  }
}
