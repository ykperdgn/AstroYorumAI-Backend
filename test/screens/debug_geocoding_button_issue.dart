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

  testWidgets('Debug: Step by step button disappearing issue', (WidgetTester tester) async {
    print('=== Step 1: Create screen with initial data ===');
    final initialBirthInfo = UserBirthInfo(
      name: 'Test User',
      birthDate: DateTime(1990, 1, 1),
      birthTime: '12:00',
      birthPlace: null,
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

    print('Submit button after createScreen: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
    print('ElevatedButton widgets: ${find.byType(ElevatedButton).evaluate().length}');

    // Check if button is enabled
    final buttonFinder = find.byType(ElevatedButton);
    if (buttonFinder.evaluate().isNotEmpty) {
      final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
      print('Button enabled: ${buttonWidget.onPressed != null}');
    }

    print('=== Step 2: Fill name field (same value as initial) ===');
    final nameField = find.widgetWithText(TextFormField, 'Ad Soyad');
    await tester.enterText(nameField, 'Test User'); // Same as initial
    await tester.pump();

    print('Submit button after filling name: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
    print('ElevatedButton widgets: ${find.byType(ElevatedButton).evaluate().length}');

    // Check if button is enabled
    if (buttonFinder.evaluate().isNotEmpty) {
      final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
      print('Button enabled: ${buttonWidget.onPressed != null}');
    }

    print('=== Step 3: Fill birth place ===');
    final birthPlaceField = find.widgetWithText(TextFormField, 'Doğum Yeri (Şehir, Ülke)');
    await tester.enterText(birthPlaceField, 'Ankara, Turkey');
    await tester.pump();

    print('Submit button after filling birth place: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
    
    print('=== Step 4: Clear coordinate fields (this might trigger validation) ===');
    final latitudeField = find.widgetWithText(TextFormField, 'Enlem (Latitude)');
    final longitudeField = find.widgetWithText(TextFormField, 'Boylam (Longitude)');
    await tester.enterText(latitudeField, '');
    await tester.enterText(longitudeField, '');
    await tester.pump();

    print('Submit button after clearing coordinates: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
    print('ElevatedButton widgets after clearing coordinates: ${find.byType(ElevatedButton).evaluate().length}');

    // Check if button is enabled
    if (buttonFinder.evaluate().isNotEmpty) {
      final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
      print('Button enabled after clearing coordinates: ${buttonWidget.onPressed != null}');
    }

    // Check for validation errors
    print('=== Step 5: Check for validation errors ===');
    final allTexts = find.byType(Text);
    print('Total text widgets: ${allTexts.evaluate().length}');
    
    for (int i = 0; i < allTexts.evaluate().length; i++) {
      final textWidget = tester.widget<Text>(allTexts.at(i));
      final text = textWidget.data ?? '';
      if (text.contains('Lütfen') || text.contains('olmalıdır') || text.contains('girin')) {
        print('Validation error found: "$text"');
      }
    }

    expect(true, true); // Always pass - this is just for debugging
  });
}
