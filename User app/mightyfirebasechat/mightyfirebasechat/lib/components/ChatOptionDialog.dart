import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/UserModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../main.dart';

class ChatOptionDialog extends StatefulWidget {
  final bool isGroup;
  final UserModel? receiverUser;

  ChatOptionDialog({this.receiverUser, this.isGroup = false});

  @override
  ChatOptionDialogState createState() => ChatOptionDialogState();
}

class ChatOptionDialogState extends State<ChatOptionDialog> {
  List<String> chatOptionList = ['clear_chat'.translate, 'delete_chat'.translate];

  int currentIndex = 0;

  UserModel sender = UserModel(
    name: getStringAsync(userDisplayName),
    photoUrl: getStringAsync(userPhotoUrl),
    uid: getStringAsync(userId),
    oneSignalPlayerId: getStringAsync(playerId),
  );

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex = getIntAsync(THEME_MODE_INDEX);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(0),
        itemCount: chatOptionList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () async {
              if (chatOptionList[index] == 'clear_chat'.translate) {
                await showConfirmDialogCustom(context,
                    dialogAnimation: DialogAnimation.SCALE,
                    title: "chat_cleared".translate,
                    positiveText: 'lbl_yes'.translate,
                    negativeText: 'lbl_no'.translate,
                    primaryColor: primaryColor, onAccept: (v) {
                  appStore.setLoading(true);
                  if (widget.isGroup) {
                    groupChatMessageService.clearAllMessages(groupDocId: getStringAsync(CURRENT_GROUP_ID)).then((value) {
                      toast("chat_clear".translate);
                      hideKeyboard(context);
                      appStore.setLoading(false);
                      setValue(CURRENT_GROUP_ID, '');
                      finish(context);
                    }).catchError((e) {
                      toast(e);
                    });
                  } else {
                    chatMessageService.clearAllMessages(senderId: sender.uid, receiverId: widget.receiverUser!.uid!).then((value) {
                      toast("chat_clear".translate);
                      hideKeyboard(context);
                      appStore.setLoading(false);
                      finish(context);
                    }).catchError((e) {
                      toast(e);
                    });
                  }
                });
              } else if (chatOptionList[index] == 'delete_chat'.translate) {
                await showConfirmDialogCustom(context,
                    dialogAnimation: DialogAnimation.SCALE,
                    title: "chat_cleared_deleted".translate,
                    positiveText: 'lbl_yes'.translate,
                    negativeText: 'lbl_no'.translate,
                    primaryColor: primaryColor, onAccept: (v) {
                  if (widget.isGroup) {
                    groupChatMessageService.deleteChat(groupDocId: getStringAsync(CURRENT_GROUP_ID)).then((value) {
                      toast("chat_deleted".translate);
                      hideKeyboard(context);
                      appStore.setLoading(false);
                      setValue(CURRENT_GROUP_ID, '');
                      finish(context);
                    }).catchError((e) {
                      toast(e);
                    });
                  } else {
                    chatMessageService.deleteChat(senderId: sender.uid, receiverId: widget.receiverUser!.uid!).then((value) {
                      toast("chat_deleted".translate);
                      chatMessageService.clearAllMessages(senderId: sender.uid, receiverId: widget.receiverUser!.uid!).then((value) => null).catchError((e) {
                        toast(e.toString());
                      });
                      hideKeyboard(context);
                      appStore.setLoading(false);
                      finish(context);
                    }).catchError((e) {
                      toast(e);
                    });
                  }
                });
              } else {
                //
              }
            },
            title: Text(chatOptionList[index], style: primaryTextStyle()),
          );
        },
      ),
    );
  }
}
