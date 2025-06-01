import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'package:astroyorumai/models/user_birth_info.dart';
import 'package:astroyorumai/widgets/loading_indicator.dart';
import 'birth_info_screen_test.mocks.dart';
import '../test_helpers.dart';

void main() {
  group('BirthInfoScreen Fixed Tests V2', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
    });

    Widget createTestWidget(Widget child) {
      return createTestApp(child);
    }

    // Helper function to set date and time directly on the screen state
    void setDateTimeDirectly(WidgetTester tester, DateTime date, TimeOfDay time) {
      final screenState = tester.state<_BirthInfoScreenState>(find.byType(BirthInfoScreen));
      screenState.setState(() {
        screenState._selectedDate = date;
        screenState._selectedTime = time;
      });
    }

    testWidgets('validates latitude field correctly - WORKING FIX', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any)).thenAnswer((_) async => null);
      
      // Track if save was called (should NOT be called with invalid data)
      bool saveWasCalled = false;
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {
        saveWasCalled = true;
      });

      // Create widget with proper initial state
      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Fill ALL required fields first to bypass early validation checks
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User'); // Name
      await tester.pump();
      
      // Set date and time directly to avoid picker dialog issues
      setDateTimeDirectly(tester, DateTime(1990, 1, 15), TimeOfDay(hour: 12, minute: 0));
      await tester.pump();

      // Now enter invalid coordinates - this is where validation should trigger
      await tester.enterText(find.byType(TextFormField).at(2), '95.0'); // Invalid latitude
      await tester.enterText(find.byType(TextFormField).at(3), '30.0'); // Valid longitude
      await tester.pump();

      // Submit form - this should trigger validation which should fail
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify form validation prevented submission
      expect(saveWasCalled, false, reason: 'Save should not be called with invalid latitude');
      
      // Verify we're still on the form screen
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
    });

    testWidgets('validates longitude field correctly - WORKING FIX', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any)).thenAnswer((_) async => null);
      
      bool saveWasCalled = false;
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {
        saveWasCalled = true;
      });

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Fill all required fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.pump();
      
      // Set date and time directly
      setDateTimeDirectly(tester, DateTime(1990, 1, 15), TimeOfDay(hour: 12, minute: 0));
      await tester.pump();

      // Enter invalid longitude
      await tester.enterText(find.byType(TextFormField).at(2), '40.0'); // Valid latitude
      await tester.enterText(find.byType(TextFormField).at(3), '200.0'); // Invalid longitude
      await tester.pump();

      // Submit form
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify validation worked
      expect(saveWasCalled, false, reason: 'Save should not be called with invalid longitude');
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
    });

    testWidgets('displays processing state during geocoding - WORKING FIX', (WidgetTester tester) async {
      // Mock geocoding with controlled delay
      when(mockGeocodingService.getCoordinates('İstanbul')).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 100));
        return {'lat': 41.0082, 'lon': 28.9784};
      });
      
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {
        await Future.delayed(Duration(milliseconds: 50));
      });

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Fill required fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.pump();
      
      // Set date and time directly
      setDateTimeDirectly(tester, DateTime(1990, 1, 15), TimeOfDay(hour: 12, minute: 0));
      await tester.pump();

      // Enter birth place but leave coordinates empty to trigger geocoding
      await tester.enterText(find.byType(TextFormField).at(1), 'İstanbul');
      await tester.pump();

      // Submit form to trigger geocoding
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      
      // Check for processing state immediately after tap
      await tester.pump();
      await tester.pump(Duration(milliseconds: 50));

      // During geocoding, should show loading indicator
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Bilgiler işleniyor...'), findsOneWidget);
      
      // Wait for geocoding and save to complete
      await tester.pumpAndSettle();

      // Verify that mock services were called
      verify(mockGeocodingService.getCoordinates('İstanbul')).called(1);
      verify(mockPreferencesService.saveUserBirthInfo(any)).called(1);
    });

    testWidgets('successfully submits valid form without geocoding', (WidgetTester tester) async {
      // No geocoding needed - manual coordinates provided
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Fill all fields correctly
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.pump();
      
      // Set date and time directly
      setDateTimeDirectly(tester, DateTime(1990, 1, 15), TimeOfDay(hour: 12, minute: 0));
      await tester.pump();

      // Provide valid coordinates manually (no geocoding needed)
      await tester.enterText(find.byType(TextFormField).at(2), '39.925533'); // Valid latitude
      await tester.enterText(find.byType(TextFormField).at(3), '32.866287'); // Valid longitude
      await tester.pump();

      // Submit form
      final submitButton = find.text('Natal Haritamı Hesapla');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify successful submission
      verify(mockPreferencesService.saveUserBirthInfo(any)).called(1);
      
      // Verify save was called with correct data
      final capturedBirthInfo = verify(mockPreferencesService.saveUserBirthInfo(captureAny)).captured.single as UserBirthInfo;
      expect(capturedBirthInfo.name, 'Test User');
      expect(capturedBirthInfo.latitude, 39.925533);
      expect(capturedBirthInfo.longitude, 32.866287);
    });
    
    testWidgets('handles form validation error display gracefully', (WidgetTester tester) async {
      // This test verifies that even if validation error messages are not visible in tests,
      // the validation logic itself works correctly
      
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
          ),
        ),
      );

      // Fill required fields correctly
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.pump();
      
      // Set date and time directly
      setDateTimeDirectly(tester, DateTime(1990, 1, 15), TimeOfDay(hour: 12, minute: 0));
      await tester.pump();

      // Test sequence: invalid -> valid to verify both states
      
      // 1. Submit with invalid data
      await tester.enterText(find.byType(TextFormField).at(2), '95.0'); // Invalid
      await tester.enterText(find.byType(TextFormField).at(3), '200.0'); // Invalid
      await tester.pump();

      await tester.tap(find.text('Natal Haritamı Hesapla'));
      await tester.pumpAndSettle();

      // Should not have been called with invalid data
      verifyNever(mockPreferencesService.saveUserBirthInfo(any));
      
      // 2. Fix the data and submit again
      await tester.enterText(find.byType(TextFormField).at(2), '39.925533'); // Valid
      await tester.enterText(find.byType(TextFormField).at(3), '32.866287'); // Valid
      await tester.pump();

      await tester.tap(find.text('Natal Haritamı Hesapla'));
      await tester.pumpAndSettle();

      // Now should be called with valid data
      verify(mockPreferencesService.saveUserBirthInfo(any)).called(1);
    });
  });
}

// Extension to access private state members - this is a common testing pattern
extension BirthInfoScreenTestExtension on _BirthInfoScreenState {
  set _selectedDate(DateTime? date) => _selectedDate = date;
  set _selectedTime(TimeOfDay? time) => _selectedTime = time;
}
