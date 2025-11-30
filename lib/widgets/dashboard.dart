import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unbound/services/calendar_service.dart';
import 'package:unbound/services/weather_service.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final WeatherService _weatherService = WeatherService();
  final CalendarService _calendarService = CalendarService();

  Map<String, dynamic>? _weatherData;
  List<Event> _events = [];
  bool _isLoadingWeather = true;
  bool _isLoadingCalendar = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _loadWeather();
    _loadCalendar();
  }

  Future<void> _loadWeather() async {
    final weather = await _weatherService.getCurrentWeather();
    if (mounted) {
      setState(() {
        _weatherData = weather;
        _isLoadingWeather = false;
      });
    }
  }

  Future<void> _loadCalendar() async {
    final events = await _calendarService.getUpcomingEvents();
    if (mounted) {
      setState(() {
        _events = events;
        _isLoadingCalendar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date & Time
          _buildDateTime(),
          const SizedBox(height: 24),

          // Weather & Calendar Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weather
              Expanded(flex: 2, child: _buildWeather()),
              const SizedBox(width: 16),
              // Calendar
              Expanded(flex: 3, child: _buildCalendar()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTime() {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateStr.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
            letterSpacing: 1.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildWeather() {
    if (_isLoadingWeather) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white54,
            ),
          ),
        ),
      );
    }

    // Mock data if API fails or no key
    final temp = _weatherData != null
        ? (_weatherData!['main']['temp'] as num).round()
        : '--';
    final description = _weatherData != null
        ? _weatherData!['weather'][0]['description']
        : 'Weather unavailable';
    final city = _weatherData != null ? _weatherData!['name'] : '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cloud, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            '$temp°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w300,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (city.isNotEmpty)
            Text(
              city,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    if (_isLoadingCalendar) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white54,
            ),
          ),
        ),
      );
    }

    if (_events.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            'No upcoming events',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: _events.map((event) {
        final startTime = event.start;
        final timeStr = startTime != null
            ? DateFormat('h:mm a').format(startTime)
            : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title ?? 'Untitled Event',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (timeStr.isNotEmpty)
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
