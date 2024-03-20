import 'package:chat/main.dart';
import 'package:chat/models/UserModel.dart';
import 'package:chat/utils/AppColors.dart';
import 'package:chat/utils/Appwidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/AppCommon.dart';
import '../utils/AppConstants.dart';

class BlockListScreen extends StatefulWidget {
  @override
  _BlockListScreenState createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  List<UserModel> blockList = [];
  List<String> list = [];

  @override
  void initState() {
    super.initState();
    appStore.setLoading(true);
    afterBuildCreated(() => init());
  }

  init() async {
    await userService.blockUserList().then((value) {
      list = value;
      value.forEach((element) async {
        blockList.clear();
        await fireStore.collection(USER_COLLECTION).doc(element).get().then((value) {
          UserModel user1 = UserModel.fromJson(value.data() as Map<String, dynamic>);
          blockList.add(user1);
          setState(() {});
        });
      });
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      log(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('blocked_user'.translate, color: primaryColor, textColor: Colors.white, showBack: true),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            if (blockList.isNotEmpty)
              ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemCount: blockList.length,
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  UserModel data = blockList[i];
                  return InkWell(
                    onTap: () {
                      unblockDialog(context, receiver: data);
                      init();
                      setState(() {});
                    },
                    child: Row(
                      children: [
                        data.photoUrl!.isEmpty
                            ? Hero(
                                tag: data.uid.validate(),
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  padding: EdgeInsets.all(10),
                                  color: primaryColor,
                                  child: Text(data.name.validate()[0].toUpperCase(), style: secondaryTextStyle(color: Colors.white)).center().fit(),
                                ).cornerRadiusWithClipRRect(50),
                              )
                            : cachedImage(data.photoUrl.validate(), width: 50, height: 50, fit: BoxFit.cover).cornerRadiusWithClipRRect(80),
                        8.width,
                        Text(data.name.validate().capitalizeFirstLetter(), style: primaryTextStyle(), maxLines: 1, textAlign: TextAlign.start, overflow: TextOverflow.ellipsis),
                      ],
                    ).paddingSymmetric(horizontal: 16, vertical: 8),
                  );
                },
              ),
            if ((list.isEmpty) && !appStore.isLoading) noDataFound(text: 'no_block_user_found'.translate),
            if (appStore.isLoading) Loader()
          ],
        );
      }),
    );
  }
}
