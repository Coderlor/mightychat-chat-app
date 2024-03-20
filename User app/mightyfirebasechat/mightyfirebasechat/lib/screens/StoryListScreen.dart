import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/StoryModel.dart';
import '../../utils/story/StoryController.dart';
import '../utils/story/StoryView.dart';

class StoryListScreen extends StatefulWidget {
  final List<StoryModel>? list;
  final String? userName;
  final Timestamp? time;
  final String? userImg;

  StoryListScreen({this.list, this.userName, this.time, this.userImg});

  @override
  _StoryListScreenState createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  final StoryController controller = StoryController();

  int currentIndex = 0;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.list.validate().isNotEmpty
          ? GestureDetector(
              onTapDown: (v) {
                controller.pause();
              },
              onTapUp: (v) {
                controller.play();
              },
              child: StoryView(
                controller: controller,
                inline: true,
                repeat: false,
                onComplete: () {
                  finish(context);
                },
                onStoryShow: (v) {
                  //
                },
                storyItems: widget.list.validate().map((e) {
                  return StoryItem.inlineImage(
                    key: Key(widget.list!.indexOf(e).toString()),
                    userImage: e.userImgPath.validate(),
                    username: e.userName.validate().capitalizeEachWord(),
                    url: e.imagePath.validate(),
                    controller: controller,
                    duration: Duration(seconds: 3),
                    roundedBottom: false,
                    roundedTop: false,
                    shown: true,
                    time: Text(formatTime(e.createAt!.millisecondsSinceEpoch.validate()), style: primaryTextStyle(color: Colors.white, size: 16), textAlign: TextAlign.left),
                  );
                }).toList(),
              ),
            )
          : SizedBox(),
    );
  }
}
