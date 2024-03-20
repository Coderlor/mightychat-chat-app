import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/UserModel.dart';
import '../../screens/ChatScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../utils/Appwidgets.dart';
import '../utils/CallFunctions.dart';
import 'Permissions.dart';

class UserListComponent extends StatefulWidget {
  final AsyncSnapshot<List<UserModel>>? snap;
  final bool isGroupCreate;
  final bool isAddParticipant;
  final List<dynamic>? data;
  final bool? isCall;

  UserListComponent({this.snap, this.isGroupCreate = false, this.isAddParticipant = false, this.data, this.isCall = false});

  @override
  UserListComponentState createState() => UserListComponentState();
}

class UserListComponentState extends State<UserListComponent> {
  List<UserModel> selectedList = [];
  List<String> selected = [];
  List<dynamic> existingMembersList = [];

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (widget.data != null) {
      existingMembersList = widget.data!;
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        if (widget.snap!.data!.isNotEmpty)
          ListView.builder(
            physics: widget.isGroupCreate ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
            itemCount: widget.snap!.data!.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              UserModel data = widget.snap!.data![index];
              if (data.uid == loginStore.mId) {
                return 0.height;
              }
              return Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    (data.photoUrl == null || data.photoUrl!.isEmpty)
                        ? Hero(
                            tag: data.uid.validate(),
                            child: Container(
                              height: 50,
                              width: 50,
                              padding: EdgeInsets.all(10),
                              color: primaryColor,
                              child: Text(data.name.validate()[0].toUpperCase(), style: secondaryTextStyle(color: Colors.white)).center().fit(),
                            ).cornerRadiusWithClipRRect(50),
                          )
                        : cachedImage(data.photoUrl.validate(), width: 50, height: 50, fit: BoxFit.cover).cornerRadiusWithClipRRect(80),
                    12.width,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${data.name.validate().capitalizeFirstLetter()}', style: primaryTextStyle()).expand(),
                            if (selected.contains(data.uid)) Icon(Icons.check_circle_outlined, color: primaryColor)
                          ],
                        ),
                        Text('${data.userStatus.validate()}', style: secondaryTextStyle()),
                      ],
                    ).expand(),
                    widget.isCall!
                        ? Row(
                            children: [
                              IconButton(
                                icon: Icon(FontAwesome.phone, color: secondaryColor, size: 18),
                                onPressed: () async {
                                  UserModel receiverData = UserModel(
                                    name: data.name,
                                    uid: data.uid,
                                    oneSignalPlayerId: data.oneSignalPlayerId,
                                    photoUrl: data.photoUrl,
                                  );
                                  UserModel sender = UserModel(
                                    name: getStringAsync(userDisplayName),
                                    photoUrl: getStringAsync(userPhotoUrl),
                                    uid: getStringAsync(userId),
                                    oneSignalPlayerId: getStringAsync(playerId),
                                  );
                                  return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.voiceDial(context: context, from: sender, to: receiverData) : {};
                                },
                              ),
                              IconButton(
                                icon: Icon(FontAwesome.video_camera, color: secondaryColor, size: 18),
                                onPressed: () async {
                                  UserModel receiverData = UserModel(
                                    name: data.name,
                                    uid: data.uid,
                                    oneSignalPlayerId: data.oneSignalPlayerId,
                                    photoUrl: data.photoUrl,
                                  );
                                  UserModel sender = UserModel(
                                    name: getStringAsync(userDisplayName),
                                    photoUrl: getStringAsync(userPhotoUrl),
                                    uid: getStringAsync(userId),
                                    oneSignalPlayerId: getStringAsync(playerId),
                                  );
                                  return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.dial(context: context, from: sender, to: receiverData) : {};
                                },
                              ),
                            ],
                          )
                        : widget.isAddParticipant
                            ? existingMembersList.contains(data.uid.toString())
                                ? Icon(Icons.check_circle_outline)
                                : Offstage()
                            : Offstage()
                  ],
                ),
              ).onTap(() {
                if (widget.isGroupCreate) {
                  if (!selected.contains(data.uid.toString())) {
                    if (widget.isAddParticipant) {
                      log(existingMembersList);
                      if (existingMembersList.contains(data.uid.toString())) {
                        toast('lblAlreadyExist'.translate);
                      } else {
                        selected.add(data.uid.toString());
                        selectedList.add(data);
                      }
                    } else {
                      selected.add(data.uid.toString());
                      selectedList.add(data);
                    }
                  } else {
                    selected.remove(data.uid.toString());
                    selectedList.remove(data);
                  }
                  setState(() {});
                  setValue(selectedMember, selected);
                } else {
                  if (widget.isCall == false) {
                    finish(context);
                    ChatScreen(data).launch(context);
                  }
                }
              });
            },
          ).paddingTop(selectedList.isNotEmpty ? 100 : 0),
        if (widget.snap!.data == null) noDataFound(text: 'no_user_found'.translate),
        if (widget.isGroupCreate && selected.isNotEmpty)
          Container(
            height: 80,
            width: context.width(),
            decoration: BoxDecoration(
              color: context.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 0.0,
                  offset: Offset(0.0, 0.0),
                ),
              ],
            ),
            child: HorizontalList(
              reverse: selectedList.length > 5 ? true : false,
              itemCount: selectedList.length,
              itemBuilder: (_, i) {
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topRight,
                  children: [
                    selectedList[i].photoUrl!.isEmpty
                        ? Container(
                            height: 50,
                            width: 50,
                            padding: EdgeInsets.all(10),
                            color: primaryColor,
                            child: Text(selectedList[i].name.validate()[0].toUpperCase(), style: secondaryTextStyle(color: Colors.white)).center().fit(),
                          ).cornerRadiusWithClipRRect(50)
                        : cachedImage(selectedList[i].photoUrl.validate(), height: 50, width: 50, fit: BoxFit.cover).cornerRadiusWithClipRRect(25),
                    Positioned(
                      top: -3,
                      child: Icon(Icons.cancel_rounded, size: 20, color: context.iconColor).onTap(() {
                        selected.remove(selectedList[i].uid.toString());
                        selectedList.remove(selectedList[i]);
                        setValue(selectedMember, selected);
                        setState(() {});
                      }),
                    )
                  ],
                ).paddingAll(6);
              },
            ),
          ),
      ],
    );
  }
}
