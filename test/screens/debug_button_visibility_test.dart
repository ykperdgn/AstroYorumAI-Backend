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

  testWidgets('Debug: Check button visibility in geocoding scenario', (WidgetTester tester) async {
    // Set up mocks
    when(mockGeocodingService.getCoordinates(any))
        .thenAnswer((_) async => {'lat': 39.9334, 'lon': 32.8597});
    when(mockPreferencesService.saveUserBirthInfo(any))
        .thenAnswer((_) async {});

    // Create screen with pre-filled date/time to bypass date/time validation
    await tester.pumpWidget(
      createTestWidget(
        BirthInfoScreen(
          initialBirthInfo: UserBirthInfo(
            name: 'Test User',
            birthDate: DateTime(2000, 1, 1),
            birthTime: '12:00',
            birthPlace: null,
            latitude: null,
            longitude: null,
          ),
          preferencesService: mockPreferencesService,
          geocodingService: mockGeocodingService,
        ),
      ),
    );
    await tester.pumpAndSettle();

    print('=== DEBUG: Initial State ===');
    print('Submit button by text: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
    print('ElevatedButton widgets: ${find.byType(ElevatedButton).evaluate().length}');
    
    // Check if button is enabled
    final buttonFinder = find.byType(ElevatedButton);
    if (buttonFinder.evaluate().isNotEmpty) {
      final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
      print('Button onPressed is null (disabled): ${buttonWidget.onPressed == null}');
    }

    // Fill name field
    await tester.enterText(find.byType(TextFormField).at(0), 'Test Name');
    await tester.pump();

    print('=== DEBUG: After filling name ===');
    print('Submit button by text: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
    
    // Check button state again
    if (buttonFinder.evaluate().isNotEmpty) {
      final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
      print('Button onPressed is null (disabled): ${buttonWidget.onPressed == null}');
    }

    // Fill birth place but leave coordinates empty
    await tester.enterText(find.widgetWithText(TextFormField, 'Doğum Yeri (Şehir, Ülke)'), 'Ankara, Turkey');
    await tester.pump();

    print('=== DEBUG: After filling birth place ===');
    print('Submit button by text: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
    
    // Check button state again
    if (buttonFinder.evaluate().isNotEmpty) {
      final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
      print('Button onPressed is null (disabled): ${buttonWidget.onPressed == null}');
    }

    // Clear coordinate fields explicitly
    await tester.enterText(find.widgetWithText(TextFormField, 'Enlem (Latitude)'), '');
    await tester.enterText(find.widgetWithText(TextFormField, 'Boylam (Longitude)'), '');
    await tester.pump();

    print('=== DEBUG: After clearing coordinates ===');
    print('Submit button by text: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
    
    // Check button state again
    if (buttonFinder.evaluate().isNotEmpty) {
      final buttonWidget = tester.widget<ElevatedButton>(buttonFinder);
      print('Button onPressed is null (disabled): ${buttonWidget.onPressed == null}');
    }

    // Try scrolling to ensure button is visible
    print('=== DEBUG: Trying to scroll to button ===');
    final submitButtonByText = find.text('Natal Haritamı Hesapla');
    if (submitButtonByText.evaluate().isNotEmpty) {
      try {
        await tester.dragUntilVisible(
          submitButtonByText,
          find.byType(ListView),
          const Offset(0, -100),
        );
        print('Successfully scrolled to button');
        print('Submit button by text after scroll: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
      } catch (e) {
        print('Error scrolling to button: $e');
      }
    } else {
      print('Submit button not found - cannot scroll to it');
    }

    // Final check
    print('=== DEBUG: Final state ===');
    print('Submit button by text: ${find.text('Natal Haritamı Hesapla').evaluate().length}');
    print('ElevatedButton widgets: ${find.byType(ElevatedButton).evaluate().length}');
    
    // Print all buttons/clickable widgets
    final allButtons = find.byType(ElevatedButton);
    print('All ElevatedButton widgets:');
    for (int i = 0; i < allButtons.evaluate().length; i++) {
      final button = tester.widget<ElevatedButton>(allButtons.at(i));
      final text = button.child;
      print('  Button $i: enabled=${button.onPressed != null}, child=$text');
    }

    // Print all text widgets to see what's actually on screen
    print('All Text widgets:');
    final allTexts = find.byType(Text);
    for (int i = 0; i < allTexts.evaluate().length; i++) {
      final textWidget = tester.widget<Text>(allTexts.at(i));
      print('  Text $i: "${textWidget.data}"');
    }
  });
}
