import '../../components/FullScreenImageWidget.dart';
import '../../screens/GroupChat/GroupChatScreen.dart';
import '../../screens/GroupChat/GroupInfoScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class GroupProfileImageDailog extends StatefulWidget {
  var data;

  GroupProfileImageDailog({this.data});

  @override
  State<GroupProfileImageDailog> createState() => _GroupProfileImageDailogState();
}

class _GroupProfileImageDailogState extends State<GroupProfileImageDailog> {
  bool isBlocked = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          widget.data!['photourl'] == null || widget.data!['photourl'].isEmpty
              ? Container(
                  height: context.height() * 0.4,
                  width: context.width(),
                  color: primaryColor,
                  child: noProfileImageFound(height: 50, width: 50, isNoRadius: true),
                ).cornerRadiusWithClipRRect(4)
              : InkWell(
                  onTap: () {
                    finish(context);
                    FullScreenImageWidget(photoUrl: widget.data!['photourl'], name: widget.data['name']).launch(context);
                  },
                  child: Hero(
                    tag: widget.data!['photourl'],
                    child: Image.network(widget.data!['photourl'], fit: BoxFit.cover, height: 350, width: context.width()),
                  ),
                ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(color: Colors.black26, backgroundBlendMode: BlendMode.luminosity),
            width: double.infinity,
            child: Text(widget.data!['name'], style: boldTextStyle(color: Colors.white, size: 20)),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Container(
              height: 45,
              color: context.scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      icon: Icon(Icons.message_rounded, size: 20),
                      onPressed: () {
                        finish(context);
                        GroupChatScreen(groupChatId: widget.data['id'], groupName: widget.data!['name'], groupData: widget.data).launch(context);
                      }),
                  IconButton(
                    icon: Icon(Icons.info, size: 20),
                    onPressed: () {
                      finish(context);
                      GroupInfoScreen(groupName: widget.data!['name'], groupId: widget.data['id'], data: widget.data).launch(context);
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
