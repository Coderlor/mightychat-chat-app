import 'dart:convert';
import 'dart:io';

import 'package:chat/main.dart';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../utils/AppConstants.dart';

class NotificationService {
  Future<void> sendPushNotifications(String title, String content, {String? recevierUid, String? id, String? image, String? receiverPlayerId, bool? isGrp = false, List<String>? mPlayerIds}) async {
    Map? req;
    var header = {HttpHeaders.authorizationHeader: 'Basic ${appSettingStore.oneSignalRestApi}', HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8', 'Content-Type': 'application/json'};
    if (!recevierUid.isEmptyOrNull) {
      isGrp == true
          ? req = {
              'headings': {
                'en': title,
              },
              'contents': {
                'en': content,
              },
              'data': {'id': recevierUid.validate(), 'isGrp': isGrp},
              'big_picture': image.validate().isNotEmpty ? image.validate() : '',
              'large_icon': image.validate().isNotEmpty ? image.validate() : '',
              'app_id': appSettingStore.oneSignalAppId,
              'android_channel_id': appSettingStore.oneSignalChannelId,
              'include_player_ids': mPlayerIds!.length >= 1 ? mPlayerIds : [recevierUid],
              'android_group': AppName,
            }
          : await chatMessageService.getUserPlayerId(uid: recevierUid).then((value) {
              req = {
                'headings': {
                  'en': title,
                },
                'contents': {
                  'en': content,
                },
                'data': {'id': recevierUid.validate(), 'isGrp': isGrp},
                'big_picture': image.validate().isNotEmpty ? image.validate() : '',
                'large_icon': image.validate().isNotEmpty ? image.validate() : '',
                'app_id': appSettingStore.oneSignalAppId,
                'android_channel_id': appSettingStore.oneSignalChannelId,
                'include_player_ids': isGrp == true ? mPlayerIds : [value.oneSignalPlayerId.validate()],
                'android_group': AppName,
              };
            });
    } else {
      req = {
        'headings': {
          'en': title,
        },
        'contents': {
          'en': content,
        },
        'big_picture': image.validate().isNotEmpty ? image.validate() : '',
        'large_icon': image.validate().isNotEmpty ? image.validate() : '',
        'app_id': appSettingStore.oneSignalAppId,
        'android_channel_id': appSettingStore.oneSignalChannelId,
        'include_player_ids': isGrp == true && mPlayerIds!.length >= 1 ? mPlayerIds : [receiverPlayerId],
        'android_group': AppName,
      };
    }

    log('======Notification request $req');

    if (appSettingStore.oneSignalAppId.isEmptyOrNull) {
      userService.updateDocument({
        'oneSignalPlayerId': getStringAsync(playerId),
      }, loginStore.mId).whenComplete(() async {
        Response res = await post(
          Uri.parse('https://onesignal.com/api/v1/notifications'),
          body: jsonEncode(req),
          headers: header,
        );

        if (res.statusCode.isSuccessful()) {
        } else {
          throw errorSomethingWentWrong;
        }
      });
    } else {
      Response res = await post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        body: jsonEncode(req),
        headers: header,
      );

      if (res.statusCode.isSuccessful()) {
      } else {
        throw errorSomethingWentWrong;
      }
    }
  }
}
