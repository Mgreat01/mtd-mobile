import 'package:latlong2/latlong.dart';

class SearchResult {
  final LatLng location;
  final String displayName;
  final double? distanceFromUser;
  SearchResult({required this.location, required this.displayName, this.distanceFromUser});
  SearchResult copyWith({
    LatLng? location,
    String? displayName,
    double? distanceFromUser,
  }) {
    return SearchResult(
      location: location ?? this.location,
      displayName: displayName ?? this.displayName,
      distanceFromUser: distanceFromUser ?? this.distanceFromUser,
    );
  }
}