import 'package:flutter/material.dart';

class HourlyForecastItem extends StatelessWidget {
  final IconData icon;
  final String time;
  final String temperature;
  const HourlyForecastItem(
      {super.key,
      required this.icon,
      required this.time,
      required this.temperature});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        elevation: 6.05,
        child: Container(
          width: 100.05,
          padding: const EdgeInsets.all(8.05),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontSize: 16.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.05),
              Icon(
                icon,
                size: 34.5,
              ),
              const SizedBox(height: 8.05),
              Text(
                temperature,
                style: const TextStyle(
                  fontSize: 16.05,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
