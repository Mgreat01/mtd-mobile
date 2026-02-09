import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        // 1. CARTE INTERACTIVE
        _buildInteractiveMap(colorScheme),

        // 2. BARRE DE RECHERCHE FLOTTANTE
        Positioned(
          top: 120,
          left: 20,
          right: 20,
          child: _buildSearchBar(theme),
        ),

        // 3. CARTE DE RÉSERVATION INFÉRIEURE
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: _buildBookingCard(theme),
        ),
      ],
    );
  }

  Widget _buildInteractiveMap(ColorScheme colorScheme) {
    final LatLng myLocation = LatLng(-4.322447, 15.307045);

    return FlutterMap(
      options: MapOptions(
        initialCenter: myLocation,
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
              point: myLocation,
              width: 60,
              height: 60,
              child: _buildUserLocationMarker(colorScheme),
            ),
            _buildMotoMarker(LatLng(-4.324, 15.308)),
            _buildMotoMarker(LatLng(-4.320, 15.305)),
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
            color: colorScheme.primary.withOpacity(0.2),
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

  Marker _buildMotoMarker(LatLng position) {
    return Marker(
      point: position,
      width: 35,
      height: 35,
      child: const Icon(Icons.two_wheeler, color: Colors.black87, size: 28),
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

  Widget _buildBookingCard(ThemeData theme) {
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
                    const Text('Ma position actuelle', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 15),
                    const Text('Destination', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text('...', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
                  children: [
                    const TextSpan(text: '10 000 FC'),
                    TextSpan(
                      text: ' . 10 min',
                      style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.normal, fontSize: 14),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008E53),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Réserver', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}