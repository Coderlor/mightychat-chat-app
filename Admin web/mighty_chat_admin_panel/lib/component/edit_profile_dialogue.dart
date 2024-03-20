import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mighty_chat_admin_panel/utils/colors.dart';
import '../main.dart';
import '../model/user_model.dart';
import '../utils/constant.dart';
import '../utils/cached_network_image.dart';
import '../utils/images.dart';
import '../utils/widget.dart';
import 'package:nb_utils/nb_utils.dart';

class EditProfileDialogue extends StatefulWidget {
  @override
  _EditProfileDialogueState createState() => _EditProfileDialogueState();
}

class _EditProfileDialogueState extends State<EditProfileDialogue> {
  final formKey = GlobalKey<FormState>();

  TextEditingController emailCont = TextEditingController();
  TextEditingController fNameCont = TextEditingController();
  TextEditingController phoneCountCont = TextEditingController();

  FocusNode emailNode = FocusNode();
  FocusNode fNameNode = FocusNode();
  FocusNode reportUserCountNode = FocusNode();

  String imageURL = "";

  FilePickerResult? image;

  UserModel? user;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setIsLoading(true);
    await userService.getUser(email: appStore.email).then((value) {
      emailCont.text = value.email.validate();
      fNameCont.text = value.name.validate();
      imageURL = value.photoUrl.validate();
      phoneCountCont.text = value.phoneNumber.validate();
      user = value;
      setState(() {});
    }).catchError((e) {
      log(e.toString());
    }).whenComplete(() => appStore.setIsLoading(false));
  }

  void submit() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      appStore.setIsLoading(true);

      Map<String, dynamic> request = {
        userKeys.uid: user!.uid,
        userKeys.name: fNameCont.text,
        userKeys.email: user!.email,
        userKeys.isEmailLogin: user!.isEmailLogin,
        userKeys.createdAt: user!.createdAt,
        userKeys.phoneNumber: phoneCountCont.text,
        userKeys.updatedAt: Timestamp.now(),
      };

      if (image != null) {
        String imageUrl = await userService.getUploadedImageURLFromWeb(image: image!.files.first.bytes!, path: "profile", fileName: user!.uid!, extension: image!.files.first.extension!);
        request.putIfAbsent(userKeys.photoUrl, () => imageUrl);
        user!.photoUrl = imageUrl;
      } else {
        request.putIfAbsent(userKeys.photoUrl, () => user!.photoUrl);
      }
      log(request);
      userService.updateDocument(request, user!.uid).then((value) {
        toast("Profile Updated Successfully");
        appStore.setFirstName(fNameCont.text.validate(), isInitializing: true);
        appStore.setPhotoUrl(user!.photoUrl.validate(), isInitializing: true);
        finish(context);
      }).catchError((e) {
        toast(e.toString());
      }).whenComplete(() => appStore.setIsLoading(false));
    }
  }

  Future getImage() async {
    image = await FilePickerWeb.platform.pickFiles();
    setState(() {});
  }

  Widget buildProfileImage() {
    double height = 120;
    double width = 120;
    if (user != null) {
      if (image != null) {
        return Image.memory(image!.files.first.bytes!, fit: BoxFit.cover, height: height, width: width);
      } else if (user!.photoUrl != null && image == null) {
        return CachedImageWidget(url: user!.photoUrl.validate(), fit: BoxFit.cover, height: height, width: width);
      }
    }
    return Image.asset(appImages.placeholderImage, fit: BoxFit.cover, height: height, width: width);
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Edit Profile', style: boldTextStyle()),
                  CloseButton(),
                ],
              ),
              32.height,
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(decoration: BoxDecoration(shape: BoxShape.circle), child: buildProfileImage()).cornerRadiusWithClipRRect(80),
                  Container(
                    decoration: boxDecorationDefault(shape: BoxShape.circle, color: context.cardColor),
                    child: IconButton(
                      icon: Icon(Icons.camera_alt, size: 16, color: context.iconColor),
                      onPressed: () {
                        getImage();
                      },
                    ),
                  )
                ],
              ).center(),
              48.height,
              AppTextField(
                textFieldType: TextFieldType.EMAIL,
                controller: emailCont,
                nextFocus: fNameNode,
                enabled: false,
                decoration: inputDecoration(labelText: 'Email', icon: Icon(Icons.mail, color: context.iconColor)),
              ),
              16.height,
              AppTextField(
                textFieldType: TextFieldType.NAME,
                controller: fNameCont,
                focus: fNameNode,
                nextFocus: reportUserCountNode,
                decoration: inputDecoration(labelText: 'First Name', icon: Icon(Icons.person, color: context.iconColor)),
              ),
              16.height,
              AppTextField(
                textFieldType: TextFieldType.PHONE,
                controller: phoneCountCont,
                focus: reportUserCountNode,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: inputDecoration(labelText: 'Contact Number', icon: Icon(LineIcons.mobile_phone, color: context.iconColor)),
              ),
              32.height,
              AppButton(
                width: context.width(),
                text: 'Update Profile',
                onTap: () {
                  showConfirmDialogCustom(
                    context,
                    primaryColor: primaryColor,
                    title: "Are you sure you want to update profile details?",
                    dialogType: DialogType.UPDATE,
                    onAccept: (c) {
                      if (appStore.isTester) {
                        toast("Test user cannot perform this action");
                        return;
                      }
                      submit();
                    },
                  );
                },
                shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
