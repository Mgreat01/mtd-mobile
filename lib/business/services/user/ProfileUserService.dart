import '../../models/user/user.dart';


abstract class ProfileUserService {
  Future<User> getProfile(String token);
}
