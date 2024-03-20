class MenuItemModel {
  int? index;
  String? imagePath;
  String? title;
  double? size;

  MenuItemModel({this.index, this.imagePath, this.title,this.size});
}

List<MenuItemModel> getMenuItems = [
  MenuItemModel(size: 20,title: 'Dashboard', index: 1, imagePath: 'https://cdn-icons-png.flaticon.com/128/3757/3757985.png'),
  MenuItemModel(size: 20,title: 'Users', index: 2, imagePath: 'https://cdn-icons-png.flaticon.com/128/10109/10109358.png'),
  MenuItemModel(size: 20,title: 'Stickers', index: 3, imagePath: 'https://cdn-icons-png.flaticon.com/128/2480/2480593.png'),
  MenuItemModel(size: 20,title: 'Wallpaper', index: 4, imagePath: 'https://cdn-icons-png.flaticon.com/128/9513/9513930.png'),
  MenuItemModel(size: 20,title: 'Ads Configurations', index: 5, imagePath: 'https://cdn-icons-png.flaticon.com/128/2787/2787121.png'),
  MenuItemModel(size: 20,title: 'OneSignal Configurations', index: 6, imagePath: 'https://cdn-icons-png.flaticon.com/128/2097/2097743.png'),
  MenuItemModel(size: 20,title: 'Settings', index: 7, imagePath: 'https://cdn-icons-png.flaticon.com/128/2040/2040504.png'),
];
