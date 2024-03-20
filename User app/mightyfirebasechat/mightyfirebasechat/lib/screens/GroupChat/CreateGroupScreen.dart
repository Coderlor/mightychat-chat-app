import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';

import '../../main.dart';
import '../../models/ContactModel.dart';
import '../../models/UserModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../../utils/GroupDbkeys.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  CreateGroupScreenState createState() => CreateGroupScreenState();
}

class CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameCont = new TextEditingController();
  final TextEditingController groupDescCont = new TextEditingController();

  XFile? image;
  String imageUrl = '';

  List membersList = [];
  List<UserModel> userModelList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    getMemberList();
  }

  getMemberList() {
    appStore.setLoading(false);
    userModelList.clear();
    List<String> data = getStringListAsync(selectedMember)!;
    data.forEach((element) async {
      UserModel userm = await userService.getUserById(val: element);
      userModelList.add(userm);
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future getImage() async {
    // ignore: deprecated_member_use
    image = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    updateGroupProfileImg(profileImage: File(image!.path));
    setState(() {});
  }

  Future<void> updateGroupProfileImg({File? profileImage}) async {
    appStore.isLoading = true;
    if (profileImage != null) {
      String fileName = basename(profileImage.path);
      Reference storageRef = FirebaseStorage.instance.ref().child("$GROUP_PROFILE_IMAGE/$fileName");
      UploadTask uploadTask = storageRef.putFile(profileImage);
      await uploadTask.then((e) async {
        await e.ref.getDownloadURL().then((value) {
          imageUrl = value;
          setState(() {});
          log(value);
          appStore.isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardColor,
      appBar: appBarWidget(
        "",
        color: primaryColor,
        textColor: Colors.white,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('lblNewgroup'.translate, style: boldTextStyle(color: Colors.white, size: 18, letterSpacing: 0.5)),
            4.height,
            Text('lblAddsubject'.translate, style: secondaryTextStyle(color: Colors.white, letterSpacing: 0.5)),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          image != null
                              ? Image.file(
                                  File(image!.path),
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ).cornerRadiusWithClipRRect(25)
                              : Container(
                                  height: 50,
                                  width: 50,
                                  decoration: boxDecorationDefault(shape: BoxShape.circle, color: Colors.grey.shade400),
                                  child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ).onTap(() {
                                  getImage();
                                }),
                          8.width,
                          Container(
                            padding: EdgeInsets.only(top: 8),
                            width: context.width() / 1.5,
                            child: AppTextField(
                              controller: groupNameCont,
                              decoration: InputDecoration(labelStyle: secondaryTextStyle(), labelText: 'lblTypegroupsubjecthere'.translate),
                              textFieldType: TextFieldType.NAME,
                              maxLength: 25,
                            ),
                          ),
                        ],
                      ),
                      4.height,
                      Text(
                        'lblProvideaGroupsubjectAndOptionalGroupicon'.translate,
                        style: secondaryTextStyle(size: 14),
                      ),
                    ],
                  ),
                ),
                16.height,
                Text(
                  'lblMembers'.translate + ': ${userModelList.length.toString()}',
                  style: secondaryTextStyle(size: 14),
                ).paddingSymmetric(horizontal: 16),
                8.height,
                SingleChildScrollView(
                  child: Wrap(
                    runSpacing: 16,
                    spacing: 16,
                    children: List.generate(userModelList.length, (index) {
                      UserModel data = userModelList[index];
                      return SizedBox(
                          width: context.width() / 4 - 32,
                          child: Column(
                            children: [
                              data.photoUrl!.isEmpty
                                  ? Container(
                                      height: 55,
                                      width: 55,
                                      padding: EdgeInsets.all(10),
                                      color: primaryColor,
                                      child: Text(data.name.validate()[0].toUpperCase(), style: secondaryTextStyle(color: Colors.white)).center().fit(),
                                    ).cornerRadiusWithClipRRect(50)
                                  : cachedImage(data.photoUrl.validate(), width: 55, height: 55, fit: BoxFit.cover).cornerRadiusWithClipRRect(30).center(),
                              4.height,
                              Text(data.name.validate(), overflow: TextOverflow.ellipsis, style: secondaryTextStyle(size: 12))
                            ],
                          ));
                    }),
                  ).paddingSymmetric(horizontal: 16, vertical: 8),
                ),
                100.height,
              ],
            ),
          ),
          Loader().center().visible(appStore.isLoading),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.check, color: Colors.white),
          backgroundColor: primaryColor,
          onPressed: () async {
            if (groupNameCont.text.isNotEmpty) {
              List<String> listusers = [getStringAsync(userId)];
              List<String> listmembers = [getStringAsync(userId)];
              userModelList.forEach((element) {
                listusers.add(element.uid.toString());
                listmembers.add(element.uid.toString());
              });

              DateTime time = DateTime.now();
              DateTime time2 = DateTime.now().add(Duration(seconds: 1));
              String groupID = '${getStringAsync(userId).toString()}--${time.millisecondsSinceEpoch.toString()}';

              Map<String, dynamic> groupdata = {
                GroupDbkeys.groupCREATEDON: time,
                GroupDbkeys.groupCREATEDBY: getStringAsync(userId).toString(),
                GroupDbkeys.groupNAME: groupNameCont.text.isEmpty ? 'Unnamed Group' : groupNameCont.text.trim(),
                GroupDbkeys.groupIDfiltered: groupID.replaceAll(RegExp('-'), '').substring(1, groupID.replaceAll(RegExp('-'), '').toString().length),
                GroupDbkeys.groupISTYPINGUSERID: '',
                // Dbkeys.groupADMINLIST: [widget.currentUserNo],
                GroupDbkeys.groupID: groupID,
                GroupDbkeys.groupPHOTOURL: imageUrl != "" ? imageUrl : null,
                GroupDbkeys.groupMEMBERSLIST: listmembers,
                GroupDbkeys.groupLATESTMESSAGETIME: time.millisecondsSinceEpoch,
                GroupDbkeys.groupTYPE: GroupDbkeys.groupTYPEallusersmessageallowed,
                GroupDbkeys.groupSEARCHSTRING: setSearchParam(groupNameCont.text),
              };

              await fireStore.collection(GROUPS_COLLECTION).doc(getStringAsync(userId).toString() + '--' + time.millisecondsSinceEpoch.toString()).set(groupdata).then((value) async {
                await fireStore
                    .collection(GROUPS_COLLECTION)
                    .doc(getStringAsync(userId).toString() + '--' + time.millisecondsSinceEpoch.toString())
                    .collection(GROUP_GROUPCHATS)
                    .doc(time.millisecondsSinceEpoch.toString() + '--' + getStringAsync(userId).toString())
                    .set({
                  GroupDbkeys.photoUrl: imageUrl,
                  GroupDbkeys.groupmsgCONTENT: '',
                  GroupDbkeys.groupmsgLISToptional: listusers,
                  GroupDbkeys.groupmsgTIME: time.millisecondsSinceEpoch,
                  GroupDbkeys.groupmsgSENDBY: getStringAsync(userId).toString(),
                  GroupDbkeys.groupmsgISDELETED: false,
                  GroupDbkeys.groupmsgTYPE: GroupDbkeys.groupmsgTYPEnotificationCreatedGroup,
                }).then((value) async {
                  await fireStore
                      .collection(GROUPS_COLLECTION)
                      .doc(getStringAsync(userId).toString() + '--' + time.millisecondsSinceEpoch.toString())
                      .collection(GROUP_GROUPCHATS)
                      .doc(time2.millisecondsSinceEpoch.toString() + '--' + getStringAsync(userId).toString())
                      .set({
                        GroupDbkeys.photoUrl: imageUrl,
                        GroupDbkeys.groupmsgCONTENT: '',
                        GroupDbkeys.groupmsgLISToptional: listmembers,
                        GroupDbkeys.groupmsgTIME: time2.millisecondsSinceEpoch,
                        GroupDbkeys.groupmsgSENDBY: getStringAsync(userId).toString(),
                        GroupDbkeys.groupmsgISDELETED: false,
                        GroupDbkeys.groupmsgTYPE: GroupDbkeys.groupmsgTYPEnotificationAddedUser,
                      })
                      .then((val) async {})
                      .catchError((err) {
                        toast('Error Creating group. $err');
                        print('Error Creating group: $err');
                      });

                  ContactModel data = ContactModel();
                  data.uid = groupID;
                  data.addedOn = Timestamp.now();
                  data.lastMessageTime = DateTime.now().millisecondsSinceEpoch;
                  data.groupRefUrl = groupID;
                  userModelList.map((e) {
                    chatMessageService.getContactsDocument(of: e.uid, forContact: groupID).set(data.toJson()).then((value) {}).catchError((e) {
                      log(e);
                    });
                  }).toList();
                  chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: groupID).set(data.toJson()).then((value) {}).catchError((e) {
                    log(e);
                  });
                });
              }).whenComplete(() {
                finish(context);
                finish(context);
                finish(context);
              });
            } else {
              toast('lblPleaseaddsubject'.translate);
            }
          }),
    );
  }
}
