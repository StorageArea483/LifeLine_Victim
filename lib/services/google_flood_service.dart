import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:life_line/models/flood_data.dart';
import 'package:life_line/styles/styles.dart';

class FloodService {
  static const String _weatherUrl = 'https://api.open-meteo.com/v1/forecast';

  static const double _heavyRain = 40.0; // High Risk
  static const double _moderateRain = 20.0; // Medium Risk

  // Fetch current rain (mm/hour) at location
  Future<double> _fetchRain(double lat, double lng) async {
    final url = Uri.parse(_weatherUrl).replace(
      queryParameters: {
        'latitude': lat.toString(),
        'longitude': lng.toString(),
        'current': 'rain,precipitation',
        'timezone': 'auto',
      },
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Weather API error: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    final current = data['current'] as Map<String, dynamic>;

    return (current['rain'] as num?)?.toDouble() ??
        (current['precipitation'] as num?)?.toDouble() ??
        0.0;
  }

  // Calculate risk purely from rain intensity
  String _calculateRisk(double rainMm) {
    if (rainMm >= _heavyRain) return 'High Risk';
    if (rainMm >= _moderateRain) return 'Medium Risk';
    return 'Low Risk';
  }

  // Main method: Get flood risk for GPS location
  Future<FloodData> getFloodRiskForLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      final double rain = await _fetchRain(latitude, longitude);
      final String risk = _calculateRisk(rain);

      return FloodData(rainMm: rain, riskLevel: risk);
    } catch (e) {
      return FloodData(
        rainMm: 0,
        riskLevel: 'Error',
        errorMessage: 'Could not fetch data. Check your internet.',
      );
    }
  }

  // Show result as SnackBar
  static void showFloodRisk(BuildContext context, FloodData data) {
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
            : '${data.riskLevel}  •  Rain: ${data.rainMm} mm/hr';

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
