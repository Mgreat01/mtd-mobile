import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userLocalService.dart';

class UserLocalServiceImpl implements UserLocalService {
  GetStorage? box;

  UserLocalServiceImpl({this.box});

  @override
  Future<bool> deleteUser() async {
    if (box == null) return false;
    await box!.remove("user");
    return true;
  }

  @override
  Future<User?> getUser() async {
    if (box == null) return null;

    var userJson = box!.read("user");

    if (userJson == null) return null;

    if (userJson is String) {
      return User.fromJson(jsonDecode(userJson));
    }

    return User.fromJson(userJson);
  }

  @override
  Future<bool> saveUser(User user) async {
    if (box == null) return false;

    var data = user.toJson();
    await box!.write("user", data);

    return true;
  }
}