import 'package:moto_taxi_digital_mobile/business/models/wallet/wallet.dart';

class WalletState {
  final bool isLoading;
  final Wallet? wallet;
  final String? errorMessage;

  WalletState({
    this.isLoading = false,
    this.wallet,
    this.errorMessage,
  });

  WalletState copyWith({
    bool? isLoading,
    Wallet? wallet,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WalletState(
      isLoading: isLoading ?? this.isLoading,
      wallet: wallet ?? this.wallet,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
