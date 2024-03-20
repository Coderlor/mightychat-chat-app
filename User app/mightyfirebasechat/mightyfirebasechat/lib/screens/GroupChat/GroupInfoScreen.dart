import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart' as path;

import '../../components/FullScreenImageWidget.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../screens/ChatScreen.dart';
import '../../screens/GroupChat/ChangeSubjectScreen.dart';
import '../../screens/GroupChat/NewGroupScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupId, groupName;
  final dynamic data;

  GroupInfoScreen({required this.groupId, required this.groupName, this.data});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  List membersList = [];
  List<UserModel> userModelList = [];
  bool isLoading = true;
  bool isProfileChange = false;
  bool isDeleteGroup = false;
  FirebaseAuth auth = FirebaseAuth.instance;

  File? imageFile;
  XFile? pickedFile;

  String createdBy = '';
  String? groupName;
  String? imageUrl;
  DateTime? createdDate = DateTime.now();

  bool isChangeAdmin = false;
  int counter = 0;
  List<dynamic> adminIds = [];

  @override
  void initState() {
    super.initState();
    getGroupDetails();
  }

  Future getGroupDetails() async {
    await groupChatMessageService.grpRef.doc(widget.groupId).get().then((chatMap) {
      createdBy = chatMap['createdBy'];
      createdDate = (chatMap['createdOn'] as Timestamp).toDate();
      //admin = chatMap['adminId'];
      membersList = chatMap['membersList'];
      adminIds = chatMap['adminIds'];
      checkAdmin();
      groupName = chatMap['name'];
      imageUrl = chatMap['photoUrl'];
      getMemberList();
      isLoading = false;
      setState(() {});
    });
  }

  getMemberList() {
    userModelList.clear();
    membersList.forEach((element) async {
      UserModel userm = await userService.getUserById(val: element);
      userModelList.add(userm);
      setState(() {});
    });
  }

  void checkAdmin() {
    if (adminIds.contains(getStringAsync(userId))) {
      setState(() {});
    } else {
      userService.singleUser(getStringAsync(userId)).first.then((value) => log("success")).catchError((e) {
        if (counter == 0) {
          isChangeAdmin = true;
          setState(() {});
          removeMembers(0, getStringAsync(userId));
        }
      });
    }
  }

  Future makeUserAdmin(String? userId, String? groupId) async {
    await groupChatMessageService.makeUserAdmin(userId: userId.toString(), groupId: groupId.toString());
    setState(() {
      getGroupDetails();
    });
  }

  Future removeUserAsAdmin(String? userId, String? groupId) async {
    await groupChatMessageService.removeUserAsAdmin(userId: userId.toString(), groupId: groupId.toString());
    setState(() {
      getGroupDetails();
    });
  }

  Future removeMembers(int index, String? uid) async {
    List newMembers = [];
    setState(() {
      isLoading = true;
      membersList.map((e) {
        if (e.toString().contains(uid.toString())) {
        } else {
          newMembers.add(e);
        }
      }).toList();
    });
    if (adminIds.contains(uid)) {
      adminIds.remove(uid);
    }

    await groupChatMessageService.grpRef
        .doc(widget.groupId)
        .update({"membersList": newMembers, "createdBy": createdBy, "adminIds": adminIds, "adminId": isChangeAdmin ? newMembers[0] : getStringAsync(userId)}).then((value) async {
      await userService.ref!.doc(widget.data['uid']).collection('group').doc(widget.groupId).delete();
      await groupChatMessageService.removeUserFromReadyByOnLeavingGroup(userId: uid.toString(), groupId: widget.groupId);
      counter = 1;
      setState(() {});
      getGroupDetails();
      setState(() {
        isLoading = false;
      });
    });
  }

  void showDialogBox(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    finish(context);
                    ChatScreen(userModelList[index]).launch(context);
                  },
                  title: Text("message".translate + " ${userModelList[index].name}", style: primaryTextStyle()),
                ),
                if (adminIds.contains(getStringAsync(userId)))
                  ListTile(
                    onTap: () {
                      finish(context);
                      removeMembers(index, userModelList[index].uid);
                    },
                    title: Text("lblRemove".translate + " ${userModelList[index].name}", style: primaryTextStyle()),
                  ),
                if (adminIds.contains(getStringAsync(userId)))
                  ListTile(
                    onTap: () {
                      finish(context);
                      adminIds.contains(userModelList[index].uid) ? removeUserAsAdmin(userModelList[index].uid, widget.groupId) : makeUserAdmin(userModelList[index].uid, widget.groupId);
                    },
                    title: Text(
                        adminIds.contains(userModelList[index].uid)
                            ? "lblRemove".translate + "  ${userModelList[index].name} " + 'as_admin'.translate
                            : "make".translate + "  ${userModelList[index].name}" + " " + "admin".translate,
                        style: primaryTextStyle()),
                  ),
              ],
            ),
          );
        });
  }

  Future onDeleteGroup() async {
    await showConfirmDialogCustom(context,
        dialogAnimation: DialogAnimation.SCALE,
        title: 'are_you_sure_you_want_to_delete'.translate,
        positiveText: 'lbl_yes'.translate,
        negativeText: 'lbl_no'.translate,
        primaryColor: primaryColor, onAccept: (v) async {
      await groupChatMessageService.deleteGroup(groupDocId: widget.groupId);
      finish(context);
      finish(context);
      finish(context);
    });
  }

  Future onLeaveGroup() async {
    if (!adminIds.contains(getStringAsync(userId))) {
      await showConfirmDialogCustom(context,
          dialogAnimation: DialogAnimation.SCALE,
          title: 'lblLeave'.translate + ' ${widget.groupName} ' + 'lblgroup'.translate + '?',
          positiveText: 'lbl_yes'.translate,
          negativeText: 'lbl_no'.translate, onAccept: (v) async {
        setState(() {
          isLoading = true;
        });

        //remove from memberslist
        for (int i = 0; i < membersList.length; i++) {
          if (adminIds.contains(getStringAsync(userId))) {
            membersList.removeAt(i);
          }
        }

        // update admin ids , members list, remove grp from user's contact collection
        // remove from readyBy  in chats collection of grp
        await groupChatMessageService.grpRef.doc(widget.groupId).update({"membersList": membersList, "adminIds": adminIds});
        await chatMessageService.deleteGroupFromUserContacts(groupId: widget.groupId);
        await groupChatMessageService.removeUserFromReadyByOnLeavingGroup(userId: getStringAsync(userId), groupId: widget.groupId);

        finish(context);
        finish(context);
      }, primaryColor: primaryColor);
    } else {
      await showConfirmDialogCustom(context,
          dialogAnimation: DialogAnimation.SCALE,
          title: 'lblLeave'.translate + ' ${widget.groupName} ' + 'lblgroup'.translate + '?',
          positiveText: 'lbl_yes'.translate,
          negativeText: 'lbl_no'.translate, onAccept: (v) async {
        for (int i = 0; i < membersList.length; i++) {
          //  if (membersList[i] == admin) {
          if (membersList[i] == getStringAsync(userId)) {
            membersList.removeAt(i);
          }
        }

        //remove from adminIDs, if its last admin in adminlist add 1st item from member list to adminList and to adminID field
        if (adminIds.contains(getStringAsync(userId))) {
          adminIds.remove(getStringAsync(userId));
        }

        if (adminIds.isEmpty && membersList.isNotEmpty) {
          adminIds.add(membersList.first);
        } else if (membersList.isEmpty) {
          print("members list is empty");
          //  setState(() {});
        }
        await groupChatMessageService.grpRef.doc(widget.groupId).update({
          "membersList": membersList,
          "adminId": adminIds.isNotEmpty ? adminIds.first : membersList.first,
          "adminIds": adminIds,
        });
        //remove grp from current chatlist , readBy list of chats collection of grp
        await chatMessageService.deleteGroupFromUserContacts(groupId: widget.groupId);
        await groupChatMessageService.removeUserFromReadyByOnLeavingGroup(userId: getStringAsync(userId), groupId: widget.groupId);
        finish(context);
        finish(context);
      }, primaryColor: primaryColor);
    }
  }

  Future<void> updateGroupProfileImg({File? profileImage}) async {
    appStore.isLoading = true;
    if (profileImage != null) {
      String fileName = path.basename(profileImage.path);
      Reference storageRef = FirebaseStorage.instance.ref().child("$GROUP_PROFILE_IMAGE/$fileName");
      UploadTask uploadTask = storageRef.putFile(profileImage);
      await uploadTask.then((e) async {
        await e.ref.getDownloadURL().then((value) async {
          imageUrl = value;
          await groupChatMessageService.grpRef.doc(widget.groupId).update({
            "photoUrl": imageUrl,
          });
          isProfileChange = true;
          setState(() {});
          getGroupDetails();
          appStore.isLoading = false;
        });
      });
    }
  }

  Widget profileImage() {
    if (imageFile != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.file(File(imageFile!.path), height: 100, width: 100, fit: BoxFit.cover).cornerRadiusWithClipRRect(50).onTap(() {
            _showBottomSheet(context);
          }),
          Loader().visible(appStore.isLoading)
        ],
      );
    } else if (imageUrl != null) {
      return Stack(
        alignment: Alignment.bottomRight,
        children: [
          cachedImage(imageUrl.validate(), height: 100, width: 100, fit: BoxFit.cover, alignment: Alignment.center).cornerRadiusWithClipRRect(50).onTap(() {
            FullScreenImageWidget(
              photoUrl: imageUrl,
              isFromChat: true,
              name: widget.groupName,
            ).launch(context);
          }),
          Container(
            padding: EdgeInsets.all(6),
            decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: primaryColor),
            child: Icon(Icons.camera, color: Colors.white),
          ).onTap(() {
            _showBottomSheet(context);
          })
        ],
      );
    } else {
      return noProfileImageFound(height: 100, width: 100).onTap(() {
        _showBottomSheet(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        finish(context, isProfileChange);
        return Future.value(false);
        //
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 210.0,
                  backgroundColor: context.scaffoldBackgroundColor,
                  floating: true,
                  pinned: false,
                  snap: false,
                  stretch: true,
                  actions: [
                    SizedBox(
                      child: PopupMenuButton(
                        icon: Icon(Icons.more_vert, color: textPrimaryColorGlobal),
                        color: context.cardColor,
                        onSelected: (value) async {
                          if (value == 1) {
                            bool? res = await ChangeSubjectScreen(groupName: widget.groupName, groupId: widget.groupId).launch(context);
                            if (res ?? true) {
                              isProfileChange = true;
                              getGroupDetails();
                              setState(() {});
                            }
                          }
                        },
                        padding: EdgeInsets.zero,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: Text('lblChangesubject'.translate, style: secondaryTextStyle()),
                            value: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                  leading: BackButton(color: textPrimaryColorGlobal).onTap(() {
                    finish(context, isProfileChange);
                  }),
                  stretchTriggerOffset: 120.0,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    stretchModes: [StretchMode.zoomBackground],
                    titlePadding: EdgeInsetsDirectional.only(start: 50.0, bottom: 20.0),
                    background: Container(
                      margin: EdgeInsets.only(bottom: 3),
                      padding: EdgeInsets.only(left: 16, bottom: 16, right: 16, top: 30),
                      decoration: appStore.isDarkMode
                          ? boxDecorationWithRoundedCorners(borderRadius: radius(0), backgroundColor: context.cardColor)
                          : boxDecorationWithShadow(borderRadius: radius(0), backgroundColor: context.cardColor),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          32.height,
                          profileImage(),
                          8.height,
                          Text(groupName.isEmptyOrNull ? "" : groupName!.validate(), overflow: TextOverflow.ellipsis, style: primaryTextStyle(size: 18)),
                          4.height,
                          Text(
                            'lblGroup'.translate + ' : ${membersList.length} ' + 'lblMembers'.translate,
                            overflow: TextOverflow.ellipsis,
                            style: secondaryTextStyle(),
                          ).expand(),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    return SingleChildScrollView(
                      physics: NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          16.height,
                          Container(
                            width: context.width(),
                            padding: EdgeInsets.all(16),
                            decoration: appStore.isDarkMode
                                ? boxDecorationWithRoundedCorners(borderRadius: radius(0), backgroundColor: context.cardColor)
                                : boxDecorationWithShadow(borderRadius: radius(0), backgroundColor: context.cardColor),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                4.height,
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(text: 'created'.translate, style: secondaryTextStyle(size: 12)),
                                      WidgetSpan(
                                        child: FutureBuilder<UserModel>(
                                            future: userService.getUserById(val: createdBy),
                                            builder: (c, snap) {
                                              if (snap.hasData) {
                                                if (snap.data != null) {
                                                  if (snap.data!.name != 'User Not found') {
                                                    return Text("by".translate + " " + snap.data!.name.validate() + ', ', style: secondaryTextStyle(size: 14));
                                                  } else {
                                                    return SizedBox();
                                                  }
                                                }
                                              }
                                              return snapWidgetHelper(snap,
                                                  loadingWidget: SizedBox(),
                                                  errorWidget: Text(
                                                    "on ",
                                                    style: secondaryTextStyle(),
                                                  ).paddingBottom(1));
                                            }),
                                      ),
                                      TextSpan(text: DateFormat('dd/MM/yy').format(createdDate!), style: secondaryTextStyle(size: 12)),
                                    ],
                                  ),
                                ),
                                8.height,
                              ],
                            ),
                          ),
                          16.height,
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: appStore.isDarkMode
                                ? boxDecorationWithRoundedCorners(borderRadius: radius(0), backgroundColor: context.cardColor)
                                : boxDecorationWithShadow(borderRadius: radius(0), backgroundColor: context.cardColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${membersList.length} " + 'lblMembers'.translate, style: secondaryTextStyle()),
                                //   isAdmin ? 16.height : 0.height,
                                adminIds.contains(getStringAsync(userId)) ? 16.height : 0.height,
                                //     isAdmin
                                adminIds.contains(getStringAsync(userId))
                                    ? InkWell(
                                        onTap: () async {
                                          bool? res = await NewGroupScreen(isAddParticipant: true, groupId: widget.groupId, data: widget.data).launch(context);
                                          if (res ?? true) {
                                            getGroupDetails();
                                            setState(() {});
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 45,
                                              width: 45,
                                              decoration: boxDecorationDefault(shape: BoxShape.circle, color: primaryColor),
                                              child: Icon(Icons.person_add, color: Colors.white.withOpacity(0.9), size: 25),
                                            ),
                                            16.width,
                                            Text('lblAddparticipants'.translate.capitalizeEachWord(), style: primaryTextStyle())
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                                ListView.builder(
                                  itemCount: userModelList.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        child: Row(
                                      children: [
                                        userModelList[index].photoUrl!.isEmpty
                                            ? Hero(
                                                tag: userModelList[index].uid.validate(),
                                                child: noProfileImageFound(height: 45, width: 45),
                                              )
                                            : cachedImage(userModelList[index].photoUrl.validate(), width: 45, height: 45, fit: BoxFit.cover).cornerRadiusWithClipRRect(25),
                                        16.width,
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(userModelList[index].uid == getStringAsync(userId) ? 'you'.translate : '${userModelList[index].name.validate().capitalizeFirstLetter()}',
                                                    style: primaryTextStyle()),
                                                Container(
                                                  decoration: boxDecorationWithRoundedCorners(
                                                      border: Border.all(color: primaryColor), borderRadius: radius(4), backgroundColor: appStore.isDarkMode ? cardDarkColor : white),
                                                  padding: EdgeInsets.all(2),
                                                  child: Text('lblGroupAdmin'.translate, style: primaryTextStyle(size: 10, color: appStore.isDarkMode ? textPrimaryColorGlobal : primaryColor)),
                                                  //  ).visible(userModelList[index].uid == admin)
                                                ).visible(adminIds.contains(userModelList[index].uid))
                                              ],
                                            ),
                                            4.height,
                                            Text('${userModelList[index].userStatus.validate()}', style: secondaryTextStyle()),
                                          ],
                                        ).expand(),
                                      ],
                                    ).paddingSymmetric(vertical: 8).onTap(() {
                                      //  if (!adminIds.no(userModelList[index].uid)) {
                                      //    if (userModelList[index].uid != admin) showDialogBox(index);
                                      if ((userModelList[index].uid != getStringAsync(userId))) showDialogBox(index);
                                      setState(() {});
                                    }));
                                  },
                                ),
                              ],
                            ),
                          ),
                          16.height,
                          Container(
                            padding: EdgeInsets.all(16),
                            width: context.width(),
                            decoration: appStore.isDarkMode
                                ? boxDecorationWithRoundedCorners(borderRadius: radius(0), backgroundColor: context.cardColor)
                                : boxDecorationWithShadow(borderRadius: radius(0), backgroundColor: context.cardColor),
                            child: Row(
                              children: [
                                Icon(Icons.exit_to_app, color: Colors.red),
                                8.width,
                                Text(
                                  'lblLeaveGroup'.translate,
                                  style: primaryTextStyle(color: Colors.red, size: 18),
                                ),
                              ],
                            ),
                          ).onTap(() {
                            if (adminIds.length == 1 && adminIds.contains(getStringAsync(userId)) && membersList.length == 1 && membersList.contains(getStringAsync(userId))) {
                              onDeleteGroup();
                            } else {
                              onLeaveGroup();
                            }
                          }),
                          70.height,
                        ],
                      ),
                    );
                  }, childCount: 1),
                )
              ],
            ),
            Loader().center().visible(isLoading)
          ],
        ),
      ),
    );
  }

  void _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      setState(() {});
      updateGroupProfileImg(profileImage: File(imageFile!.path));
    }
  }

  _getFromCamera() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      setState(() {});
      updateGroupProfileImg(profileImage: File(imageFile!.path));
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: context.cardColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: 'lblGallery'.translate,
              leading: Icon(Icons.image, color: primaryColor),
              onTap: () {
                _getFromGallery();
                finish(context);
              },
            ),
            Divider(color: context.dividerColor),
            SettingItemWidget(
              title: 'camera'.translate,
              leading: Icon(Icons.camera, color: primaryColor),
              onTap: () {
                _getFromCamera();
                finish(context);
              },
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }
}
