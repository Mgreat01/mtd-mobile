import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/pages/user/course/confirmRacePage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/course/confirmRaceState.dart';
//import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/RaceTurackingPage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';
class UserHomePage extends ConsumerWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final state = ref.watch(userHomeControllerProvider);
    final notifier = ref.read(userHomeControllerProvider.notifier);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final MapController mapController = MapController();
    final TextEditingController searchController = TextEditingController();
    return Scaffold(
      body: Stack(
        children: [
          _buildInteractiveMap(state, notifier, colorScheme),

          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: _buildSearchBar(theme),
          ),

          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: _buildBookingCard(context, theme, state, notifier),
          ),

          if (state.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildInteractiveMap(UserHomeState state, UserHomeController notifier, ColorScheme colorScheme) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: state.myLocation,
        initialZoom: 15.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.votreapp.taxi',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: state.myLocation,
              width: 60,
              height: 60,
              child: _buildUserLocationMarker(colorScheme),
            ),

            ...state.nearbyBikers.map((biker) {
              final isSelected = state.selectedBiker?.id == biker.id;

              return Marker(
                point: biker.position,
                width: 60,
                height: 60,
                child: GestureDetector(
                  onTap: () => notifier.selectBiker(biker),
                  child: Column(
                    children: [
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.green, width: 1),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                          ),
                          child: Text(
                            biker.name,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        ),
                      Image.asset(
                        'assets/moto.png',
                        width: 40,
                        height: 40,
                       color: isSelected ? Colors.green : null,
                        colorBlendMode: isSelected ? BlendMode.srcIn : null,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.two_wheeler, size: 30),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildUserLocationMarker(ColorScheme colorScheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 24),
          const SizedBox(width: 15),
          Text(
            'Où allez-vous ?',
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, ThemeData theme, UserHomeState state, UserHomeController notifier) {
    final String currentPositionString = state.currentAddress ?? "${state.myLocation.latitude},${state.myLocation.longitude}";
    const String destinationName = "Gombe, Kinshasa";
    const double prixEstime = 10000.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: Color(0xFF1E8142), size: 14),
                  Container(width: 2, height: 25, color: Colors.grey.shade300),
                  const Icon(Icons.circle, color: Colors.red, size: 14),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Départ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text('Ma position ($currentPositionString)',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 15),
                    const Text('Destination', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const Text(destinationName, style: TextStyle(fontSize: 14, color: Colors.black87)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (state.selectedBiker != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text("Motard sélectionné : ${state.selectedBiker!.name}",
                  style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: '${prixEstime.toInt()} FC'),
                    TextSpan(
                      text: ' . 10 min',
                      style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.normal, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: state.selectedBiker == null
                    ? null
                    : () {
                  final params = ConfirmRaceState(
                    destinationName: destinationName,
                    startAddress: currentPositionString,
                    amount: prixEstime,
                    selectedBiker: state.selectedBiker!,
                    priceListId: 1,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmRacePage(params: params),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: Text(
                    state.selectedBiker == null ? 'Choisir un motard' : 'Réserver',
                    style: const TextStyle(fontWeight: FontWeight.bold)
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}