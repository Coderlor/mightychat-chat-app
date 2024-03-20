import 'package:flutter/material.dart';
import '../component/inactive_user_list_component.dart';
import '../model/user_model.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalInactiveUsersComponent extends StatelessWidget {
  final List<UserModel>? userList;

  TotalInactiveUsersComponent({this.userList});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent Inactive users', style: boldTextStyle()),
        16.height,
        if (userList!.isNotEmpty)
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
