import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'walletCtrl.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletControllerProvider);
    final notifier = ref.read(walletControllerProvider.notifier);

    final  currentBalance = state.wallet?.balance ?? "0.00";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => notifier.fetchWalletBalance(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                const Text(
                  "Mon Wallet",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                if (state.isLoading && state.wallet == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF1E2A3A))),
                  )
                else if (state.errorMessage != null && state.wallet == null)
                  _buildErrorCard(state.errorMessage!, notifier.fetchWalletBalance)
                else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2A3A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                "Solde disponible",
                                style: TextStyle(color: Colors.white70),
                              ),
                              Icon(Icons.account_balance_wallet, color: Colors.white70)
                            ],
                          ),
                          const SizedBox(height: 20),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Expanded(
                                child: Text(
                                  currentBalance.toString(),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                "FC",
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _actionButton(Icons.add, "Recharger", notifier.rechargerWallet),
                              _actionButton(Icons.send, "Transférer", notifier.transfererFonds),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],

                const SizedBox(height: 30),

                const Text(
                  "Détails du compte",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                _infoCard(
                  icon: Icons.info_outline,
                  title: "Statut du compte",
                  value: state.wallet != null ? "ACTIF" : "---",
                  valueColor: Colors.green,
                ),

                const SizedBox(height: 10),

                _infoCard(
                  icon: Icons.verified_user_outlined,
                  title: "Niveau de sécurité",
                  value: "Élevé",
                  valueColor: Colors.blue,
                ),

                if (state.isLoading && state.wallet != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: Center(child: LinearProgressIndicator(color: Color(0xFF1E2A3A))),
                  )
              ],
            ),
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action scan QR Code
        },
        backgroundColor: const Color(0xFF1E2A3A),
        child: const Icon(Icons.qr_code, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _actionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white24,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))
          ],
        ),
      ),
    );
  }

  /// Info Card Widget
  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  /// Error UI Feedback Widget
  Widget _buildErrorCard(String error, VoidCallback onRetry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Text(error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E2A3A)),
            icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
            label: const Text("Réessayer", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}