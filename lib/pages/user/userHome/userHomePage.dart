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
              initialCenter: state.myLocation,
              initialZoom: 15.0,
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

          ///  CURSEUR CENTRE
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: Icon(Icons.location_on, color: Colors.red, size: 45),
            ),
          ),

          /// SEARCH + RESULTS
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

          ///  BOOKING CARD
          Positioned(
            bottom: 140,
            left: 20,
            right: 20,
            child: _buildBookingCard(context, state, notifier),
          ),

          ///  LOADER
          if (state.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  ///  SEARCH BAR
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
          prefixIcon: const Icon(Icons.search, color: Colors.green),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              notifier.searchAddresses("");
            },
          )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }

  ///  SEARCH RESULTS
  Widget _buildResultsOverlay(
      UserHomeState state, UserHomeController notifier) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        itemCount: state.searchResults.length,
        itemBuilder: (_, i) {
          final result = state.searchResults[i];

          return ListTile(
            title: Text(result.displayName),
            onTap: () {
              notifier.selectSearchResult(result);
              _mapController.move(result.location, 16);
              _searchController.text = result.displayName;
              FocusScope.of(context).unfocus();
            },
          );
        },
      ),
    );
  }

  /// 🚕 BOOKING CARD
  Widget _buildBookingCard(BuildContext context, UserHomeState state,
      UserHomeController notifier) {
    final current = state.currentAddress ?? "Localisation...";
    final dest = state.destinationAddress ?? "Choisir destination";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ///  ADDRESSES
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.my_location, color: Colors.green, size: 18),
                  Container(width: 1, height: 20, color: Colors.grey.shade300),
                  const Icon(Icons.location_on, color: Colors.red, size: 18),
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
                          fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      dest,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (state.destinationAddress == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Choisissez une destination")),
                  );
                  return;
                }

                notifier.confirmBooking(
                  destinationName: state.destinationAddress!,
                  priceListId: 1,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfirmRacePage(
                      params: ConfirmRaceState(
                        destinationName: dest,
                        startAddress: current,
                        amount: 10000,
                        priceListId: 1,
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "RÉSERVER",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}