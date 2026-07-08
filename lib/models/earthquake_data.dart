class EarthquakeData {
  final double magnitude;
  final String riskLevel;
  final String? errorMessage;

  EarthquakeData({
    required this.magnitude,
    required this.riskLevel,
    this.errorMessage,
  });
}
