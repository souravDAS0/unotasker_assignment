import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';

/// Abstract interface for remote location operations.
abstract class LocationRemoteDataSource {
  /// Fetches the current GPS location.
  Future<Position> getCurrentLocation();

  /// Converts GPS coordinates to a human-readable address.
  Future<String> geocodeAddress(double latitude, double longitude);

  /// Checks if location permissions are granted.
  Future<bool> hasPermissions();
}

/// Implementation of LocationRemoteDataSource using Geolocator and Geocoding packages.
class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  @override
  Future<Position> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          AppConstants.locationServiceDisabledMessage,
        );
      }

      // Get current position with high accuracy
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 30),
      );

      return position;
    } on LocationException {
      rethrow;
    } catch (e) {
      throw LocationException('Failed to fetch current location', e);
    }
  }

  @override
  Future<String> geocodeAddress(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        // Build address from available components
        final List<String> addressParts = [];

        if (placemark.street != null && placemark.street!.isNotEmpty) {
          addressParts.add(placemark.street!);
        }
        if (placemark.locality != null && placemark.locality!.isNotEmpty) {
          addressParts.add(placemark.locality!);
        }
        if (placemark.administrativeArea != null &&
            placemark.administrativeArea!.isNotEmpty) {
          addressParts.add(placemark.administrativeArea!);
        }
        if (placemark.country != null && placemark.country!.isNotEmpty) {
          addressParts.add(placemark.country!);
        }

        if (addressParts.isNotEmpty) {
          return addressParts.join(', ');
        }
      }

      // Fallback if no address components available
      return AppConstants.addressUnavailable;
    } catch (e) {
      // Return fallback on any error (network, service unavailable, etc.)
      return AppConstants.addressUnavailable;
    }
  }

  @override
  Future<bool> hasPermissions() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }
}
