import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../models/CallModel.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import '../utils/AppColors.dart';

// ignore: must_be_immutable
class AgoraVoiceCallScreen extends StatefulWidget {
  final CallModel? callModel;

  AgoraVoiceCallScreen({this.callModel});

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<AgoraVoiceCallScreen> {
  bool isJoined = false;
  bool openMicrophone = false;
  bool enableSpeakerphone = false;
  String callStatus = 'calling...';
  late RtcEngine? _engine;

  final _infoStrings = <String>[];
  final _users = <int>[];
  late final RtcEngineEventHandler _rtcEngineEventHandler;

  @override
  void initState() {
    super.initState();
    init();
  }

  late StreamSubscription callStreamSubcription;
  init() async {
    addPostFrameCallBack();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    _users.clear();
    _engine!.unregisterEventHandler(_rtcEngineEventHandler);
    await _engine!.leaveChannel();
    await _engine!.release();
    callStreamSubcription.cancel();
  }

  Future<void> initialize() async {
    if (appSettingStore.agoraCallId.isEmptyOrNull) {
      setState(() {
        _infoStrings.add('videoAppId missing, please provide your videoAppId in settings.dart');
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }

    await _initAgoraRtcEngine();
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine?.initialize(const RtcEngineContext(
      appId: agoraVideoCallId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    await _engine?.joinChannel(
      token: "", //TODO  need to pass token as currently not available
      channelId: widget.callModel!.channelId!,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    _rtcEngineEventHandler = RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        setState(() {
          final info = 'onJoinChannel: ${connection.toJson()}, elapsed: $elapsed';
          _infoStrings.add(info);
          isJoined = true;
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        setState(() {
          final info = 'userJoined: $remoteUid';
          _infoStrings.add(info);
          callStatus = 'Connected';
          _users.add(remoteUid);
        });
      },
      onError: (ErrorCodeType err, String msg) {
        debugPrint('[onError] err: $err, msg: $msg');
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        callService.endCall(callModel: widget.callModel!);
        setState(() {
          final info = 'userOffline: $remoteUid';
          _infoStrings.add(info);
          _users.remove(remoteUid);
        });
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      },
    );
    _engine?.registerEventHandler(_rtcEngineEventHandler);

    await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine?.enableVideo();
    await _engine?.startPreview();
  }


  void addPostFrameCallBack() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      callStreamSubcription = callService.callStream(uid: getStringAsync(userId)).listen((DocumentSnapshot ds) {
        switch (ds.data()) {
          case null:
            finish(context);
            break;

          default:
            break;
        }
      });
      //
    });
  }

  _switchMicrophone() {
    _engine!.enableLocalAudio(openMicrophone).then((value) {
      setState(() {
        openMicrophone = !openMicrophone;
      });
    }).catchError((err) {
      log('enableLocalAudio $err');
    });
  }

  _switchSpeakerphone() {
    _engine!.setEnableSpeakerphone(enableSpeakerphone).then((value) {
      log("enableSpeakerphone" + enableSpeakerphone.toString());
      setState(() {
        enableSpeakerphone = !enableSpeakerphone;
      });
    }).catchError((err) {
      log('setEnableSpeakerphone $err');
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget getCallScreen({bool? value}) {
      if (value!) {
        print("if part executed");
        return Container(
          color: primaryColor,
          height: context.height(),
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    width: context.width(),
                    padding: EdgeInsets.only(top: context.statusBarHeight + 8, bottom: 20),
                    color: context.primaryColor,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        widget.callModel!.receiverPhotoUrl.isEmptyOrNull
                            ? CircleAvatar(
                                backgroundColor: whiteColor,
                                radius: 28,
                                child: Text(
                                  widget.callModel!.receiverName.validate()[0],
                                  style: primaryTextStyle(size: 22, color: primaryColor),
                                ),
                              )
                            : cachedImage(widget.callModel!.receiverPhotoUrl, height: 110, width: 110, fit: BoxFit.fill, radius: 70).cornerRadiusWithClipRRect(70),
                        8.height,
                        Text(widget.callModel!.receiverName!, style: primaryTextStyle(color: Colors.white, size: 22)),
                        8.height,
                        Text(callStatus, style: secondaryTextStyle(color: Colors.white70, size: 16)),
                      ],
                    ),
                  ),
                  Container(
                    height: context.height() * 0.60,
                    width: context.width(),
                    color: Colors.black,
                    child: cachedImage(widget.callModel!.receiverPhotoUrl, fit: BoxFit.fill),
                  ),
                ],
              ),
              Positioned(
                bottom: 30,
                child: Container(
                  width: context.width(),
                  padding: EdgeInsets.only(bottom: 8, top: 20),
                  color: context.primaryColor,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RawMaterialButton(
                        onPressed: _switchSpeakerphone,
                        child: Icon(Octicons.unmute, color: Colors.white, size: 24.0),
                        shape: CircleBorder(),
                        elevation: 0,
                        fillColor: enableSpeakerphone ? Colors.white38 : context.primaryColor,
                        padding: EdgeInsets.all(16.0),
                      ),
                      RawMaterialButton(
                        onPressed: () => callService.endCall(callModel: widget.callModel!),
                        child: Icon(Icons.call_end, color: Colors.white, size: 35.0),
                        shape: CircleBorder(),
                        elevation: 2.0,
                        fillColor: Colors.redAccent,
                        padding: EdgeInsets.all(15.0),
                      ),
                      RawMaterialButton(
                        onPressed: _switchMicrophone,
                        child: Icon(MaterialIcons.mic_off, color: Colors.white, size: 24.0),
                        shape: CircleBorder(),
                        elevation: 0.0,
                        fillColor: openMicrophone ? Colors.white38 : context.primaryColor,
                        padding: EdgeInsets.all(16.0),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        print("else part executed");
        return Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: context.height() * 0.3,
                width: context.width(),
                color: context.primaryColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: context.statusBarHeight),
                    widget.callModel!.callerPhotoUrl.isEmptyOrNull
                        ? CircleAvatar(
                            backgroundColor: whiteColor,
                            radius: 28,
                            child: Text(widget.callModel!.callerName.validate()[0], style: primaryTextStyle(size: 22, color: primaryColor)),
                          )
                        : cachedImage(widget.callModel!.callerPhotoUrl, height: 120, width: 120, fit: BoxFit.cover, radius: 80).cornerRadiusWithClipRRect(80),
                    8.height,
                    Text(widget.callModel!.callerName!, style: primaryTextStyle(color: Colors.white, size: 22)),
                    16.height,
                    Text('Connected', style: secondaryTextStyle(color: Colors.white70, size: 16)),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: context.height() * 0.3),
              width: context.width(),
              height: context.height(),
              child: cachedImage(widget.callModel!.callerPhotoUrl, fit: BoxFit.fill),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: context.height() * 0.10,
                width: context.width(),
                color: context.primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    RawMaterialButton(
                      onPressed: _switchSpeakerphone,
                      child: Icon(Octicons.unmute, color: Colors.white, size: 24.0),
                      shape: CircleBorder(),
                      elevation: 0,
                      fillColor: enableSpeakerphone ? Colors.white38 : context.primaryColor,
                      padding: EdgeInsets.all(16.0),
                    ),
                    RawMaterialButton(
                      onPressed: () => callService.endCall(callModel: widget.callModel!),
                      child: Icon(Icons.call_end, color: Colors.white, size: 35.0),
                      shape: CircleBorder(),
                      elevation: 2.0,
                      fillColor: Colors.redAccent,
                      padding: EdgeInsets.all(15.0),
                    ),
                    RawMaterialButton(
                      onPressed: _switchMicrophone,
                      child: Icon(MaterialIcons.mic_off, color: Colors.white, size: 24.0),
                      shape: CircleBorder(),
                      elevation: 0.0,
                      fillColor: openMicrophone ? Colors.white38 : context.primaryColor,
                      padding: EdgeInsets.all(16.0),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      }
    }

    return Scaffold(
      body: getCallScreen(value: widget.callModel?.callerId == getStringAsync(userId)),
    );
  }
}
