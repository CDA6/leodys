class GeoPosition {
  final double latitude;
  final double longitude;

  const GeoPosition({required this.latitude, required this.longitude});

  @override
  String toString() {
    return "Lat=$latitude, Lng=$longitude";
  }
}
