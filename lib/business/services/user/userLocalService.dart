import '../../models/user/user.dart';

abstract class UserLocalService {
  Future<User?> getUser();
  Future<bool> saveUser(User user);
  Future<bool> deleteUser();
}
