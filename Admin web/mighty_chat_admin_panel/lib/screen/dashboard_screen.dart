import 'package:flutter/material.dart';
import 'package:mighty_chat_admin_panel/main.dart';
import '../component/dashboard_card_component.dart';
import '../component/total_inactive_users_component.dart';
import '../component/total_users_component.dart';
import 'package:nb_utils/nb_utils.dart';
import '../model/user_model.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              DashboardCardComponent(title: 'Total User', future: userService.getTotalUsers()),
              DashboardCardComponent(title: 'Total Active User', future: userService.getTotalNumberOfActiveUsers()),
              DashboardCardComponent(title: 'Total Inactive User', future: userService.getTotalNumberOfInactiveUsers()),
              DashboardCardComponent(title: 'Total Wallpaper', future: wallpaperService.getTotalWallpaper()),
              DashboardCardComponent(title: 'Total Sticker', future: stickerService.getTotalSticker()),
            ],
          ),
          16.height,
          StreamBuilder<List<UserModel>>(
            stream: userService.getAllUsers(),
            builder: (context, snap) {
              List<UserModel> totalInActiveUser = [];
              List<UserModel> totalActiveUser = [];
              if (snap.data != null)
                snap.data!.forEach((element) {
                  if (element.active == true && element.createdAt!.toDate().isAfter(DateTime.now().subtract(Duration(days: 6)))) {
                    totalActiveUser.add(element);
                  } else if (element.active == false) {
                    totalInActiveUser.add(element);
                  }
                });
              if (snap.data != null)
                return Row(
                  children: [
                    if (totalInActiveUser.isNotEmpty) TotalInactiveUsersComponent(userList: totalInActiveUser).expand(),
                    16.width,
                    if (totalActiveUser.isNotEmpty) TotalUserComponent(userList: totalActiveUser).expand(),
                  ],
                ).expand();
              return snapWidgetHelper(snap, loadingWidget: Loader().center());
            },
          ),
        ],
      ),
    );
  }
}
