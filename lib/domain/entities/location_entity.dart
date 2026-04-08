class LocationEntity {
  final double latitude;
  final double longitude;
  final String? city;
  final String? country;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.city,
    this.country,
  });

  bool get hasAddress => city != null && country != null;

  String get displayName {
    final parts = [city, country].where((p) => p != null);
    return parts.isNotEmpty ? parts.join(', ') : '$latitude, $longitude';
  }

  LocationEntity copyWith({
    double? latitude,
    double? longitude,
    String? city,
    String? country,
  }) {
    return LocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationEntity &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          city == other.city &&
          country == other.country;

  @override
  int get hashCode => Object.hash(latitude, longitude, city, country);
}
