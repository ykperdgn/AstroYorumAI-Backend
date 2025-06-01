import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'package:astroyorumai/models/user_birth_info.dart';
import 'package:astroyorumai/widgets/loading_indicator.dart'; // Import LoadingIndicator
import 'birth_info_screen_test.mocks.dart';
import '../test_helpers.dart';

void main() {
  group('BirthInfoScreen Validation Working Tests', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
    });

    Widget createTestWidget(Widget child) {
      return createTestApp(child);
    }

    testWidgets('validates latitude field correctly with prefilled profile', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any)).thenAnswer((_) async => null);
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {});

      final profile = UserProfile(
        id: 'test-profile-id-latitude', // Added dummy ID
        name: 'Test User',
        birthDate: DateTime(1990, 1, 15),
        birthTime: '12:00',
        birthPlace: 'Test City',
        latitude: 40.0, // Valid initial
        longitude: 30.0, // Valid initial
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            prefilledProfile: profile,
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
            alwaysAutoValidate: true,
          ),
        ),
      );

      await tester.pumpAndSettle(); 
      
      // Ensure LoadingIndicator is not present initially
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing initially");

      // Find the latitude field and enter invalid value
      final latitudeField = find.byType(TextFormField).at(2); // Latitude is the 3rd TextFormField
      await tester.enterText(latitudeField, '95.0'); // Invalid latitude (>90)
      await tester.pumpAndSettle(); // Let auto-validation run and UI update

      // Verify validation error message is shown due to alwaysAutoValidate
      expect(find.text('Enlem -90 ile 90 arasında olmalıdır'), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing after invalid input");
      
      // Check if the Form widget itself is still present
      expect(find.byType(Form), findsOneWidget, reason: "Form should still be present");

      // Add this line for debugging:
      debugPrint(tester.binding.renderView.toStringDeep());

      final submitButtonFinder = find.byKey(const Key('submit_button'));
      expect(submitButtonFinder, findsOneWidget, reason: 'Submit button should be found after invalid latitude input');
      
      ElevatedButton buttonWidget = tester.widget<ElevatedButton>(submitButtonFinder);
      var onPressed = buttonWidget.onPressed;
      expect(onPressed, isNotNull, reason: 'Submit button should be enabled with invalid latitude but not processing');

      if (onPressed != null) {
        await tester.runAsync(() async {
          onPressed?.call(); // This calls _handleFormSubmission
        });
      }
      await tester.pumpAndSettle(); // Let _handleFormSubmission run (it should return early)

      // Verify form validation prevented submission
      verifyNever(mockPreferencesService.saveUserBirthInfo(any));
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing after failed submission attempt");
      
      // Verify we're still on the form screen
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
      
      // Re-check button state if necessary, though it might be disabled if form is still invalid
      // and _handleFormSubmission did not set _isProcessing to true and back to false.
      buttonWidget = tester.widget<ElevatedButton>(submitButtonFinder); // Re-fetch widget
      onPressed = buttonWidget.onPressed;
      expect(onPressed, isNotNull, reason: 'Button onPressed should still be active as form is on screen');
    });

    testWidgets('validates longitude field correctly with prefilled profile', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any)).thenAnswer((_) async => null);
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {});

      final profile = UserProfile(
        id: 'test-profile-id-longitude', // Added dummy ID
        name: 'Test User',
        birthDate: DateTime(1990, 1, 15),
        birthTime: '12:00',
        birthPlace: 'Test City', // Non-empty birthPlace
        latitude: 40.0,
        longitude: 30.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            prefilledProfile: profile,
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
            alwaysAutoValidate: true,
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Ensure LoadingIndicator is not present initially
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing initially");
      
      // Find the longitude field and enter invalid value
      final longitudeField = find.byType(TextFormField).at(3); // Longitude is the 4th TextFormField
      await tester.enterText(longitudeField, '185.0'); // Invalid longitude (>180)
      await tester.pumpAndSettle(); // Let auto-validation run and UI update

      // Verify validation error message is shown due to alwaysAutoValidate
      expect(find.text('Boylam -180 ile 180 arasında olmalıdır'), findsOneWidget);
      // Ensure LoadingIndicator is still not present after text entry and validation
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing after invalid input");
      
      // Check if the Form widget itself is still present
      expect(find.byType(Form), findsOneWidget, reason: "Form should still be present");
      // Add this line for debugging:
      debugPrint(tester.binding.renderView.toStringDeep());

      // Ensure the button is findable before interacting
      await tester.pumpAndSettle();
      final submitButtonFinder = find.byKey(const Key('submit_button'));
      expect(submitButtonFinder, findsOneWidget, reason: 'Submit button should be found after invalid longitude input');

      ElevatedButton buttonWidget = tester.widget<ElevatedButton>(submitButtonFinder);
      var onPressed = buttonWidget.onPressed;
      expect(onPressed, isNotNull, reason: 'Submit button should be enabled with invalid longitude but not processing');

      if (onPressed != null) {
        await tester.runAsync(() async {
          onPressed?.call();
        });
      }
      await tester.pumpAndSettle();

      // Verify form validation prevented submission
      verifyNever(mockPreferencesService.saveUserBirthInfo(any));
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing after failed submission attempt");
      
      // Verify we're still on the form screen
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);

      buttonWidget = tester.widget<ElevatedButton>(submitButtonFinder);
      onPressed = buttonWidget.onPressed;
      expect(onPressed, isNotNull, reason: 'Button onPressed should still be active as form is on screen');
    });

    testWidgets('validates coordinate format correctly', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any)).thenAnswer((_) async => null);
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {});

      final profile = UserProfile(
        id: 'test-profile-id-format', // Added dummy ID
        name: 'Test User',
        birthDate: DateTime(1990, 1, 15),
        birthTime: '12:00',
        birthPlace: 'Test City', // Non-empty birthPlace
        latitude: 40.0,
        longitude: 30.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            prefilledProfile: profile,
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
            alwaysAutoValidate: true,
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Ensure LoadingIndicator is not present initially
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing initially");

      // Enter invalid format for latitude (non-numeric)
      final latitudeField = find.byType(TextFormField).at(2);
      await tester.enterText(latitudeField, 'invalid');
      await tester.pumpAndSettle(); // Let auto-validation run and UI update

      // Verify validation error message is shown due to alwaysAutoValidate
      expect(find.text('Geçerli bir sayı girin'), findsOneWidget);
      // Ensure LoadingIndicator is still not present after text entry and validation
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing after invalid input");
      
      // Check if the Form widget itself is still present
      expect(find.byType(Form), findsOneWidget, reason: "Form should still be present");
      // Add this line for debugging:
      debugPrint(tester.binding.renderView.toStringDeep());

      // Ensure the button is findable before interacting
      final submitButtonFinder = find.byKey(const Key('submit_button'));
      expect(submitButtonFinder, findsOneWidget, reason: 'Submit button should be found after invalid format input');
      
      ElevatedButton buttonWidget = tester.widget<ElevatedButton>(submitButtonFinder);
      var onPressed = buttonWidget.onPressed;
      expect(onPressed, isNotNull, reason: 'Submit button should be enabled with invalid latitude format but not processing');

      if (onPressed != null) {
        await tester.runAsync(() async {
          onPressed?.call();
        });
      }
      await tester.pumpAndSettle();

      // Verify form validation prevented submission
      verifyNever(mockPreferencesService.saveUserBirthInfo(any));
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing after failed submission attempt");
      
      // Verify we're still on the form screen
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);

      buttonWidget = tester.widget<ElevatedButton>(submitButtonFinder);
      onPressed = buttonWidget.onPressed;
      expect(onPressed, isNotNull, reason: 'Button onPressed should still be active as form is on screen');
    });    testWidgets('submits successfully with valid data (prefilled profile, no geocoding needed)', (WidgetTester tester) async {
      UserBirthInfo? capturedBirthInfo;
      
      // Setup mock to capture the saved birth info
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((invocation) async {
        capturedBirthInfo = invocation.positionalArguments[0] as UserBirthInfo;
      });
      
      final profile = UserProfile(
        id: 'test-profile-id-submit', // Added dummy ID
        name: 'Valid User',
        birthDate: DateTime(1990, 1, 15),
        birthTime: '12:00',
        birthPlace: 'Test City',
        latitude: 40.0,
        longitude: 30.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            prefilledProfile: profile,
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
            alwaysAutoValidate: true, 
          ),
        ),
      );

      await tester.pumpAndSettle(); 
      // Ensure LoadingIndicator is not present initially
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing initially for valid form");

      // No validation errors should be present with valid prefilled data and alwaysAutoValidate
      expect(find.text('Lütfen adınızı ve soyadınızı girin.'), findsNothing);
      expect(find.text('Enlem -90 ile 90 arasında olmalıdır'), findsNothing);
      expect(find.text('Boylam -180 ile 180 arasında olmalıdır'), findsNothing);
      expect(find.text('Geçerli bir sayı girin'), findsNothing);
      expect(find.text('Lütfen enlem girin (Örn: 39.925533)'), findsNothing);
      expect(find.text('Lütfen boylam girin (Örn: 32.866287)'), findsNothing);
      
      // Ensure the button is findable before interacting
      final submitButtonFinder = find.byKey(const Key('submit_button'));
      expect(submitButtonFinder, findsOneWidget, reason: 'Submit button should be found with valid data');
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing before submission attempt");
        final ElevatedButton buttonWidget = tester.widget<ElevatedButton>(submitButtonFinder);
      final onPressed = buttonWidget.onPressed;
      expect(onPressed, isNotNull, reason: 'Submit button should be enabled with valid data');

      if (onPressed != null) {
        await tester.runAsync(() async {
          onPressed?.call(); // This calls _handleFormSubmission
        });
        await tester.pump(); // Start state change for _isProcessing
        await tester.pump(const Duration(milliseconds: 200)); // Allow more time for UI to rebuild with LoadingIndicator
        expect(find.byType(LoadingIndicator), findsOneWidget, reason: "Should be processing during submission");
      }
      // Wait for _handleFormSubmission to complete, including async save and SnackBar
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Allow time for save and snackbar
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing after submission completes");

      verify(mockPreferencesService.saveUserBirthInfo(any)).called(1);
      expect(capturedBirthInfo, isNotNull);
      expect(capturedBirthInfo!.name, equals('Valid User'));
      expect(capturedBirthInfo!.latitude, equals(40.0));
      expect(capturedBirthInfo!.longitude, equals(30.0));
      expect(find.text('Doğum bilgileriniz kaydedildi.'), findsOneWidget);
      
      // Verify navigation or callback occurred (not explicitly testable here without more setup)
    });

    testWidgets('validates required name field (shows field error on load, then SnackBar on submit attempt)', (WidgetTester tester) async {
      when(mockGeocodingService.getCoordinates(any)).thenAnswer((_) async => null);
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {});

      final profile = UserProfile(
        id: 'test-profile-id-name', // Added dummy ID
        name: '', // Empty name
        birthDate: DateTime(1990, 1, 15),
        birthTime: '12:00',
        birthPlace: 'Test City',
        latitude: 40.0,
        longitude: 30.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        createTestWidget(
          BirthInfoScreen(
            prefilledProfile: profile, 
            preferencesService: mockPreferencesService,
            geocodingService: mockGeocodingService,
            alwaysAutoValidate: true, 
          ),
        ),
      );

      // With alwaysAutoValidate: true, the Form's AutovalidateMode.always
      // should trigger the name field's validator immediately.
      await tester.pumpAndSettle(); 
        // Check for the TextFormField's own error message (with period).
      expect(find.text('Lütfen adınızı ve soyadınızı girin.'), findsOneWidget, 
        reason: "Name field's validator should show error due to AutovalidateMode.always on initial load with empty name");
      
      // Ensure LoadingIndicator is not present initially
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing initially with name error");

      // Ensure the button is findable before interacting
      final submitButtonFinder = find.byKey(const Key('submit_button'));
      expect(submitButtonFinder, findsOneWidget, reason: 'Submit button should be found even with name error');
      
      ElevatedButton buttonWidget = tester.widget<ElevatedButton>(submitButtonFinder);
      var onPressed = buttonWidget.onPressed;
      expect(onPressed, isNotNull, reason: 'Submit button should be enabled with invalid latitude but not processing');      if (onPressed != null) {
        await tester.runAsync(() async {
          onPressed?.call(); // This calls _handleFormSubmission
        });
        await tester.pump(); // Start state change for _isProcessing
        await tester.pump(const Duration(milliseconds: 200)); // Allow more time for UI to rebuild with LoadingIndicator
        expect(find.byType(LoadingIndicator), findsOneWidget, reason: "Should be processing during submission");
      }
      // Wait for _handleFormSubmission to complete, including async save and SnackBar
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Allow time for save and snackbar
      expect(find.byType(LoadingIndicator), findsNothing, reason: "Should not be processing after submission completes");

      // Verify form validation prevented submission
      verifyNever(mockPreferencesService.saveUserBirthInfo(any));
        // Check that the TextFormField error is still present (with period)
      expect(find.text('Lütfen adınızı ve soyadınızı girin.'), findsOneWidget,
          reason: 'Name field error (with period) should still be visible');

      // Check that the SnackBar is also shown (with period)
      expect(find.widgetWithText(SnackBar, 'Lütfen adınızı ve soyadınızı girin.'), findsOneWidget,
          reason: 'SnackBar with validation message (with period) for name should be visible after submit attempt');

      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget); 

      buttonWidget = tester.widget<ElevatedButton>(submitButtonFinder);
      onPressed = buttonWidget.onPressed;
      expect(onPressed, isNotNull, reason: 'Button onPressed should still be active as form is on screen with name error');
    });
  });
}
