import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';

class CalendarService {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<List<Event>> getUpcomingEvents() async {
    try {
      // Check permissions
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
          return [];
        }
      }

      // Get calendars
      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) {
        return [];
      }

      final calendars = calendarsResult.data!;
      final List<Event> allEvents = [];
      final now = DateTime.now();
      final end = now.add(const Duration(days: 7)); // Look ahead 7 days

      // Fetch events from all writable calendars
      for (var calendar in calendars) {
        if (calendar.id != null) {
          final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
            calendar.id,
            RetrieveEventsParams(startDate: now, endDate: end),
          );

          if (eventsResult.isSuccess && eventsResult.data != null) {
            allEvents.addAll(eventsResult.data!);
          }
        }
      }

      // Sort by start time
      allEvents.sort((a, b) {
        if (a.start == null || b.start == null) return 0;
        return a.start!.compareTo(b.start!);
      });

      // Return top 3 upcoming events
      return allEvents.take(3).toList();
    } catch (e) {
      debugPrint('Error getting calendar events: $e');
      return [];
    }
  }
}
