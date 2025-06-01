import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:astroyorumai/screens/birth_info_screen.dart';
import 'package:astroyorumai/models/user_birth_info.dart';
import 'package:astroyorumai/models/user_profile.dart';
import 'package:astroyorumai/services/user_preferences_service.dart';
import 'package:astroyorumai/services/geocoding_service.dart';
import 'package:astroyorumai/widgets/loading_indicator.dart';

import 'birth_info_screen_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<UserPreferencesService>(),
  MockSpec<GeocodingService>(),
])
void main() {
  group('Debug Single Validation Test', () {
    late MockUserPreferencesService mockPreferencesService;
    late MockGeocodingService mockGeocodingService;

    setUp(() {
      mockPreferencesService = MockUserPreferencesService();
      mockGeocodingService = MockGeocodingService();
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

    testWidgets('DEBUG: Test widget build and basic interaction', (WidgetTester tester) async {
      try {
        debugPrint('🔍 Test başlatılıyor...');
        
        // Setup mocks
        when(mockGeocodingService.getCoordinates(any))
            .thenAnswer((_) async => null);
        when(mockPreferencesService.saveUserBirthInfo(any))
            .thenAnswer((_) async {});
        
        debugPrint('🔍 Mocks kuruldu...');

        // Create profile
        final profile = UserProfile(
          id: 'test-id-debug',
          name: 'Test User',
          birthDate: DateTime(1985, 12, 25),
          birthTime: '14:30',
          birthPlace: null,
          latitude: null,
          longitude: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        debugPrint('🔍 Profile oluşturuldu...');

        // Create widget
        await tester.pumpWidget(
          createTestWidget(
            BirthInfoScreen(
              prefilledProfile: profile,
              preferencesService: mockPreferencesService,
              geocodingService: mockGeocodingService,
              onComplete: (birthInfo) {
                debugPrint('🔍 onComplete callback çağrıldı: ${birthInfo.name}');
              },
            ),
          ),
        );
        
        debugPrint('🔍 Widget pump edildi...');
        
        await tester.pumpAndSettle();
        debugPrint('🔍 PumpAndSettle tamamlandı...');

        // Check if basic widgets exist
        expect(find.byType(Form), findsOneWidget);
        debugPrint('🔍 Form widget bulundu');
        
        expect(find.byType(TextFormField), findsAtLeastNWidgets(4));
        debugPrint('🔍 TextFormField widget\'ları bulundu');
        
        expect(find.byType(ElevatedButton), findsOneWidget);
        debugPrint('🔍 ElevatedButton widget bulundu');

        // Try entering text in latitude field
        debugPrint('🔍 Latitude alanına text giriliyor...');
        await tester.enterText(find.byType(TextFormField).at(2), '95');
        await tester.pump();
        debugPrint('🔍 Latitude text girildi');

        // Try entering text in longitude field
        debugPrint('🔍 Longitude alanına text giriliyor...');
        await tester.enterText(find.byType(TextFormField).at(3), '30');
        await tester.pump();
        debugPrint('🔍 Longitude text girildi');

        // Try tapping the button
        debugPrint('🔍 Submit button\'a tıklanıyor...');
        final submitButton = find.byType(ElevatedButton);
        await tester.tap(submitButton);
        await tester.pump();
        debugPrint('🔍 Submit button tıklandı, ilk pump tamamlandı');
        
        await tester.pump();
        debugPrint('🔍 İkinci pump tamamlandı');
        
        await tester.pumpAndSettle(Duration(seconds: 2));
        debugPrint('🔍 PumpAndSettle (2s timeout) tamamlandı');

        debugPrint('🔍 Test başarıyla tamamlandı!');

      } catch (e, stack) {
        debugPrint('❌ Test içinde hata yakalandı: $e');
        debugPrint('❌ Stack trace: $stack');
        rethrow;
      }
    });
  });
}
