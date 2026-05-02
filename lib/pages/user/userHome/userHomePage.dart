import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moto_taxi_digital_mobile/pages/user/course/confirmRacePage.dart';
import 'package:moto_taxi_digital_mobile/pages/user/course/confirmRaceState.dart';

import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeCtrl.dart';
import 'package:moto_taxi_digital_mobile/pages/user/userHome/userHomeState.dart';

class UserHomePage extends ConsumerStatefulWidget {
  const UserHomePage({super.key});

  @override
  ConsumerState<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends ConsumerState<UserHomePage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userHomeControllerProvider);
    final notifier = ref.read(userHomeControllerProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          /// MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: state.mapCenter,
              initialZoom: 15,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && position.center != null) {
                  notifier.updateLocationFromMap(position.center!);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.moto_taxi.app',
              ),
            ],
          ),

          /// CURSEUR FIXE
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 45,
              ),
            ),
          ),

          /// SEARCH BAR + RESULTS
          Positioned(
            top: 145,
            left: 20,
            right: 20,
            child: Column(
              children: [
                _buildSearchBar(notifier),
                if (state.searchResults.isNotEmpty)
                  _buildResultsOverlay(state, notifier),
              ],
            ),
          ),

          /// BOOKING CARD
          Positioned(
            left: 20,
            right: 20,
            bottom: 140,
            child: _buildBookingCard(
              context,
              state,
              notifier,
            ),
          ),

          /// LOADER
          if (state.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
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
      ) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      constraints: const BoxConstraints(
        maxHeight: 250,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        itemCount: state.searchResults.length,
        itemBuilder: (_, index) {
          final result = state.searchResults[index];

          return ListTile(
            title: Text(result.displayName),
            onTap: () {
              notifier.selectSearchResult(result);

              _mapController.move(
                result.location,
                16,
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
    final destination =
        state.destinationAddress ?? "Choisir destination";

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
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                        destinationName:
                        state.destinationAddress!,
                        startAddress: current,
                        amount: 10000,
                        priceListId: 1,

                        /// DEPART = vraie position client
                        startLat:
                        state.pickupLocation.latitude,
                        startLng:
                        state.pickupLocation.longitude,

                        /// DESTINATION
                        endLat: state
                            .destinationLocation!.latitude,
                        endLng: state
                            .destinationLocation!.longitude,
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
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