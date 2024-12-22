import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_application/weather_forecast_items.dart';
import 'package:weather_application/additional_info_items.dart';
import 'package:weather_application/secrets.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  /// Function to get the user's current location.
  Future<Position> getLocation() async {
    // Check for location permission
    if (await Permission.location.isDenied) {
      await Permission.location.request(); // Request location permission
    }

    if (await Permission.location.isGranted) {
      // Return user's current location
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } else {
      throw 'Location permissions are denied'; // Throw error if permission is denied
    }
  }

  /// Function to fetch weather data using OpenWeather API.
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // Fetch user's location
      Position position = await getLocation();

      // Latitude and Longitude
      final latitude = position.latitude;
      final longitude = position.longitude;

      // API call with latitude and longitude
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&APPID=$openWeatherAPIKey'),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw 'An unexpected error occurred'; // Handle API error response
      }
      return data;
    } catch (e) {
      throw e.toString(); // Catch and return any error
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather(); // Initial fetch of weather data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              setState(() {
                weather = getCurrentWeather(); // Refresh weather data
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Loading state
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'), // Error state
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No data available'), // No data state
            );
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'] -
              273.15; // Convert Kelvin to Celsius
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];
          final currentHumidity = currentWeatherData['main']['humidity'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current weather card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '${currentTemp.toStringAsFixed(0)}°C', // Display temperature
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 70,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentSky, // Display current weather condition
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hourly forecast',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Hourly forecast list
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlySky = hourlyForecast['weather'][0]['main'];
                      final hourlyTemp = hourlyForecast['main']['temp'] -
                          273.15; // Convert Kelvin to Celsius
                      final time = DateTime.parse(hourlyForecast['dt_txt']);

                      return HourlyForecastItem(
                        time: DateFormat.j().format(time), // Display time
                        temperature: hourlyTemp
                            .toStringAsFixed(0), // Display temperature
                        icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // Additional information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: currentHumidity.toString(), // Display humidity
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: currentWindSpeed.toString(), // Display wind speed
                    ),
                    AdditionalInfoItem(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: currentPressure.toString(), // Display pressure
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
