import 'dart:io';

import 'package:chat/utils/AppImages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../../components/ChatItemWidget.dart';
import '../../components/ChatTopWidget.dart';
import '../../components/MultipleSelectedAttachment.dart';
import '../../main.dart';
import '../../models/ChatMessageModel.dart';
import '../../models/ChatRequestModel.dart';
import '../../models/ContactModel.dart';
import '../../models/FileModel.dart';
import '../../models/StickerModel.dart';
import '../../models/UserModel.dart';
import '../../screens/PickupLayout.dart';
import '../../services/ChatMessageService.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../utils/VoiceNoteRecordWidget.dart';
import '../utils/providers/ChatRequestProvider.dart';

class ChatScreen extends StatefulWidget {
  final UserModel? receiverUser;
  final bool isFromRequest;

  ChatScreen(this.receiverUser, {this.isFromRequest = false});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late ChatMessageService chatMessageService;
  InterstitialAd? myInterstitial;
  TextEditingController messageCont = TextEditingController();
  FocusNode messageFocus = FocusNode();

  List<StickerModel> stickerList = [];

  bool emojiShowing = false;
  bool emojiStickerShowing = false;

  bool isStickerShows = false;
  bool isFirstMsg = false;
  bool isBlocked = false;
  bool showPlayer = false;
  Future<bool>? requestData;

  String id = '';
  String? currentLat;
  String? currentLong;
  String? audioPath;
  String? currentlyUploadedAudioPath;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    WidgetsBinding.instance.addObserver(this);
    OneSignal.User.pushSubscription.optIn();
    id = getStringAsync(userId);
    getValues();

