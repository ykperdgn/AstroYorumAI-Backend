import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroyorumai/screens/astrology_calendar_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../test_helpers.dart';

void main() {
  group('AstrologyCalendarScreen Widget Tests', () {
    setUpAll(() async {
      // Initialize date formatting for table_calendar
      await initializeDateFormatting('tr_TR', null);
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Displays calendar tab with date range button',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const AstrologyCalendarScreen()));
      await tester.pumpAndSettle();

      // Check that the calendar tab is displayed
      expect(find.text('Takvim'), findsOneWidget);

      // Check for date range button (should be visible by default on calendar tab)
      expect(find.byKey(const Key('dateRangeButton')), findsOneWidget);
    });
    testWidgets('Search tab displays filter chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const AstrologyCalendarScreen()));
      await tester.pumpAndSettle();

      // Navigate to search tab
      await tester.tap(find.text('Ara'));
      await tester.pumpAndSettle();

      // Test filter chips exist by finding FilterChip widgets
      expect(find.byType(FilterChip), findsAtLeastNWidgets(3));

      // Test that specific filter labels exist (but more specifically)
      expect(find.widgetWithText(FilterChip, 'Tümü'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Yeni Ay'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Dolunay'), findsOneWidget);
    });

    testWidgets('Upcoming tab displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const AstrologyCalendarScreen()));
      await tester.pumpAndSettle();

      // Navigate to upcoming tab
      await tester.tap(find.text('Yaklaşan'));
      await tester.pumpAndSettle();

      // Should display upcoming events section
      expect(find.text('Önümüzdeki 30 Gün'), findsOneWidget);
    });

    testWidgets('Add new event button is visible', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const AstrologyCalendarScreen()));
      await tester.pumpAndSettle();

      // Find the FloatingActionButton with correct key
      final addEventBtn = find.byKey(const Key('addEventButton'));
      expect(addEventBtn, findsOneWidget);
    });
  });
}
