import 'dart:io';

import '../../models/user/authentification.dart';
import '../../models/user/user.dart';
import '../../models/user/verifyOtp.dart';
import 'package:moto_taxi_digital_mobile/business/models/searchResult/searchResult.dart';

import '../../models/wallet/wallet.dart';

abstract class UserNetworkService {
  Future<User?> login(Authentication authentication);
  Future<bool> verifyOtp(VerifyOtp verifyOtp);
  Future<User?> registerUser(
    User user, {
    File? profilePhoto,
    File? identityDoc,
    File? registrationCard,
    File? businessLicense,
  });
  Future<User?> getUserProfile(String token);
  Future<String> getAddressFromLatLng(double lat, double lon);
  Future<List<SearchResult>> searchAddresses(String query);
  Future<Wallet> getWallet();
}
