import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mighty_chat_admin_panel/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../model/StickerModel.dart';
import '../utils/cached_network_image.dart';
import '../utils/common.dart';

class StickerScreen extends StatefulWidget {
  @override
  _StickerScreenState createState() => _StickerScreenState();
}

class _StickerScreenState extends State<StickerScreen> {
  XFile? imageProfile;
  Uint8List? image;
  String? storeImage;
  File? sticker;

  Future getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 100);
    image = await imageProfile!.readAsBytes();

    showConfirmDialogCustom(context, subTitle: 'Are you sure want to add this sticker?', primaryColor: primaryColor, dialogType: DialogType.ADD, onAccept: (v) async {
      appStore.setIsLoading(true);
      await stickerService.addStickerToStorage(image, imageProfile!.path.split("/").last).then((value) {
        StickerModel data = StickerModel();
        data.stickerPath = value;
        data.updatedAt = DateTime.timestamp();
        data.createdAt = DateTime.timestamp();
        stickerService.addSticker(data).then((value) {
          toast('Sticker Upload successfully');
          appStore.setIsLoading(false);
          setState(() {});
        });
      }).catchError((e) {
        log(e);
        appStore.setIsLoading(false);
      });
    });
    appStore.setIsLoading(false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: AppButton(
            text: 'Add Sticker',
            shapeBorder: RoundedRectangleBorder(borderRadius: radius(16)),
            onTap: () {
              getImage();
            },
          ),
        ),
        16.height,
        Stack(
          children: [
            SingleChildScrollView(
              child: FutureBuilder<List<StickerModel>>(
                  future: stickerService.getAllSticker(),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: snap.data!.map((e) {
                          return HoverWidget(builder: (context, isHovering) {
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                CachedImageWidget(url: e.stickerPath.validate(), height: 130, width: 130, fit: BoxFit.cover),
                                if (isHovering)
                                  outlineActionIcon(Icons.delete, redColor, 'Delete', () {
                                    if (!appStore.isTester) {
                                      showConfirmDialogCustom(context, subTitle: 'Are you sure want to delete this Sticker?', primaryColor: Colors.red, dialogType: DialogType.DELETE, onAccept: (v) {
                                        appStore.setIsLoading(true);
                                        stickerService.removeDocument(e.id.validate()).then((value) {
                                          stickerService.deleteImage(e.stickerPath.validate());
                                          toastWidget(context, 'Sticker deleted successfully');
                                          appStore.setIsLoading(false);
                                          setState(() {});
                                        });
                                      });
                                    } else {
                                      toastWidget(context, 'Test user cannot perform this action');
                                    }
                                  }).paddingAll(8),
                              ],
                            );
                          });
                        }).toList(),
                      );
                    }
                    return snapWidgetHelper(snap);
                  }),
            ),
            Observer(builder: (context) {
              return Positioned(child: Loader()).visible(appStore.isLoading);
            })
          ],
        ).expand(),
      ],
    ).paddingAll(16);
  }
}
