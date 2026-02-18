import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/pages/user/owner/ownerCtrl.dart';


class OwnerHomePage extends ConsumerWidget {
  const OwnerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ownerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
        children: [
          // --- SECTION STATISTIQUES (Cartes de couleur) ---
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.5,
            children: [
              _statCard("Motos actives", state.stats['assigned_bikes']?.toString() ?? "0", Icons.motorcycle, Colors.green),
              _statCard("Disponibles", state.stats['available_bikes']?.toString() ?? "0", Icons.vpn_key, Colors.blue),
              _statCard("En maintenance", "0", Icons.build, Colors.orange),
              _statCard("Hors service", "0", Icons.error_outline, Colors.red),
            ],
          ),

          const SizedBox(height: 30),
          Text("Activité des motos", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

          // --- LISTE DES MOTOS ---
          ...state.bikes.map((bike) => _buildBikeItem(bike, colorScheme)).toList(),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildBikeItem(dynamic bike, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.two_wheeler)),
        title: Text("${bike.brand} ${bike.model}"),
        subtitle: Text("Matricule: ${bike.matricule}"),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: Colors.white),
          child: const Text("Détails"),
        ),
      ),
    );
  }
}