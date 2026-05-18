import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/framework/user/userNetworkServiceImpl.dart';
import 'walletState.dart';

class WalletController extends StateNotifier<WalletState> {
  final UserNetworkServiceImpl _networkService;

  WalletController(this._networkService) : super(WalletState()) {
    fetchWalletBalance();
  }

  Future<void> fetchWalletBalance() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final walletData = await _networkService.getWallet();
      state = state.copyWith(wallet: walletData, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll("Exception: ", ""),
      );
    }
  }

  void rechargerWallet() {
    print("Action : Recharger le compte");
  }

  void transfererFonds() {
    print("Action : Transférer les fonds");
  }
}

final walletControllerProvider = StateNotifierProvider<WalletController, WalletState>((ref) {
  return WalletController(UserNetworkServiceImpl());
});