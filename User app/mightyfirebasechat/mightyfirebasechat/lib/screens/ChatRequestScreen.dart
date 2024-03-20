import 'package:chat/utils/AppCommon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/UserProfileImageDialog.dart';
import '../main.dart';
import '../models/ChatRequestModel.dart';
import '../models/UserModel.dart';
import '../utils/AppColors.dart';
import '../utils/Appwidgets.dart';
import 'ChatScreen.dart';
import 'PickupLayout.dart';

class ChatRequestScreen extends StatefulWidget {
  @override
  _ChatRequestScreenState createState() => _ChatRequestScreenState();
}

class _ChatRequestScreenState extends State<ChatRequestScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      child: WillPopScope(
        onWillPop: () {
          finish(context, true);
          return Future.value(true);
        },
        child: Scaffold(
          appBar: appBarWidget("chat_request".translate,
              textColor: Colors.white,
              backWidget: BackButton(
                color: white,
                onPressed: () {
                  finish(context, true);
                },
              )),
          body: StreamBuilder<List<ChatRequestModel>>(
              stream: chatRequestService.getChatRequestList(),
              builder: (context, snap) {
                print("Stream state: ${snap.connectionState}");
                if (snap.hasData) {
                  return snap.data!.isNotEmpty
                      ? ListView.builder(
                          itemCount: snap.data!.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            ChatRequestModel? data = snap.data![index];
                            return FutureBuilder<UserModel?>(
                              future: getUser(data.senderIdRef!),
                              builder: (context, value) {
                                if (value.hasError) {
                                  return Text(value.error.toString(), style: primaryTextStyle());
                                } else {
                                  if (value.hasData && value.data != null) {
                                    return SettingItemWidget(
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                      leading: value.data!.photoUrl!.isEmpty
                                          ? Container(
                                              height: 50,
                                              width: 50,
                                              padding: EdgeInsets.all(10),
                                              color: primaryColor,
                                              child: Text(value.data!.name.validate()[0].capitalizeFirstLetter(), style: secondaryTextStyle(color: Colors.white)).center().fit(),
                                            ).cornerRadiusWithClipRRect(50).onTap(() {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return UserProfileImageDialog(data: value.data);
                                                },
                                              );
                                            })
                                          : Hero(
                                              tag: value.data!.uid.validate(),
                                              child: cachedImage(value.data!.photoUrl.validate(), height: 50, width: 50, fit: BoxFit.cover).cornerRadiusWithClipRRect(50),
                                            ).onTap(() {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return UserProfileImageDialog(data: value.data);
                                                },
                                              );
                                            }),
                                      title: value.data!.name.validate(),
                                      onTap: () async {
                                        ChatScreen(value.data!, isFromRequest: true).launch(context);
                                      },
                                    );
                                  }
                                }
                                return snapWidgetHelper(value, loadingWidget: Offstage());
                              },
                            );
                          },
                        )
                      : noDataFound().center();
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  print("waiting state============");
                  return Container(
                    width: 100,
                    height: 100,
                    child: Loader(),
                  );
                }

                return snapWidgetHelper(snap, loadingWidget: Loader(valueColor: AlwaysStoppedAnimation<Color>(primaryColor)), errorWidget: SizedBox().center());
              }),
        ),
      ),
    );
  }

  Future<UserModel?> getUser(DocumentReference data) async {
    return await data.get().then((value) => UserModel.fromJson(value.data() as Map<String, dynamic>)).catchError((e) {
      log(e);
      return e;
    });
  }
}
