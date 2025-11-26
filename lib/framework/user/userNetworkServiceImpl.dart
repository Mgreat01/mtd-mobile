import 'package:moto_taxi_digital_mobile/business/models/user/authentification.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/verifyOtp.dart';
import 'package:moto_taxi_digital_mobile/business/services/user/userNetworkService.dart';

class UserNetworkServiceImpl extends UserNetworkService {
  @override
  Future<User?> login(Authentication authentication) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyOtp(VerifyOtp verifyOtp) {
    // TODO: implement verifyOtp
    throw UnimplementedError();
  }

}