    if (mAdShowCount < 5) {
      mAdShowCount++;
    } else {
      mAdShowCount = 0;
      buildInterstitialAd();
    }
  }

  getValues() async {
    mChatFontSize = getIntAsync(FONT_SIZE_PREF, defaultValue: 16);
    mIsEnterKey = getBoolAsync(IS_ENTER_KEY, defaultValue: false);
    mSelectedImage = getStringAsync(SELECTED_WALLPAPER, defaultValue: appStore.isDarkMode ? mSelectedImageDark : "assets/default_wallpaper.png");

    chatMessageService = ChatMessageService();
    try {
      isBlocked = await userService.isUserBlocked(widget.receiverUser!.uid!);
    } catch (e) {
      print("Error========");
    }

    chatMessageService.fetchLastMessage(loginStore.mId, widget.receiverUser!.uid!).then((value) {
      if (loginStore.mId == value.receiverId.validate()) chatMessageService.setUnReadStatusToTrue(senderId: sender.uid!, receiverId: widget.receiverUser!.uid!);
      chatMessageService.fetchForMessageCount(loginStore.mId);
    });
    requestData = chatRequestService.isRequestsUserExist(widget.receiverUser!.uid!);
    setState(() {});
  }

  void getLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    currentLat = position.latitude.toString();
    currentLong = position.longitude.toString();

    sendMessage(type: TYPE_LOCATION);
    if (messageCont.text.trim().isEmpty) {
      return;
    }
  }

  getSticker() {
    stickerService.getAllSticker().then((value) {
      stickerList = value;
      log(stickerList.length);
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) async {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.detached) {
  //     //  oneSignal.disablePush(false);
  //     OneSignal.User.pushSubscription.optOut();
  //   }
  //   if (state == AppLifecycleState.paused) {
  //     //   oneSignal.disablePush(false);
  //     OneSignal.User.pushSubscription.optOut();
  //   }
  //   if (state == AppLifecycleState.resumed) {
  //     //  oneSignal.disablePush(true);
  //     OneSignal.User.pushSubscription.optIn();
  //   }
  // }

  @override
  void dispose() async {
    // oneSignal.disablePush(false);
    //  OneSignal.User.pushSubscription.optOut();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildChatRequestWidget(AsyncSnapshot<bool> snap) {
      if (snap.hasData) {
        return getRequestedWidget(snap.data!);
      } else if (snap.hasError) {
        return getRequestedWidget(false);
      } else {
        return getRequestedWidget(false);
      }
    }

    return PickupLayout(
      child: WillPopScope(
        onWillPop: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          return Future.value(false);
          //
        },
        child: Scaffold(
            backgroundColor: context.scaffoldBackgroundColor,
            appBar: PreferredSize(
              preferredSize: Size(context.width(), kToolbarHeight),
              child: ChatAppBarWidget(
                receiverUser: widget.receiverUser!,
                isFromRequest: widget.isFromRequest,
              ),
            ),
            body: FutureBuilder<bool>(
              future: requestData,
              builder: (context, snap) {
                if (snap.hasData) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      backgroundImage(),
                      PaginateFirestore(
                        reverse: true,
                        isLive: true,
                        padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                        physics: BouncingScrollPhysics(),
                        query: chatMessageService.chatMessagesWithPagination(currentUserId: getStringAsync(userId), receiverUserId: widget.receiverUser!.uid!),
                        itemsPerPage: PER_PAGE_CHAT_COUNT,
                        shrinkWrap: true,
                        onLoaded: (page) {
                          isFirstMsg = page.documentSnapshots.isEmpty;
                        },
                        onEmpty: SizedBox(),
                        itemBuilderType: PaginateBuilderType.listView,
                        itemBuilder: (context, snap, index) {
                          ChatMessageModel data = ChatMessageModel.fromJson(snap[index].data() as Map<String, dynamic>);

                          data.isMe = data.senderId == id;
                          return ChatItemWidget(data: data);
                        },
                      ).paddingBottom(!emojiStickerShowing
                          ? snap.hasData
                              ? (snap.data! ? 176 : 76)
                              : 76
                          : 320),
                      buildChatRequestWidget(snap),
                      if (isBlocked)
                        Positioned(
                          top: 16,
                          left: 32,
                          right: 32,
                          child: Container(
                            decoration: boxDecorationDefault(color: Colors.red.shade100),
                            child: TextButton(
                              onPressed: () {
                                unblockDialog(context, receiver: widget.receiverUser!);
                              },
                              child: Text('you_blocked_this_contact'.translate, style: secondaryTextStyle(color: Colors.red)),
                            ),
                          ),
                        )
                    ],
                  ).onTap(() {
                    hideKeyboard(context);
                  });
                }
                //   return snapWidgetHelper(snap, loadingWidget: Loader());
                return SizedBox();
              },
            )),
      ),
    );
  }

  //region send Message
  void sendMessage({FilePickerResult? result, String? stickerPath, File? filepath, String? type}) async {
    log(type == TYPE_VOICE_NOTE);

    if (isBlocked.validate(value: false)) {
      unblockDialog(context, receiver: widget.receiverUser!);
      return;
    }

    ChatMessageModel data = ChatMessageModel();
    data.receiverId = widget.receiverUser!.uid;
    data.senderId = sender.uid;
    data.message = messageCont.text.trim();
    data.isMessageRead = false;
    data.stickerPath = stickerPath;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;
    data.isEncrypt = false;
    if (result != null) {
      if (type == TYPE_Image) {
        data.messageType = MessageType.IMAGE.name;
      } else if (type == TYPE_VIDEO) {
        data.messageType = MessageType.VIDEO.name;
      } else if (type == TYPE_AUDIO) {
        data.messageType = MessageType.AUDIO.name;
      } else if (type == TYPE_DOC) {
        data.messageType = MessageType.DOC.name;
      } else if (type == TYPE_VOICE_NOTE) {
        data.messageType = MessageType.VOICE_NOTE.name;
      } else {
        data.messageType = MessageType.TEXT.name;
        data.message = encryptData(messageCont.text.trim());
        data.isEncrypt = true;
      }
    } else if (stickerPath.validate().isNotEmpty) {
      data.messageType = MessageType.STICKER.name;
    } else if (type == TYPE_Image) {
      data.messageType = MessageType.IMAGE.name;
    } else {
      if (type == TYPE_LOCATION) {
        data.messageType = MessageType.LOCATION.name;
        data.currentLat = currentLat;
        data.currentLong = currentLong;
      } else if (type == TYPE_VOICE_NOTE) {
        data.messageType = MessageType.VOICE_NOTE.name;
        log(data.messageType);
        log(MessageType.VOICE_NOTE.name);
      } else {
        data.messageType = MessageType.TEXT.name;
        data.message = encryptData(messageCont.text.trim());
        data.isEncrypt = true;
      }
    }

    if (!widget.receiverUser!.blockedTo!.contains(userService.getUserReference(uid: getStringAsync(userId)))) {
      if (await chatRequestService.isRequestsUserExist(widget.receiverUser!.uid!)) {
        print("send normal messge ================");
        sendNormalMessages(data, result: result != null ? result : null, filepath: filepath);
      } else {
        print("send chatRequest ================");
        sendChatRequest(data, result: result != null ? result : null, file: filepath);
      }
      chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: widget.receiverUser!.uid).update(<String, dynamic>{
        "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
      });
      chatMessageService.getContactsDocument(of: widget.receiverUser!.uid, forContact: getStringAsync(userId)).update(<String, dynamic>{
        "lastMessageTime": DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      data.isMessageRead = true;
      chatMessageService.addMessage(data).then((value) {
        messageCont.clear();
        setState(() {});
      });
    }
  }

  void sendNormalMessages(ChatMessageModel data, {FilePickerResult? result, File? filepath}) async {
    if (isFirstMsg) {
      ContactModel data = ContactModel();
      data.uid = widget.receiverUser!.uid;
      data.addedOn = Timestamp.now();
      data.lastMessageTime = DateTime.now().millisecondsSinceEpoch;

      chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: widget.receiverUser!.uid).set(data.toJson()).then((value) {
        //
      }).catchError((e) {
        log(e);
      });
    }
    String? message = '';
    if (data.messageType == TYPE_Image) {
      message = " Sent you " + MessageType.IMAGE.name.capitalizeFirstLetter();
    } else if (data.messageType == TYPE_VIDEO.toUpperCase()) {
      message = " Sent You " + MessageType.VIDEO.name.capitalizeFirstLetter();
    } else if (data.messageType == TYPE_AUDIO) {
      message = " Sent you " + MessageType.AUDIO.name.capitalizeFirstLetter();
    } else if (data.messageType == TYPE_DOC) {
      message = " Sent you " + MessageType.DOC.name.capitalizeFirstLetter();
    } else if (data.messageType == TYPE_VOICE_NOTE) {
      message = " Sent you";
    } else if (data.messageType == TYPE_LOCATION) {
      message = " Sent you " + MessageType.LOCATION.name.capitalizeFirstLetter();
    } else if (data.messageType == TYPE_STICKER) {
      message = " Sent you " + MessageType.STICKER.name.capitalizeFirstLetter();
    } else {
      message = messageCont.text.trim().validate();
    }
    //   notificationService.sendPushNotifications(getStringAsync(userDisplayName), messageCont.text.trim(), receiverPlayerId: widget.receiverUser!.oneSignalPlayerId).catchError(log);
    notificationService
        .sendPushNotifications(getStringAsync(userDisplayName), message, recevierUid: widget.receiverUser!.uid.validate(), receiverPlayerId: widget.receiverUser!.oneSignalPlayerId)
        .catchError((e) {
      print("erooor============${e.toString()}");
    });
    messageCont.clear();
    setState(() {});
    if (data.messageType == MessageType.LOCATION.name) {
      chatMessageService.addLatLong(data, lat: currentLat, long: currentLong);
    }
    await chatMessageService.addMessage(data).then((value) async {
      if (result != null) {
        FileModel fileModel = FileModel();
        fileModel.id = value.id;
        fileModel.file = File(result.files.single.path!);
        fileList.add(fileModel);
        setState(() {});

        // ignore: unnecessary_null_comparison
        await chatMessageService
            .addMessageToDb(senderDoc: value, data: data, sender: sender, user: widget.receiverUser, image: result != null ? File(result.files.single.path!) : null, isRequest: false)
            .then((value) {
          //
        });
      }
    });

    userService.fireStore
        .collection(USER_COLLECTION)
        .doc(getStringAsync(userId))
        .collection(CONTACT_COLLECTION)
        .doc(widget.receiverUser!.uid)
        .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
      log(e);
    });
    userService.fireStore
        .collection(USER_COLLECTION)
        .doc(widget.receiverUser!.uid)
        .collection(CONTACT_COLLECTION)
        .doc(getStringAsync(userId))
        .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
      log(e);
    });
  }

  //endregion

  //region Emoji
  showEmojiBottomsheet() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          child: emojiShowing == true
              ? Container(
                  height: 255,
                  width: context.width(),
                  color: context.cardColor,
                  constraints: BoxConstraints(maxHeight: 500),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
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
              : isStickerShows == true
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
                                  sendMessage(stickerPath: e.stickerPath, type: TYPE_STICKER);
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
                  isStickerShows = false;
                  setState(() {});
                },
                icon: Icon(Icons.emoji_emotions_outlined, size: 28, color: emojiShowing ? primaryColor : textSecondaryColorGlobal.withOpacity(0.7)),
              ),
              IconButton(
                onPressed: () {
                  isStickerShows = true;
                  getSticker();
                  emojiShowing = false;
                  setState(() {});
                },
                icon: Icon(Icons.face, size: 28, color: isStickerShows ? primaryColor : textSecondaryColorGlobal.withOpacity(0.7)),
              ),
            ],
          ),
        )
      ],
    );
  }

  //endregion

  //region Attchment dialog
  showAttachmentDialog() {
    return showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 12),
            margin: EdgeInsets.only(bottom: 78, left: 12, right: 12),
            decoration: BoxDecoration(color: context.scaffoldBackgroundColor, borderRadius: BorderRadius.circular(12)),
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
                      bool res = await MultipleSelectedAttachment(attachedFiles: image, userModel: widget.receiverUser, isImage: true).launch(context);
                      if (res) {
                        finish(context);
                        sendMessage(result: null, filepath: File(result.path.validate()), type: TYPE_Image);
                      }
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: "lblGallery".translate, image: ic_wallpaper, color: Colors.purple.shade400).onTap(() async {
                    //

                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true, allowCompression: true);

                    if (result != null) {
                      List<File> image = [];
                      result.files.map((e) {
                        image.add(File(e.path.validate()));
                      }).toList();
                      // finish(context);
                      bool res = await MultipleSelectedAttachment(attachedFiles: image, userModel: widget.receiverUser, isImage: true).launch(context);
                      if (res) {
                        finish(context);
                        result.files.map((e) {
                          sendMessage(result: result, filepath: File(e.path.validate()), type: TYPE_Image);
                        }).toList();
                      }
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: "lblVideo".translate, image: ic_video_call, color: Colors.pink[400]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video, allowMultiple: true, allowCompression: true);

                    if (result != null) {
                      List<File> videos = [];
                      result.files.map((e) {
                        videos.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      //
                      bool res = await (MultipleSelectedAttachment(attachedFiles: videos, userModel: widget.receiverUser, isVideo: true).launch(context));
                      if (res) {
                        result.files.map((e) {
                          sendMessage(result: result, filepath: File(e.path.validate()), type: TYPE_VIDEO);
                        }).toList();
                      }
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: "lblAudio".translate, image: ic_audio, color: Colors.blue[700]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio, allowCompression: true, allowMultiple: true);
                    if (result != null) {
                      List<File> audio = [];
                      result.files.map((e) {
                        audio.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      //
                      result.files.map((e) {
                        sendMessage(result: result, filepath: File(e.path.validate()), type: TYPE_AUDIO);
                      }).toList();
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: "lblDocument".translate, image: ic_term_condition, color: Colors.blue[700]).onTap(() async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['docx', 'doc', 'txt', 'pdf'], allowMultiple: true);
                    if (result != null) {
                      List<File> docs = [];
                      result.files.map((e) {
                        docs.add(File(e.path.validate()));
                      }).toList();
                      finish(context);
                      //
                      result.files.map((e) {
                        log(e);
                        sendMessage(result: result, filepath: File(e.path.validate()), type: TYPE_DOC);
                      }).toList();
                    } else {
                      // User canceled the picker
                    }
                  }),
                  iconsBackgroundWidget(context, name: "lblLocation".translate, image: ic_location, color: Colors.green.shade500).onTap(
                    () async {
                      determinePosition();
                      showConfirmDialogCustom(
                        context,
                        dialogAnimation: DialogAnimation.SCALE,
                        positiveText: 'lbl_yes'.translate,
                        negativeText: 'lbl_no'.translate,
                        title: "are_you_sure_you_want_to_share_your_current_location".translate,
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

  //endregion

  //region chat request
  void sendChatRequest(ChatMessageModel data, {FilePickerResult? result, File? file}) async {
    String? message = '';
    print("Data=================${data.messageType}");
    if (data.messageType == TYPE_Image.toUpperCase()) {
      message = " Sent you " + MessageType.IMAGE.name.capitalizeFirstLetter();
    } else if (data.messageType == TYPE_VIDEO.toUpperCase()) {
      message = " Sent You " + MessageType.VIDEO.name.capitalizeFirstLetter();
    } else if (data.messageType == TYPE_AUDIO.toUpperCase()) {
      message = " Sent you " + MessageType.AUDIO.name.capitalizeFirstLetter();
    } else if (data.messageType == TYPE_DOC.toUpperCase()) {
      message = " Sent you " + MessageType.DOC.name.capitalizeFirstLetter();
    } else if (data.messageType == TYPE_VOICE_NOTE) {
      message = " Sent you " + MessageType.VOICE_NOTE.name.capitalizeFirstLetter();
    } else if (data.messageType == "LOCATION") {
      message = " Sent you " + MessageType.LOCATION.name.capitalizeFirstLetter();
    } else if (data.messageType == TYPE_STICKER) {
      message = " Sent you " + MessageType.STICKER.name.capitalizeFirstLetter();
    } else {
      message = messageCont.text.trim().validate();
    }
    if (!widget.receiverUser!.oneSignalPlayerId.isEmptyOrNull) {
      notificationService
          .sendPushNotifications(getStringAsync(userDisplayName), message, recevierUid: widget.receiverUser!.uid.validate(), receiverPlayerId: widget.receiverUser!.oneSignalPlayerId)
          .catchError((e) {
      });
      //  notificationService.sendPushNotifications(getStringAsync(userDisplayName), messageCont.text.trim(), receiverPlayerId: widget.receiverUser!.oneSignalPlayerId).catchError(log);
    }

    messageCont.clear();

    ChatRequestModel chatReq = ChatRequestModel();
    chatReq.uid = data.senderId;
    chatReq.profilePic = data.photoUrl;
    chatReq.requestStatus = RequestStatus.Pending.index;
    chatReq.senderIdRef = userService.ref!.doc(sender.uid);
    chatReq.createdAt = DateTime.now().millisecondsSinceEpoch;
    chatReq.updatedAt = DateTime.now().millisecondsSinceEpoch;

    if (await chatRequestService.isRequestUserExist(sender.uid!, widget.receiverUser!.uid.validate())) {
      chatMessageService.addMessage(data).then((value) async {
        if (result != null) {
          FileModel fileModel = FileModel();
          fileModel.id = value.id;
          fileModel.file = file;
          fileList.add(fileModel);

          setState(() {});
        }
        if (file != null) {
          FileModel fileModel = FileModel();
          fileModel.id = value.id;
          fileModel.file = file;
          fileList.add(fileModel);

          //  setState(() {});
        }

        await chatMessageService.addMessageToDb(senderDoc: value, data: data, sender: sender, user: widget.receiverUser, image: file, isRequest: true).then((value) {
          //  setState(() {});
        });
      });
    } else {
      chatRequestService.addChatWithCustomId(sender.uid!, chatReq.toJson(), widget.receiverUser!.uid.validate()).then((value) {}).catchError((e) {
        //
      });
      chatMessageService.addMessage(data).then((value) async {
        if (result != null) {
          FileModel fileModel = FileModel();
          fileModel.id = value.id;
          fileModel.file = File(result.files.single.path!);
          fileList.add(fileModel);

          //  setState(() {});
        }
        await chatMessageService
            .addMessageToDb(
                senderDoc: value,
                data: data,
                sender: sender,
                user: widget.receiverUser,
                image: result != null
                    ? File(result.files.single.path!)
                    : file != null
                        ? file
                        : null,
                isRequest: true)
            .then((value) {
          audioPath = null;
        });
        userService.fireStore
            .collection(USER_COLLECTION)
            .doc(getStringAsync(userId))
            .collection(CONTACT_COLLECTION)
            .doc(widget.receiverUser!.uid)
            .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
          setState(() {});
        });
        userService.fireStore
            .collection(USER_COLLECTION)
            .doc(widget.receiverUser!.uid)
            .collection(CONTACT_COLLECTION)
            .doc(getStringAsync(userId))
            .update({'lastMessageTime': DateTime.now().millisecondsSinceEpoch}).catchError((e) {
          setState(() {});
        });
      });
    }
  }

  Widget getRequestedWidget(bool isRequested) {
    if (isRequested) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          decoration: BoxDecoration(color: context.primaryColor, borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('message_request'.translate, style: boldTextStyle(color: Colors.white)),
              8.height,
              Text('if_you_accept_the_invite'.translate + " ${widget.receiverUser!.name.validate()}" + " " + 'can_message_you'.translate, style: primaryTextStyle(color: Colors.white70)),
              16.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    text: "cancel".translate,
                    color: context.primaryColor,
                    shapeBorder: OutlineInputBorder(borderRadius: radius(), borderSide: BorderSide(color: Colors.white)),
                    onTap: () {
                      chatRequestService.removeDocument(widget.receiverUser!.uid.validate()).then((value) {
                        chatMessageService.deleteChat(senderId: getStringAsync(userId), receiverId: widget.receiverUser!.uid.validate()).then((value) {
                          finish(context);
                          finish(context);
                        }).catchError((e) {
                          log(e.toString());
                        });
                      }).catchError(
                        (e) {
                          log(e.toString());
                        },
                      );
                    },
                  ),
                  16.width,
                  AppButton(
                    text: "accept".translate,
                    textStyle: boldTextStyle(),
                    shapeBorder: OutlineInputBorder(borderRadius: radius(), borderSide: BorderSide(color: Colors.white)),
                    onTap: () async {
                      ContactModel data = ContactModel();
                      data.uid = widget.receiverUser!.uid;
                      data.addedOn = Timestamp.now();
                      data.lastMessageTime = DateTime.now().millisecondsSinceEpoch;

                      chatMessageService.getContactsDocument(of: getStringAsync(userId), forContact: widget.receiverUser!.uid).set(data.toJson()).then((value) {
                        init();
                        toast("invitation_accepted".translate);
                      }).catchError((e) {
                        log(e);
                      });
                      chatRequestService.updateDocument({"requestStatus": RequestStatus.Accepted.index}, widget.receiverUser!.uid).then((value) => null).catchError(
                            (e) {
                              log(e.toString());
                            },
                          );
                      isRequested = false;
                      setState(() {});
                    },
                  ),
                  8.width,
                ],
              )
            ],
          ),
        ),
      );
    }
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
                            if (isBlocked) {
                              unblockDialog(context, receiver: widget.receiverUser!);
                              return;
                            }
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
                          focus: messageFocus,
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
                            sendMessage();
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
                            if (isBlocked.validate(value: false)) {
                              unblockDialog(context, receiver: widget.receiverUser!);
                              return;
                            }
                            showAttachmentDialog();
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
                        sendMessage();
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
                    sendMessage(result: null, filepath: File.fromUri(Uri.parse(audioPath!)), type: TYPE_VOICE_NOTE);
                  },
                ).paddingOnly(bottom: 8, left: 8, right: 8),
            ],
          ),
          if (emojiStickerShowing) showEmojiBottomsheet(),
        ],
      ),
    );
  }
//endregion
}
