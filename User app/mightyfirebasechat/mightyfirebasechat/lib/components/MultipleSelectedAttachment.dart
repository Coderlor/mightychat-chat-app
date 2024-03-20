import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:video_player/video_player.dart';

import '../../models/StoryModel.dart';
import '../../models/UserModel.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../main.dart';

class MultipleSelectedAttachment extends StatefulWidget {
  final List<File>? attachedFiles;
  final bool isImage;
  final bool isVideo;
  final bool isAudio;
  final UserModel? userModel;
  final bool isStory;

  MultipleSelectedAttachment({this.attachedFiles, this.isImage = false, this.isVideo = false, this.isAudio = false, this.userModel, this.isStory = false});

  @override
  _MultipleSelectedAttachmentState createState() => _MultipleSelectedAttachmentState();
}

class _MultipleSelectedAttachmentState extends State<MultipleSelectedAttachment> {
  PageController controller = PageController(initialPage: 0);
  PageController? videoPageController = PageController(initialPage: 0, keepPage: true);

  int videoIndex = 0;

  Duration pageTurnDuration = Duration(milliseconds: 500);
  Curve pageTurnCurve = Curves.ease;

  VoidCallback? listener;
  VideoPlayerController? playerController;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    afterBuildCreated(() async {
      if (widget.isVideo) {
        videoIndex = 0;
        await setupVideo(widget.attachedFiles![0]);
      } else if (widget.isAudio) {
        uploadStory();
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> uploadStory() async {
    appStore.setLoading(true);
    widget.attachedFiles!.map((e) async {
      await storyService.uploadImage(File(e.path)).then((value) async {
        if (widget.isStory) {
          StoryModel data = StoryModel();
          data.userId = getStringAsync(userId);
          data.caption = '';
          data.createAt = Timestamp.now();
          data.updatedAt = Timestamp.now();
          data.imagePath = value;
          data.userImgPath = loginStore.mPhotoUrl;
          data.userName = loginStore.mDisplayName;

          await storyService.addStory(data, userId: getStringAsync(userId)).then((value) {
            toast('status_uploaded'.translate);
          }).catchError((e) {
            toast(e.toString(), print: true);
          });
        } else {
          // finish(context, true);
        }
      }).catchError((e) {
        toast(e.toString(), print: true);
      });
    }).toList();
    appStore.setLoading(false);
    finish(context, true);
  }

  Future<void> setupVideo(File file) async {
    if (file.existsSync()) {
      playerController = (VideoPlayerController.file(file)
        ..addListener(() => setState(() {}))
        ..setLooping(true)
        ..initialize().then((_) {
          log(playerController != null);
          playerController!.play();
        }));
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (widget.isVideo) {
      controller.dispose();
      playerController!.dispose();
      videoPageController!.dispose();
      finish(context);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget showWidget() {
      return widget.isImage
          ? PageView.builder(
              // controller: ,
              itemCount: widget.attachedFiles?.length,
              itemBuilder: (_, i) {
                return Container(
                  height: context.height(),
                  width: context.width(),
                  child: Image.file(
                    widget.attachedFiles![i],
                    width: context.width(),
                    height: context.height(),
                  ),
                );
              })
          : widget.isVideo
              ? PageView.builder(
                  controller: videoPageController,
                  itemCount: widget.attachedFiles!.length,
                  itemBuilder: (_, index) {
                    return playerController != null ? VideoPlayer(playerController!) : Offstage();
                  },
                  onPageChanged: (index) async {
                    setState(() {
                      playerController?.dispose();
                      videoIndex = index;
                    });
                    //
                    await Future.delayed(Duration(milliseconds: 500), () {
                      setupVideo(widget.attachedFiles![videoIndex]);
                    });
                  },
                )
              : widget.isAudio
                  ? CircularProgressIndicator(
                      color: primaryColor,
                    ).center()
                  : SizedBox();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: !widget.isStory
          ? appBarWidget("${widget.userModel != null ? "sent_to".translate + " " + widget.userModel!.name.validate() : ''}",
              textColor: Colors.white,
              backWidget: Icon(Icons.arrow_back, color: Colors.white).onTap(() {
                finish(context);
              }))
          : null,
      body: Container(
        height: context.height(),
        child: Stack(
          children: [
            showWidget(),
            Observer(builder: (_) => Loader().visible(appStore.isLoading)),
            if (widget.isStory)
              Positioned(
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    finish(context);
                  },
                ),
              ),
            Align(
              alignment: isRTL ? Alignment.bottomLeft : Alignment.bottomRight,
              child: Container(
                height: 60,
                width: 60,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(shape: BoxShape.circle, color: primaryColor),
                child: Icon(Icons.send, color: Colors.white),
              ).onTap(() {
                uploadStory();
              }, borderRadius: BorderRadius.circular(50)),
            ),
          ],
        ),
      ),
    );
  }
}
