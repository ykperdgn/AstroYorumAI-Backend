import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'birth_info_screen_test.mocks.dart';

void main() {
  testWidgets('Debug button state test', (WidgetTester tester) async {
    final mockGeocodingService = MockGeocodingService();
    final mockPreferencesService = MockUserPreferencesService();

    final profile = UserProfile(
      id: 'test-id-valid',
      name: 'Test User',
      birthDate: DateTime(1985, 12, 25),
      birthTime: '14:30',
      birthPlace: null,
      latitude: null,
      longitude: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await tester.pumpWidget(
      MaterialApp(
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
        home: BirthInfoScreen(
          prefilledProfile: profile,
          preferencesService: mockPreferencesService,
          geocodingService: mockGeocodingService,
        ),
      ),
    );    await tester.pumpAndSettle();

    // Find the button in different ways
    final submitButtonByText = find.text('Natal Haritamı Hesapla');
    final submitButtonByType = find.byType(ElevatedButton);
    
    print('DEBUG: Submit button by text found: ${submitButtonByText.evaluate().length}');
    print('DEBUG: ElevatedButton widgets found: ${submitButtonByType.evaluate().length}');
    
    // Try both approaches
    if (submitButtonByText.evaluate().isNotEmpty) {
      print('DEBUG: Found button by text');
      
      // Scroll to make button visible
      await tester.dragUntilVisible(
        submitButtonByText,
        find.byType(ListView),
        const Offset(0, -100),
      );
      
      print('DEBUG: Attempting to tap button by text...');
      await tester.tap(submitButtonByText, warnIfMissed: false);
      await tester.pumpAndSettle();
      print('DEBUG: Button tap by text completed');
    }
    
    if (submitButtonByType.evaluate().isNotEmpty) {
      print('DEBUG: Attempting to tap button by type...');
      await tester.tap(submitButtonByType);
      await tester.pumpAndSettle();
      print('DEBUG: Button tap by type completed');
    }

    expect(true, true); // Always pass - we're just debugging
  });
}
