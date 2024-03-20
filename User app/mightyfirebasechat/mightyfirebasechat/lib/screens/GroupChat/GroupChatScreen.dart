import 'dart:io';

import 'package:chat/utils/AppImages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../components/ChatItemWidget.dart';
import '../../components/MultipleSelectedAttachment.dart';
import '../../main.dart';
import '../../models/ChatMessageModel.dart';
import '../../models/ContactModel.dart';
import '../../models/FileModel.dart';
import '../../models/StickerModel.dart';
import '../../models/UserModel.dart';
import '../../screens/GroupChat/GroupInfoScreen.dart';
import '../../screens/PickupLayout.dart';
import '../../services/ChatMessageService.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../../utils/VoiceNoteRecordWidget.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupChatId, groupName;

  final dynamic groupData;

  GroupChatScreen({required this.groupName, required this.groupChatId, this.groupData});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController messageCont = TextEditingController();
  bool emojiShowing = false;
  bool emojiStickerShowing = false;
  bool isStrickerShows = false;
  bool isFirstMsg = false;
  String? imageUrl;
  String? name = '';

  List membersList = [];
  List<UserModel> userModelList = [];
  List<UserModel> userList = [];
  List<String> mList = [];
  List<StickerModel> stickerList = [];
  String admin = '';

  String? currentLat;
  String? currentLong;

  bool showPlayer = false;
  String? audioPath;
  Map<String, bool> readBy = {};

  @override
  void initState() {
    super.initState();
    name = widget.groupName;
    getGroupDetails();
    mSelectedImage = getStringAsync(SELECTED_WALLPAPER, defaultValue: appStore.isDarkMode ? mSelectedImageDark : "assets/default_wallpaper.png");
  }

  Future getGroupDetails() async {
    await groupChatMessageService.grpRef.doc(widget.groupChatId).get().then((chatMap) async {
      membersList = chatMap['membersList'];
      getMemberList();
      imageUrl = chatMap['photoUrl'];
      name = chatMap['name'];
      admin = chatMap['adminId'];
      if (getStringAsync(userId) == admin) {
        if (chatMap['adminIds'] == null) {
          print("Group chat empty");
          await groupChatMessageService.grpRef.doc(getStringAsync(userId)).update({
            'adminIds': [getStringAsync(userId)],
          });
        }
      }
      setState(() {});
    });
  }

  getMemberList() {
    userModelList.clear();
    membersList.forEach((element) async {
      UserModel userm = await userService.getUserById(val: element);
      userModelList.add(userm);
      userList.add(userm);
      if (userm.uid != getStringAsync(userId)) {
        if (!userm.oneSignalPlayerId.isEmptyOrNull) {
          mList.add(userm.oneSignalPlayerId.toString());
          setState(() {});
          print(userm.uid.toString() + "----------------------------------------" + userm.oneSignalPlayerId.toString());
        }
      }
      setState(() {});
    });
  }

  void addReadBy() {
    readBy.clear();
    membersList.forEach((element) {
      if (element == getStringAsync(userId)) {
        readBy[element] = true;
      } else {
        readBy[element] = false;
      }
    });
  }

  void onSendMessageToGroup() {
    addReadBy();
    ChatMessageModel chatMessageModel = ChatMessageModel();
    chatMessageModel.senderId = getStringAsync(userId);
    chatMessageModel.message = encryptData(messageCont.text);
    chatMessageModel.isMessageRead = false;
    chatMessageModel.stickerPath = null;
    chatMessageModel.isEncrypt = true;
    chatMessageModel.createdAt = DateTime.now().millisecondsSinceEpoch;
    chatMessageModel.messageType = MessageType.TEXT.name;
    chatMessageModel.readBy = readBy;
    sendNormalGroupMessages(chatMessageModel, result: null);
  }

  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    currentLat = position.latitude.toString();
    currentLong = position.longitude.toString();

    sendGroupMessage(type: TYPE_LOCATION);
  }

  getSticker() {
    stickerService.getAllSticker().then((value) {
      stickerList = value;
      log(stickerList.length);
      setState(() {});
    });
  }

  void sendGroupMessage({FilePickerResult? result, String? stickerPath, File? filepath, String? type}) async {
    messageCont.clear();
    addReadBy();
    ChatMessageModel chatMessageModel = ChatMessageModel();
    chatMessageModel.senderId = sender.uid;
    chatMessageModel.message = messageCont.text;
    chatMessageModel.isMessageRead = false;
    chatMessageModel.stickerPath = stickerPath;
    chatMessageModel.isEncrypt = false;
    chatMessageModel.createdAt = DateTime.now().millisecondsSinceEpoch;
    chatMessageModel.readBy = readBy;
    if (result != null) {
      if (type == TYPE_Image) {
        chatMessageModel.messageType = MessageType.IMAGE.name;
      } else if (type == TYPE_VIDEO) {
        chatMessageModel.messageType = MessageType.VIDEO.name;
      } else if (type == TYPE_AUDIO) {
        chatMessageModel.messageType = MessageType.AUDIO.name;
      } else if (type == TYPE_DOC) {
        chatMessageModel.messageType = MessageType.DOC.name;
      } else if (type == TYPE_VOICE_NOTE) {
        chatMessageModel.messageType = MessageType.VOICE_NOTE.name;
      } else {
        chatMessageModel.messageType = MessageType.TEXT.name;
        messageCont.text = encryptData(messageCont.text);
        chatMessageModel.message = messageCont.text;
        chatMessageModel.isEncrypt = true;
      }
    } else if (stickerPath.validate().isNotEmpty) {
      chatMessageModel.messageType = MessageType.STICKER.name;
    } else {
      if (type == TYPE_LOCATION) {
        chatMessageModel.messageType = MessageType.LOCATION.name;
        chatMessageModel.currentLat = currentLat;
        chatMessageModel.currentLong = currentLong;
      } else if (type == TYPE_Image) {
        chatMessageModel.messageType = MessageType.IMAGE.name;
      } else if (type == TYPE_VOICE_NOTE) {
        chatMessageModel.messageType = MessageType.VOICE_NOTE.name;
        log(chatMessageModel.messageType);
        log(MessageType.VOICE_NOTE.name);
      } else {
        chatMessageModel.messageType = MessageType.TEXT.name;
        messageCont.text = encryptData(messageCont.text);
        chatMessageModel.message = messageCont.text;
        chatMessageModel.isEncrypt = true;
      }
    }

    //  sendNormalGroupMessages(chatMessageModel, result: result != null ? result : null, filepath: filepath);
    sendNormalGroupMessages(chatMessageModel, type: type, result: result != null ? result : null, filepath: filepath);
  }

  void sendNormalGroupMessages(ChatMessageModel data, {String? type, FilePickerResult? result, File? filepath}) async {
    userList.clear();

    String? msgValue = messageCont.text.toString();
    ContactModel contactModel = ContactModel();
    contactModel.uid = widget.groupChatId;
    contactModel.addedOn = Timestamp.now();
    contactModel.lastMessageTime = DateTime.now().millisecondsSinceEpoch;
    contactModel.groupRefUrl = widget.groupChatId;
    print("Data=================${data.messageType}");
    String? message = '';
    if (type == TYPE_Image) {
      message = getStringAsync(userDisplayName) + " Sent you " + MessageType.IMAGE.name.capitalizeFirstLetter();
    } else if (type == TYPE_VIDEO) {
      message = getStringAsync(userDisplayName) + " sent you " + MessageType.VIDEO.name.capitalizeFirstLetter();
    } else if (type == TYPE_AUDIO) {
      message = getStringAsync(userDisplayName) + " Sent you " + MessageType.AUDIO.name.capitalizeFirstLetter();
    } else if (type == TYPE_DOC) {
      message = getStringAsync(userDisplayName) + " Sent you " + MessageType.DOC.name.capitalizeFirstLetter();
    } else if (type == TYPE_VOICE_NOTE) {
      message = getStringAsync(userDisplayName) + " Sent you " + MessageType.VOICE_NOTE.name.capitalizeFirstLetter();
    } else if (type == TYPE_LOCATION) {
      message = getStringAsync(userDisplayName) + " Sent you " + MessageType.LOCATION.name.capitalizeFirstLetter();
    } else if (type == TYPE_STICKER) {
      message = getStringAsync(userDisplayName) + " Sent you " + MessageType.STICKER.name.capitalizeFirstLetter();
    } else {
      message = getStringAsync(userDisplayName) + " Sent you " + msgValue.validate();
    }

    await notificationService.sendPushNotifications(name.validate() + " ", message, isGrp: true, recevierUid: widget.groupChatId, mPlayerIds: mList).catchError((e) {
      log('error' + e.toString());
    }).then((value) async {
      await chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: widget.groupChatId).update(<String, dynamic>{
        "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
      }).catchError((e) {
        log(e);
      }).then((value) {
        userModelList.forEach((element) async {
          log(element.oneSignalPlayerId);
          await chatMessageService.getContactsDocument(of: element.uid.validate(), forContact: widget.groupChatId).update(<String, dynamic>{
            "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
          });
          // if (element.uid != getStringAsync(userId)) {
          //   notificationService.sendPushNotifications(getStringAsync(userDisplayName), messageCont.text, receiverPlayerId: element.oneSignalPlayerId).catchError((e) {
          //     log('error' + e);
          //   });
          // }
        });
      });
    });

    messageCont.clear();

    setState(() {});

    if (data.messageType == MessageType.LOCATION.name) {
      //  groupChatMessageService.addLatLong(data, groupId: widget.groupChatId, lat: currentLat, long: currentLong);
    }

    groupChatMessageService.addIsEncrypt(data);

    await groupChatMessageService.addMessage(data, widget.groupChatId).then((value) async {
      if (result != null || filepath != null) {
        FileModel fileModel = FileModel();
        fileModel.id = value.id;
        fileModel.file = result != null ? File(result.files.single.path!) : filepath;
        fileList.add(fileModel);

        setState(() {});

        await groupChatMessageService
            .addMessageToDb(
                senderDoc: value,
                data: data,
                image: result != null
                    ? File(result.files.single.path!)
                    : filepath != null
                        ? filepath
                        : null,
                isRequest: false)
            .then((value) {});
      }
    }).catchError((e) {
      log("message send:$e");
    });
  }

  // void sendNormalGroupMessages(ChatMessageModel data, {FilePickerResult? result, File? filepath}) async {
  //   ContactModel contactModel = ContactModel();
  //   contactModel.uid = widget.groupChatId;
  //   contactModel.addedOn = Timestamp.now();
  //   contactModel.lastMessageTime = DateTime.now().millisecondsSinceEpoch;
  //   contactModel.groupRefUrl = '';
  //   List<dynamic> playerIds = [];
  //   //current user  =>contacts ==> grp doc  last time update
  //
  //   chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: widget.groupChatId).update(<String, dynamic>{
  //     "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
  //   }).catchError((e) {
  //     log(e);
  //   }).then((value) {
  //     userModelList.forEach((element) async {
  //       log(element.oneSignalPlayerId);
  //       await chatMessageService.getContactsDocument(of: element.uid.validate(), forContact: widget.groupChatId).update(<String, dynamic>{
  //         "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
  //       });
  //     });
  //   });
  //   messageCont.clear();
  //   setState(() {});
  //
  //   if (data.messageType == MessageType.LOCATION.name) {
  //     groupChatMessageService.addLatLong(data, groupId: widget.groupChatId, lat: currentLat, long: currentLong);
  //   }
  //
  //   groupChatMessageService.addIsEncrypt(data);
  //
  //   await groupChatMessageService.addMessage(data, widget.groupChatId).then((value) async {
  //     if (result != null || filepath != null) {
  //       FileModel fileModel = FileModel();
  //       fileModel.id = value.id;
  //       fileModel.file = result != null ? File(result.files.single.path!) : filepath;
  //       fileList.add(fileModel);
  //
  //       setState(() {});
  //
  //       await groupChatMessageService
  //           .addMessageToDb(
  //               senderDoc: value,
  //               data: data,
  //               image: result != null
  //                   ? File(result.files.single.path!)
  //                   : filepath != null
  //                       ? filepath
  //                       : null,
  //               isRequest: false)
  //           .then((value) {});
  //     }
  //   }).catchError((e) {
  //     log("message send:$e");
  //   });
  // }

  _showAttachmentDialog() {
    return showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 12),
            margin: EdgeInsets.only(bottom: 78, left: 12, right: 12),
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: context.scaffoldBackgroundColor,
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  iconsBackgroundWidget(context, name: "camera".translate, image: ic_camera, color: Colors.purple.shade400).onTap(() async {
                    //

                    var result = await ImagePicker().pickImage(source: ImageSource.camera);
                    if (result != null) {
                      List<File> image = [];
                      image.add(File(result.path.validate()));
                      // finish(context);
                      bool res = await MultipleSelectedAttachment(attachedFiles: image, userModel: null, isImage: true).launch(context);
                      if (res) {
                        finish(context);
                        sendGroupMessage(result: null, filepath: File(result.path.validate()), type: TYPE_Image);
                      }
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: 'lblGallery'.translate, image: ic_wallpaper, color: Colors.purple.shade400).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: false, allowCompression: true);

                    if (result != null) {
                      List<File> image = [];
                      result.files.map((e) {
                        image.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      bool res = await (MultipleSelectedAttachment(attachedFiles: image, userModel: null, isImage: true).launch(context));
                      if (res) {
                        result.files.map((e) {
                          sendGroupMessage(result: result, filepath: File(e.path.validate()), type: TYPE_Image);
                        }).toList();
                      }
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: 'lblVideo'.translate, image: ic_video_call, color: Colors.pink[400]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: false, allowCompression: true);
                    if (result != null) {
                      log(result);
                      List<File> videos = [];
                      result.files.map((e) {
                        log(e.path);
                        videos.add(File(e.path.validate()));
                      }).toList();
                      log(videos);
                      finish(context);
                      bool res = await (MultipleSelectedAttachment(attachedFiles: videos, userModel: null, isVideo: true).launch(context));
                      if (res) {
                        result.files.map((e) {
                          sendGroupMessage(result: result, filepath: File(e.path.validate()), type: TYPE_VIDEO);
                        }).toList();
                      }
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: 'lblAudio'.translate, image: ic_audio, color: Colors.blue[700]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio, allowCompression: true, allowMultiple: false);
                    if (result != null) {
                      List<File> audio = [];
                      result.files.map((e) {
                        audio.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      result.files.map((e) {
                        sendGroupMessage(result: result, filepath: File(e.path.validate()), type: TYPE_AUDIO);
                      }).toList();
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: 'lblDocument'.translate, image: ic_term_condition, color: Colors.blue[700]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['docx', 'doc', 'txt', 'pdf'], allowMultiple: true);
                    if (result != null) {
                      List<File> docs = [];
                      result.files.map((e) {
                        docs.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      result.files.map((e) {
                        sendGroupMessage(result: result, filepath: File(e.path.validate()), type: TYPE_DOC);
                      }).toList();
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: 'lblLocation'.translate, image: ic_location, color: Colors.green.shade500).onTap(
                    () async {
                      determinePosition();

                      showConfirmDialogCustom(
                        context,
                        dialogAnimation: DialogAnimation.SCALE,
                        positiveText: 'lbl_yes'.translate,
                        negativeText: 'lbl_no'.translate,
                        title: 'are_you_sure_you_want_to_share_your_current_location'.translate,
                        primaryColor: primaryColor,
                        onAccept: (v) async {
                          bool? isEnable = await checkPermission();

                          log(isEnable);
                          if (isEnable == true) {
                            getLocation();
                            finish(context);
                          } else {
                            toast('lblPleaseEnableLocation'.translate);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> handleOnTap() async {
    bool res = await GroupInfoScreen(groupName: name.validate(), groupId: widget.groupChatId, data: widget.groupData)
        .launch(context, pageRouteAnimation: PageRouteAnimation.Scale, duration: 300.milliseconds);
    print(res.toString());
    if (res == true) {
      getGroupDetails();
      setState(() {});
    }
  }

  @override
  void dispose() {
    setValue(CURRENT_GROUP_ID, '');

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(context.width(), kToolbarHeight),
          child: AppBar(
            titleSpacing: 0,
            automaticallyImplyLeading: false,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    onPressed: () {
                      finish(context);
                    },
                    icon: Icon(Icons.arrow_back, color: whiteColor)),
                4.width,
                InkWell(
                  onTap: () {
                    handleOnTap();
                  },
                  child: Row(
                    children: [
                      imageUrl != null
                          ? Hero(
                              tag: 'profile',
                              child: cachedImage(imageUrl, width: 35, height: 35, fit: BoxFit.cover).cornerRadiusWithClipRRect(25),
                            )
                          : noProfileImageFound(height: 35, width: 35),
                      10.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name.validate(), style: TextStyle(color: whiteColor, overflow: TextOverflow.ellipsis)),
                          // 2.height,
                          // Row(
                          //     children: List.generate(userModelList.length >= 3 ? 3 : userModelList.length, (index) {
                          //   return userModelList.length - 1 == index
                          //       ? Text(userModelList[index].name.validate(), style: secondaryTextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)
                          //       : Text(userModelList[index].name.validate() + ",", style: secondaryTextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis);
                          // })),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: context.primaryColor,
            // actions: [
            //   IconButton(
            //     onPressed: () {
            //       handleOnTap();
            //     },
            //     icon: Icon(Icons.more_vert, color: whiteColor),
            //   ),
            // ],
          ),
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            backgroundImage(),
            Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: PaginateFirestore(
                    //  bottomLoader: Loader(),
                    //initialLoader: Loader(),
                    reverse: true,
                    isLive: true,
                    //  padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: !emojiStickerShowing ? 100 : 200),
                    physics: BouncingScrollPhysics(),
                    query: groupChatMessageService.chatMessagesWithPagination(currentUserId: getStringAsync(userId), groupDocId: widget.groupChatId),
                    itemsPerPage: PER_PAGE_CHAT_COUNT,
                    shrinkWrap: true,
                    onLoaded: (page) {
                      isFirstMsg = page.documentSnapshots.isEmpty;
                    },
                    onEmpty: SizedBox(),
                    itemBuilderType: PaginateBuilderType.listView,
                    itemBuilder: (context, snap, index) {
                      ChatMessageModel data = ChatMessageModel.fromJson(snap[index].data() as Map<String, dynamic>);

                      data.isMe = data.senderId == getStringAsync(userId);

                      return ChatItemWidget(data: data, isGroup: true);
                    },
                  ).paddingBottom(emojiStickerShowing ? 320 : 75),
                ),
                getRequestedWidget(),
                // Column(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Stack(
                //       alignment: Alignment.bottomRight,
                //       children: [
                //         Row(
                //           crossAxisAlignment: CrossAxisAlignment.end,
                //           children: [
                //             Container(
                //               decoration: boxDecorationWithShadow(borderRadius: BorderRadius.circular(30), spreadRadius: 0, blurRadius: 0, backgroundColor: context.cardColor),
                //               padding: EdgeInsets.only(left: 0, right: 8),
                //               child: Row(
                //                 children: [
                //                   IconButton(
                //                     icon: Icon(LineIcons.smiling_face_with_heart_eyes),
                //                     iconSize: 24.0,
                //                     padding: EdgeInsets.all(2),
                //                     color: Colors.grey,
                //                     onPressed: () {
                //                       hideKeyboard(context);
                //                       emojiStickerShowing = !emojiStickerShowing;
                //                       emojiShowing = true;
                //                       setState(() {});
                //                     },
                //                   ),
                //                   AppTextField(
                //                     controller: messageCont,
                //                     textFieldType: TextFieldType.OTHER,
                //                     cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                //                     textCapitalization: TextCapitalization.sentences,
                //                     keyboardType: TextInputType.multiline,
                //                     minLines: 1,
                //                     maxLines: 5,
                //                     onTap: () {
                //                       emojiStickerShowing = false;
                //                       setState(() {});
                //                     },
                //                     textInputAction: mIsEnterKey ? TextInputAction.send : TextInputAction.newline,
                //                     onFieldSubmitted: (p0) {
                //                       onSendMessageToGroup();
                //                     },
                //                     onChanged: (s) {
                //                       emojiStickerShowing = false;
                //                       setState(() {});
                //                     },
                //                     decoration: InputDecoration(
                //                       border: InputBorder.none,
                //                       hintText: 'lblMessage'.translate,
                //                       hintStyle: secondaryTextStyle(size: 16),
                //                       isDense: true,
                //                     ),
                //                   ).expand(),
                //                   IconButton(
                //                     visualDensity: VisualDensity(horizontal: 0, vertical: 1),
                //                     icon: Icon(Icons.attach_file),
                //                     iconSize: 25.0,
                //                     padding: EdgeInsets.all(2),
                //                     color: Colors.grey,
                //                     onPressed: () {
                //                       _showAttachmentDialog();
                //                       hideKeyboard(context);
                //                     },
                //                   ),
                //                 ],
                //               ),
                //               width: context.width(),
                //             ).expand(),
                //             8.width,
                //             if (messageCont.text.isNotEmpty || emojiStickerShowing)
                //               GestureDetector(
                //                 onTap: () {
                //                   print(messageCont.text);
                //                   onSendMessageToGroup();
                //                 },
                //                 child: Container(
                //                   width: 50,
                //                   height: 50,
                //                   alignment: Alignment.center,
                //                   decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                //                   child: Icon(Icons.send, color: Colors.white, size: 22),
                //                 ),
                //               ),
                //             if (messageCont.text.isEmpty && !emojiStickerShowing) SizedBox(width: 48)
                //           ],
                //         ).paddingOnly(bottom: 8, left: 8, right: 8),
                //         if (messageCont.text.isEmpty && !emojiStickerShowing)
                //           AudioRecorder(
                //             onStop: (path) {
                //               if (found.kDebugMode) print('Recorded file path: $path');
                //
                //               setState(() {
                //                 audioPath = path;
                //               });
                //
                //               sendGroupMessage(result: null, filepath: File.fromUri(Uri.parse(audioPath!)), type: TYPE_VOICE_NOTE);
                //             },
                //           ).paddingOnly(bottom: 8, left: 8, right: 8),
                //       ],
                //     ),
                //   ],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getRequestedWidget() {
    return Positioned(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: boxDecorationWithShadow(borderRadius: BorderRadius.circular(30), spreadRadius: 0, blurRadius: 0, backgroundColor: context.cardColor),
                    padding: EdgeInsets.only(left: 0, right: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(LineIcons.smiling_face_with_heart_eyes),
                          iconSize: 24.0,
                          padding: EdgeInsets.all(2),
                          color: Colors.grey,
                          onPressed: () {
                            hideKeyboard(context);
                            emojiStickerShowing = !emojiStickerShowing;
                            emojiShowing = true;
                            setState(() {});
                          },
                        ),
                        AppTextField(
                          controller: messageCont,
                          textFieldType: TextFieldType.OTHER,
                          cursorColor: appStore.isDarkMode ? Colors.white : Colors.black,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          onTap: () {
                            emojiStickerShowing = false;
                            setState(() {});
                          },
                          textInputAction: mIsEnterKey ? TextInputAction.send : TextInputAction.newline,
                          onFieldSubmitted: (p0) {
                            onSendMessageToGroup();
                          },
                          onChanged: (s) {
                            emojiStickerShowing = false;
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'lblMessage'.translate,
                            hintStyle: secondaryTextStyle(size: 16),
                            isDense: true,
                          ),
                        ).expand(),
                        IconButton(
                          visualDensity: VisualDensity(horizontal: 0, vertical: 1),
                          icon: Icon(Icons.attach_file),
                          iconSize: 25.0,
                          padding: EdgeInsets.all(2),
                          color: Colors.grey,
                          onPressed: () {
                            _showAttachmentDialog();
                            hideKeyboard(context);
                            emojiStickerShowing = false;
                          },
                        ),
                      ],
                    ),
                    width: context.width(),
                  ).expand(),
                  8.width,
                  if (messageCont.text.isNotEmpty || emojiStickerShowing)
                    GestureDetector(
                      onTap: () {
                        print(messageCont.text);
                        onSendMessageToGroup();
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                        child: Icon(Icons.send, color: Colors.white, size: 22),
                      ),
                    ),
                  if (messageCont.text.isEmpty && !emojiStickerShowing) SizedBox(width: 48)
                ],
              ).paddingOnly(bottom: 8, left: 8, right: 8),
              if (messageCont.text.isEmpty && !emojiStickerShowing)
                AudioRecorder(
                  onStop: (path) {
                    setState(() {
                      audioPath = path;
                    });
                    sendGroupMessage(result: null, filepath: File(path), type: TYPE_VOICE_NOTE);
                  },
                ).paddingOnly(bottom: 8, left: 8, right: 8),
            ],
          ),
          if (emojiStickerShowing) showEmojiBottomsheet(),
        ],
      ),
    );
  }

  showEmojiBottomsheet() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          child: emojiShowing == true
              ? ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 500),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      SizedBox(
                        height: 255,
                        child: EmojiPicker(
                          onEmojiSelected: (Category? category, Emoji emoji) {
                            messageCont.text = messageCont.text + emoji.emoji;
                            //  setState(() {});
                          },
                          config: Config(
                            columns: 8,
                            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            bgColor: context.cardColor,
                            gridPadding: EdgeInsets.only(bottom: 50),
                            initCategory: Category.RECENT,
                            indicatorColor: primaryColor,
                            iconColor: Colors.grey,
                            iconColorSelected: primaryColor,
                            backspaceColor: primaryColor,
                            skinToneIndicatorColor: Colors.grey,
                            enableSkinTones: true,
                            recentTabBehavior: RecentTabBehavior.RECENT,
                            recentsLimit: 28,
                            replaceEmojiOnLimitExceed: false,
                            noRecents: Text('no_recent'.translate, style: TextStyle(fontSize: 20, color: Colors.black26), textAlign: TextAlign.center),
                            tabIndicatorAnimDuration: kTabScrollDuration,
                            categoryIcons: CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : isStrickerShows == true
                  ? Container(
                      height: 255,
                      width: context.width(),
                      color: context.cardColor,
                      constraints: BoxConstraints(maxHeight: 500),
                      child: GridView.count(
                          padding: EdgeInsets.only(top: 8, bottom: 50),
                          crossAxisCount: 4,
                          crossAxisSpacing: 4.0,
                          mainAxisSpacing: 8.0,
                          children: stickerList.map((e) {
                            return Stack(
                              children: [
                                Container(height: 100, width: 100, child: Loader().center()),
                                cachedImage(e.stickerPath.validate(), height: 100, width: 100, fit: BoxFit.cover).onTap(() {
                                  hideKeyboard(context);
                                  sendGroupMessage(stickerPath: e.stickerPath, type: TYPE_STICKER);
                                }),
                              ],
                            );
                          }).toList()),
                    )
                  : SizedBox(),
        ),
        Container(
          height: 40,
          alignment: Alignment.center,
          width: context.width(),
          color: context.cardColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  emojiShowing = true;
                  isStrickerShows = false;
                  setState(() {});
                },
                icon: Icon(Icons.emoji_emotions_outlined, size: 28, color: emojiShowing ? primaryColor : textSecondaryColorGlobal.withOpacity(0.7)),
              ),
              IconButton(
                onPressed: () {
                  isStrickerShows = true;
                  getSticker();
                  emojiShowing = false;
                  setState(() {});
                },
                icon: Icon(Icons.face, size: 28, color: isStrickerShows ? primaryColor : textSecondaryColorGlobal.withOpacity(0.7)),
              ),
            ],
          ),
        )
      ],
    );
  }
}
