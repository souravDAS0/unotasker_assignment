import '../../domain/entities/location_record.dart';

/// State model for tracking UI.
/// Manages the state of location tracking, records list, loading, and errors.
class TrackingState {
  final bool isTracking;
  final List<LocationRecord> records;
  final bool isLoading;
  final String? errorMessage;

  const TrackingState({
    required this.isTracking,
    required this.records,
    required this.isLoading,
    this.errorMessage,
  });

  /// Creates the initial state.
  factory TrackingState.initial() {
    return const TrackingState(
      isTracking: false,
      records: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  /// Creates a copy of this state with the given fields replaced.
  TrackingState copyWith({
    bool? isTracking,
    List<LocationRecord>? records,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      records: records ?? this.records,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TrackingState &&
        other.isTracking == isTracking &&
        other.records == records &&
        other.isLoading == isLoading &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return isTracking.hashCode ^
        records.hashCode ^
        isLoading.hashCode ^
        errorMessage.hashCode;
  }

  @override
  String toString() {
    return 'TrackingState(isTracking: $isTracking, records: ${records.length}, isLoading: $isLoading, errorMessage: $errorMessage)';
  }
}
