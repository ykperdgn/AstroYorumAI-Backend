import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroyorumai/screens/astrology_calendar_screen.dart';
import 'package:astroyorumai/models/celestial_event.dart';
import 'package:astroyorumai/services/astrology_calendar_service.dart';
import '../test_helpers.dart';

void main() {
  group('AstrologyCalendarScreen Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });    testWidgets('Displays correct events for selected date range', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(AstrologyCalendarScreen()));

      // Simulate selecting a date range
      // Add assertions to verify correct events are displayed
    });    testWidgets('Filters work correctly (Today, This Week, All Events)', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(AstrologyCalendarScreen()));

      // Simulate filter selection
      // Add assertions to verify correct filtering
    });    testWidgets('Add new event button opens form and saves event', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(AstrologyCalendarScreen()));

      // Simulate button click
      // Add assertions to verify form opens and event is saved
    });    testWidgets('Date range selection filters events correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(AstrologyCalendarScreen()));

      // Simulate date range selection
      final dateRangeButton = find.byKey(Key('dateRangeButton'));
      expect(dateRangeButton, findsOneWidget);
      await tester.tap(dateRangeButton);
      await tester.pumpAndSettle();

      // Select start and end dates
      await tester.tap(find.text('2025-06-01'));
      await tester.tap(find.text('2025-06-07'));
      await tester.pumpAndSettle();      // Verify filtered events are displayed
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Today filter displays only today’s events', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: AstrologyCalendarScreen()));

      final todayFilter = find.text('Today');
      await tester.tap(todayFilter);
      await tester.pumpAndSettle();

      // Verify only today’s events are displayed
      expect(find.textContaining('June 1'), findsNothing);
    });    testWidgets('Add New Event opens form and saves event', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(AstrologyCalendarScreen()));

      final addEventBtn = find.byKey(Key('addEventButton'));
      expect(addEventBtn, findsOneWidget);
      await tester.tap(addEventBtn);
      await tester.pumpAndSettle();

      // Fill out the form
      await tester.enterText(find.byKey(Key('eventTitleField')), 'Test Event');
      await tester.tap(find.byKey(Key('saveEventButton')));
      await tester.pumpAndSettle();

      // Verify the new event is added to the list
      expect(find.text('Test Event'), findsOneWidget);
    });
  });
}
