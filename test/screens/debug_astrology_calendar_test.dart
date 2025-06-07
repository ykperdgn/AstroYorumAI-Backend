import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:astroyorumai/screens/astrology_calendar_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  group('Debug AstrologyCalendarScreen Widget', () {

    setUpAll(() async {
      // Initialize date formatting for table_calendar
      await initializeDateFormatting('tr_TR', null);
    });

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Check widget tree structure', (WidgetTester tester) async {
      // Create test app without using test_helpers
      const app = MaterialApp(
        home: AstrologyCalendarScreen(),
      );
      
      await tester.pumpWidget(app);

      // Wait for initial loading
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Check loading state
      final circularProgress = find.byType(CircularProgressIndicator);
      print('CircularProgressIndicator found: ${circularProgress.evaluate().length}');

      // Wait longer for async operations
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Check if we can find any FloatingActionButton
      final fab = find.byType(FloatingActionButton);
      print('FloatingActionButton found: ${fab.evaluate().length}');
      
      // Check if we can find any ElevatedButton
      final elevatedButtons = find.byType(ElevatedButton);
      print('ElevatedButton found: ${elevatedButtons.evaluate().length}');

      // Try to find by key
      final dateRangeButton = find.byKey(const Key('dateRangeButton'));
      print('dateRangeButton key found: ${dateRangeButton.evaluate().length}');
      
      final addEventButton = find.byKey(const Key('addEventButton'));
      print('addEventButton key found: ${addEventButton.evaluate().length}');

      // Basic assertions to pass the test
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
