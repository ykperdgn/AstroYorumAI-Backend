import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:astroyorumai/services/astrology_calendar_service.dart';
import 'package:astroyorumai/models/celestial_event.dart';
import '../test_setup.dart';
import '../helpers/firebase_test_helper.dart';

void main() {
  group('AstrologyCalendarService', () {
    setUpAll(() {
      // Firebase test mock'larını ayarla
      setupFirebaseTestMocks();
    });

    setUp(() async {
      await setupFirebaseForTest();
      resetServiceSingletons();
    });

    tearDown(() {
      resetServiceSingletons();
    });

    group('getAllEvents', () {
      test('should return sample events when no events stored', () async {
        // Clear any existing events
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('celestial_events');

        final events = await AstrologyCalendarService.getAllEvents();

        expect(events, isNotEmpty);
        expect(events, isA<List<CelestialEvent>>());
        expect(events.length, greaterThan(10)); // Should have sample events
      });

      test('should return stored events when available', () async {
        // Store sample events
        final sampleEvents = [
          CelestialEvent(
            id: 'test_event_1',
            title: 'Test Event',
            description: 'Test Description',
            dateTime: DateTime.now(),
            type: 'test',
            isImportant: false,
            impactDescription: 'Test impact',
          )
        ];

        final prefs = await SharedPreferences.getInstance();
        final eventsJson =
            json.encode(sampleEvents.map((e) => e.toJson()).toList());
        await prefs.setString('celestial_events', eventsJson);

        final events = await AstrologyCalendarService.getAllEvents();

        expect(events, hasLength(1));
        expect(events.first.id, equals('test_event_1'));
        expect(events.first.title, equals('Test Event'));
      });

      test('should handle JSON parsing correctly', () async {
        final sampleEvents = [
          CelestialEvent(
            id: 'json_test',
            title: 'JSON Test Event',
            description: 'Testing JSON serialization',
            dateTime: DateTime(2025, 6, 15, 10, 30),
            type: 'test',
            isImportant: true,
            impactDescription: 'JSON test impact',
            planetInvolved: 'Mercury',
            signInvolved: 'Gemini',
            aspectType: 'conjunction',
          )
        ];

        final prefs = await SharedPreferences.getInstance();
        final eventsJson =
            json.encode(sampleEvents.map((e) => e.toJson()).toList());
        await prefs.setString('celestial_events', eventsJson);

        final events = await AstrologyCalendarService.getAllEvents();
        final event = events.first;

        expect(event.id, equals('json_test'));
        expect(event.title, equals('JSON Test Event'));
        expect(event.isImportant, isTrue);
        expect(event.planetInvolved, equals('Mercury'));
        expect(event.signInvolved, equals('Gemini'));
        expect(event.aspectType, equals('conjunction'));
      });
    });

    group('getEventsInRange', () {
      test('should return events within date range', () async {
        final startDate = DateTime(2025, 6, 1);
        final endDate = DateTime(2025, 6, 30);

        final events =
            await AstrologyCalendarService.getEventsInRange(startDate, endDate);

        expect(events, isA<List<CelestialEvent>>());

        // Verify all events are within the range (with buffer)
        for (final event in events) {
          expect(
              event.dateTime
                  .isAfter(startDate.subtract(const Duration(days: 2))),
              isTrue,
              reason:
                  'Event ${event.title} should be after start date with buffer');
          expect(event.dateTime.isBefore(endDate.add(const Duration(days: 2))),
              isTrue,
              reason:
                  'Event ${event.title} should be before end date with buffer');
        }
      });

      test('should handle empty date range', () async {
        final startDate = DateTime(2025, 12, 31);
        final endDate = DateTime(2025, 12, 31);

        final events =
            await AstrologyCalendarService.getEventsInRange(startDate, endDate);

        expect(events, isA<List<CelestialEvent>>());
        // May be empty or contain events with buffer
      });

      test('should handle reverse date range', () async {
        final startDate = DateTime(2025, 6, 30);
        final endDate = DateTime(2025, 6, 1);

        final events =
            await AstrologyCalendarService.getEventsInRange(startDate, endDate);

        expect(events, isA<List<CelestialEvent>>());
        expect(events, isEmpty); // Should be empty for reverse range
      });

      test('should handle date range spanning multiple months', () async {
        final startDate = DateTime(2025, 5, 15);
        final endDate = DateTime(2025, 8, 15);

        final events =
            await AstrologyCalendarService.getEventsInRange(startDate, endDate);

        expect(events, isA<List<CelestialEvent>>());
        expect(events, isNotEmpty);
      });

      test('should return events within the specified date range', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('celestial_events');

        final startDate = DateTime.now().subtract(const Duration(days: 5));
        final endDate = DateTime.now().add(const Duration(days: 5));

        final events =
            await AstrologyCalendarService.getEventsInRange(startDate, endDate);

        expect(events, isNotEmpty);
        expect(
            events.every((event) =>
                event.dateTime
                    .isAfter(startDate.subtract(const Duration(days: 1))) &&
                event.dateTime.isBefore(endDate.add(const Duration(days: 1)))),
            isTrue);
      });
    });

    group('getUpcomingEvents', () {
      test('should return events for next 30 days by default', () async {
        final events = await AstrologyCalendarService.getUpcomingEvents();

        expect(events, isA<List<CelestialEvent>>());

        final now = DateTime.now();
        final thirtyDaysFromNow = now.add(const Duration(days: 30));

        for (final event in events) {
          expect(event.dateTime.isAfter(now.subtract(const Duration(days: 1))),
              isTrue,
              reason: 'Upcoming event should be after now');
          expect(
              event.dateTime
                  .isBefore(thirtyDaysFromNow.add(const Duration(days: 1))),
              isTrue,
              reason: 'Upcoming event should be within 30 days');
        }
      });

      test('should handle custom days parameter', () async {
        const customDays = 7;
        final events =
            await AstrologyCalendarService.getUpcomingEvents(days: customDays);

        expect(events, isA<List<CelestialEvent>>());

        final now = DateTime.now();
        final customDaysFromNow = now.add(const Duration(days: customDays));

        for (final event in events) {
          expect(event.dateTime.isAfter(now.subtract(const Duration(days: 1))),
              isTrue,
              reason: 'Event should be after now');
          expect(
              event.dateTime
                  .isBefore(customDaysFromNow.add(const Duration(days: 1))),
              isTrue,
              reason: 'Event should be within custom days range');
        }
      });

      test('should handle zero days parameter', () async {
        final events =
            await AstrologyCalendarService.getUpcomingEvents(days: 0);

        expect(events, isA<List<CelestialEvent>>());
      });

      test('should handle large days parameter', () async {
        final events =
            await AstrologyCalendarService.getUpcomingEvents(days: 365);

        expect(events, isA<List<CelestialEvent>>());
      });

      test('should return events for the next 30 days by default', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('celestial_events');

        final events = await AstrologyCalendarService.getUpcomingEvents();

        expect(events, isNotEmpty);
        expect(
            events.every((event) =>
                event.dateTime.isAfter(DateTime.now()) &&
                event.dateTime
                    .isBefore(DateTime.now().add(const Duration(days: 30)))),
            isTrue);
      });
    });

    group('getTodaysEvents', () {
      test('should return events for today', () async {
        final events = await AstrologyCalendarService.getTodaysEvents();

        expect(events, isA<List<CelestialEvent>>());

        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);
        final endOfDay = startOfDay.add(const Duration(days: 1));

        for (final event in events) {
          expect(
              event.dateTime
                  .isAfter(startOfDay.subtract(const Duration(days: 1))),
              isTrue,
              reason: 'Today event should be after start of day with buffer');
          expect(event.dateTime.isBefore(endOfDay.add(const Duration(days: 1))),
              isTrue,
              reason: 'Today event should be before end of day with buffer');
        }
      });

      test('should handle timezone considerations', () async {
        final events = await AstrologyCalendarService.getTodaysEvents();

        expect(events, isA<List<CelestialEvent>>());
        // Timezone handling is implicit in the date range logic
      });

      test('should return events for today', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('celestial_events');
        final events = await AstrologyCalendarService.getTodaysEvents();
        final now = DateTime.now();

        expect(events, isNotEmpty);
        expect(events.every((event) {
          final eventDay = DateTime(
              event.dateTime.year, event.dateTime.month, event.dateTime.day);
          final today = DateTime(now.year, now.month, now.day);
          return eventDay.isAtSameMomentAs(today);
        }), isTrue);
      });
    });

    group('getEventsForMonth', () {
      test('should return events for specific month', () async {
        final testMonth = DateTime(2025, 6, 15); // June 2025
        final events =
            await AstrologyCalendarService.getEventsForMonth(testMonth);

        expect(events, isA<List<CelestialEvent>>());

        final startOfMonth = DateTime(2025, 6, 1);
        final endOfMonth = DateTime(2025, 7, 1);

        for (final event in events) {
          expect(
              event.dateTime
                  .isAfter(startOfMonth.subtract(const Duration(days: 1))),
              isTrue,
              reason:
                  'Monthly event should be after start of month with buffer');
          expect(
              event.dateTime.isBefore(endOfMonth.add(const Duration(days: 1))),
              isTrue,
              reason:
                  'Monthly event should be before end of month with buffer');
        }
      });

      test('should handle February in leap year', () async {
        final febLeapYear = DateTime(2024, 2, 15); // February 2024 (leap year)
        final events =
            await AstrologyCalendarService.getEventsForMonth(febLeapYear);

        expect(events, isA<List<CelestialEvent>>());
      });

      test('should handle December (year boundary)', () async {
        final december = DateTime(2025, 12, 15);
        final events =
            await AstrologyCalendarService.getEventsForMonth(december);

        expect(events, isA<List<CelestialEvent>>());
      });
    });

    group('addCustomEvent', () {
      test('should add custom event to existing events', () async {
        final initialEvents = await AstrologyCalendarService.getAllEvents();
        final initialCount = initialEvents.length;

        final customEvent = CelestialEvent(
          id: 'custom_test_event',
          title: 'Custom Test Event',
          description: 'User-added custom event',
          dateTime: DateTime.now().add(const Duration(days: 5)),
          type: 'custom',
          isImportant: false,
          impactDescription: 'Custom event impact',
        );

        await AstrologyCalendarService.addCustomEvent(customEvent);

        final updatedEvents = await AstrologyCalendarService.getAllEvents();

        expect(updatedEvents.length, equals(initialCount + 1));
        expect(updatedEvents.any((e) => e.id == 'custom_test_event'), isTrue,
            reason: 'Custom event should be added');
      });

      test('should maintain chronological order after adding event', () async {
        final pastEvent = CelestialEvent(
          id: 'past_event',
          title: 'Past Event',
          description: 'Event in the past',
          dateTime: DateTime.now().subtract(const Duration(days: 10)),
          type: 'custom',
          isImportant: false,
          impactDescription: 'Past event impact',
        );

        await AstrologyCalendarService.addCustomEvent(pastEvent);

        final events = await AstrologyCalendarService.getAllEvents();

        // Verify events are sorted chronologically
        for (int i = 0; i < events.length - 1; i++) {
          expect(
              events[i].dateTime.isBefore(events[i + 1].dateTime) ||
                  events[i].dateTime.isAtSameMomentAs(events[i + 1].dateTime),
              isTrue,
              reason: 'Events should be in chronological order');
        }
      });

      test('should handle duplicate event IDs', () async {
        final event1 = CelestialEvent(
          id: 'duplicate_id',
          title: 'First Event',
          description: 'First event description',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'custom',
          isImportant: false,
          impactDescription: 'First impact',
        );

        final event2 = CelestialEvent(
          id: 'duplicate_id',
          title: 'Second Event',
          description: 'Second event description',
          dateTime: DateTime.now().add(const Duration(days: 2)),
          type: 'custom',
          isImportant: false,
          impactDescription: 'Second impact',
        );

        await AstrologyCalendarService.addCustomEvent(event1);
        await AstrologyCalendarService.addCustomEvent(event2);

        final events = await AstrologyCalendarService.getAllEvents();
        final duplicateEvents =
            events.where((e) => e.id == 'duplicate_id').toList();

        expect(duplicateEvents.length, equals(2));
      });

      test('should add a custom event and persist it', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('celestial_events');

        final customEvent = CelestialEvent(
          id: 'custom_event_1',
          title: 'Custom Event',
          description: 'Custom Description',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'custom',
        );

        await AstrologyCalendarService.addCustomEvent(customEvent);
        final events = await AstrologyCalendarService.getAllEvents();

        expect(events.any((event) => event.id == customEvent.id), isTrue);
      });
    });

    group('removeEvent', () {
      test('should remove event by ID', () async {
        // Add a test event
        final testEvent = CelestialEvent(
          id: 'removable_event',
          title: 'Removable Event',
          description: 'Event to be removed',
          dateTime: DateTime.now().add(const Duration(days: 3)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Removable impact',
        );

        await AstrologyCalendarService.addCustomEvent(testEvent);

        // Verify it was added
        final eventsWithAdded = await AstrologyCalendarService.getAllEvents();
        expect(eventsWithAdded.any((e) => e.id == 'removable_event'), isTrue,
            reason: 'Event should be added before removal');

        // Remove the event
        await AstrologyCalendarService.removeEvent('removable_event');

        // Verify it was removed
        final eventsAfterRemoval =
            await AstrologyCalendarService.getAllEvents();
        expect(
            eventsAfterRemoval.any((e) => e.id == 'removable_event'), isFalse,
            reason: 'Event should be removed');
      });

      test('should handle removing non-existent event', () async {
        final initialEvents = await AstrologyCalendarService.getAllEvents();
        final initialCount = initialEvents.length;

        // Try to remove non-existent event
        await AstrologyCalendarService.removeEvent('non_existent_id');

        final eventsAfterRemoval =
            await AstrologyCalendarService.getAllEvents();

        expect(eventsAfterRemoval.length, equals(initialCount));
      });

      test('should remove all instances of duplicate IDs', () async {
        // Add events with same ID
        final event1 = CelestialEvent(
          id: 'duplicate_remove_id',
          title: 'First Duplicate',
          description: 'First duplicate event',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'test',
          isImportant: false,
          impactDescription: 'First duplicate impact',
        );

        final event2 = CelestialEvent(
          id: 'duplicate_remove_id',
          title: 'Second Duplicate',
          description: 'Second duplicate event',
          dateTime: DateTime.now().add(const Duration(days: 2)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Second duplicate impact',
        );

        await AstrologyCalendarService.addCustomEvent(event1);
        await AstrologyCalendarService.addCustomEvent(event2);

        // Remove by ID (should remove both)
        await AstrologyCalendarService.removeEvent('duplicate_remove_id');

        final events = await AstrologyCalendarService.getAllEvents();
        expect(events.any((e) => e.id == 'duplicate_remove_id'), isFalse,
            reason: 'All duplicate events should be removed');
      });
    });

    group('needsUpdate', () {
      test('should return true when no last update timestamp', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('events_last_update');

        final needsUpdate = await AstrologyCalendarService.needsUpdate();

        expect(needsUpdate, isTrue);
      });

      test('should return true when last update is old', () async {
        final prefs = await SharedPreferences.getInstance();
        final oldDate = DateTime.now().subtract(const Duration(days: 10));
        await prefs.setString('events_last_update', oldDate.toIso8601String());

        final needsUpdate = await AstrologyCalendarService.needsUpdate();

        expect(needsUpdate, isTrue);
      });

      test('should return false when last update is recent', () async {
        final prefs = await SharedPreferences.getInstance();
        final recentDate = DateTime.now().subtract(const Duration(days: 3));
        await prefs.setString(
            'events_last_update', recentDate.toIso8601String());

        final needsUpdate = await AstrologyCalendarService.needsUpdate();

        expect(needsUpdate, isFalse);
      });

      test('should handle exactly 7 days threshold', () async {
        final prefs = await SharedPreferences.getInstance();
        final exactlySevenDays =
            DateTime.now().subtract(const Duration(days: 7));
        await prefs.setString(
            'events_last_update', exactlySevenDays.toIso8601String());

        final needsUpdate = await AstrologyCalendarService.needsUpdate();

        expect(needsUpdate, isTrue);
      });
    });

    group('getEventsByType', () {
      test('should filter events by type', () async {
        // Add events of different types
        final newMoonEvent = CelestialEvent(
          id: 'new_moon_test',
          title: 'New Moon Test',
          description: 'New moon for testing',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'new_moon',
          isImportant: true,
          impactDescription: 'New moon impact',
        );

        final retrogradeEvent = CelestialEvent(
          id: 'retrograde_test',
          title: 'Retrograde Test',
          description: 'Retrograde for testing',
          dateTime: DateTime.now().add(const Duration(days: 2)),
          type: 'retrograde',
          isImportant: true,
          impactDescription: 'Retrograde impact',
        );

        await AstrologyCalendarService.addCustomEvent(newMoonEvent);
        await AstrologyCalendarService.addCustomEvent(retrogradeEvent);

        final newMoonEvents =
            await AstrologyCalendarService.getEventsByType('new_moon');
        final retrogradeEvents =
            await AstrologyCalendarService.getEventsByType('retrograde');

        expect(newMoonEvents.every((e) => e.type == 'new_moon'), isTrue);
        expect(retrogradeEvents.every((e) => e.type == 'retrograde'), isTrue);
        expect(newMoonEvents.any((e) => e.id == 'new_moon_test'), isTrue);
        expect(retrogradeEvents.any((e) => e.id == 'retrograde_test'), isTrue);
      });

      test('should return empty list for non-existent type', () async {
        final events =
            await AstrologyCalendarService.getEventsByType('non_existent_type');

        expect(events, isEmpty);
      });

      test('should handle case sensitivity', () async {
        final events =
            await AstrologyCalendarService.getEventsByType('NEW_MOON');

        expect(events, isA<List<CelestialEvent>>());
        // Case sensitivity depends on the stored data
      });
    });

    group('getImportantEvents', () {
      test('should return only important events', () async {
        // Add important and non-important events
        final importantEvent = CelestialEvent(
          id: 'important_test',
          title: 'Important Event',
          description: 'This is important',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'test',
          isImportant: true,
          impactDescription: 'Important impact',
        );

        final normalEvent = CelestialEvent(
          id: 'normal_test',
          title: 'Normal Event',
          description: 'This is not important',
          dateTime: DateTime.now().add(const Duration(days: 2)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Normal impact',
        );

        await AstrologyCalendarService.addCustomEvent(importantEvent);
        await AstrologyCalendarService.addCustomEvent(normalEvent);

        final importantEvents =
            await AstrologyCalendarService.getImportantEvents();

        expect(importantEvents.every((e) => e.isImportant), isTrue);
        expect(importantEvents.any((e) => e.id == 'important_test'), isTrue);
        expect(importantEvents.any((e) => e.id == 'normal_test'), isFalse);
      });

      test('should return empty list if no important events', () async {
        // Clear existing events
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('celestial_events');

        // Add only non-important event
        final normalEvent = CelestialEvent(
          id: 'only_normal_test',
          title: 'Only Normal Event',
          description: 'This is not important',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Normal impact',
        );

        // Need to save manually since we cleared events
        final prefs2 = await SharedPreferences.getInstance();
        final eventsJson = json.encode([normalEvent.toJson()]);
        await prefs2.setString('celestial_events', eventsJson);

        final importantEvents =
            await AstrologyCalendarService.getImportantEvents();

        expect(importantEvents, isEmpty);
      });
    });

    group('searchEvents', () {
      test('should search by title', () async {
        final searchableEvent = CelestialEvent(
          id: 'searchable_title',
          title: 'Mercury Retrograde Special',
          description: 'Regular description',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'retrograde',
          isImportant: true,
          impactDescription: 'Search impact',
        );

        await AstrologyCalendarService.addCustomEvent(searchableEvent);

        final results = await AstrologyCalendarService.searchEvents('Mercury');

        expect(results.any((e) => e.id == 'searchable_title'), isTrue);
      });

      test('should search by description', () async {
        final searchableEvent = CelestialEvent(
          id: 'searchable_description',
          title: 'Regular Title',
          description: 'This event involves Venus energy',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Search impact',
        );

        await AstrologyCalendarService.addCustomEvent(searchableEvent);

        final results = await AstrologyCalendarService.searchEvents('Venus');

        expect(results.any((e) => e.id == 'searchable_description'), isTrue);
      });

      test('should search by planet involved', () async {
        final searchableEvent = CelestialEvent(
          id: 'searchable_planet',
          title: 'Planet Event',
          description: 'Event description',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Search impact',
          planetInvolved: 'Jupiter',
        );

        await AstrologyCalendarService.addCustomEvent(searchableEvent);

        final results = await AstrologyCalendarService.searchEvents('Jupiter');

        expect(results.any((e) => e.id == 'searchable_planet'), isTrue);
      });

      test('should search by sign involved', () async {
        final searchableEvent = CelestialEvent(
          id: 'searchable_sign',
          title: 'Sign Event',
          description: 'Event description',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Search impact',
          signInvolved: 'Aries',
        );

        await AstrologyCalendarService.addCustomEvent(searchableEvent);

        final results = await AstrologyCalendarService.searchEvents('Aries');

        expect(results.any((e) => e.id == 'searchable_sign'), isTrue);
      });

      test('should handle case insensitive search', () async {
        final searchableEvent = CelestialEvent(
          id: 'case_test',
          title: 'UPPERCASE TITLE',
          description: 'lowercase description',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Case impact',
        );

        await AstrologyCalendarService.addCustomEvent(searchableEvent);

        final upperResults =
            await AstrologyCalendarService.searchEvents('uppercase');
        final lowerResults =
            await AstrologyCalendarService.searchEvents('LOWERCASE');

        expect(upperResults.any((e) => e.id == 'case_test'), isTrue);
        expect(lowerResults.any((e) => e.id == 'case_test'), isTrue);
      });

      test('should return empty list for no matches', () async {
        final results = await AstrologyCalendarService.searchEvents(
            'NonExistentSearchTerm');

        expect(results, isEmpty);
      });

      test('should handle empty search query', () async {
        final results = await AstrologyCalendarService.searchEvents('');

        expect(results, isA<List<CelestialEvent>>());
        // Empty query might return all events or no events depending on implementation
      });

      test('should handle null planet/sign fields', () async {
        final eventWithNulls = CelestialEvent(
          id: 'null_fields_test',
          title: 'Event with null fields',
          description: 'Testing null safety',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Null safety impact',
          planetInvolved: null,
          signInvolved: null,
        );

        await AstrologyCalendarService.addCustomEvent(eventWithNulls);

        // Should not throw error when searching with null fields
        final results = await AstrologyCalendarService.searchEvents('testing');

        expect(results, isA<List<CelestialEvent>>());
      });
    });

    group('Sample Events Generation', () {
      test('should generate events for multiple months', () async {
        // Clear existing events and get fresh sample events
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('celestial_events');

        final events = await AstrologyCalendarService.getAllEvents();

        // Should have events for next 6 months
        final now = DateTime.now();
        final sixMonthsFromNow = DateTime(now.year, now.month + 6, now.day);

        final futureEvents = events
            .where((e) =>
                e.dateTime.isAfter(now) &&
                e.dateTime.isBefore(sixMonthsFromNow))
            .toList();

        expect(futureEvents, isNotEmpty);
      });

      test('should include different types of events', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('celestial_events');

        final events = await AstrologyCalendarService.getAllEvents();

        final eventTypes = events.map((e) => e.type).toSet();

        expect(eventTypes.contains('new_moon'), isTrue);
        expect(eventTypes.contains('full_moon'), isTrue);
        expect(eventTypes.contains('eclipse'), isTrue);
        expect(eventTypes.contains('retrograde'), isTrue);
      });

      test('should include important events', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('celestial_events');

        final events = await AstrologyCalendarService.getAllEvents();

        final importantEvents = events.where((e) => e.isImportant).toList();

        expect(importantEvents, isNotEmpty);
      });

      test('should have valid event properties', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('celestial_events');

        final events = await AstrologyCalendarService.getAllEvents();

        for (final event in events) {
          expect(event.id, isNotEmpty);
          expect(event.title, isNotEmpty);
          expect(event.description, isNotEmpty);
          expect(event.type, isNotEmpty);
          expect(event.impactDescription, isNotEmpty);
          expect(event.dateTime, isNotNull);
        }
      });
    });

    group('Storage and Persistence', () {
      test('should persist events across service calls', () async {
        final testEvent = CelestialEvent(
          id: 'persistence_test',
          title: 'Persistence Test Event',
          description: 'Testing data persistence',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Persistence impact',
        );

        await AstrologyCalendarService.addCustomEvent(testEvent);

        // Get events again (simulating app restart)
        final events = await AstrologyCalendarService.getAllEvents();

        expect(events.any((e) => e.id == 'persistence_test'), isTrue);
      });

      test('should update last update timestamp when saving', () async {
        final prefs = await SharedPreferences.getInstance();

        // Clear timestamp
        await prefs.remove('events_last_update');

        final testEvent = CelestialEvent(
          id: 'timestamp_test',
          title: 'Timestamp Test',
          description: 'Testing timestamp update',
          dateTime: DateTime.now().add(const Duration(days: 1)),
          type: 'test',
          isImportant: false,
          impactDescription: 'Timestamp impact',
        );

        await AstrologyCalendarService.addCustomEvent(testEvent);

        final lastUpdateStr = prefs.getString('events_last_update');
        expect(lastUpdateStr, isNotNull);

        final lastUpdate = DateTime.parse(lastUpdateStr!);
        expect(
            lastUpdate.difference(DateTime.now()).abs().inMinutes, lessThan(1));
      });
    });

    group('Error Handling', () {
      test('should handle corrupted JSON data', () async {
        final prefs = await SharedPreferences.getInstance();

        // Store corrupted JSON
        await prefs.setString('celestial_events', '{"corrupted": json}');

        // Should handle gracefully and return sample events
        final events = await AstrologyCalendarService.getAllEvents();

        expect(events, isA<List<CelestialEvent>>());
        expect(events, isNotEmpty);
      });

      test('should handle invalid date strings', () async {
        final prefs = await SharedPreferences.getInstance();

        // Store event with invalid date
        await prefs.setString('events_last_update', 'invalid-date');
        // Should handle gracefully
        final needsUpdate = await AstrologyCalendarService.needsUpdate();

        expect(needsUpdate, isTrue); // Should default to needing update
      });
    });

    tearDownAll(() {
      // Firebase test mock'larını temizle
      tearDownFirebaseTestMocks();
    });
  });
}
