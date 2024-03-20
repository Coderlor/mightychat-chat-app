import 'WallpaperServiceModel.dart';

class WallpaperModel {
  List<WallpaperServiceModel>? sublist;
  int? categoryId;
  String? name;
  bool? isSelected;
  String? path;

  WallpaperModel({this.path, this.name, this.categoryId, this.sublist, this.isSelected});
}
