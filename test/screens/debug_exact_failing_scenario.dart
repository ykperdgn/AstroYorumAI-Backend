import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/services/geocoding_service.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'package:astroyorumai/models/user_birth_info.dart';

import 'birth_info_screen_validation_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserPreferencesService>(),
  MockSpec<GeocodingService>(),
])
void main() {
  late MockGeocodingService mockGeocodingService;
  late MockUserPreferencesService mockPreferencesService;

  setUp(() {
    mockGeocodingService = MockGeocodingService();
    mockPreferencesService = MockUserPreferencesService();

    reset(mockGeocodingService);
    reset(mockPreferencesService);
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('tr', 'TR'),
      home: child,
    );
  }

  // Exact replica of the helper functions from the main test
  Future<void> createScreenWithDateTime({
    required WidgetTester tester,
    required DateTime initialDate,
    required TimeOfDay initialTime,
    String? name,
    String? birthPlace,
  }) async {
    final initialBirthInfo = UserBirthInfo(
      name: name,
      birthDate: initialDate,
      birthTime: '${initialTime.hour.toString().padLeft(2, '0')}:${initialTime.minute.toString().padLeft(2, '0')}',
      birthPlace: birthPlace,
      latitude: null,
      longitude: null,
    );

    await tester.pumpWidget(
      createTestWidget(
        BirthInfoScreen(
          initialBirthInfo: initialBirthInfo,
          preferencesService: mockPreferencesService,
          geocodingService: mockGeocodingService,
          alwaysAutoValidate: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> fillRequiredFields(WidgetTester tester, {String name = 'Test User'}) async {
    final nameField = find.widgetWithText(TextFormField, 'Ad Soyad');
    expect(nameField, findsOneWidget, reason: "Name field with label 'Ad Soyad' not found");
    await tester.enterText(nameField, name);
    await tester.pump();
  }

  testWidgets('Debug: Exact failing scenario replication', (WidgetTester tester) async {
    const testBirthPlace = 'Ankara, Turkey';
    final expectedGeocodedCoords = {'lat': 39.9334, 'lon': 32.8597};

    // Set up the mock response
    when(mockGeocodingService.getCoordinates(testBirthPlace))
        .thenAnswer((_) async => expectedGeocodedCoords);
    when(mockPreferencesService.saveUserBirthInfo(any))
        .thenAnswer((_) async {});

    print('=== DEBUG: Setting up screen ===');
    await createScreenWithDateTime(
      tester: tester,
      initialDate: DateTime(2000, 1, 1),
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    print('Submit button after createScreenWithDateTime: ${find.text('Natal Haritamı Hesapla').evaluate().length}');

    print('=== DEBUG: Filling required fields ===');
    await fillRequiredFields(tester, name: 'Test Name');
    await tester.pumpAndSettle();

    print('Submit button after fillRequiredFields: ${find.text('Natal Haritamı Hesapla').evaluate().length}');

    print('=== DEBUG: Starting geocoding simulation ===');
    
    // Replicate the exact steps from simulateGeocodingViaFormSubmission
    print('Step 1: Fill birth place field');
    final birthPlaceField = find.widgetWithText(TextFormField, 'Doğum Yeri (Şehir, Ülke)');
    expect(birthPlaceField, findsOneWidget);
    await tester.enterText(birthPlaceField, testBirthPlace);
    await tester.pump();

    print('Submit button after filling birth place: ${find.text('Natal Haritamı Hesapla').evaluate().length}');

    print('Step 2: Clear coordinate fields');
    final latitudeField = find.widgetWithText(TextFormField, 'Enlem (Latitude)');
    final longitudeField = find.widgetWithText(TextFormField, 'Boylam (Longitude)');
    await tester.enterText(latitudeField, '');
    await tester.enterText(longitudeField, '');
    await tester.pump();

    print('Submit button after clearing coordinates: ${find.text('Natal Haritamı Hesapla').evaluate().length}');

    print('Step 3: Check button state');
    final buttonFinder = find.byType(ElevatedButton);
    if (buttonFinder.evaluate().isNotEmpty) {
      final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
      print('Button enabled: ${buttonWidget.onPressed != null}');
    }

    print('Step 4: Try to find submit button');
    final submitButton = find.text('Natal Haritamı Hesapla');
    print('Submit button found: ${submitButton.evaluate().length}');
    
    if (submitButton.evaluate().isNotEmpty) {
      print('SUCCESS: Submit button is visible');
      
      // Try to scroll to it
      try {
        await tester.dragUntilVisible(
          submitButton,
          find.byType(ListView),
          const Offset(0, -100),
        );
        print('Successfully scrolled to button');
        
        // Try to tap it
        await tester.tap(submitButton);
        await tester.pump();
        print('Successfully tapped button');
        
      } catch (e) {
        print('Error during button interaction: $e');
      }
    } else {
      print('PROBLEM: Submit button not found');
      
      // Debug: Print all widgets
      print('All Text widgets:');
      final allTexts = find.byType(Text);
      for (int i = 0; i < allTexts.evaluate().length; i++) {
        final textWidget = tester.widget<Text>(allTexts.at(i));
        print('  Text $i: "${textWidget.data}"');
      }
      
      print('All ElevatedButton widgets:');
      final allButtons = find.byType(ElevatedButton);
      for (int i = 0; i < allButtons.evaluate().length; i++) {
        final button = tester.widget<ElevatedButton>(allButtons.at(i));
        print('  Button $i: enabled=${button.onPressed != null}, child=${button.child}');
      }
    }
  });
}
