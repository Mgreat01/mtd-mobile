import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:moto_taxi_digital_mobile/pages/user/course/confirmRacePage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/course/confirmRaceState.dart';

import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';
import 'package:moto_taxi_digital_mobile/utils/mapbox_config.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
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

      ref.listenManual<UserHomeState>(
        userHomeControllerProvider,
            (previous, next) {
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
        },
      );
    });
  }

  Future<Uint8List> _loadDestinationMarker() async {
    final data = await rootBundle.load(
      'assets/images/locations.png',
    );

    return data.buffer.asUint8List();
  }
  Future<Uint8List> _loadUserMarker() async {
    final data = await rootBundle.load(
      'assets/images/arrival.png',
    );

    return data.buffer.asUint8List();
  }

  Future<void> _showDestinationMarker(
      double latitude,
      double longitude,
      ) async {

    if (_pointManager == null) return;

    if (_destinationMarker != null) {
      await _pointManager!.delete(_destinationMarker!);
    }

    final image = await _loadDestinationMarker();

    _destinationMarker = await _pointManager!.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            longitude,
            latitude,
          ),
        ),
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
  Future<void> _showUserMarker(
      double latitude,
      double longitude,
      ) async {

    if (_pointManager == null) return;

    final image = await _loadUserMarker();

    if (_userMarker != null) {
      await _pointManager!.delete(_userMarker!);
    }

    _userMarker = await _pointManager!.create(
      PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(
            longitude,
            latitude,
          ),
        ),
        image: image,
        iconSize: 0.1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final state =
    ref.watch(userHomeControllerProvider);

    final notifier =
    ref.read(userHomeControllerProvider.notifier);

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

                final destination = LatLng(
                  lat.toDouble(),
                  lng.toDouble(),
                );

                notifier.updateLocationFromMap(
                  destination,
                );
                await _showDestinationMarker(
                  lat.toDouble(),
                  lng.toDouble(),
                );

                await _mapboxMap?.flyTo(

                  CameraOptions(

                    center: Point(
                      coordinates: Position(
                        lng,
                        lat,
                      ),
                    ),

                    zoom: 16,
                  ),

                  MapAnimationOptions(
                    duration: 1000,
                  ),
                );
              },

              onMapCreated: (controller) async {
                _mapboxMap = controller;

                _pointManager = await controller.annotations
                    .createPointAnnotationManager();

                await _showUserMarker(
                  state.pickupLocation.latitude,
                  state.pickupLocation.longitude,
                );
              },
            )
          ),

          Positioned(

            left: 20,
            right: 20,
            bottom: 140,

            child: AnimatedSlide(

              duration: const Duration(
                milliseconds: 250,
              ),

              curve: Curves.easeInOut,

              offset: keyboardVisible
                  ? const Offset(0, 3)
                  : Offset.zero,

              child: AnimatedOpacity(

                duration: const Duration(
                  milliseconds: 200,
                ),

                opacity: keyboardVisible ? 0 : 1,

                child: IgnorePointer(

                  ignoring: keyboardVisible,

                  child: _buildBookingCard(
                    context,
                    state,
                    notifier,
                  ),
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

                  _buildResultsOverlay(
                    state,
                    notifier,
                    keyboardVisible,
                  ),
              ],
            ),
          ),

          IgnorePointer(

            child: Center(

              child: Padding(

                padding: const EdgeInsets.only(
                  bottom: 80,
                ),

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

              child: const Center(
                child:
                CircularProgressIndicator(),
              ),
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
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: notifier.searchAddresses,
        decoration: InputDecoration(
          hintText: 'Où allez-vous ?',
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.green,
          ),
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

      constraints: BoxConstraints(
        maxHeight: keyboardVisible ? 500 : 400,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: state.searchResults.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: Colors.grey.shade200,
        ),
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
                color: Colors.green.withOpacity(.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.green,
              ),
            ),
            title: Text(
              result.displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: result.distanceFromUser != null
                ? Text(
              result.distanceFromUser! < 1000
                  ? "${result.distanceFromUser!.toStringAsFixed(0)} m"
                  : "${(result.distanceFromUser! / 1000).toStringAsFixed(1)} km",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
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
                MapAnimationOptions(
                  duration: 1000,
                ),
              );

              _searchController.text = result.displayName;
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
            color: theme.colorScheme.shadow.withOpacity(.1),
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
              onPressed: () {
                if (state.destinationLocation == null ||
                    state.destinationAddress == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Choisissez une destination"),
                    ),
                  );
                  return;
                }

                Navigator.push(
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

}