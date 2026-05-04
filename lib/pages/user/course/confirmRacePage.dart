import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'confirmRaceCtrl.dart';
import 'confirmRaceState.dart';

class ConfirmRacePage extends ConsumerWidget {
  final ConfirmRaceState params;

  const ConfirmRacePage({super.key, required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ref.listen<ConfirmRaceState>(
      confirmRaceControllerProvider(params),
          (previous, next) {
        if (!next.isLoading && next.errorMessage == null) {
          if (context.mounted) {
            Navigator.pop(context);
          }
        }
        if (next.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
        }
      },
    );
    final state = ref.watch(confirmRaceControllerProvider(params));
    final notifier = ref.read(confirmRaceControllerProvider(params).notifier);
    final theme = Theme.of(context);



    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Détails de la course", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // INFOS MOTARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child: Image.asset('assets/images/moto.png', width: 40),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            params.selectedBiker?.name ?? "Motard en cours d'attribution",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const Text("Motard sélectionné", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // RÉCAPITULATIF TRAJET
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  _buildRouteItem(Icons.circle, Colors.green, "Point de départ", params.startAddress),
                  Padding(
                    padding: const EdgeInsets.only(left: 11),
                    child: Align(alignment: Alignment.centerLeft, child: Container(width: 2, height: 30, color: Colors.grey[200])),
                  ),
                  _buildRouteItem(Icons.location_on, Colors.red, "Destination", params.destinationName),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // PAIEMENT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _priceRow("Montant estimé", "${params.amount} FC"),
                  const Divider(height: 30),
                  _priceRow("Total", "${params.amount} FC", isTotal: true),
                ],
              ),
            ),

            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20),
               // child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white),
        child: ElevatedButton(
          onPressed: state.isLoading ? null : () async {
            final race = await notifier.confirmAndCreate();
            if (race != null && context.mounted) {
              Navigator.pop(context); // Retour ou vers page de suivi
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF008E53),
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: state.isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("CONFIRMER LA COURSE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildRouteItem(IconData icon, Color color, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        )
      ],
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 16 : 14)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 18 : 14, color: isTotal ? const Color(0xFF008E53) : Colors.black)),
      ],
    );
  }
}