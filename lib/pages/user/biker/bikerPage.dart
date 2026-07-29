import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:moto_taxi_digital_mobile/pages/user/biker/bikerCtrl.dart';
import 'package:moto_taxi_digital_mobile/utils/mapbox_config.dart';
import 'bikerState.dart';

class BikerPage extends ConsumerStatefulWidget {
  const BikerPage({super.key});

  @override
  ConsumerState<BikerPage> createState() => _BikerPageState();
}

class _BikerPageState extends ConsumerState<BikerPage> {
  MapboxMap? _mapboxMap;
  PolylineAnnotationManager? _polylineManager;
  PolylineAnnotation? _routePolyline;
  PointAnnotationManager? _pointManager;
  PointAnnotation? _passengerMarker;

  Future<void> _renderRoute(BikerState state) async {
    if (_polylineManager == null || _pointManager == null) return;

    if (_routePolyline != null) {
      await _polylineManager!.delete(_routePolyline!);
      _routePolyline = null;
    }
    if (_passengerMarker != null) {
      await _pointManager!.delete(_passengerMarker!);
      _passengerMarker = null;
    }
    if (state.routeCoordinates.length < 2) return;

    final coordinates = state.routeCoordinates
        .where((coordinate) => coordinate.length >= 2)
        .map((coordinate) => Position(coordinate[0], coordinate[1]))
        .toList();
    if (coordinates.length < 2) return;

    _routePolyline = await _polylineManager!.create(
      PolylineAnnotationOptions(
        geometry: LineString(coordinates: coordinates),
        lineColor: 0xFF1565C0,
        lineWidth: 7,
        lineOpacity: 0.9,
      ),
    );

    final markerData = await rootBundle.load('assets/images/location.png');
    _passengerMarker = await _pointManager!.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: coordinates.last),
        image: markerData.buffer.asUint8List(),
        iconSize: 0.12,
      ),
    );

    final middle = coordinates[coordinates.length ~/ 2];
    await _mapboxMap?.flyTo(
      CameraOptions(center: Point(coordinates: middle), zoom: 13),
      MapAnimationOptions(duration: 1000),
    );
  }

  @override
  void initState() {
    super.initState();

    ref.listenManual(bikerControllerProvider.select((s) => s.currentPosition), (
      previous,
      next,
    ) {
      if (previous != next) {
        print("Move map => ${next.latitude}");

        _mapboxMap?.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(next.longitude, next.latitude)),
            zoom: 15,
          ),
          MapAnimationOptions(duration: 1000),
        );
      }
    });

    ref.listenManual(bikerControllerProvider, (prev, next) {
      final prevCount = prev?.notifications.length ?? 0;
      final nextCount = next.notifications.length;

      if (nextCount > prevCount) {
        final newNotif = next.notifications.first;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newNotif.title),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    ref.listenManual(
      bikerControllerProvider.select((state) => state.routeCoordinates),
      (previous, next) {
        if (previous != next) {
          _renderRoute(ref.read(bikerControllerProvider));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bikerControllerProvider);
    final notifier = ref.read(bikerControllerProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isServiceActive = state.isOnline || notifier.isRaceActive;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // Carte Mapbox
          MapWidget(
            key: const ValueKey("mapWidget"),
            styleUri: MapboxConfig.navigationStyle,
            cameraOptions: CameraOptions(
              center: Point(
                coordinates: Position(
                  state.currentPosition.longitude,
                  state.currentPosition.latitude,
                ),
              ),
              zoom: 15.0,
            ),
            onMapCreated: (controller) async {
              _mapboxMap = controller;
              _polylineManager = await controller.annotations
                  .createPolylineAnnotationManager();
              _pointManager = await controller.annotations
                  .createPointAnnotationManager();
              await controller.location.updateSettings(
                LocationComponentSettings(enabled: true, pulsingEnabled: true),
              );
              await _renderRoute(state);
            },
          ),

          if (state.activeRace != null)
            Positioned(
              top: 105,
              left: 20,
              right: 20,
              child: _buildActiveRouteCard(state, theme, colorScheme),
            ),

          // Bouton recentrer
          Positioned(
            right: 20,
            bottom: isServiceActive ? 130 : 330,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: colorScheme.surface,
              onPressed: () {
                _mapboxMap?.flyTo(
                  CameraOptions(
                    center: Point(
                      coordinates: Position(
                        state.currentPosition.longitude,
                        state.currentPosition.latitude,
                      ),
                    ),
                    zoom: 15,
                  ),
                  MapAnimationOptions(duration: 1000),
                );
              },
              child: Icon(Icons.my_location, color: colorScheme.primary),
            ),
          ),
          // Bouton service
          if (isServiceActive)
            Positioned(
              bottom: 200,
              left: 30,
              right: 30,
              child: _buildServiceButton(state, notifier, colorScheme),
            )
          else
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  _buildRevenueCard(state, theme, colorScheme),
                  const SizedBox(height: 12),
                  _buildServiceButton(state, notifier, colorScheme),
                  const SizedBox(height: 12),
                  _buildQuickAccess(theme, colorScheme),
                ],
              ),
            ),

          if (state.isLoading)
            LinearProgressIndicator(
              color: colorScheme.primary,
              backgroundColor: colorScheme.primaryContainer,
            ),
        ],
      ),
    );
  }

  Widget _buildActiveRouteCard(
    BikerState state,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final race = state.activeRace!;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Course n° ${race.id} · Passager",
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              race.startingPoint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (state.routeCoordinates.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "${state.routeDistanceKm?.toStringAsFixed(1) ?? '--'} km"
                " · ${state.routeDurationMin?.ceil() ?? '--'} min",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if (state.routeError != null) ...[
              const SizedBox(height: 8),
              Text(
                state.routeError!,
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueCard(
    BikerState state,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
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
            _rowInfo(
              "Revenus d'aujourd'hui",
              "${state.dailyRevenue} CDF",
              colorScheme,
            ),
            _rowInfo(
              "Courses terminées",
              "${state.completedRacesCount}",
              colorScheme,
            ),
            _rowInfo("Solde wallet", state.walletBalance, colorScheme),
            const Divider(height: 30),
            TextButton(
              onPressed: () {},
              child: Text(
                "VOIR MES REVENUS",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
          Text(
            label,
            style: TextStyle(color: colorScheme.outline, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton(
    BikerState state,
    BikerController notifier,
    ColorScheme colorScheme,
  ) {
    final bool isBusy = notifier.isRaceActive;

    if (isBusy) {
      return ElevatedButton.icon(
        onPressed:
            null, // Désactivé : on ne peut pas arrêter le service en course
        icon: const Icon(Icons.directions_bike, color: Colors.white70),
        label: const Text(
          "COURSE EN COURS...",
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade800.withOpacity(
            0.6,
          ), // Couleur d'avertissement
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }

    // Cas 2 : État normal (En ligne ou Hors ligne)
    return ElevatedButton.icon(
      onPressed: () => notifier.toggleService(),
      icon: Icon(
        state.isOnline ? Icons.power_settings_new : Icons.play_arrow,
        color: colorScheme.onPrimary,
      ),
      label: Text(
        state.isOnline ? "ARRÊTER LE SERVICE" : "COMMENCER LE SERVICE",
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: state.isOnline
            ? colorScheme.error
            : colorScheme.primary,
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
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Accès rapide",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
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
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context, BikerState state) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return ListView.builder(
          itemCount: state.notifications.length,
          itemBuilder: (_, i) {
            final n = state.notifications[i];

            return ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(n.title),
              subtitle: Text(n.message),
            );
          },
        );
      },
    );
  }
}
