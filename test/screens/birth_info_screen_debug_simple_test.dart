import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'package:astroyorumai/models/user_birth_info.dart';
import 'birth_info_screen_test.mocks.dart';
import '../test_helpers.dart';

void main() {
  group('BirthInfoScreen Debug Simple Tests', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
    });

    Widget createTestWidget(Widget child) {
      return createTestApp(child);
    }

    testWidgets('Debug: Check widget tree structure', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any)).thenAnswer((_) async => null);
      
      bool saveWasCalled = false;
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((_) async {
        saveWasCalled = true;
      });

      // Create a prefilled profile with valid data
      final profile = UserProfile(
        id: 'test',
        name: 'Test User',
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

      // Debug: Print all keys
      print('\n=== ALL WIDGETS WITH KEYS ===');
      final allWidgets = tester.allWidgets;
      for (final widget in allWidgets) {
        if (widget.key != null) {
          print('Widget: ${widget.runtimeType}, Key: ${widget.key}');
        }
      }

      // Debug: Check how many submit buttons exist
      final submitButtons = find.byKey(const Key('submit_button'));
      print('\n=== SUBMIT BUTTONS FOUND ===');
      print('Count: ${submitButtons.evaluate().length}');
      
      // Debug: Try to find ElevatedButton widgets
      final elevatedButtons = find.byType(ElevatedButton);
      print('\n=== ELEVATED BUTTONS FOUND ===');
      print('Count: ${elevatedButtons.evaluate().length}');
      
      // This should pass - just checking that widgets exist
      expect(find.text('Doğum Bilgilerini Girin'), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('Simple submit test without scrolling', (WidgetTester tester) async {
      // Setup mocks
      when(mockGeocodingService.getCoordinates(any)).thenAnswer((_) async => null);
      
      UserBirthInfo? savedBirthInfo;
      when(mockPreferencesService.saveUserBirthInfo(any)).thenAnswer((invocation) async {
        savedBirthInfo = invocation.positionalArguments[0] as UserBirthInfo;
      });

      // Create a prefilled profile with valid data
      final profile = UserProfile(
        id: 'test',
        name: 'Test User',
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

      // Try to find submit button using different approaches
      print('\n=== SEARCHING FOR SUBMIT BUTTON ===');
      
      // Approach 1: By key
      final submitByKey = find.byKey(const Key('submit_button'));
      print('By key count: ${submitByKey.evaluate().length}');
      
      // Approach 2: By type and text
      final submitByText = find.widgetWithText(ElevatedButton, 'Natal Haritamı Hesapla');
      print('By text count: ${submitByText.evaluate().length}');
        // Use the one that works
      final submitButton = submitByText.evaluate().isNotEmpty ? submitByText : submitByKey;
      
      // Check if button is enabled
      if (submitButton.evaluate().isNotEmpty) {
        final buttonWidget = tester.widget<ElevatedButton>(submitButton.first);
        print('Button onPressed: ${buttonWidget.onPressed}');
        print('Button enabled: ${buttonWidget.onPressed != null}');
          if (buttonWidget.onPressed != null) {
          print('Tapping button...');
          await tester.tap(submitButton.first, warnIfMissed: false);
          print('Button tapped, pumping...');
          await tester.pumpAndSettle();
          print('Pumped and settled');
          
          // Check if submission worked
          print('Save called: ${savedBirthInfo != null}');
          if (savedBirthInfo != null) {
            print('SavedBirthInfo name: ${savedBirthInfo!.name}');
          }
        } else {
          print('Button is disabled!');
        }
      } else {
        print('No submit button found!');
      }
    });
  });
}
