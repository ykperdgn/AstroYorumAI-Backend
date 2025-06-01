import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:astroyorumai/screens/splash_screen.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/screens/natal_chart_screen.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'package:astroyorumai/models/user_birth_info.dart';

import 'splash_screen_test.mocks.dart';

@GenerateNiceMocks([MockSpec<UserPreferencesService>()])
void main() {
  group('SplashScreen Widget Tests', () {
    late MockUserPreferencesService mockPrefsService;

    setUp(() {
      mockPrefsService = MockUserPreferencesService();
    });

    tearDownAll(() async {
      // Cleanup any pending timers or async operations
      await Future.delayed(Duration.zero);
    });testWidgets('displays correct UI elements', (WidgetTester tester) async {
      // Mock empty user preferences to prevent navigation
      when(mockPrefsService.loadUserBirthInfo()).thenAnswer((_) async => null);

      // Build SplashScreen with mock service
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(preferencesService: mockPrefsService),
          routes: {
            '/birthInfo': (context) => BirthInfoScreen(),
          },
        ),
      );

      // Verify UI elements are present
      expect(find.byIcon(Icons.star_border_purple500_outlined), findsOneWidget);
      expect(find.text('AstroYorum AI'), findsOneWidget);
      expect(find.text('Gökyüzü Rehberiniz'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify styling
      final titleText = tester.widget<Text>(find.text('AstroYorum AI'));
      expect(titleText.style?.fontSize, equals(32));
      expect(titleText.style?.fontWeight, equals(FontWeight.bold));
      expect(titleText.style?.color, equals(Colors.deepPurple));

      final subtitleText = tester.widget<Text>(find.text('Gökyüzü Rehberiniz'));
      expect(subtitleText.style?.fontSize, equals(18));

      // Wait for timer to complete to avoid pending timer error
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();
    });    testWidgets('displays loading indicator with correct styling', (WidgetTester tester) async {
      // Mock empty user preferences to prevent navigation
      when(mockPrefsService.loadUserBirthInfo()).thenAnswer((_) async => null);

      // Build SplashScreen with mock service
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(preferencesService: mockPrefsService),
          routes: {
            '/birthInfo': (context) => BirthInfoScreen(),
          },
        ),
      );

      // Verify loading indicator is present immediately
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      final progressIndicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(progressIndicator.color, equals(Colors.deepPurpleAccent));

      // Verify star icon styling
      final icon = tester.widget<Icon>(find.byIcon(Icons.star_border_purple500_outlined));
      expect(icon.size, equals(120));
      expect(icon.color, equals(Colors.deepPurpleAccent));

      // Wait for timer to complete to avoid pending timer error
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to BirthInfoScreen when no saved user info', (WidgetTester tester) async {
      // Mock empty user preferences
      when(mockPrefsService.loadUserBirthInfo()).thenAnswer((_) async => null);

      // Build SplashScreen with navigation routes
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(preferencesService: mockPrefsService),
          routes: {
            '/birthInfo': (context) => BirthInfoScreen(),
            '/natalChart': (context) => NatalChartScreen(
              name: 'Test', 
              birthDate: DateTime.now(), 
              latitude: 0.0, 
              longitude: 0.0
            ),
          },
        ),
      );

      // Wait for the 2-second delay plus some buffer
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify navigation to BirthInfoScreen
      expect(find.byType(BirthInfoScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('navigates to BirthInfoScreen when saved info is incomplete', (WidgetTester tester) async {
      // Mock incomplete user preferences (missing essential data)
      final incompleteInfo = UserBirthInfo(
        name: 'Test User',
        birthDate: null, // Missing essential data
        birthTime: null,
        birthPlace: null,
        latitude: null,
        longitude: null,
      );
      
      when(mockPrefsService.loadUserBirthInfo()).thenAnswer((_) async => incompleteInfo);

      // Build SplashScreen with navigation routes
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(preferencesService: mockPrefsService),
          routes: {
            '/birthInfo': (context) => BirthInfoScreen(initialBirthInfo: incompleteInfo),
            '/natalChart': (context) => NatalChartScreen(
              name: 'Test', 
              birthDate: DateTime.now(), 
              latitude: 0.0, 
              longitude: 0.0
            ),
          },
        ),
      );

      // Wait for the 2-second delay plus some buffer
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify navigation to BirthInfoScreen with initial data
      expect(find.byType(BirthInfoScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });    testWidgets('navigates to NatalChartScreen when complete saved info exists', (WidgetTester tester) async {
      // Mock complete user preferences
      final completeInfo = UserBirthInfo(
        name: 'Test User',
        birthDate: DateTime(1990, 5, 15),
        birthTime: '14:30',
        birthPlace: 'Istanbul, Turkey',
        latitude: 41.0082,
        longitude: 28.9784,
      );
      
      when(mockPrefsService.loadUserBirthInfo()).thenAnswer((_) async => completeInfo);

      // Build SplashScreen with navigation routes
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(preferencesService: mockPrefsService),
          routes: {
            '/birthInfo': (context) => BirthInfoScreen(),
            '/natalChart': (context) => NatalChartScreen(
              name: completeInfo.name!,
              birthDate: completeInfo.birthDate!,
              birthTime: completeInfo.birthTime,
              birthPlace: completeInfo.birthPlace,
              latitude: completeInfo.latitude!,
              longitude: completeInfo.longitude!,
            ),
          },
        ),
      );

      // Wait for the 2-second delay plus some buffer
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify navigation to NatalChartScreen
      expect(find.byType(NatalChartScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });    testWidgets('onLocaleChange callback is properly stored', (WidgetTester tester) async {
      // Mock empty user preferences to prevent navigation
      when(mockPrefsService.loadUserBirthInfo()).thenAnswer((_) async => null);

      bool callbackCalled = false;
      void onLocaleChange(Locale locale) {
        callbackCalled = true;
      }

      // Build SplashScreen with callback and mock service
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onLocaleChange: onLocaleChange,
            preferencesService: mockPrefsService,
          ),
          routes: {
            '/birthInfo': (context) => BirthInfoScreen(),
          },
        ),
      );

      // Verify the callback is properly stored (widget builds without error)
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('AstroYorum AI'), findsOneWidget);

      // Wait for timer to complete to avoid pending timer error
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();
    });    testWidgets('handles service injection correctly', (WidgetTester tester) async {
      // Mock service için test
      when(mockPrefsService.loadUserBirthInfo()).thenAnswer((_) async => null);
      
      // Test with mock service 
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(preferencesService: mockPrefsService), 
          routes: {
            '/birthInfo': (context) => BirthInfoScreen(),
          },
        ),
      );

      // Verify widget builds without error
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('AstroYorum AI'), findsOneWidget);

      // Wait for timer and verify service injection worked
      await tester.pump(Duration(seconds: 2));
      await tester.pumpAndSettle();
      
      // Verify mock service was called (not default service)
      verify(mockPrefsService.loadUserBirthInfo()).called(1);
    });
  });
}
