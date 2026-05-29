import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moto_taxi_digital_mobile/pages/user/course/confirmRacePage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/course/confirmRaceState.dart';

import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';
import 'package:moto_taxi_digital_mobile/utils/mapbox_config.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  MapboxMap? _mapboxMap;
  final TextEditingController _searchController = TextEditingController();

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

            print("Nouvelle position reçue : "
                "${next.pickupLocation.latitude}");

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final state =
    ref.watch(userHomeControllerProvider);

    final notifier =
    ref.read(userHomeControllerProvider.notifier);

    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    final keyboardVisible =
        MediaQuery.of(context).viewInsets.bottom > 0;

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

              styleUri:MapboxConfig.navigationStyle,

              cameraOptions: CameraOptions(

                center: Point(
                  coordinates: Position(
                    state.pickupLocation.longitude,
                    state.pickupLocation.latitude,
                  ),
                ),

                zoom: 15,
              ),

              onMapCreated: (controller) async {

                _mapboxMap = controller;

                final pointManager =
                await controller.annotations
                    .createPointAnnotationManager();

                await pointManager.create(

                  PointAnnotationOptions(

                    geometry: Point(
                      coordinates: Position(
                        state.pickupLocation.longitude,
                        state.pickupLocation.latitude,
                      ),
                    ),

                    iconSize: 1.5,

                    textField: "📍",
                  ),
                );
              },
            )
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

      margin: const EdgeInsets.only(top: 8),

      constraints: BoxConstraints(

        maxHeight:
        keyboardVisible ? 420 : 250,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
        BorderRadius.circular(18),

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(.08),

            blurRadius: 15,
          ),
        ],
      ),

      child: ListView.separated(

        shrinkWrap: true,

        itemCount:
        state.searchResults.length,

        separatorBuilder: (_, __) =>
            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),

        itemBuilder: (_, index) {

          final result =
          state.searchResults[index];

          return ListTile(

            contentPadding:
            const EdgeInsets.symmetric(

              horizontal: 15,
              vertical: 5,
            ),

            leading: Container(

              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(

                color:
                Colors.green.withOpacity(.1),

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

              overflow:
              TextOverflow.ellipsis,

              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

            subtitle:
            result.distanceFromUser != null

                ? Text(

              result.distanceFromUser! < 1000

                  ? "${result.distanceFromUser!.toStringAsFixed(0)} m"

                  : "${(result.distanceFromUser! / 1000).toStringAsFixed(1)} km",

              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            )

                : null,

            onTap: () {

              notifier.selectSearchResult(
                result,
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

              _searchController.text =
                  result.displayName;

              FocusScope.of(context)
                  .unfocus();
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.1),
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
                  const Icon(
                    Icons.my_location,
                    color: Colors.green,
                    size: 18,
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.grey.shade300,
                  ),
                  const Icon(
                    Icons.location_on,
                    color: Colors.red,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      destination,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                      ),
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
                      content: Text(
                        "Choisissez une destination",
                      ),
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

                        /// DEPART = vraie position client
                        startLat: state.pickupLocation.latitude,
                        startLng: state.pickupLocation.longitude,

                        /// DESTINATION
                        endLat: state.destinationLocation!.latitude,
                        endLng: state.destinationLocation!.longitude,
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "RÉSERVER",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}