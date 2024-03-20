import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path/path.dart';

import '../../main.dart';
import '../../models/UserModel.dart';
import '../../services/BaseService.dart';
import '../../utils/AppConstants.dart';

class UserService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  UserService() {
    ref = fireStore.collection(USER_COLLECTION);
  }

  Future<void> updateUserInfo(Map data, String id, {File? profileImage}) async {
    if (profileImage != null) {
      String fileName = basename(profileImage.path);
      Reference storageRef = _storage.ref().child("$USER_PROFILE_IMAGE/$fileName");
      UploadTask uploadTask = storageRef.putFile(profileImage);
      await uploadTask.then((e) async {
        await e.ref.getDownloadURL().then((value) {
          loginStore.setPhotoUrl(aPhotoUrl: value);
          setValue(userPhotoUrl, value);

          data.putIfAbsent("photoUrl", () => value);
        });
      });
    }

    return ref!.doc(id).update(data as Map<String, Object?>);
  }

  Future<void> updateUserStatus(Map data, String id) async {
    return ref!.doc(id).update(data as Map<String, Object?>);
  }

  Future<UserModel> getUser({String? email}) {
    return ref!.where("email", isEqualTo: email).limit(1).get().then((value) {
      if (value.docs.length == 1) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'User Not found';
      }
    });
  }

  Future<UserModel> getUserById({String? val}) {
    return ref!.where("uid", isEqualTo: val).limit(1).get().then((value) {
      if (value.docs.length == 1) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'User Not found';
      }
    });
  }

  Stream<List<UserModel>> users({String? searchText}) {
    return ref!.where('caseSearch', arrayContains: searchText.validate().isEmpty ? null : searchText!.toLowerCase()).snapshots().map((x) {
      return x.docs.map((y) {
        return UserModel.fromJson(y.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Query userWithPagination({String? searchText}) {
    return ref!.where('caseSearch', arrayContains: searchText.validate().isEmpty ? null : searchText!.toLowerCase()).orderBy('createdAt', descending: true);
  }

  Future<UserModel> userByEmail(String? email) async {
    return await ref!.where('email', isEqualTo: email).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'No User Found';
      }
    });
  }

  Stream<UserModel> singleUser(String? id, {String? searchText}) {
    return ref!.where('uid', isEqualTo: id).limit(1).snapshots().map((event) {
      return UserModel.fromJson(event.docs.first.data() as Map<String, dynamic>);
    });
  }

  Future<UserModel> getUserByUserId({String? id}) {
    return ref!.where('uid', isEqualTo: id).get().then((value) {
      log(value.docs);
      return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
    });
  }

  Future<UserModel> userByMobileNumber(String? phone) async {
    return await ref!.where('phoneNumber', isEqualTo: phone).limit(1).get().then((value) {
      if (value.docs.isNotEmpty) {
        return UserModel.fromJson(value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw EXCEPTION_NO_USER_FOUND;
      }
    });
  }

  bool getPreviouslyChat(String uid) {
    return messageRequestStore.userContactList.where((element) => element.uid == uid).length != 0;
  }

  Future<String> blockUser(Map<String, dynamic> data) async {
    return await ref!.doc(getStringAsync(userId)).update(data).then((value) {
      return "User Blocked";
    }).catchError((e) {
      toast(e.toString());
      throw errorSomethingWentWrong;
    });
  }

  Future<String> unBlockUser(Map<String, dynamic> data) async {
    return await ref!.doc(getStringAsync(userId)).update(data).then((value) {
      return "User Blocked";
    }).catchError((e) {
      toast(e.toString());
      throw errorSomethingWentWrong;
    });
  }

  Future<String> reportUser(Map<String, dynamic> data, String reportUserId) async {
    return await ref!.doc(reportUserId).update(data).then((value) {
      return "Account Reported to Mighty Chat";
    }).catchError((e) {
      toast(e.toString());
      throw errorSomethingWentWrong;
    });
  }

  DocumentReference getUserReference({required String uid}) {
    return userService.ref!.doc(uid);
  }

  Future<void> removeDocument(String? id) => userService.ref!.doc(id).delete();

  Future<bool> isUserBlocked(String uid) async {
    return await userService.userByEmail(getStringAsync(userEmail)).then((value) {
      return value.blockedTo!.contains(getUserReference(uid: uid));
    });
  }

  Future isBlockUser({String? id}) {
    bool? isBlock = false;
    return ref!.doc(loginStore.mId).get().then((value1) {
      UserModel user = UserModel.fromJson(value1.data() as Map<String, dynamic>);
      user.blockedTo!.forEach((element) async {
        if (element.id == id) {
          isBlock = true;
        }
      });

      return isBlock;
    });
  }

  Future<List<String>> blockUserList() {
    List<String> blockList = [];
    return ref!.doc(loginStore.mId).get().then((value1) {
      UserModel user = UserModel.fromJson(value1.data() as Map<String, dynamic>);
      user.blockedTo!.forEach((element) async {
        blockList.add(element.id);
      });
      log(blockList);
      //blockUserData(blockList);
      return blockList;
    });
  }
}
