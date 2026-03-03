import 'package:flutter/material.dart';
import 'package:tracker_frontend/data/models/domain/trip_location.dart';
import 'package:tracker_frontend/presentation/helpers/battery_helpers.dart';
import 'package:tracker_frontend/presentation/helpers/weather_helpers.dart';

class CustomInfoWindow extends StatelessWidget {
  final TripLocation location;
  final VoidCallback onClose;

  const CustomInfoWindow({
    super.key,
    required this.location,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleRow(),
            const SizedBox(height: 6),
            _buildDivider(),
            const SizedBox(height: 8),
            _buildTimestampRow(),
            const SizedBox(height: 6),
            _buildMessageBatteryRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 6, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              location.displayLocation,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.2,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.close,
                size: 18,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.grey.shade200,
      indent: 14,
      endIndent: 14,
    );
  }

  Widget _buildTimestampRow() {
    final condition = location.weatherCondition;
    final temp = location.temperatureCelsius;
    final hasWeather = condition != null || temp != null;
    final weatherColor =
        condition != null ? WeatherHelpers.getWeatherColor(condition) : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text(
            _formatTimestamp(location.timestamp),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          if (hasWeather) ...[
            const SizedBox(width: 10),
            if (condition != null)
              Icon(
                WeatherHelpers.getWeatherIcon(condition),
                size: 14,
                color: weatherColor,
              ),
            if (temp != null) ...[
              const SizedBox(width: 3),
              Text(
                WeatherHelpers.formatTemperature(temp),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: weatherColor ?? Colors.grey.shade700,
                ),
              ),
            ],
            if (condition != null) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  WeatherHelpers.getWeatherLabel(condition),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBatteryRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              _messageText(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          if (location.battery != null) ...[
            const SizedBox(width: 8),
            _buildBatteryBadge(location.battery!),
          ],
        ],
      ),
    );
  }

  String _messageText() {
    if (location.message != null && location.message!.isNotEmpty) {
      return location.message!;
    }
    return '';
  }

  Widget _buildBatteryBadge(int battery) {
    final color = BatteryHelpers.getBatteryColor(battery);
    final icon = BatteryHelpers.getBatteryIcon(battery);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            _batteryText(battery),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  static String _batteryText(int battery) {
    return '$battery%';
  }

  static String _formatTimestamp(DateTime timestamp) {
    final day = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    final hour = timestamp.hour.toString();
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$day  $hour:$minute';
  }
}
