import 'package:flutter/material.dart';
import '../component/inactive_user_list_component.dart';
import '../component/no_data_component.dart';
import '../main.dart';
import '../model/user_model.dart';
import '../utils/config.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import '../utils/constant.dart';

class TotalUserScreen extends StatefulWidget {
  @override
  _TotalUserScreenState createState() => _TotalUserScreenState();
}

class _TotalUserScreenState extends State<TotalUserScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return PaginateFirestore(
      padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
      physics: BouncingScrollPhysics(),
      initialLoader: Loader(),
      isLive: true,
      onEmpty: NoDataComponent().center(),
      query: userService.userListWithPagination(),
      itemsPerPage: perPage,
      shrinkWrap: true,
      onError: (p0) {
        return Text(p0.toString(), style: boldTextStyle());
      },
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, snap, index) {
        UserModel data = UserModel.fromJson(snap[index].data() as Map<String, dynamic>);
        return InactiveUserListComponent(currentUser: data);
      },
    );
  }
}
