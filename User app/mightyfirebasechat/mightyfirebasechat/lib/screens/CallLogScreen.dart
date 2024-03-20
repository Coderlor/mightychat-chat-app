import 'package:chat/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/Permissions.dart';
import '../../models/LogModel.dart';
import '../../models/UserModel.dart';
import '../../services/localDB/LogRepository.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../../utils/CallFunctions.dart';
import 'NewChatScreen.dart';

class CallLogScreen extends StatefulWidget {
  @override
  _CallLogScreenState createState() => _CallLogScreenState();
}

class _CallLogScreenState extends State<CallLogScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<LogModel>?>(
        future: LogRepository.getLogs(),
        builder: (context, snap) {
          if (snap.hasData) {
            if (snap.data!.length == 0) {
              return noDataFound(text: 'lblNoLogs'.translate);
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 0, bottom: 80),
              itemCount: snap.data!.length,
              itemBuilder: (context, index) {
                LogModel data = snap.data![index];
                print("log model details=${data.toJson().toString()}");

                bool hasDialled = data.callStatus == CALLED_STATUS_DIALLED;

                return InkWell(
                  onLongPress: () async {
                    bool? res = await showConfirmDialog(context, 'log_confirmation'.translate, positiveText: 'lbl_yes'.translate, negativeText: 'lbl_no'.translate);
                    if (res ?? false) {
                      LogRepository.deleteLogs(data.logId);
                      setState(() {});
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        cachedImage(hasDialled ? data.receiverPic.validate() : data.callerPic.validate(), height: 45, width: 45, fit: BoxFit.cover).cornerRadiusWithClipRRect(25).onTap(() {}),
                        15.width,
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hasDialled ? data.receiverName.validate() : data.callerName.validate(), style: boldTextStyle(letterSpacing: 0.5)),
                            5.height,
                            Row(
                              children: [
                                getCallStatusIcon(data.callStatus),
                                5.width,
                                Text('${formatDateString(data.timestamp!)}', style: primaryTextStyle()),
                              ],
                            ),
                          ],
                        ).expand(),
                        data.callType.validate() == "voice"
                            ? IconButton(
                                icon: Icon(FontAwesome.phone, color: secondaryColor, size: 18),
                                onPressed: () async {
                                  print("callog=============== single${data.toJson().toString()}");
                                  var receiverId = data.receiverId == getStringAsync(userId) ? data.callerId : data.receiverId;
                                  await userService.getUserById(val: receiverId).then((value) async {
                                    print("onesignal player id of receiver ${value.oneSignalPlayerId}");
                                    UserModel receiverData = UserModel(
                                      name: value.name,
                                      photoUrl: value.photoUrl,
                                      uid: value.uid,
                                      oneSignalPlayerId: value.oneSignalPlayerId,
                                    );
                                    UserModel sender = UserModel(
                                      name: getStringAsync(userDisplayName),
                                      photoUrl: getStringAsync(userPhotoUrl),
                                      uid: getStringAsync(userId),
                                      oneSignalPlayerId: getStringAsync(playerId),
                                    );
                                    return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.voiceDial(context: context, from: sender, to: receiverData) : {};
                                  });
                                },
                              )
                            : IconButton(
                                icon: Icon(FontAwesome.video_camera, color: secondaryColor, size: 18),
                                onPressed: () async {
                                  print("callog=============== single${data.toJson().toString()}");
                                  var receiverId = data.receiverId == getStringAsync(userId) ? data.callerId : data.receiverId;

                                  await userService.getUserById(val: receiverId).then((value) async {
                                    print("onesignal player id of receiver ${value.oneSignalPlayerId}");
                                    UserModel receiverData = UserModel(name: value.name, photoUrl: value.photoUrl, oneSignalPlayerId: value.oneSignalPlayerId, uid: value.uid);
                                    UserModel sender = UserModel(
                                        name: getStringAsync(userDisplayName), photoUrl: getStringAsync(userPhotoUrl), uid: getStringAsync(userId), oneSignalPlayerId: getStringAsync(playerId));
                                    print("receiver data============${receiverData.toJson().toString()}");
                                    print("sender data============${sender.toJson().toString()}");
                                    return await Permissions.cameraAndMicrophonePermissionsGranted() ? CallFunctions.dial(context: context, from: sender, to: receiverData) : {};
                                  });
                                },
                              ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return snapWidgetHelper(snap);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Image.asset('assets/Icons/ic_call.png', width: 25, height: 25, color: Colors.white),
        onPressed: () async {
          NewChatScreen(isCall: true).launch(context).then((value) {
            setState(() {});
          });
        },
      ),
    );
  }
}
