import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/geocoding_error_type.dart';

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
      // Validate coordinates first
      if (latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180 ||
          latitude.isNaN ||
          longitude.isNaN) {
        developer.log(
          'Invalid coordinates: lat=$latitude, lng=$longitude',
          name: 'LocationRemoteDataSource',
          error: 'Coordinates out of valid range or NaN',
        );
        throw const GeocodingException(
          'Invalid coordinates provided',
          GeocodingErrorType.invalidCoordinates,
        );
      }

      // Attempt geocoding with timeout
      final placemarks = await placemarkFromCoordinates(latitude, longitude)
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw const GeocodingException(
            'Geocoding request timed out',
            GeocodingErrorType.networkError,
          );
        },
      );

      if (placemarks.isEmpty) {
        // No results - likely ocean, remote area, or coordinates with no address
        developer.log(
          'No placemarks found for coordinates: lat=$latitude, lng=$longitude',
          name: 'LocationRemoteDataSource',
        );
        throw const GeocodingException(
          'No address found for these coordinates',
          GeocodingErrorType.noAddressFound,
        );
      }

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

      if (addressParts.isEmpty) {
        // Placemark exists but has no address components
        developer.log(
          'Placemark has no usable address components for: lat=$latitude, lng=$longitude',
          name: 'LocationRemoteDataSource',
          error: placemark.toString(),
        );
        throw const GeocodingException(
          'Address components unavailable',
          GeocodingErrorType.noAddressFound,
        );
      }

      return addressParts.join(', ');
    } on GeocodingException {
      // Re-throw our custom exceptions
      rethrow;
    } on TimeoutException catch (e) {
      developer.log(
        'Geocoding timeout for coordinates: lat=$latitude, lng=$longitude',
        name: 'LocationRemoteDataSource',
        error: e,
      );
      throw GeocodingException(
        'Network timeout while geocoding',
        GeocodingErrorType.networkError,
        e,
      );
    } on SocketException catch (e) {
      // No internet connection
      developer.log(
        'Network error during geocoding: lat=$latitude, lng=$longitude',
        name: 'LocationRemoteDataSource',
        error: e,
      );
      throw GeocodingException(
        'No internet connection',
        GeocodingErrorType.networkError,
        e,
      );
    } on PlatformException catch (e) {
      // Geocoding service issues (rate limit, service down)
      developer.log(
        'Geocoding service error: lat=$latitude, lng=$longitude',
        name: 'LocationRemoteDataSource',
        error: e,
      );
      throw GeocodingException(
        'Geocoding service unavailable: ${e.message}',
        GeocodingErrorType.serviceUnavailable,
        e,
      );
    } catch (e) {
      // Unexpected errors
      developer.log(
        'Unexpected geocoding error: lat=$latitude, lng=$longitude',
        name: 'LocationRemoteDataSource',
        error: e,
      );
      throw GeocodingException(
        'Unexpected geocoding error: ${e.toString()}',
        GeocodingErrorType.unknown,
        e,
      );
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
