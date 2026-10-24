import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zeokash/core/storage/secure_storage.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  final storage = ref.read(secureStorageProvider);
  return LocationService(storage);
});

class LocationState {
  final String? localityName;
  final bool isCached;
  final bool isLoading;
  final String? errorMessage;

  const LocationState({
    this.localityName,
    this.isCached = false,
    this.isLoading = false,
    this.errorMessage,
  });

  LocationState copyWith({
    String? localityName,
    bool? isCached,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationState(
      localityName: localityName ?? this.localityName,
      isCached: isCached ?? this.isCached,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LocationService {
  final SecureStorageService _storage;

  LocationService(this._storage);

  /// Loads locally cached locality name.
  Future<String?> getCachedLocality() async {
    return await _storage.getCachedLocality();
  }

  /// Extracts exclusively the locality/neighborhood name from Placemark.
  /// Strictly avoids road names, building numbers, state, country, or postal codes.
  String? _resolveLocalityName(Placemark place) {
    // 1. Prefer subLocality (neighborhood/sector/colony)
    final subLoc = place.subLocality?.trim();
    if (subLoc != null && subLoc.isNotEmpty && !_isGenericOrNumber(subLoc)) {
      return subLoc;
    }

    // 2. Otherwise use locality (city/town/named locality)
    final loc = place.locality?.trim();
    if (loc != null && loc.isNotEmpty && !_isGenericOrNumber(loc)) {
      return loc;
    }

    // 3. Fallback to subAdministrativeArea
    final subAdmin = place.subAdministrativeArea?.trim();
    if (subAdmin != null && subAdmin.isNotEmpty && !_isGenericOrNumber(subAdmin)) {
      return subAdmin;
    }

    // 4. Fallback to place.name if it represents a named neighborhood
    final name = place.name?.trim();
    if (name != null && name.isNotEmpty && !_isGenericOrNumber(name)) {
      return name;
    }

    return null;
  }

  bool _isGenericOrNumber(String text) {
    // Exclude building/plot numbers, pure digits, and plus codes
    if (RegExp(r'^[0-9\-\/,\s]+$').hasMatch(text)) return true;
    if (text.contains('+') && text.length <= 12) return true;
    return false;
  }

  /// Detects user's current locality via GPS and reverse geocoding on demand.
  /// Does not run background tracking.
  Future<LocationState> detectCurrentLocality() async {
    try {
      // 1. Check device location service status
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        final cached = await getCachedLocality();
        return LocationState(
          localityName: cached,
          isCached: cached != null,
          errorMessage: 'Location services are disabled on your device.',
        );
      }

      // 2. Check and request location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          final cached = await getCachedLocality();
          return LocationState(
            localityName: cached,
            isCached: cached != null,
            errorMessage: 'Location permission was denied.',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        final cached = await getCachedLocality();
        return LocationState(
          localityName: cached,
          isCached: cached != null,
          errorMessage: 'Location permission permanently denied. Enable it in device settings.',
        );
      }

      // 3. Fetch single position with timeout (no background tracking)
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );

      // 4. Reverse geocode coordinates to locality
      final geocoding = Geocoding();
      final List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? localityName;
      for (final place in placemarks) {
        final resolved = _resolveLocalityName(place);
        if (resolved != null && resolved.isNotEmpty) {
          localityName = resolved;
          break;
        }
      }

      if (localityName != null && localityName.isNotEmpty) {
        // Cache place name locally
        await _storage.saveCachedLocality(localityName);
        return LocationState(
          localityName: localityName,
          isCached: false,
        );
      } else {
        final cached = await getCachedLocality();
        return LocationState(
          localityName: cached,
          isCached: cached != null,
          errorMessage: 'Could not resolve locality from coordinates.',
        );
      }
    } catch (e) {
      final cached = await getCachedLocality();
      return LocationState(
        localityName: cached,
        isCached: cached != null,
        errorMessage: 'Failed to detect location: ${e.toString()}',
      );
    }
  }
}
