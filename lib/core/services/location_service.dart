import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final String districtName;
  final bool isLive;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.districtName,
    this.isLive = false,
  });

  // Default coordinate: Alun-Alun Sidoarjo
  static const UserLocation defaultLocation = UserLocation(
    latitude: -7.45254,
    longitude: 112.71634,
    districtName: 'Sidoarjo',
    isLive: false,
  );
}

class LocationService {
  // Known centers of Sidoarjo districts to identify closest area
  static const Map<String, List<double>> _districtCenters = {
    'Sidoarjo': [-7.4525, 112.7163],
    'Buduran': [-7.4281, 112.7182],
    'Waru': [-7.3485, 112.7214],
    'Gedangan': [-7.3815, 112.7242],
    'Taman': [-7.3511, 112.6827],
    'Candi': [-7.4812, 112.7225],
    'Sukodono': [-7.4123, 112.6781],
    'Krian': [-7.4112, 112.5841],
    'Sedati': [-7.3821, 112.7824],
    'Surabaya': [-7.2575, 112.7521],
  };

  /// Request permission and get current device position
  static Future<UserLocation> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Location service disabled, using fallback');
        return UserLocation.defaultLocation;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Permission denied, using fallback');
          return UserLocation.defaultLocation;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Permission denied forever, using fallback');
        return UserLocation.defaultLocation;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 7),
        ),
      );

      final district = detectDistrict(position.latitude, position.longitude);

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        districtName: district,
        isLive: true,
      );
    } catch (e) {
      debugPrint('[LocationService] Error determining position: $e');
      return UserLocation.defaultLocation;
    }
  }

  /// Calculate distance in km between two lat/lng coordinates
  static double calculateDistanceKm({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    final distanceMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
    return distanceMeters / 1000.0;
  }

  /// Detect closest district name based on latitude & longitude
  static String detectDistrict(double lat, double lng) {
    String closestName = 'Sidoarjo';
    double minDistance = double.infinity;

    _districtCenters.forEach((name, coords) {
      final d = calculateDistanceKm(
        startLatitude: lat,
        startLongitude: lng,
        endLatitude: coords[0],
        endLongitude: coords[1],
      );
      if (d < minDistance) {
        minDistance = d;
        closestName = name;
      }
    });

    return closestName;
  }

  /// Open external Google Maps for turn-by-turn navigation to a cafe
  static Future<bool> openGoogleMapsRoute({
    required double destLat,
    required double destLng,
    required String placeName,
  }) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving',
    );
    final geoUri = Uri.parse('geo:$destLat,$destLng?q=$destLat,$destLng($placeName)');

    try {
      if (await canLaunchUrl(geoUri)) {
        return await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        return await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[LocationService] Failed to launch map: $e');
    }
    return false;
  }
}

