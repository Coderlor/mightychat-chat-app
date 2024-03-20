import 'package:flutter/material.dart';
import '../component/inactive_user_list_component.dart';
import '../model/user_model.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalUserComponent extends StatelessWidget {
  final List<UserModel>? userList;

  TotalUserComponent({this.userList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('New users in Last 7 days', style: boldTextStyle()),
        16.height,
        ListView.builder(
          shrinkWrap: true,
          itemCount: userList!.length,
          itemBuilder: (context, index) {
            return InactiveUserListComponent(currentUser: userList![index]);
          },
        ).expand()
      ],
    );
  }
}
