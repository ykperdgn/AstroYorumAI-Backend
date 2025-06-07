import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:astroyorumai/screens/home_screen.dart';
import 'package:astroyorumai/screens/profile_management_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    setUp(() async {
      // Set up mock SharedPreferences with the correct structure that ProfileManagementService expects
      // The service expects profiles to be stored in 'user_profiles' as a JSON array
      final testProfile = {
        "id": "test-profile-id",
        "name": "Test User",
        "birthDate": "2000-01-01T00:00:00.000",
        "birthTime": "12:00",
        "birthPlace": "Test City",
        "latitude": 40.0,
        "longitude": 30.0,
        "createdAt": "2023-01-01T00:00:00.000",
        "updatedAt": "2023-01-01T00:00:00.000",
        "isDefault": true,
        "isPro": false
      };
      
      SharedPreferences.setMockInitialValues({
        'active_profile_id': 'test-profile-id',
        'user_profiles': '[${json.encode(testProfile)}]',
      });
    });testWidgets('Shows loading indicator and then displays active profile', (WidgetTester tester) async {
      // Act: Build the widget 
      await tester.pumpWidget(
        createTestApp(const HomeScreen()),
      );

      // Initially, loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Allow async code to complete
      await tester.pumpAndSettle();

      // Assert: Profile name should now be shown
      expect(find.text('Test User'), findsOneWidget);
    });    testWidgets('Displays active profile after loading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp(const HomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Test User'), findsOneWidget);
    });    testWidgets('Navigates to profile management screen on button tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestAppWithSettings(
          child: const HomeScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the profile management button (person icon)
      final profileButton = find.byIcon(Icons.person);
      expect(profileButton, findsOneWidget);

      await tester.tap(profileButton);
      await tester.pumpAndSettle();

      // Expect to navigate to profile management screen
      expect(find.byType(ProfileManagementScreen), findsOneWidget);
    });
  });
}
