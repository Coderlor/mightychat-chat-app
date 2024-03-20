import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:otp_text_field/otp_field.dart' as otp;
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

import '../../screens/DashboardScreen.dart';
import '../../screens/SignUpScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../main.dart';

class OTPDialog extends StatefulWidget {
  final String? verificationId;
  final String? phoneNumber;
  final bool? isCodeSent;
  final PhoneAuthCredential? credential;

  OTPDialog({this.verificationId, this.isCodeSent = false, this.phoneNumber, this.credential});

  @override
  OTPDialogState createState() => OTPDialogState();
}

class OTPDialogState extends State<OTPDialog> {
  TextEditingController numberController = TextEditingController();
  String? countryCode = '';
  String otpCode = '';

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> submit() async {
    appStore.setLoading(true);
    AuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId!, smsCode: otpCode.validate());

    await FirebaseAuth.instance.signInWithCredential(credential).then((result) async {
      User currentUser = result.user!;

      await userService.userByMobileNumber(currentUser.phoneNumber).then((user) async {
        await authService.updateUserData(user);
        await authService.setUserDetailPreference(user);
        setValue(isSocialLogin, true);
        DashboardScreen().launch(context, isNewTask: true);
      }).catchError((e) {
        log(e);
        if (e.toString() == EXCEPTION_NO_USER_FOUND) {
          SignUpScreen(user: currentUser, isOTP: true).launch(context).then((value) {
            appStore.setLoading(false);
            finish(context);
          });
        } else {
          throw e;
        }
      });
    }).catchError((e) {
      log(e);
      appStore.setLoading(false);
      toast(e.toString());
      appStore.setLoading(false);
    });
  }

  Future<void> sendOTP() async {
    appStore.setLoading(true);
    if (numberController.text.trim().isEmpty) {
      appStore.setLoading(false);
      return toast(errorThisFieldRequired);
    }

    String number = '+$countryCode${numberController.text.trim()}';
    if (!number.startsWith('+')) {
      number = '+$countryCode${numberController.text.trim()}';
    }

    await authService.loginWithOTP(context, number).then((value) {
      //
    }).catchError((e) {
      appStore.setLoading(false);
      toast("log" + e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => !widget.isCodeSent.validate()
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("enter_your_phone".translate, style: boldTextStyle()),
                    Icon(Icons.close).onTap(() {
                      finish(context);
                    }),
                  ],
                ),
                22.height,
                AppTextField(
                  controller: numberController,
                  textFieldType: TextFieldType.PHONE,
                  decoration: inputDecoration(
                    context,
                    labelText: "mobile_number".translate,
                    prefix: SizedBox(
                      width: 65,
                      child: CountryCodePicker(
                        padding: EdgeInsets.zero,
                        initialSelection: defaultCountry,
                        showCountryOnly: false,
                        showFlag: false,
                        showFlagDialog: true,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        dialogTextStyle: primaryTextStyle(),
                        showDropDownButton: true,
                        dialogBackgroundColor: context.cardColor,
                        textStyle: primaryTextStyle(size: 20),
                        onInit: (c) {
                          countryCode = c!.dialCode;
                        },
                        onChanged: (c) {
                          countryCode = c.dialCode;
                        },
                      ).fit(),
                    ),
                  ),
                  autoFocus: true,
                  onFieldSubmitted: (s) {
                    sendOTP();
                  },
                ),
                16.height,
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AppButton(
                      onTap: () {
                        hideKeyboard(context);
                        sendOTP();
                      },
                      text: 'send_otp'.translate,
                      color: primaryColor,
                      textStyle: boldTextStyle(color: white),
                      width: context.width(),
                    ),
                    Positioned(
                      child: Loader(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)).visible(appStore.isLoading),
                    ),
                  ],
                )
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("enter_otp_received".translate, style: boldTextStyle()),
                16.height,
                otp.OTPTextField(
                  otpFieldStyle: OtpFieldStyle(
                    borderColor: appStore.isDarkMode ? Colors.white : Colors.black,
                    enabledBorderColor: appStore.isDarkMode ? Colors.white : Colors.black,
                    focusBorderColor: primaryColor,
                  ),
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 35,
                  style: primaryTextStyle(),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  onChanged: (s) {
                    otpCode = s;
                  },
                  onCompleted: (pin) {
                    otpCode = pin;
                    submit();
                  },
                ).fit(),
                16.height,
                Stack(
                  alignment: Alignment.center,
                  children: [
                    AppButton(
                      onTap: () {
                        submit();
                      },
                      text: "confirm".translate,
                      color: primaryColor,
                      textStyle: boldTextStyle(color: white),
                      width: context.width(),
                    ),
                    Positioned(child: Loader(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)).visible(appStore.isLoading))
                  ],
                )
              ],
            ),
    );
  }
}
