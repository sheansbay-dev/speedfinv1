// /speedfin/lib/core/services/location_service.dart

import 'package:geolocator/geolocator.dart';

class LocationService {
  // 1. ස්ථාන අවසරය (permission) පරීක්ෂා කිරීම
  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // රියදුරුට යෙදුම් සැකසුම් වෙත යොමු කරන්න
        return false;
      }
    }
    return true;
  }

  // 2. තත්‍ය කාලීන ස්ථාන වෙනස්වීම් Stream කිරීම
  Stream<Position> getPositionStream() {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation, // ඉහළම නිරවද්‍යතාවය
      distanceFilter: 0, // සෑම මීටරයකම වෙනස්වීම් ලබා ගන්න
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }
}
