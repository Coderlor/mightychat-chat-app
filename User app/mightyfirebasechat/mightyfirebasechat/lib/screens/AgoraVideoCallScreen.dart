import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../main.dart';
import '../../models/CallModel.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';

class AgoraVideoCallScreen extends StatefulWidget {
  final CallModel? callModel;

  AgoraVideoCallScreen({this.callModel});

  @override
  _AgoraVideoCallScreenState createState() => _AgoraVideoCallScreenState();
}

class _AgoraVideoCallScreenState extends State<AgoraVideoCallScreen> {
  List<int> _users = [];
  bool muted = false;
  late RtcEngine _engine;
  bool switchRender = true;
  bool isUserJoined = false;

  Offset offset = Offset(120, 16);

  String callStatus = "Ringing";
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

  Future<void> initialize() async {
    await _initAgoraRtcEngine();
  }

  Future<void> _initAgoraRtcEngine() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: agoraVideoCallId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
    await _engine.joinChannel(
      token: "", //TODO  need to pass token as currently not available
      channelId: widget.callModel!.channelId!,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
    _rtcEngineEventHandler = RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint("local user ${connection.localUid} joined");
        setState(() {
          log(_users);
        });
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        debugPrint("remote user $remoteUid joined");
        setState(() {
          toast("connected");
          isUserJoined = true;
          _users.add(remoteUid);
        });
      },
      onError: (ErrorCodeType err, String msg) {
        debugPrint('[onError] err: $err, msg: $msg');
      },
      onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
        debugPrint("remote user $remoteUid left channel");
        callService.endCall(callModel: widget.callModel!);
        setState(() {
          _users.remove(remoteUid);
        });
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        setState(() {
          _users.clear();
        });
      },
      onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint('[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
      },
    );
    _engine.registerEventHandler(_rtcEngineEventHandler);

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();
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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  Future<void> _dispose() async {
    _users.clear();
    _engine.unregisterEventHandler(_rtcEngineEventHandler);
    await _engine.leaveChannel();
    await _engine.release();
    callStreamSubcription.cancel();
  }

  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(muted ? Icons.mic_off : Icons.mic, color: muted ? Colors.white : Colors.blueAccent, size: 20.0),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => callService.endCall(callModel: widget.callModel!),
            child: Icon(Icons.call_end, color: Colors.white, size: 35.0),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(Icons.switch_camera, color: Colors.blueAccent, size: 20.0),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  _switchRender() {
    log("After $_users");

    setState(() {
      switchRender = !switchRender;
      _users = List.of(_users.reversed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // RtcLocalView.SurfaceView().visible(!isUserJoined),
          AgoraVideoView(
            controller: VideoViewController(
              rtcEngine: _engine,
              canvas: const VideoCanvas(uid: 0),
            ),
          ).visible(!isUserJoined),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                cachedImage(widget.callModel!.receiverPhotoUrl.validate(), height: 120, width: 120, fit: BoxFit.fill).cornerRadiusWithClipRRect(80),
                16.height,
                Text(widget.callModel!.receiverName.validate(), style: boldTextStyle(size: 18, color: Colors.white)),
                16.height,
                Text(callStatus, style: boldTextStyle(color: Colors.white)).center(),
              ],
            ),
          ).visible(!isUserJoined),
          Stack(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.of(_users.map(
                    (e) => GestureDetector(
                      onTap: this._switchRender,
                      child: Container(
                        width: context.width(),
                        height: context.height(),
                        child: AgoraVideoView(
                          controller: VideoViewController.remote(
                            rtcEngine: _engine,
                            canvas: VideoCanvas(uid: _users[0]),
                            connection: RtcConnection(channelId: widget.callModel!.channelId!),
                          ),
                        ),
                      ),
                    ),
                  )),
                ).visible(isUserJoined),
              ),
              Positioned(
                bottom: offset.dx,
                right: offset.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {});
                  },
                  child: Container(
                      height: 180,
                      width: 150,
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: _engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      )),
                ),
              ).visible(isUserJoined)
            ],
          ),
          _toolbar(),
        ],
      ).center(),
    );
  }
}
