//region Test Credentials
const testEmail = "admin@demo.com";
const testPassword = "12345678";
//endregion

//region AppTheme
AppThemes appTheme = AppThemes();

class AppThemes {
  int themeModeLight = 0;
  int themeModeDark = 1;
  int themeModeSystem = 2;
}

//endregion

// region SharePreferencesKey
SharePreferencesKey sharePrefKey = SharePreferencesKey();

class SharePreferencesKey {
  String isLoggedIn = "isLoggedIn";
  String isEmailLogin = "isEmailLogin";
  String firstName = "firstName";
  String email = "email";
  String photoUrl = "photoUrl";
  String uid = "uid";
  String password = "password";
  String isTester = "isTester";
}
//endregion

const perPage = 15;
const userNotFound = "User Not found";
const accessDenied = "Access Denied";

//region Collection
Collection collections = Collection();

class Collection {
  String admin = "admin";
  String user = "users";
  String sticker = 'Sticker';
  String wallpaper = 'Wallpaper';
}
//endregion

//region storage Name
const STICKER = 'STICKER';
const WALLPAPER = 'wallpaper';
//endregion

// region UserKey Strings
UserKeys userKeys = UserKeys();

const LightModeLive = 'LightModeLive';

class UserKeys {
  String uid = 'uid';
  String name = "name";
  String email = "email";
  String photoUrl = "photoUrl";
  String password = "password";
  String caseSearch = "caseSearch";
  String phoneNumber = "phoneNumber";
  String lastSeen = "lastSeen";
  String isTester = "isTester";
  String userRole = "userRole";
  String reportUserCount = "reportUserCount";
  String isEmailLogin = "isEmailLogin";
  String createdAt = 'createdAt';
  String updatedAt = 'updatedAt';
}
//endregion
