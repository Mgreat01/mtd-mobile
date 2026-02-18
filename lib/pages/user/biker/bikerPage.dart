import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/bikerCtrl.dart';
import 'bikerState.dart';

class BikerPage extends ConsumerStatefulWidget {
  const BikerPage({super.key});

  @override
  ConsumerState<BikerPage> createState() => _BikerPageState();
}

class _BikerPageState extends ConsumerState<BikerPage> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bikerControllerProvider);
    final notifier = ref.read(bikerControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    ref.listen(bikerControllerProvider.select((s) => s.currentPosition), (previous, next) {
      if (next != previous) {
        print("UI : Déplacement de la carte vers la latitude : ${next.latitude}");
        _mapController.move(next, 15.0);
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // 1. FOND : CARTE
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: state.currentPosition,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'moto_taxi_digital_mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: state.currentPosition,
                    width: 60,
                    height: 60,
                    child: Icon(
                      Icons.motorcycle,
                      color: state.isOnline ? colorScheme.primary : colorScheme.error,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. OVERLAY : CARTE DE REVENUS
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: _buildRevenueCard(state, theme, colorScheme),
          ),

          // 3. BOUTON RECENTRER
          Positioned(
            right: 20,
            bottom: 330,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: colorScheme.surface,
              onPressed: () => _mapController.move(state.currentPosition, 15.0),
              child: Icon(Icons.my_location, color: colorScheme.primary),
            ),
          ),

          // 4. PANNEAU DE CONTRÔLE
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _buildServiceButton(state, notifier, colorScheme),
                const SizedBox(height: 12),
                _buildQuickAccess(theme, colorScheme),
              ],
            ),
          ),

          if (state.isLoading)
            LinearProgressIndicator(color: colorScheme.primary, backgroundColor: colorScheme.primaryContainer),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(BikerState state, ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Revenus du jour",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 15),
            _rowInfo("Revenus d'aujourd'hui", "${state.dailyRevenue} CDF", colorScheme),
            _rowInfo("Courses terminées", "${state.completedRacesCount}", colorScheme),
            _rowInfo("Solde wallet", state.walletBalance, colorScheme),
            const Divider(height: 30),
            TextButton(
              onPressed: () {},
              child: Text(
                "VOIR MES REVENUS",
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.outline, fontSize: 14)),
          Text(value, style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.onSurface
          )),
        ],
      ),
    );
  }

  Widget _buildServiceButton(BikerState state, BikerController notifier, ColorScheme colorScheme) {
    return ElevatedButton.icon(
      onPressed: () => notifier.toggleService(),
      icon: Icon(
        state.isOnline ? Icons.power_settings_new : Icons.play_arrow,
        color: colorScheme.onPrimary,
      ),
      label: Text(
        state.isOnline ? "ARRÊTER LE SERVICE" : "COMMENCER LE SERVICE",
        style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        // Utilisation de errorContainer pour l'arrêt et primary pour le début
        backgroundColor: state.isOnline ? colorScheme.error : colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildQuickAccess(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: colorScheme.shadow.withOpacity(0.05), blurRadius: 20)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Accès rapide",
            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.8,
            children: [
              _quickButton("Mon historique", Icons.history, colorScheme),
              _quickButton("Mon portefeuille", Icons.wallet, colorScheme),
              _quickButton("Formation", Icons.school, colorScheme),
              _quickButton("Support", Icons.support_agent, colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickButton(String label, IconData icon, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        // Utilisation de surfaceContainer (ou variant) pour les petits boutons
        color: colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}