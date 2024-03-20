import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/SelectedAttachmentComponent.dart';
import '../../components/StoryListWidget.dart';
import '../../main.dart';
import '../../models/StoryModel.dart';
import '../../screens/StoryListScreen.dart';
import '../../utils/AppColors.dart';
import '../../utils/AppCommon.dart';
import '../../utils/AppConstants.dart';
import '../../utils/Appwidgets.dart';
import 'MyStoryListScreen.dart';

class StoriesScreen extends StatefulWidget {
  @override
  StoriesScreenState createState() => StoriesScreenState();
}

class StoriesScreenState extends State<StoriesScreen> {
  List<RecentStoryModel> recentStoryList = [];
  List<RecentStoryModel> recentList = [];

  File? imageFile;
  XFile? pickedFile;

  List<StoryModel> myStoryList = [];

  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<File> selectImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    return File(result!.files.single.path!);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    Widget myStatusWidget({List<StoryModel>? data}) {
      return Stack(
        children: [
          Row(
            children: [
              data!.isNotEmpty
                  ? Container(
                      height: 55,
                      width: 55,
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: primaryColor, width: 2),
                        borderRadius: radius(30),
                      ),
                      child: cachedImage(data.first.imagePath.validate(), fit: BoxFit.cover).cornerRadiusWithClipRRect(50),
                    )
                  : SizedBox(
                      height: 55,
                      width: 55,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          loginStore.mPhotoUrl.validate().isNotEmpty
                              ? cachedImage(loginStore.mPhotoUrl.validate(), height: 55, width: 55, fit: BoxFit.cover).cornerRadiusWithClipRRect(50)
                              : CircleAvatar(
                                  backgroundColor: primaryColor,
                                  radius: 28,
                                  child: Text(loginStore.mDisplayName.validate()[0], style: primaryTextStyle(size: 22, color: Colors.white)),
                                ),
                          Container(
                            height: 20,
                            width: 20,
                            decoration: boxDecorationWithShadow(boxShape: BoxShape.circle, backgroundColor: whiteColor),
                            child: Icon(Icons.add, size: 18, color: Colors.black),
                          )
                        ],
                      ),
                    ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('my_status'.translate, style: boldTextStyle(size: 18)),
                  4.height,
                  Text(data.isEmpty ? 'add_Story'.translate : formatTime(data.first.createAt!.millisecondsSinceEpoch.validate()), style: secondaryTextStyle()),
                ],
              ).expand(),
              if (data.isNotEmpty)
                IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () async {
                      bool? res = await MyStoryListScreen(list: data).launch(context);
                      if (res!) {
                        setState(() {});
                      }
                    }),
            ],
          ).paddingAll(16).onTap(() async {
            if (data.isNotEmpty) {
              StoryListScreen(list: data, userName: data.first.userName, time: data.first.createAt, userImg: data.first.userImgPath).launch(context);
            } else {
              _showBottomSheet(context);
            }
          }),
        ],
      );
    }

    return Scaffold(
      body: Column(
        children: [
          FutureBuilder<List<StoryModel>>(
              future: storyService.getMyStory(uid: getStringAsync(userId)),
              builder: (_, snap) {
                myStoryList.clear();
                if (snap.hasData) {
                  snap.data!.forEach((e) {
                    if (e.createAt!.toDate().difference(currentDate).inDays == 0) {
                      myStoryList.add(e);
                    }
                  });
                  return myStatusWidget(data: myStoryList);
                }
                return SizedBox();
              }),
          StreamBuilder<List<StoryModel>>(
            stream: storyService.getAllStory(uid: getStringAsync(userId)),
            builder: (_, snap) {
              if (snap.hasError) return Text(snap.error.toString(), style: boldTextStyle()).center();
              if (snap.hasData) {
                if (snap.data!.isNotEmpty) {
                  recentStoryList.clear();

                  snap.data!.forEach(
                    (element) async {
                      RecentStoryModel data = RecentStoryModel();
                      data.userId = element.userId;
                      data.userName = element.userName;
                      data.userImgPath = element.userImgPath;
                      data.createAt = element.createAt;
                      data.updatedAt = element.updatedAt;
                      data.list = [];
                      if (data.createAt!.toDate().difference(currentDate).inDays == 0) {
                        if (recentStoryList.length > 0) {
                          final index = recentStoryList.indexWhere((e) => e.userId == element.userId);
                          if (index > -1) {
                            recentStoryList[index].list?.add(element);
                          } else {
                            data.list!.add(element);
                            recentStoryList.add(data);
                          }
                        } else {
                          data.list!.add(element);
                          recentStoryList.add(data);
                        }
                      } else {
                        // ignore: unnecessary_null_comparison
                        if (element != null) {
                          if (element.id != null) {
                            await storyService.removeDocument(element.id!);
                            await storyService.deleteStory(id: element.id!, url: element.imagePath);
                          }
                        }
                      }
                    },
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      16.height,
                      Text('recent_stories'.translate, style: secondaryTextStyle()).paddingSymmetric(horizontal: 16),
                      16.height,
                      StoryListWidget(recentStoryList).visible(recentStoryList.isNotEmpty),
                    ],
                  );
                } else {
                  return noDataFound(text: 'no_story_available'.translate).visible(recentStoryList.isEmpty);
                }
              }
              return snapWidgetHelper(snap);
            },
          ).expand(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Image.asset('assets/Icons/ic_camera.png', height: 25, width: 25, color: Colors.white),
        onPressed: () async {
          _showBottomSheet(context);
        },
      ),
    );
  }

  void _getFromGallery() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      setState(() {});
      bool? res = await (SelectedAttachmentComponent(file: imageFile, isStory: true).launch(context));
      if (res!) {
        //
        setState(() {});
      }
    }
  }

  _getFromCamera() async {
    pickedFile = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1800, maxHeight: 1800);
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
      setState(() {});
      bool? res = await (SelectedAttachmentComponent(file: imageFile, isStory: true).launch(context));
      if (res!) {
        //
        setState(() {});
      }
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      backgroundColor: context.cardColor,
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingItemWidget(
              title: 'lblGallery'.translate,
              leading: Icon(Icons.image, color: primaryColor),
              onTap: () {
                _getFromGallery();
                finish(context);
              },
            ),
            Divider(color: context.dividerColor),
            SettingItemWidget(
              title: 'camera'.translate,
              leading: Icon(Icons.camera, color: primaryColor),
              onTap: () {
                _getFromCamera();
                finish(context);
              },
            ),
          ],
        ).paddingAll(16.0);
      },
    );
  }
}
