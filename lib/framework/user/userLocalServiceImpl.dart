import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userLocalService.dart';

class UserLocalServiceImpl implements UserLocalService {
  GetStorage? box;

  UserLocalServiceImpl({this.box});

  @override
  Future<bool> deleteUser() async{
    await box?.remove("user");
    return true ;
  }

  @override
  Future<User?> getUser() async{
    var userJson = await box?.read("user");
    if(userJson == null ){
      return null;
    }
    var user = User.fromJson(userJson);

    return user;
  }

  @override
  Future<bool> saveUser(User user) async{
    var data = user.toJson();
    await box?.write("user", jsonEncode(data));
    return true;

  }

}