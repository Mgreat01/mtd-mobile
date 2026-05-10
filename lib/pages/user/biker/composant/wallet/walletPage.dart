import 'package:flutter/material.dart';



class Walletpage extends StatelessWidget {
  const Walletpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// Title
              const Text(
                "Mon Wallet",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// Card Wallet
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2A3A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Top Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "Solde disponible",
                          style: TextStyle(color: Colors.white70),
                        ),
                        Icon(Icons.account_balance_wallet,
                            color: Colors.white70)
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// Balance
                    const Text(
                      "9999942000.00",
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "FC",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),

                    const SizedBox(height: 25),

                    /// Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _actionButton(Icons.add, "Recharger"),
                        _actionButton(Icons.send, "Transférer"),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// Details Title
              const Text(
                "Détails du compte",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              /// Status Card
              _infoCard(
                icon: Icons.info_outline,
                title: "Statut du compte",
                value: "ACTIF",
                valueColor: Colors.green,
              ),

              const SizedBox(height: 10),

              /// Security Card
              _infoCard(
                icon: Icons.verified_user_outlined,
                title: "Niveau de sécurité",
                value: "Élevé",
                valueColor: Colors.blue,
              ),
            ],
          ),
        ),
      ),

      /// Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.home),
              Icon(Icons.account_balance_wallet),
              SizedBox(width: 40), // space for FAB
              Icon(Icons.history),
              Icon(Icons.settings),
            ],
          ),
        ),
      ),

      /// Floating Button (QR)
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E2A3A),
        child: const Icon(Icons.qr_code),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Action Button
  Widget _actionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white24,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        )
      ],
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
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}