import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/Permissions.dart';
import '../../main.dart';
import '../../models/CallModel.dart';
import '../../models/LogModel.dart';
import '../../screens/AgoraVideoCallScreen.dart';
import '../../screens/AgoraVoiceCallScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../services/localDB/LogRepository.dart';

class PickUpScreen extends StatefulWidget {
  final CallModel? callModel;

  PickUpScreen({this.callModel});

  @override
  _PickUpScreenState createState() => _PickUpScreenState();
}

class _PickUpScreenState extends State<PickUpScreen> {
  bool isCalledMissed = true;

  addToLocalStorage({String? status}) {
    LogModel callLog = LogModel(
        callerName: widget.callModel!.callerName,
        callerPic: widget.callModel!.callerPhotoUrl,
        callStatus: status,
        callerId: widget.callModel!.callerId,
        receiverId: widget.callModel!.receiverId,
        receiverName: widget.callModel!.receiverName,
        receiverPic: widget.callModel!.receiverPhotoUrl,
        timestamp: DateTime.now().toString(),
        callType: widget.callModel!.callType);
    LogRepository.addLogs(callLog);
  }

  @override
  void dispose() {
    if (isCalledMissed) {
      addToLocalStorage(status: CALLED_STATUS_MISSED);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //  Container(color: Colors.black54),
          Container(color: primaryColor),
          Container(
            height: context.height() * 0.35,
            color: primaryColor,
            width: context.width(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: context.statusBarHeight + 40),
                widget.callModel!.callerPhotoUrl.isEmptyOrNull
                    ? CircleAvatar(
                        backgroundColor: whiteColor,
                        radius: 60,
                        child: Text(widget.callModel!.callerName.validate()[0], style: primaryTextStyle(size: 34, color: primaryColor)),
                      )
                    : cachedImage(widget.callModel!.callerPhotoUrl, height: 120, width: 120, fit: BoxFit.cover, radius: 80).cornerRadiusWithClipRRect(80),
                10.height,
                Text(widget.callModel!.callerName.validate(), style: primaryTextStyle(color: Colors.white, size: 22)),
                10.height,
                Text('Incoming...', style: secondaryTextStyle(size: 16, color: Colors.white60)),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.call_end, color: Colors.redAccent),
                    onPressed: () async {
                      isCalledMissed = false;
                      setState(() {});
                      addToLocalStorage(status: CALLED_STATUS_RECEIVED);
                      await callService.endCall(callModel: widget.callModel!);
                    },
                  ),
                ),
                6.width,
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.call, color: Colors.green),
                    onPressed: () async {
                      addToLocalStorage(status: CALLED_STATUS_RECEIVED);
                      isCalledMissed = false;
                      setState(() {});

                      if (widget.callModel!.isVoice!) {
                        if (await Permissions.cameraAndMicrophonePermissionsGranted()) AgoraVoiceCallScreen(callModel: widget.callModel).launch(context);
                      } else {
                        if (await Permissions.cameraAndMicrophonePermissionsGranted()) AgoraVideoCallScreen(callModel: widget.callModel).launch(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
