import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/pages/user/course/confirmRacePage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/course/confirmRaceState.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/coposants/RaceTrackingPage.dart';

import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';
import 'package:moto_taxi_digital_mobile/utils/mapbox_config.dart';
import 'package:flutter/services.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  bool _acceptanceDialogVisible = false;
  bool _bookingPageOpen = false;
  PolylineAnnotationManager? _polylineManager;
  PolylineAnnotation? _routePolyline;
  Future<void> _drawRoute(List<List<double>> coordinates) async {
    if (_polylineManager == null) return;

    if (_routePolyline != null) {
      await _polylineManager!.delete(_routePolyline!);
      _routePolyline = null;
    }

    final validCoordinates = coordinates
        .where((coordinate) => coordinate.length >= 2)
        .map((coordinate) => Position(coordinate[0], coordinate[1]))
        .toList(growable: false);
    if (validCoordinates.length < 2) return;

    final line = LineString(coordinates: validCoordinates);

    _routePolyline = await _polylineManager!.create(
      PolylineAnnotationOptions(
        geometry: line,

        lineColor: 0xFF1E88E5,

        lineWidth: 6,

        lineOpacity: 0.9,
      ),
    );

    final map = _mapboxMap;
    if (map == null) return;
    final camera = await map.cameraForCoordinatesPadding(
      validCoordinates.map((position) => Point(coordinates: position)).toList(),
      CameraOptions(bearing: 0, pitch: 0),
      MbxEdgeInsets(top: 90, left: 45, bottom: 360, right: 45),
      16,
      null,
    );
    await map.flyTo(camera, MapAnimationOptions(duration: 900));
  }

  MapboxMap? _mapboxMap;
  final TextEditingController _searchController = TextEditingController();
  PointAnnotationManager? _pointManager;

  PointAnnotation? _destinationMarker;
  PointAnnotation? _userMarker;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<UserHomeState>(userHomeControllerProvider, (
        previous,
        next,
      ) {
        if (previous?.pickupLocation != next.pickupLocation) {
          print(
            "Nouvelle position reçue : "
            "${next.pickupLocation.latitude}",
          );

          _showUserMarker(
            next.pickupLocation.latitude,
            next.pickupLocation.longitude,
          );

          _mapboxMap?.flyTo(
            CameraOptions(
              center: Point(
                coordinates: Position(
                  next.pickupLocation.longitude,
                  next.pickupLocation.latitude,
                ),
              ),
              zoom: 15,
            ),
            MapAnimationOptions(duration: 1000),
          );
        }
      });
    });
    ref.listenManual<UserHomeState>(userHomeControllerProvider, (
      previous,
      next,
    ) async {
      if (previous?.routeCoordinates != next.routeCoordinates) {
        await _drawRoute(next.routeCoordinates);
      }
    });
    ref.listenManual<Map<String, dynamic>?>(
      userHomeControllerProvider.select((state) => state.bikerAcceptance),
      (previous, next) {
        if (next != null && !_acceptanceDialogVisible && !_bookingPageOpen) {
          _showBikerAcceptanceDialog(next);
        }
      },
    );
  }

  Future<void> _showBikerAcceptanceDialog(Map<String, dynamic> payload) async {
    _acceptanceDialogVisible = true;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.two_wheeler, size: 42),
        title: const Text('Biker trouvé'),
        content: Text(
          payload['message']?.toString() ??
              'Un biker a accepté votre course, voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('PAS MAINTENANT'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CONTINUER'),
          ),
        ],
      ),
    );
    _acceptanceDialogVisible = false;
    if (!mounted) return;
    final notifier = ref.read(userHomeControllerProvider.notifier);
    if (confirmed == true) {
      await notifier.confirmAcceptedBiker();
    } else {
      notifier.dismissBikerAcceptance();
    }
  }

  Future<Uint8List> _loadDestinationMarker() async {
    final data = await rootBundle.load('assets/images/locations.png');

    return data.buffer.asUint8List();
  }

  Future<Uint8List> _loadUserMarker() async {
    final data = await rootBundle.load('assets/images/arrival.png');

    return data.buffer.asUint8List();
  }

  Future<void> _showDestinationMarker(double latitude, double longitude) async {
    if (_pointManager == null) return;

    if (_destinationMarker != null) {
      await _pointManager!.delete(_destinationMarker!);
    }

    final image = await _loadDestinationMarker();

    _destinationMarker = await _pointManager!.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(longitude, latitude)),
        image: image,
        iconSize: 0.1,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showUserMarker(double latitude, double longitude) async {
    if (_pointManager == null) return;

    final image = await _loadUserMarker();

    if (_userMarker != null) {
      await _pointManager!.delete(_userMarker!);
    }

    _userMarker = await _pointManager!.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: Position(longitude, latitude)),
        image: image,
        iconSize: 0.1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userHomeControllerProvider);

    final notifier = ref.read(userHomeControllerProvider.notifier);

    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: MapWidget(
              key: const ValueKey("mapWidget"),

              styleUri: MapboxConfig.navigationStyle,

              cameraOptions: CameraOptions(
                center: Point(
                  coordinates: Position(
                    state.pickupLocation.longitude,
                    state.pickupLocation.latitude,
                  ),
                ),

                zoom: 15,
              ),

              onTapListener: (mapContext) async {
                final lat = mapContext.point.coordinates.lat;
                final lng = mapContext.point.coordinates.lng;

                print("MAP CLICK => $lat, $lng");

                final destination = LatLng(lat.toDouble(), lng.toDouble());

                notifier.updateLocationFromMap(destination);
                await _showDestinationMarker(lat.toDouble(), lng.toDouble());

                await _mapboxMap?.flyTo(
                  CameraOptions(
                    center: Point(coordinates: Position(lng, lat)),

                    zoom: 16,
                  ),

                  MapAnimationOptions(duration: 1000),
                );
              },

              onMapCreated: (controller) async {
                _mapboxMap = controller;

                _pointManager = await controller.annotations
                    .createPointAnnotationManager();
                _polylineManager = await controller.annotations
                    .createPolylineAnnotationManager();

                await _showUserMarker(
                  state.pickupLocation.latitude,
                  state.pickupLocation.longitude,
                );
                if (state.routeCoordinates.isNotEmpty) {
                  await _drawRoute(state.routeCoordinates);
                }
              },
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 140,

            child: AnimatedSlide(
              duration: const Duration(milliseconds: 250),

              curve: Curves.easeInOut,

              offset: keyboardVisible ? const Offset(0, 3) : Offset.zero,

              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),

                opacity: keyboardVisible ? 0 : 1,

                child: IgnorePointer(
                  ignoring: keyboardVisible,

                  child: _buildBookingCard(context, state, notifier),
                ),
              ),
            ),
          ),

          Positioned(
            top: 80,
            left: 20,
            right: 20,

            child: Column(
              children: [
                _buildSearchBar(notifier),

                if (state.searchResults.isNotEmpty)
                  _buildResultsOverlay(state, notifier, keyboardVisible),
              ],
            ),
          ),

          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),

                // child: Icon(
                //
                //   Icons.place,
                //
                //   color: Colors.red.shade700,
                //
                //   size: 45,
                // ),
              ),
            ),
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

  Widget _buildSearchBar(UserHomeController notifier) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: notifier.searchAddresses,
        decoration: InputDecoration(
          hintText: 'Où allez-vous ?',
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    notifier.clearDestination();
                    notifier.searchAddresses("");
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildResultsOverlay(
    UserHomeState state,
    UserHomeController notifier,
    bool keyboardVisible,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 8),

      constraints: BoxConstraints(maxHeight: keyboardVisible ? 500 : 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state.searchResults.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: Colors.grey.shade200),
        itemBuilder: (_, index) {
          final result = state.searchResults[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on, color: Colors.green),
            ),
            title: Text(
              result.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: result.distanceFromUser != null
                ? Text(
                    result.distanceFromUser! < 1000
                        ? "${result.distanceFromUser!.toStringAsFixed(0)} m"
                        : "${(result.distanceFromUser! / 1000).toStringAsFixed(1)} km",
                    style: TextStyle(color: Colors.grey.shade600),
                  )
                : null,
            onTap: () async {
              notifier.selectSearchResult(result);
              await _showDestinationMarker(
                result.location.latitude,
                result.location.longitude,
              );

              _mapboxMap?.flyTo(
                CameraOptions(
                  center: Point(
                    coordinates: Position(
                      result.location.longitude,
                      result.location.latitude,
                    ),
                  ),
                  zoom: 16,
                ),
                MapAnimationOptions(duration: 1000),
              );

              _searchController.text = result.displayName;
              if (!mounted) return;
              FocusScope.of(context).unfocus();
            },
          );
        },
      ),
    );
  }

  Widget _buildBookingCard(
    BuildContext context,
    UserHomeState state,
    UserHomeController notifier,
  ) {
    if (state.currentRace != null && state.step != UserStep.searching) {
      return _buildInProgressCard(context, state);
    }

    final current = state.currentAddress ?? "Localisation...";
    final destination = state.destinationAddress ?? "Choisir destination";

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: .1),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ADDRESSES
          Row(
            children: [
              Column(
                children: [
                  Icon(
                    Icons.my_location,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: theme.colorScheme.outline,
                  ),
                  Icon(
                    Icons.location_on,
                    color: theme.colorScheme.error,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      current,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          /// BUTTON
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                if (state.destinationLocation == null ||
                    state.destinationAddress == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Choisissez une destination")),
                  );
                  return;
                }

                _bookingPageOpen = true;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfirmRacePage(
                      params: ConfirmRaceState(
                        destinationName: state.destinationAddress!,
                        startAddress: current,
                        amount: 10000,
                        priceListId: 1,
                        startLat: state.pickupLocation.latitude,
                        startLng: state.pickupLocation.longitude,
                        endLat: state.destinationLocation!.latitude,
                        endLng: state.destinationLocation!.longitude,
                      ),
                    ),
                  ),
                );
                _bookingPageOpen = false;
                if (!mounted || _acceptanceDialogVisible) return;
                final acceptance = ref
                    .read(userHomeControllerProvider)
                    .bikerAcceptance;
                if (acceptance != null) _showBikerAcceptanceDialog(acceptance);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "RÉSERVER",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressCard(BuildContext context, UserHomeState state) {
    final awaitingConfirmation =
        state.currentRace?.status == 'pending' &&
        state.currentRace?.bikerId != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.directions_bike, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Votre course',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.currentRace!.destination,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          if (state.currentRace?.status == 'pending') ...[
            Text(
              awaitingConfirmation
                  ? 'Un biker a accepté votre course. Votre confirmation est attendue.'
                  : 'Recherche d’un biker en cours…',
            ),
            const SizedBox(height: 12),
          ],
          if (awaitingConfirmation) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => ref
                    .read(userHomeControllerProvider.notifier)
                    .showBikerAcceptance(),
                child: const Text('CONFIRMER LE BIKER'),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (state.errorMessage != null) ...[
            Text(
              state.errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const RaceTrackingPage(),
                ),
              ),
              child: Text(
                state.currentRace?.status == 'pending'
                    ? 'VOIR LA COURSE EN ATTENTE'
                    : 'SUIVRE OU TERMINER LA COURSE',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
