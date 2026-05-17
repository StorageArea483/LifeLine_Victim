import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:life_line/models/earthquake_data.dart';
import 'package:life_line/styles/styles.dart';

class EarthquakeService {
  static const String _usgsUrl =
      'https://earthquake.usgs.gov/fdsnws/event/1/query';
  static const double _highRiskMagnitude = 6.0;
  static const double _mediumRiskMagnitude = 4.5;
  static const double _minMagnitude = 4.0;

  Future<Map<String, dynamic>?> _fetchNearestEarthquake(
    double lat,
    double lng,
  ) async {
    final now = DateTime.now().toUtc();
    final since = now.subtract(const Duration(minutes: 20));

    String toIso(DateTime dt) =>
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}'
        'T${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:00';

    final url = Uri.parse(_usgsUrl).replace(
      queryParameters: {
        'format': 'geojson',
        'latitude': lat.toString(),
        'longitude': lng.toString(),
        'maxradiuskm': '150',
        'minmagnitude': _minMagnitude.toString(),
        'starttime': toIso(since),
        'endtime': toIso(now),
        'orderby': 'magnitude',
      },
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('An unexpected error occurred: ${response.statusCode}');
    }
    return json.decode(response.body) as Map<String, dynamic>;
  }

  String _calculateRisk(double magnitude) {
    if (magnitude >= _highRiskMagnitude) return 'High Risk';
    if (magnitude >= _mediumRiskMagnitude) return 'Medium Risk';
    return 'Low Risk';
  }

  Future<EarthquakeData> getEarthquakeRiskForLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final earthquakeData = await _fetchNearestEarthquake(latitude, longitude);

      if (earthquakeData == null) {
        return EarthquakeData(
          magnitude: 0,
          riskLevel: 'Error',
          errorMessage: 'Unable to process your request, please try again',
        );
      }

      final features = earthquakeData['features'] as List<dynamic>?;

      if (features == null || features.isEmpty) {
        return EarthquakeData(magnitude: 0, riskLevel: 'Low Risk');
      }

      final properties = features[0]['properties'] as Map<String, dynamic>;
      final magnitude = (properties['mag'] as num?)?.toDouble() ?? 0;

      return EarthquakeData(
        magnitude: magnitude,
        riskLevel: _calculateRisk(magnitude),
      );
    } catch (e) {
      return EarthquakeData(
        magnitude: 0,
        riskLevel: 'Error',
        errorMessage: 'Unable to process your request, please try again',
      );
    }
  }

  static void showEarthquakeRisk(BuildContext context, EarthquakeData data) {
    final Color bgColor;
    final IconData icon;

    switch (data.riskLevel) {
      case 'High Risk':
        bgColor = AppColors.error;
        icon = Icons.warning;
        break;
      case 'Medium Risk':
        bgColor = AppColors.warning;
        icon = Icons.warning_amber;
        break;
      case 'Error':
        bgColor = AppColors.textSecondary;
        icon = Icons.error_outline;
        break;
      default:
        bgColor = AppColors.success;
        icon = Icons.check_circle;
    }

    final message =
        data.riskLevel == 'Error'
            ? data.errorMessage ?? 'Unknown error'
            : data.magnitude > 0
            ? '${data.riskLevel}  •  Magnitude: ${data.magnitude.toStringAsFixed(1)}'
            : data.riskLevel; // No recent quake: just show "Low Risk"

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: bgColor,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
