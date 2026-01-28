class GeoPosition {
  final double latitude;
  final double longitude;
  final double accuracy;

  const GeoPosition({
    required this.latitude,
    required this.longitude,
    this.accuracy = 0,
  });

  @override
  String toString() {
    return "Lat=$latitude, Lng=$longitude";
  }
}
