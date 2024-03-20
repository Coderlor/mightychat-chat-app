import 'dart:math';

import 'package:chat/utils/AppCommon.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/CallModel.dart';
import '../../models/LogModel.dart';
import '../../models/UserModel.dart';
import '../../screens/AgoraVideoCallScreen.dart';
import '../../screens/AgoraVoiceCallScreen.dart';
import '../../services/localDB/LogRepository.dart';
import '../../utils/AppConstants.dart';

class CallFunctions {
  static dial({required context, required UserModel from, required UserModel to}) async {
    CallModel callModel = CallModel(
        callerId: from.uid,
        callerName: from.name,
        callerPhotoUrl: from.photoUrl,
        channelId: Random().nextInt(1000).toString(),
        receiverId: to.uid,
        receiverName: to.name,
        receiverPhotoUrl: to.photoUrl,
        callType: "video",
        isVoice: false);

    LogModel log = LogModel(
      callerId: from.uid,
      receiverId: to.uid,
      callerName: from.name,
      callerPic: from.photoUrl,
      callStatus: CALLED_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.photoUrl,
      callType: "video",
      timestamp: DateTime.now().toString(),
    );

    bool callMade = await callService.makeCall(callModel: callModel);
    callModel.hasDialed = true;
    if (callMade) {
      notificationService.sendPushNotifications("${from.name}", 'lbl_video_calling_you'.translate, receiverPlayerId: to.oneSignalPlayerId);
      print("addLogs============ called from dial callFUnctions${log.toJson().toString()}");
      LogRepository.addLogs(log);
      AgoraVideoCallScreen(callModel: callModel).launch(context);
    }
  }

  static voiceDial({required context, required UserModel from, required UserModel to}) async {
    print("to-----${to.toJson()}");
    CallModel callModel = CallModel(
      callerId: from.uid,
      callerName: from.name,
      callerPhotoUrl: from.photoUrl,
      channelId: Random().nextInt(1000).toString(),
      receiverId: to.uid,
      receiverName: to.name,
      receiverPhotoUrl: to.photoUrl,
      callStatus: CALLED_STATUS_DIALLED,
      callType: "voice",
      isVoice: true,
    );

    LogModel log = LogModel(
      callerName: from.name,
      callerPic: from.photoUrl,
      callerId: from.uid,
      receiverId: to.uid,
      callStatus: CALLED_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.photoUrl,
      callType: "voice",
      timestamp: DateTime.now().toString(),
    );

    print("object-------${callModel.toJson()}");
    // chatMessageService.addToCallContacts(receiverId: to.uid, senderId: from.uid,callModel: callModel);

    bool callMade = await callService.makeCall(callModel: callModel, isVoiceCall: true);
    callModel.hasDialed = true;
    if (callMade) {
      //add calls to local db
      notificationService.sendPushNotifications("${from.name}", 'lbl_video_calling_you'.translate, receiverPlayerId: to.oneSignalPlayerId);
      print("addLogs============ called from voice");
      LogRepository.addLogs(log);
      //  chatMessageService.addToCallContacts(receiverId: to.uid, senderId: from.uid);

      AgoraVoiceCallScreen(callModel: callModel).launch(context);
    }
  }
}
