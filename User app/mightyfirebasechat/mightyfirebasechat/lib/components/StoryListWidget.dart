import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/StoryModel.dart';
import '../../screens/StoryListScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/Appwidgets.dart';
import '../main.dart';
import '../models/UserModel.dart';

class StoryListWidget extends StatefulWidget {
  static String tag = '/StoryListWidget';
  final List<RecentStoryModel> list;

  StoryListWidget(this.list);

  @override
  State<StoryListWidget> createState() => _StoryListWidgetState();
}

class _StoryListWidgetState extends State<StoryListWidget> {
  String name = '';
  String userImage = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ListView.builder(
            itemCount: widget.list.length,
            shrinkWrap: true,
            itemBuilder: (_, i) {
              RecentStoryModel data = widget.list[i];
              return Row(
                children: [
                  Container(
                    height: 55,
                    width: 55,
                    margin: EdgeInsets.only(top: 4, bottom: 4),
                    decoration: BoxDecoration(border: Border.all(color: primaryColor, width: 2), borderRadius: radius(30)),
                    child: cachedImage(data.list!.first.imagePath.validate(), height: context.height(), fit: BoxFit.cover).cornerRadiusWithClipRRect(50),
                  ),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      data.userName.isEmptyOrNull
                          ? FutureBuilder<UserModel>(
                              future: userService.getUserById(val: data.userId),
                              builder: (c, n) {
                                if (n.hasData) if (n.data != null) {
                                  name = n.data!.name.validate();
                                  userImage = n.data!.photoUrl.validate();
                                  return Text(n.data!.name.validate().capitalizeEachWord(), style: boldTextStyle(size: 18));
                                }
                                return snapWidgetHelper(n, loadingWidget: Loader());
                              })
                          : Text(data.userName.validate().capitalizeEachWord(), style: boldTextStyle(size: 18)),
                      Text(formatTime(data.createAt!.millisecondsSinceEpoch.validate()), style: secondaryTextStyle()),
                    ],
                  )
                ],
              ).paddingSymmetric(horizontal: 16, vertical: 4).onTap(() {
                StoryListScreen(list: data.list, userName: name, time: data.createAt, userImg: userImage).launch(context);
              });
            }).visible(widget.list.isNotEmpty),
      ],
    );
  }
}
