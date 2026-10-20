
import 'dart:convert';

import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final int weatherCode;
  final DateTime time;

  const WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.time,
  });

  String get description {
    switch (weatherCode) {
      case 0:
        return 'Clear sky';
      case 1:
        return 'Mainly clear';
      case 2:
        return 'Partly cloudy';
      case 3:
        return 'Overcast';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
        return 'Light drizzle';
      case 53:
        return 'Moderate drizzle';
      case 55:
        return 'Heavy drizzle';
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
        return 'Light snow';
      case 73:
        return 'Moderate snow';
      case 75:
        return 'Heavy snow';
      case 77:
        return 'Snow grains';
      case 80:
        return 'Light rain showers';
      case 81:
        return 'Moderate rain showers';
      case 82:
        return 'Heavy rain showers';
      case 85:
      case 86:
        return 'Snow showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with hail';
      default:
        return 'Weather unavailable';
    }
  }

  String get emoji {
    switch (weatherCode) {
      case 0:
        return '☀️';
      case 1:
      case 2:
        return '🌤️';
      case 3:
        return '☁️';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
      case 61:
      case 63:
      case 65:
      case 66:
      case 67:
      case 80:
      case 81:
      case 82:
        return '🌧️';
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return '❄️';
      case 95:
      case 96:
      case 99:
        return '⛈️';
      default:
        return '🌦️';
    }
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      time: DateTime.parse(current['time'] as String),
    );
  }
}

class WeatherService {
  static const double _latitude = -36.8509;
  static const double _longitude = 174.7645;

  static Future<WeatherData> fetchCurrentWeather() async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': '$_latitude',
        'longitude': '$_longitude',
        'current': 'temperature_2m,weather_code',
        'temperature_unit': 'celsius',
        'timezone': 'Pacific/Auckland',
      },
    );

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Weather service returned status ${response.statusCode}.',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    } on FormatException {
      throw Exception('The weather service returned invalid data.');
    } on http.ClientException {
      throw Exception(
        'Could not connect to the weather service. Check your internet connection.',
      );
    }
  }
}
