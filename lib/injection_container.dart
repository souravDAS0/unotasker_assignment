import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ============================================================================
// DEPENDENCY INJECTION CONTAINER
// ============================================================================
// This file contains all Riverpod providers for dependency injection.
// Dependencies flow: Presentation -> Domain <- Data
// All providers are defined here to maintain single source of truth.
// ============================================================================

// ============================================================================
// CORE PROVIDERS
// ============================================================================

// Hive Box Provider
final hiveBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('Hive box must be initialized in main.dart');
});

// ============================================================================
// DATA LAYER PROVIDERS
// ============================================================================

// Data Sources
// TODO: Add data source providers (LocalDataSource, RemoteDataSource, NotificationDataSource)

// Repository Implementation
// TODO: Add repository implementation provider

// ============================================================================
// DOMAIN LAYER PROVIDERS
// ============================================================================

// Use Cases
// TODO: Add use case providers (StartTracking, StopTracking, GetLocationRecords, UpdateLocation)

// ============================================================================
// PRESENTATION LAYER PROVIDERS
// ============================================================================

// State Management
// TODO: Add StateNotifier provider for tracking state

// ============================================================================
// HELPER PROVIDERS
// ============================================================================

// TODO: Add permission handler, notification manager, etc.
