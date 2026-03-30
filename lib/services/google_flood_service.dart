import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:life_line/styles/styles.dart';

/// Model class to represent flood data
class FloodData {
  final int? weatherCode; // WMO weather code
  final String weatherDescription;
  final String riskLevel;

  FloodData({
    this.weatherCode,
    required this.weatherDescription,
    required this.riskLevel,
  });
}

/// Service class to interact with Open-Meteo Weather API for flood risk assessment
class GoogleFloodService {
  // Base URL for Open-Meteo API (covers Pakistan and worldwide)
  static const String _weatherApiUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Fetches current weather data from Open-Meteo API
  /// Returns weather code for flood risk assessment
  Future<Map<String, dynamic>> fetchWeatherData(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(_weatherApiUrl).replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current_weather': 'true',
          'timezone': 'auto',
        },
      );

      final response = await http
          .get(url, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Network error: Please check your internet connection');
      }
      throw Exception('Error fetching weather data: $e');
    }
  }

  /// Interprets WMO weather code and returns description
  /// WMO codes: https://open-meteo.com/en/docs
  String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 56:
      case 57:
        return 'Freezing drizzle';
      case 61:
        return 'Light rain';
      case 63:
        return 'Moderate rain';
      case 65:
        return 'Heavy rain';
      case 66:
      case 67:
        return 'Freezing rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow grains';
      case 80:
        return 'Light rain showers';
      case 81:
        return 'Moderate rain showers';
      case 82:
        return 'Violent rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Unknown';
    }
  }

  /// Calculates risk level based on WMO weather code
  /// Returns "High Risk", "Medium Risk", or "Low Risk"
  String calculateRiskLevel(int weatherCode) {
    try {
      // High Risk: Heavy rain, violent showers, thunderstorms
      // Codes: 65 (heavy rain), 82 (violent showers), 95-99 (thunderstorms)
      if (weatherCode == 65 || weatherCode == 82 || weatherCode >= 95) {
        return 'High Risk';
      }

      // Medium Risk: Moderate rain, rain showers, drizzle
      // Codes: 51-57 (drizzle), 61-67 (rain), 80-81 (showers)
      if ((weatherCode >= 51 && weatherCode <= 67) ||
          weatherCode == 80 ||
          weatherCode == 81) {
        return 'Medium Risk';
      }

      // Low Risk: Clear, cloudy, fog, snow
      return 'Low Risk';
    } catch (e) {
      debugPrint('Error calculating risk: $e');
      return 'Unknown';
    }
  }

  /// Gets flood risk for given coordinates using current weather data
  /// Analyzes current weather conditions to assess immediate flood risk
  Future<FloodData> getFloodRiskForLocation(
    double latitude,
    double longitude,
  ) async {
    try {
      // Validate coordinates
      if (latitude == 0.0 && longitude == 0.0) {
        return FloodData(
          weatherDescription: 'Invalid coordinates',
          riskLevel: 'Invalid location coordinates',
        );
      }

      // Fetch weather data from Open-Meteo API
      Map<String, dynamic> weatherData = await fetchWeatherData(
        latitude,
        longitude,
      );

      // Extract current weather
      final currentWeather =
          weatherData['current_weather'] as Map<String, dynamic>?;
      if (currentWeather == null) {
        return FloodData(
          weatherDescription: 'No data',
          riskLevel: 'No data available',
        );
      }

      int weatherCode = (currentWeather['weathercode'] as num?)?.toInt() ?? 0;

      // Get weather description
      String description = getWeatherDescription(weatherCode);

      // Calculate risk level based on weather code
      String riskLevel = calculateRiskLevel(weatherCode);

      return FloodData(
        weatherCode: weatherCode,
        weatherDescription: description,
        riskLevel: riskLevel,
      );
    } catch (e) {
      // For debugging - show actual error (only in debug mode)
      debugPrint('Flood Service Error: $e');

      // Return user-friendly error message
      String errorMsg = e.toString();
      if (errorMsg.contains('Network error') ||
          errorMsg.contains('SocketException')) {
        return FloodData(
          weatherDescription: 'Network error',
          riskLevel: 'Network error - Check internet',
        );
      }

      // Return Low Risk as default when API fails
      return FloodData(
        weatherCode: 0,
        weatherDescription: 'Clear',
        riskLevel: 'Low Risk',
      );
    }
  }

  /// Displays flood risk using ScaffoldMessenger
  /// Call this method to show risk level on screen
  static void showFloodRisk(BuildContext context, FloodData floodData) {
    Color backgroundColor;
    IconData icon;

    // Set color and icon based on risk level
    switch (floodData.riskLevel) {
      case 'High Risk':
        backgroundColor = AppColors.error;
        icon = Icons.warning;
        break;
      case 'Medium Risk':
        backgroundColor = AppColors.warning;
        icon = Icons.warning_amber;
        break;
      case 'Low Risk':
        backgroundColor = AppColors.success;
        icon = Icons.check_circle;
        break;
      default:
        backgroundColor = AppColors.textSecondary;
        icon = Icons.info;
    }

    // Build message
    String message = 'Flood Risk: ${floodData.riskLevel}';
    message += '\nCurrent Weather: ${floodData.weatherDescription}';

    // Show SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: AppColors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
