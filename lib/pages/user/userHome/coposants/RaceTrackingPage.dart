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

    if (race == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: Text("Course #${race.id}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => notifier.cancelRace(),
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
    Color statusColor = status == 'pending' ? Colors.orange : Colors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: statusColor.withOpacity(0.1),
      child: Center(
        child: Text(
          status == 'pending' ? "⏳ En attente du motard..." : "✅ Course en cours",
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
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
                      const Text("Honda Wave - Noir", style: TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const Text(" 4.8", style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
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
            child: Align(alignment: Alignment.centerLeft, child: Container(width: 2, height: 30, color: Colors.grey.shade200)),
          ),
          _buildLocationRow(Icons.location_on, Colors.red, "Destination", race.destination),
        ],
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String title, String address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(address, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14), overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(dynamic race) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tarif de la course", style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text("${race.name.contains('10 000') ? '10 000' : '8 000'} FC",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF008E53))),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Méthode de paiement", style: TextStyle(color: Colors.grey)),
              Text("Portefeuille Digital", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
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
          backgroundColor: isPending ? Colors.redAccent : const Color(0xFF008E53),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(
          isPending ? "ANNULER LA COURSE" : "COURSE TERMINÉE",
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}