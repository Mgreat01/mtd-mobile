import '../../models/user/authentification.dart';
import '../../models/user/user.dart';
import '../../models/user/verifyOtp.dart';

abstract class UserNetworkService {
  Future<User?> login(Authentication authentication);
  Future<bool>  verifyOtp(VerifyOtp verifyOtp);
}
