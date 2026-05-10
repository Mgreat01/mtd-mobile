import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moto_taxi_digital_mobile/business/models/race/race.dart';
import 'BikerHistoryCtrl.dart';

class BikerHistoryPage extends ConsumerWidget {
  const BikerHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(BikerHistoryControllerProvider);
    final notifier = ref.read(BikerHistoryControllerProvider.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Mes Courses", style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            tabs: [Tab(text: "En cours"), Tab(text: "Historique")],
            indicatorColor: Colors.green,
            labelColor: Colors.green,
          ),
        ),
        body: state.isLoading && state.allRaces.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
          children: [
            _buildRaceList(notifier.activeRaces, notifier, state.isLoading),
            _buildRaceList(notifier.historyRaces, notifier, state.isLoading, isHistory: true),
          ],
        ),
      ),
    );
  }

  Widget _buildRaceList(List<Race> races, BikerHistoryController notifier, bool isLoading, {bool isHistory = false}) {
    if (races.isEmpty) return const Center(child: Text("Aucune course trouvée"));

    return RefreshIndicator(
      onRefresh: () => notifier.fetchRaces(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: races.length,
        itemBuilder: (context, index) => _buildRaceCard(races[index], notifier, isHistory, isLoading),
      ),
    );
  }

  Widget _buildRaceCard(Race race, BikerHistoryController notifier, bool isHistory, bool isLoading) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("N° ${race.id}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                _buildStatusChip(race.status),
              ],
            ),
            const Divider(height: 25),
            _locationInfo(Icons.circle, Colors.green, race.startingPoint),
            const SizedBox(height: 10),
            _locationInfo(Icons.location_on, Colors.red, race.destination),
            const SizedBox(height: 20),
            if (!isHistory) _buildActionButtons(race, notifier, isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Race race, BikerHistoryController notifier, bool isLoading) {
    String label = "";
    Color color = Colors.green;

    final bool hasActiveRace = notifier.isRaceActive;

    if (race.status == 'pending') {
      if (hasActiveRace) {
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text("FINISSEZ VOTRE COURSE ACTUELLE",
              style: TextStyle(color: Colors.white, fontSize: 12)),
        );
      }
      label = "ACCEPTER LA COURSE";
      color = Colors.green;
    } else if (race.status == 'ongoing') {
      label = "TERMINER LA COURSE";
      color = Colors.orange;
    } else {
      return const SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: isLoading ? null : () => notifier.changeStatus(race.id),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      )
          : Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _locationInfo(IconData icon, Color color, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 12),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = Colors.grey;
    String label = status.toUpperCase();

    switch (status) {
      case 'ongoing': color = Colors.blue; label = "EN COURS"; break;
      case 'pending': color = Colors.orange; label = "EN ATTENTE"; break;
      case 'completed': color = Colors.green; label = "TERMINÉE"; break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}