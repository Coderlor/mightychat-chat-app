import '../main.dart';
import '../models/SettingModel.dart';
import '../utils/AppConstants.dart';
import 'BaseService.dart';

class SettingsService extends BaseService {
  SettingsService() {
    ref = fireStore.collection(SETTING);
  }

  setAdmobSettings({AdMobAdsModel? adsModel}) async {
    return ref!.doc("admob").set(adsModel!.toJson());
  }

  Future<AdMobAdsModel> getAdmobSettings() async {
    return await ref!.get().then((value) async {
      if (value.docs.isEmpty) {
        return await setAdmobSettings();
      } else {
        return await ref!.doc('admob').get().then((value) async {
          return AdMobAdsModel.fromJson(value.data() as Map<String, dynamic>);
        }).catchError((e) {
          throw e;
        });
      }
    }).catchError((e) {
      throw e;
    });
  }

  setOneSignalSettings({OneSignalModel? oneSignalModel}) async {
    return ref!.doc("onesignal").set(oneSignalModel!.toJson());
  }

  Future<OneSignalModel> getOneSignalSettings() async {
    return await ref!.get().then((value) async {
      if (value.docs.isEmpty) {
        return await setOneSignalSettings();
      } else {
        return await ref!.doc('onesignal').get().then((value) async {
          return OneSignalModel.fromJson(value.data() as Map<String, dynamic>);
        }).catchError((e) {
          throw e;
        });
      }
    }).catchError((e) {
      throw e;
    });
  }

  setSettings({SettingsModel? settingsModel}) async {
    return ref!.doc("setting").set(settingsModel!.toJson());
  }

  Future<SettingsModel> getSettings() async {
    return await ref!.get().then((value) async {
      if (value.docs.isEmpty) {
        return await setSettings();
      } else {
        return await ref!.doc('setting').get().then((value) async {
          return SettingsModel.fromJson(value.data() as Map<String, dynamic>);
        }).catchError((e) {
          throw e;
        });
      }
    }).catchError((e) {
      throw e;
    });
  }
}
