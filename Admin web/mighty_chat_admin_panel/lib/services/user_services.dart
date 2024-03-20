import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../model/user_model.dart';
import '../services/base_service.dart';
import '../utils/constant.dart';
import '../utils/config.dart';

class UserService extends BaseService<UserModel> {
  CollectionReference? userRef;

  UserService() {
    ref = fireStore.collection(collections.admin).withConverter<UserModel>(
          fromFirestore: (snapshot, options) => UserModel.fromJson(snapshot.data()!),
          toFirestore: (value, options) => value.toJson(),
        );
    userRef = fireStore.collection(collections.user);
  }

  Future<UserModel> userByEmail(String? email) async {
    return ref!.limit(1).where(userKeys.email, isEqualTo: email).get().then((value) => value.docs.first.data());
  }

  Future<int> getTotalUsers() async {
    return await fireStore.collection(collections.user).get().then((value) => value.size);
  }

  Future<int> getTotalNumberOfActiveUsers() async {
    return await fireStore.collection(collections.user).where("isActive", isEqualTo: true).get().then((value) => value.size);
  }

  Future<int> getTotalNumberOfInactiveUsers() async {
    return await fireStore.collection(collections.user).where("isActive", isEqualTo: false).get().then((value) => value.size);
  }

  // Stream<List<UserModel>> getLast7daysUsers() {
  //   return fireStore
  //       .collection(collections.user)
  //       .where("createdAt", isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(Duration(days: 6))))
  //       .orderBy("createdAt", descending: true)
  //       .snapshots()
  //       .map((event) => event.docs.map((e) => UserModel.fromJson(e.data())).toList());
  // }
  //
  // Stream<List<UserModel>> getLast7daysInactiveUsers() {
  //   return fireStore
  //       .collection(collections.user)
  //       .where("isActive", isEqualTo: false)
  //       .orderBy("createdAt", descending: true)
  //       .snapshots()
  //       .map((event) => event.docs.map((e) => UserModel.fromJson(e.data())).toList());
  // }

  Query userListWithPagination() {
    return fireStore.collection(collections.user).orderBy("createdAt", descending: true);
  }
  //
  // Query inactiveUserListWithPagination() {
  //   return fireStore.collection(collections.user).where("isActive", isEqualTo: false);
  // }

  Future<UserModel> getUser({String? email}) {
    return ref!.where(userKeys.email, isEqualTo: email).limit(1).get().then(
      (value) {
        if (value.docs.length == 1) {
          if (value.docs.first.data().userRole != "admin") {
            throw accessDenied;
          }
          return value.docs.first.data();
        } else {
          throw userNotFound;
        }
      },
    );
  }

  Stream<List<UserModel>> getAllUsers() {
    return fireStore
        .collection(collections.user)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((event) => event.docs.map((e) => UserModel.fromJson(e.data())).toList());
  }

  Future<void> setActiveUser({required bool isActive, required String uid}) async {
    fireStore.collection(collections.user).doc(uid).update({'isActive': isActive});
  }
}
