import 'package:chat/utils/AppCommon.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/UserListComponent.dart';
import '../../main.dart';
import '../../models/UserModel.dart';
import '../../screens/GroupChat/NewGroupScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/Appwidgets.dart';

class NewChatScreen extends StatefulWidget {
  final bool? isCall;

  NewChatScreen({this.isCall = false});

  @override
  _NewChatScreenState createState() => _NewChatScreenState();
}

class _NewChatScreenState extends State<NewChatScreen> {
  bool isSearch = false;
  bool autoFocus = false;
  TextEditingController searchCont = TextEditingController();
  String search = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.isCall! ? "new_call".translate : 'new_chat'.translate,
        textColor: Colors.white,
        actions: [
          AnimatedContainer(
            margin: EdgeInsets.only(left: 8),
            duration: Duration(milliseconds: 100),
            curve: Curves.decelerate,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isSearch)
                  TextField(
                    autofocus: true,
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: Colors.white,
                    onChanged: (s) {
                      setState(() {});
                    },
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    controller: searchCont,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "lblSearchHere".translate,
                      hintStyle: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ).expand(),
                IconButton(
                  icon: isSearch ? Icon(Icons.close) : Icon(Icons.search),
                  onPressed: () async {
                    isSearch = !isSearch;
                    searchCont.clear();
                    search = "";
                    setState(() {});
                  },
                  color: Colors.white,
                )
              ],
            ),
            width: isSearch ? context.width() - 86 : 50,
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: userService.users(searchText: searchCont.text),
        builder: (_, snap) {
          if (snap.hasData) {
            if (snap.data != null && snap.data!.isNotEmpty) snap.data!.sort((a, b) => a.name.validate().toLowerCase().compareTo(b.name.validate().toLowerCase()));
            if (snap.data != null && snap.data!.isNotEmpty)
              return SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!widget.isCall!)
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: boxDecorationWithRoundedCorners(boxShape: BoxShape.circle, backgroundColor: primaryColor),
                            child: Icon(Icons.people, color: Colors.white),
                          ),
                          12.width,
                          Text('create_group'.translate.capitalizeEachWord(), style: primaryTextStyle(size: 18)),
                        ],
                      ).paddingSymmetric(horizontal: 16, vertical: 16).onTap(() {
                        NewGroupScreen(snap: snap).launch(context, pageRouteAnimation: PageRouteAnimation.SlideBottomTop, duration: 300.milliseconds);
                      }),
                    UserListComponent(snap: snap, isCall: widget.isCall, isGroupCreate: false),
                  ],
                ),
              );
            else
              return noDataFound(text: isSearch ? "no_result".translate : "no_data_found".translate).center();
          }
          return snapWidgetHelper(snap);
        },
      ),
    );
  }
}
