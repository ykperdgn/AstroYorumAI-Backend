import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:astroyorumai/screens/home_screen.dart';
import 'package:astroyorumai/screens/profile_management_screen.dart';
import 'package:astroyorumai/services/profile_management_service.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../test_helpers.dart';

class MockProfileManagementService extends Mock implements ProfileManagementService {}

void main() {
  group('HomeScreen Widget Tests', () {
    late MockProfileManagementService mockService;

    setUp(() {
      mockService = MockProfileManagementService();
      // Mock the instance method instead of static method
      when(mockService.getActiveProfile()).thenAnswer((_) async => UserProfile(
        id: '1',
        name: 'Active Profile',
        birthDate: DateTime(2000, 1, 1),
        birthTime: '12:00',
        birthPlace: 'New York',
        latitude: 40.7128,
        longitude: -74.0060,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: true,
      ));
    });

    testWidgets('Shows loading indicator and then displays active profile', (WidgetTester tester) async {
      // Arrange: Create a fake profile to return
      final fakeProfile = UserProfile(
        id: '1',
        name: 'Test User',
        birthDate: DateTime(2000, 1, 1),
        birthTime: '12:00',
        birthPlace: 'New York',
        latitude: 40.7128,
        longitude: -74.0060,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: true,
      );

      // Mock the async method
      when(mockService.getActiveProfile()).thenAnswer((_) async => fakeProfile);      // Act: Build the widget with injected service
      await tester.pumpWidget(
        createTestApp(HomeScreen(profileService: mockService)),
      );

      // Initially, loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Allow async code to complete
      await tester.pumpAndSettle();

      // Assert: Profile name should now be shown
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('Displays active profile after loading', (WidgetTester tester) async {
      final fakeProfile = UserProfile(
        id: '2',
        name: 'Active Profile',
        birthDate: DateTime(2000, 1, 1),
        birthTime: '12:00',
        birthPlace: 'New York',
        latitude: 40.7128,
        longitude: -74.0060,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: true,
      );

      when(mockService.getActiveProfile()).thenAnswer((_) async => fakeProfile);

      await tester.pumpWidget(createTestApp(HomeScreen(profileService: mockService)));
      await tester.pumpAndSettle();
      expect(find.text('Active Profile'), findsOneWidget);
    });

    testWidgets('Navigates to profile management screen on button tap', (WidgetTester tester) async {
      final fakeProfile = UserProfile(
        id: '3',
        name: 'Tester',
        birthDate: DateTime(2000, 1, 1),
        birthTime: '12:00',
        birthPlace: 'New York',
        latitude: 40.7128,
        longitude: -74.0060,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: true,
      );

      when(mockService.getActiveProfile()).thenAnswer((_) async => fakeProfile);      await tester.pumpWidget(        createTestAppWithSettings(
          child: HomeScreen(profileService: mockService),
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
