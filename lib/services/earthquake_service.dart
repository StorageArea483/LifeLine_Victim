import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:life_line/models/earthquake_data.dart';
import 'package:life_line/styles/styles.dart';

class EarthquakeService {
  static const String _usgsUrl =
      'https://earthquake.usgs.gov/fdsnws/event/1/query';

  static const double _highRiskMagnitude = 6.0; // High Risk
  static const double _mediumRiskMagnitude = 4.5; // Medium Risk

  Future<Map<String, dynamic>?> _fetchNearestEarthquake(
    double lat,
    double lng,
  ) async {
    final url = Uri.parse(_usgsUrl).replace(
      queryParameters: {
        'format': 'geojson',
        'latitude': lat.toString(),
        'longitude': lng.toString(),
        'minmagnitude': '2.5', // Include all detectable earthquakes
        'orderby': 'time', // Get most recent earthquake first
        'limit': '1', // Only fetch the nearest/most recent earthquake
      },
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('USGS API error: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    return data as Map<String, dynamic>;
  }

  // Calculate risk based solely on earthquake magnitude
  String _calculateRisk(double magnitude) {
    if (magnitude == 0) {
      return 'Low Risk';
    }

    if (magnitude >= _highRiskMagnitude) {
      return 'High Risk';
    }

    if (magnitude >= _mediumRiskMagnitude) {
      return 'Medium Risk';
    }

    return 'Low Risk';
  }

  // Main method: Get real-time earthquake risk for user's GPS location
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
        // No earthquakes detected in the area
        return EarthquakeData(magnitude: 0, riskLevel: 'Low Risk');
      }

      // Extract magnitude from the nearest earthquake
      final properties = features[0]['properties'] as Map<String, dynamic>;
      final magnitude = (properties['mag'] as num?)?.toDouble() ?? 0;

      // Calculate risk based solely on magnitude
      final String risk = _calculateRisk(magnitude);

      return EarthquakeData(magnitude: magnitude, riskLevel: risk);
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
            : '${data.riskLevel}  •  Magnitude: ${data.magnitude.toStringAsFixed(1)}';

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
