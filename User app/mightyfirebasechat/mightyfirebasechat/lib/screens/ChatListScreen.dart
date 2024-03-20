import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/ChatOptionDialog.dart';
import '../../components/LastMessageContainer.dart';
import '../../components/UserProfileImageDialog.dart';
import '../../main.dart';
import '../../models/ContactModel.dart';
import '../../models/UserModel.dart';
import '../../screens/DashboardScreen.dart';
import '../../screens/GroupChat/GroupProfileImageDailog.dart';
import '../../screens/NewChatScreen.dart';
import '../../screens/PickupLayout.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../utils/AppImages.dart';
import 'ChatRequestScreen.dart';
import 'ChatScreen.dart';
import 'GroupChat/GroupChatScreen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  ChatListScreenState createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> with WidgetsBindingObserver {
  String id = '';
  bool autoFocus = false;
  String searchCont = "";

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    WidgetsBinding.instance.addObserver(this);
    Map<String, dynamic> presenceStatusTrue = {
      'isPresence': true,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    };
    await userService.updateUserStatus(presenceStatusTrue, getStringAsync(userId));
    id = getStringAsync(userId);
    setState(() {});

    LiveStream().on(SEARCH_KEY, (s) {
      searchCont = s as String;
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Stream<List<dynamic>> group({String? searchText}) {
    return fireStore.collection('group').where('searchCase', arrayContains: searchText.validate().isEmpty ? null : searchText!.toLowerCase()).snapshots().map((x) {
      return x.docs.map((y) {
        return y.data();
      }).toList();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Map<String, dynamic> presenceStatusFalse = {
      'isPresence': false,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    };
    if (state == AppLifecycleState.detached) {
      userService.updateUserStatus(presenceStatusFalse, getStringAsync(userId));
    }

    if (state == AppLifecycleState.paused) {
      userService.updateUserStatus(presenceStatusFalse, getStringAsync(userId));
    }
    if (state == AppLifecycleState.resumed) {
      Map<String, dynamic> presenceStatusTrue = {
        'isPresence': true,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      };

      userService.updateUserStatus(presenceStatusTrue, getStringAsync(userId));
    }
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(SEARCH_KEY);
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                StreamBuilder<int>(
                  stream: chatRequestService.getRequestLength(),
                  builder: (context, snap) {
                    //chat request
                    if (snap.hasData) {
                      if (snap.data != 0) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            8.height,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(ic_messages, height: 25, width: 25, color: primaryColor),
                                16.width,
                                Text('new_chat_request'.translate, style: primaryTextStyle(size: 14)).expand(),
                                Container(
                                  decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: primaryColor),
                                  padding: EdgeInsets.all(6),
                                  child: Text(snap.data.validate().toString(), style: primaryTextStyle(color: Colors.white)),
                                )
                              ],
                            ).paddingSymmetric(vertical: 8, horizontal: 16).onTap(() async {
                             await ChatRequestScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide);
                              setState(() {});
                            }),
                            Divider(color: context.dividerColor)
                          ],
                        );
                      }
                    }

                    return snapWidgetHelper(snap, loadingWidget: SizedBox());
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: chatMessageService.fetchContacts(userId: getStringAsync(userId)),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Text(snapshot.error.toString(), style: boldTextStyle()).center();
                    if (snapshot.hasData) {
                      messageRequestStore.addContactData(
                        data: snapshot.data!.docs.map((e) => ContactModel.fromJson(e.data() as Map<String, dynamic>)).toList(),
                        isClear: true,
                      );

                      if (snapshot.data!.docs.isNotEmpty) {
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.only(bottom: 65,top:8),
                          itemBuilder: (context, index) {
                            ContactModel contact = ContactModel.fromJson(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildGroupItemWidget(contact: contact).visible(contact.groupRefUrl != null),
                                buildChatItemWidget(contact: contact).visible(contact.uid != getStringAsync(userId)),
                              ],
                            );
                          },
                        );
                      } else {
                        return noDataFound();
                      }
                    }
                    return snapWidgetHelper(snapshot, loadingWidget: Loader().center());
                  },
                ).expand(),
              ],
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Image.asset(ic_messages, width: 25, height: 25, color: Colors.white),
          backgroundColor: primaryColor,
          onPressed: () {
            isSearch = false;
            hideKeyboard(context);
            setState(() {});

            NewChatScreen().launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 300.milliseconds);
          },
        ),
      ),
    );
  }

  StreamBuilder<List<UserModel>> buildChatItemWidget({required ContactModel contact}) {
    return StreamBuilder(
      stream: chatMessageService.getUserDetailsById(id: contact.uid, searchText: searchCont),
      builder: (context, snap) {
        if (snap.hasData) {
          return ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(0),
            itemCount: snap.data!.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              UserModel data = snap.data![index];

              if (snap.data!.length == 0) {
                return noDataFound().center();
              }
              return InkWell(
                onTap: () async {
                  if (id != data.uid) {
                    hideKeyboard(context);

                    bool? res = await ChatScreen(data).launch(context);
                    if (res != null || res == null) {
                      await chatMessageService.setUnReadStatusToTrue(senderId: sender.uid!, receiverId: data.uid!).then((value) {});
                      setState(() {});
                    }
                  }
                },
                onLongPress: () async {
                  await showInDialog(context, builder: (p0) {
                    return ChatOptionDialog(receiverUser: data);
                  }, contentPadding: EdgeInsets.zero, dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM);
                  setState(() {});
                },
                child: Row(
                  children: [
                    data.photoUrl!.isEmpty
                        ? noProfileImageFound(height: 45, width: 45).cornerRadiusWithClipRRect(50).onTap(() {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return UserProfileImageDialog(data: data);
                              },
                            );
                          })
                        : Hero(
                            tag: data.uid.validate(),
                            child: cachedImage(data.photoUrl.validate(), height: 45, width: 45, fit: BoxFit.cover).cornerRadiusWithClipRRect(50),
                          ).onTap(() {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return UserProfileImageDialog(data: data);
                              },
                            );
                          }),
                    10.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(data.name.validate().capitalizeFirstLetter(), style: primaryTextStyle(), maxLines: 1, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis).expand(),
                            StreamBuilder<int>(
                              stream: chatMessageService.getUnReadCount(senderId: getStringAsync(userId), receiverId: contact.uid.validate()),
                              builder: (context, snap) {
                                if (snap.hasData) {
                                  print("snapdata${snap.data}");
                                  if (snap.data != 0) {
                                    //chatMessageService.fetchForMessageCount(loginStore.mId);
                                    return Container(
                                      height: 18,
                                      width: 18,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: primaryColor),
                                      child: Text(snap.data.validate().toString(), style: secondaryTextStyle(size: 12, color: Colors.white)).center(),
                                    );
                                  }
                                }
                                return Offstage();
                              },
                            ),
                          ],
                        ),
                        2.height,
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LastMessageContainer(
                              stream: chatMessageService.fetchLastMessageBetween(senderId: getStringAsync(userId), receiverId: contact.uid!),
                            ),
                          ],
                        ),
                      ],
                    ).expand(),
                  ],
                ).paddingSymmetric(horizontal: 16, vertical: 8),
              );
            },
          );
        }
        return snapWidgetHelper(snap, loadingWidget: Offstage()).center();
      },
    );
  }

  StreamBuilder<List<dynamic>> buildGroupItemWidget({required ContactModel contact}) {
    return StreamBuilder(
      stream: group(searchText: searchCont),
      builder: (_, snap) {
        if (snap.hasData) {
          return snap.data != null
              ? ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  itemCount: snap.data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    var members = snap.data![index]['membersList'];
                    var data;
                    if (members != null)
                      members.map((e) {
                        if (e.contains(getStringAsync(userId)) && contact.groupRefUrl == snap.data![index]['id']) {
                          if (snap.data != null) data = snap.data![index];
                        }
                      }).toList();
                    return data != null
                        ? InkWell(
                            onTap: () async {
                              setValue(CURRENT_GROUP_ID, data['id']);

                              //  bool? res = await GroupChatScreen(groupChatId: data['id'], groupName: data['name'], groupData: data).launch(context);
                              GroupChatScreen(groupChatId: data['id'], groupName: data['name'], groupData: data).launch(context);
                              await groupChatMessageService.setUnReadStatusToTrue(groupDocId: data['id']).then((value) {});
                              // if (res != null || res == null) {
                              //
                              //   setState(() {});
                              // }
                            },
                            onLongPress: () async {
                              setValue(CURRENT_GROUP_ID, data['id']);
                              await showInDialog(
                                context,
                                builder: (p0) {
                                  return ChatOptionDialog(isGroup: true);
                                },
                                contentPadding: EdgeInsets.zero,
                                dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
                              );
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      noProfileImageFound(height: 45, width: 45, isGroup: true).cornerRadiusWithClipRRect(50),
                                      data['photoUrl'] == null
                                          ? noProfileImageFound(height: 45, width: 45, isGroup: true).cornerRadiusWithClipRRect(50).onTap(() {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return GroupProfileImageDailog(data: data);
                                                },
                                              );
                                            })
                                          : Hero(
                                              tag: data['photoUrl'],
                                              child: Image.network(
                                                data['photoUrl'],
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) {
                                                  return noProfileImageFound(height: 45, width: 45, isGroup: true);
                                                },
                                              ).cornerRadiusWithClipRRect(50),
                                            ).onTap(() {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return GroupProfileImageDailog(data: data);
                                                },
                                              );
                                            }),
                                    ],
                                  ),
                                  10.width,
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            data['name'].toString().capitalizeFirstLetter(),
                                            style: primaryTextStyle(),
                                            maxLines: 1,
                                            textAlign: TextAlign.start,
                                            overflow: TextOverflow.ellipsis,
                                          ).expand(),
                                          2.width,
                                          StreamBuilder<int>(
                                            stream: groupChatMessageService.getUnReadCount(currentUser: getStringAsync(userId), groupDocId: data['id']),
                                            builder: (context, snap) {
                                              if (snap.hasData) {
                                                print("unread count for groups====== ${snap.data}");
                                                if (snap.data != 0) {
                                                  //chatMessageService.fetchForMessageCount(loginStore.mId);
                                                  return Container(
                                                    height: 18,
                                                    width: 18,
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: primaryColor),
                                                    child: Text(snap.data.validate().toString(), style: secondaryTextStyle(size: 12, color: Colors.white)).center(),
                                                  );
                                                }
                                              }
                                              return Offstage();
                                            },
                                          ),
                                        ],
                                      ),
                                      2.height,
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          LastMessageContainer(
                                            stream: groupChatMessageService.fetchLastMessageBetween(
                                              groupDocId: data['id'],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ).expand(),
                                ],
                              ),
                            ),
                          )
                        : SizedBox();
                  },
                )
              : noDataFound();
        }
        return snapWidgetHelper(snap, loadingWidget: Offstage());
      },
    );
  }
}
