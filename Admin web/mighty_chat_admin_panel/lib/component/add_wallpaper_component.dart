import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mighty_chat_admin_panel/main.dart';
import 'package:mighty_chat_admin_panel/model/WallpaperModel.dart';
import 'package:mighty_chat_admin_panel/utils/images.dart';
import 'package:mighty_chat_admin_panel/utils/widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/cached_network_image.dart';
import '../utils/colors.dart';
import '../utils/common.dart';

class AddWallpaperComponent extends StatefulWidget {
  @override
  _AddWallpaperComponentState createState() => _AddWallpaperComponentState();
}

class _AddWallpaperComponentState extends State<AddWallpaperComponent> {
  XFile? imageProfile;
  Uint8List? image;
  String? wallpaperImage;
  List<String> categoryList = [
    'Dark Wallpaper',
    'Bright Wallpaper',
    'Solid Wallpaper'
  ];
  String? selectedCategory = 'Dark Wallpaper';
  int? categoryIndex = 1;

  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  @override
  void initState() {
    selectedCategory = categoryList.first;
    super.initState();
  }

  Future<void> getImage() async {
    imageProfile = null;
    imageProfile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 100);
    image = await imageProfile!.readAsBytes();
    setState(() {});
  }

  saveWallpaper() async {
    appStore.setIsLoading(true);
    if (categoryIndex == 3) {
      WallpaperModel data = WallpaperModel();
      data.wallpaperPath = pickerColor.toHex();
      data.category = selectedCategory;
      data.categoryId = categoryIndex;
      data.updatedAt = DateTime.timestamp();
      data.createdAt = DateTime.timestamp();
      wallpaperService.addWallpaper(data).then((value) {
        toastWidget(context, 'Wallpaper Uploaded successfully');
        appStore.setIsLoading(false);
        finish(context);
        setState(() {});
      });
    } else {
      await wallpaperService
          .addWallPaperToStorage(
              image, imageProfile!.path.split("/").last, selectedCategory)
          .then((value) {
        WallpaperModel data = WallpaperModel();
        data.wallpaperPath = value;
        data.category = selectedCategory;
        data.categoryId = categoryIndex;
        data.updatedAt = DateTime.timestamp();
        data.createdAt = DateTime.timestamp();
        wallpaperService.addWallpaper(data).then((value) {
          toastWidget(context, 'Wallpaper Uploaded successfully');
          appStore.setIsLoading(false);
          finish(context);
          setState(() {});
        });
      }).catchError((e) {
        log(e);
        appStore.setIsLoading(false);
      });
    }
  }

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(
        children: [
          Container(
            width: context.width() * 0.4,
            padding: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.cardColor, borderRadius: radius(8)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Add Wallpaper', style: boldTextStyle()).expand(),
                    IconButton(
                      onPressed: () {
                        finish(context);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                16.height,
                SizedBox(
                  width: context.width() * 0.4,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    decoration: inputDecoration(),
                    dropdownColor: Theme.of(context).cardColor,
                    style: primaryTextStyle(),
                    items: categoryList.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item, style: primaryTextStyle()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedCategory = value;
                      categoryIndex =
                          categoryList.indexOf(value.validate()) + 1;
                      setState(() {});
                    },
                    validator: (value) {
                      if (selectedCategory == null)
                        return errorThisFieldRequired;
                      return null;
                    },
                  ),
                ),
                16.height,
                categoryIndex == 3
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              Image.asset(appImages.icSolidWallpaper,
                                  height: 150,
                                  width: context.width() * 0.1,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center),
                              Container(
                                height: 150,
                                width: context.width() * 0.1,
                                color: pickerColor.withOpacity(0.7),
                              )
                            ],
                          ),
                          16.width,
                          AppButton(
                            text: 'Pick color',
                            shapeBorder: RoundedRectangleBorder(
                                borderRadius: radius(16)),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Pick a color!'),
                                  content: SingleChildScrollView(
                                    child: ColorPicker(
                                      pickerColor: pickerColor,
                                      onColorChanged: changeColor,
                                    ),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    16.width,
                                    ElevatedButton(
                                      child: Text('Got it'),
                                      onPressed: () {
                                        setState(
                                            () => currentColor = pickerColor);
                                        log(pickerColor.toHex());
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    : InkWell(
                        onTap: () async {
                          getImage();
                          setState(() {});
                        },
                        child: Container(
                          width: context.width() * 0.4,
                          padding: EdgeInsets.all(16),
                          decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: Colors.grey.withOpacity(0.1)),
                          child: image == null && !wallpaperImage.isEmptyOrNull
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    20.width,
                                    CachedImageWidget(
                                        url: wallpaperImage.validate(),
                                        height: 150,
                                        width: context.width() * 0.3,
                                        fit: BoxFit.cover,
                                        alignment: Alignment.center),
                                    24.width,
                                    Text('Edit image',
                                        style: primaryTextStyle(
                                            color: primaryColor)),
                                    20.width,
                                  ],
                                )
                              : image == null
                                  ? Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        height: 105,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.camera_alt),
                                            8.height,
                                            Text('Upload Image',
                                                style: primaryTextStyle()),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        20.width,
                                        Image.memory(image!,
                                            height: 150,
                                            width: context.width() * 0.1,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.center),
                                        24.width,
                                        TextButton(
                                          onPressed: () {
                                            image = null;
                                            setState(() {});
                                          },
                                          child: Text('Remove image',
                                              style: primaryTextStyle(
                                                  color: primaryColor)),
                                        ),
                                        20.width,
                                      ],
                                    ),
                        ),
                      ),
                16.height,
                Align(
                  alignment: Alignment.bottomRight,
                  child: AppButton(
                    text: 'save',
                    shapeBorder:
                        RoundedRectangleBorder(borderRadius: radius(16)),
                    onTap: () {
                      if ((categoryIndex == 1 || categoryIndex == 2) &&
                          image == null) {
                        toast('Please add wallpaper');
                      } else {
                        saveWallpaper();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Observer(builder: (context) {
            return Positioned.fill(child: Loader()).visible(appStore.isLoading);
          })
        ],
      ),
    );
  }
}
