import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';

class RaceTrackingPage extends ConsumerWidget {
  const RaceTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userHomeControllerProvider);
    final notifier = ref.read(userHomeControllerProvider.notifier);
    final race = state.currentRace;

    if (race == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: Text("Course #${race.id}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildStatusHeader(race.status),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [

                  _buildBikerInfoCard(state),

                  const SizedBox(height: 20),

                  if (race.status == 'pending')
                    _buildPinCodeCard(race.pinCode ?? "----"),

                  const SizedBox(height: 20),


                  _buildTripDetails(race),

                  const SizedBox(height: 25),


                  _buildPriceSummary(race),

                  const SizedBox(height: 40),

                   _buildActionButton(race, notifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String status) {
    bool isPending = status == 'pending';
    Color statusColor = isPending ? Colors.orange : Colors.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: statusColor.withOpacity(0.1),
      child: Center(
        child: Text(
          isPending ? " Le motard est en route vers vous" : " Course en cours vers destination",
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPinCodeCard(String pin) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            "CODE DE VÉRIFICATION",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          Text(
            pin,
            style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 12,
                color: Colors.black87
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Donnez ce code au motard pour démarrer la course",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBikerInfoCard(UserHomeState state) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF008E53),
                  child: Icon(Icons.person, color: Colors.white, size: 35),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.selectedBiker?.name ?? "Chargement...",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Text("Moto vérifiée • Kinshasa",
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                const Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        Text(" 4.8", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text("Note", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleAction(Icons.call, "Appeler", Colors.green),
                _buildCircleAction(Icons.message, "Message", Colors.blue),
                _buildCircleAction(Icons.security, "SOS", Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTripDetails(dynamic race) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildLocationRow(Icons.radio_button_checked, Colors.green, "Départ", race.startingPoint),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 2, height: 25, color: Colors.grey.shade200)
            ),
          ),
          _buildLocationRow(Icons.location_on, Colors.red, "Destination", race.destination),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String title, String address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              Text(address,
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(dynamic race) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Tarif estimé", style: TextStyle(color: Colors.grey, fontSize: 15)),
            Text("${race.priceListId == 1 ? '10 000' : '8 000'} FC",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF008E53))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Méthode de paiement", style: TextStyle(color: Colors.grey, fontSize: 14)),
            Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 5),
                const Text("Portefeuille", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(dynamic race, UserHomeController notifier) {
    bool isPending = race.status == 'pending';

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          if (isPending) {
            notifier.cancelRace();
          } else {
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isPending ? Colors.redAccent : Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(
          isPending ? "ANNULER LA COURSE" : "COURSE EN COURS",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}