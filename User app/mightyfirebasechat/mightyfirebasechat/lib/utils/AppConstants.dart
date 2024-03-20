//region start region
const AppName = 'Mighty Chat';
//endregion

//region agora call key
const agoraVideoCallId = "YOUR AGORA ID";
//endregion

//region firebase app id
const mFirebaseAppId = 'YOUR FIREBASE APP ID';
const mAppIconUrl = 'https://firebasestorage.googleapis.com/v0/b/$mFirebaseAppId/o/app_icon.png?alt=media&token=738b073d-c575-4a79-a257-de052dadd2e3';
//endregion

//region Notification
const mOneSignalAppId = 'YOUR ONESIGNAL APP ID';
const mOneSignalRestKey = 'YOUR ONE SIGNAL REST API KEY';
const mOneSignalChannelId = 'YOUR ONESIGNAL CHANNEL ID';
//endregion

//region AdMobIntegration
const mAdMobAppId = 'YOUR ADMOB APP ID';
const mAdMobBannerId = 'YOUR ADMOB BANNER ID';
const mAdMobInterstitialId = 'YOUR ADMOB INETRSTITIAL ID';
//endregion

//region copyright
const copyRight = '';
//endregion

//region country code
const defaultCountry = 'IN';
const defaultCountryCode = '+91';
const defaultLanguage = 'en';
//endregion

//region AppUrls
const termsAndConditionURL = 'https://meetmighty.com/codecanyon/document/mightychat/#mm-help-support';
const privacyPolicy = 'https://support.meetmighty.com/page/privacy-policy';
const supportURL = 'https://support.meetmighty.com/';
const mailto = '';
//endregion

List<String> rtlLanguage = ['ar', 'ur'];

const SEARCH_KEY = "Search";

const LANGUAGE = "LANGUAGE";
const SELECTED_LANGUAGE = "SELECTED_LANGUAGE";

enum MessageType { TEXT, IMAGE, VIDEO, AUDIO, STICKER, DOC, LOCATION, VOICE_NOTE }

const TEXT = "TEXT";
const IMAGE = "IMAGE";
const VIDEO = "VIDEO";
const AUDIO = "AUDIO";
const DOC = "DOC";
const STICKER = "STICKER";
const LOCATION = "LOCATION";
const VOICE_NOTE = "VOICE_NOTE";

extension MessageExtension on MessageType {
  String? get name {
    switch (this) {
      case MessageType.TEXT:
        return 'TEXT';
      case MessageType.IMAGE:
        return 'IMAGE';
      case MessageType.VIDEO:
        return 'VIDEO';
      case MessageType.AUDIO:
        return 'AUDIO';
      case MessageType.LOCATION:
        return 'LOCATION';
      case MessageType.DOC:
        return 'DOC';
      case MessageType.STICKER:
        return 'STICKER';
      case MessageType.VOICE_NOTE:
        return 'VOICE_NOTE';
      default:
        return null;
    }
  }
}

const EXCEPTION_NO_USER_FOUND = "EXCEPTION_NO_USER_FOUND";

//FireBase Collection Name
const MESSAGES_COLLECTION = "messages";
const USER_COLLECTION = "users";
const CONTACT_COLLECTION = "contact";
const STORY_COLLECTION = 'story';
const CHAT_REQUEST = 'chatRequest';
const ADMIN = 'admin';
//const GROUP_COLLECTION = 'groups';
const GROUPS_COLLECTION = 'group';
const GROUP_CHATS = 'chats';
const GROUP_GROUPCHATS = 'groupChats';
const DEVICE_COLLECTION = 'device';
const WALLPAPER = 'Wallpaper';
const STICKER_COLLECTION = 'Sticker';
const SETTING = 'Setting';

const USER_PROFILE_IMAGE = "userProfileImage";
const CHAT_DATA_IMAGES = "chatImages";
const STORY_DATA_IMAGES = "storyImages";
const GROUP_PROFILE_IMAGE = "groupProfileImage";
const GROUP_PROFILE_IMAGES = "groupChatImages";
// Call Status For Call Logs
const CALLED_STATUS_DIALLED = "dialled";
const CALLED_STATUS_RECEIVED = "received";
const CALLED_STATUS_MISSED = "missed";

/* Theme Mode Type */
const ThemeModeLight = 0;
const ThemeModeDark = 1;
const ThemeModeSystem = 2;

//Default Font Size
const FONT_SIZE_SMALL = 12;
const FONT_SIZE_MEDIUM = 16;
const FONT_SIZE_LARGE = 20;

const chatMsgRadius = 12.0;
//Pagination Setting
const PER_PAGE_CHAT_COUNT = 50;

//region SharePreference Key
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const userId = 'userId';
const userDisplayName = 'userDisplayName';
const userEmail = 'userEmail';
const userPhotoUrl = 'userPhotoUrl';
const isEmailLogin = "isEmailLogin";
const userStatus = "userStatus";
const userMobileNumber = "userMobileNumber";
const playerId = "playerId";
const reportCount = "reportCount";
const selectedMember = "selectedMember";
const isSocialLogin = "isSocialLogin";
const CURRENT_GROUP_ID = "current_group_chat_id";
const isRemember = "isRemember";
const userPassword = 'userPassword';
//endregion

//region DefaultSettingConstant
const FONT_SIZE_INDEX = "FONT_SIZE_INDEX";
const FONT_SIZE_PREF = "FONT_SIZE_PREF";
const IS_ENTER_KEY = "IS_ENTER_KEY";
const SELECTED_WALLPAPER = "SELECTED_WALLPAPER";
const SELECTED_WALLPAPER_CATEGORY = "SELECTED_WALLPAPER_CATEGORY";
//endregion

//region message type
const TYPE_AUDIO = "audio";
const TYPE_VIDEO = "video";
const TYPE_Image = "image";
const TYPE_DOC = "doc";
const TYPE_LOCATION = "current_location";
const TYPE_VOICE_NOTE = "voice_note";
const TYPE_STICKER = "sticker";
//endregion
