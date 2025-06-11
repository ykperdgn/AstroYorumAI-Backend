import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:astroyorumai/screens/settings_screen.dart';
import 'package:astroyorumai/services/auth_service.dart';
import 'package:astroyorumai/services/cloud_sync_service.dart';
import 'package:astroyorumai/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../test_setup.dart';
import '../helpers/firebase_test_helper.dart';

// Generate mocks
@GenerateMocks([
  User,
  FirebaseAuth,
  FirebaseFirestore,
  DocumentReference<Map<String, dynamic>>,
  DocumentSnapshot<Map<String, dynamic>>,
], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(
      as: #MockCollectionReference),
])
import 'settings_screen_test.mocks.dart';

void main() {
  setUpAll(() async {
    // Firebase test mock'larını ayarla
    setupFirebaseTestMocks();
    await setupFirebaseForTest();
  });

  group('SettingsScreen Widget Tests', () {
    late AuthService mockAuthService;
    late CloudSyncService mockCloudSyncService;
    late MockUser mockUser;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockUsersCollection;
    late MockDocumentReference<Map<String, dynamic>> mockUserDocument;
    setUp(() {
      mockUser = MockUser();
      mockFirebaseAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUsersCollection = MockCollectionReference();
      mockUserDocument = MockDocumentReference<Map<String, dynamic>>();

      // Reset any existing singletons first
      resetServiceSingletons(); // Create mocked services using dependency injection
      mockAuthService =
          AuthService(auth: mockFirebaseAuth, firestore: mockFirestore);
      mockCloudSyncService = CloudSyncService(
        firestore: mockFirestore,
        authService: mockAuthService,
      );

      // Set the test instances AFTER creating the mocked services
      AuthService.testInstance = mockAuthService;
      CloudSyncService.testInstance = mockCloudSyncService;

      // Setup basic mocks
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.uid).thenReturn('test-user-id');

      // Setup Firestore mocks
      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockUsersCollection.doc('test-user-id'))
          .thenReturn(mockUserDocument);
    });

    Widget createTestWidget() {
      return const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', ''),
          Locale('tr', ''),
        ],
        home: SettingsScreen(),
      );
    }

    testWidgets('should display settings sections',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ayarlar'), findsOneWidget);
      expect(find.text('Dil'), findsOneWidget);
      // "Bulut Senkronizasyonu" appears multiple times (section header and info section)
      expect(find.text('Bulut Senkronizasyonu'), findsAtLeastNWidgets(1));
    });

    testWidgets('should show language selection dialog',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Act - tap on language setting
      await tester.tap(find.text('Dil'));
      await tester
          .pumpAndSettle(); // Assert - should show language selection dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Dil Seçin'), findsOneWidget);
      expect(find.text('English'), findsWidgets);
      expect(find.text('Türkçe'),
          findsAtLeastNWidgets(1)); // Multiple "Türkçe" widgets expected
    });
    testWidgets('should display cloud sync status when signed in',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isSignedIn).thenReturn(true);
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');

      // Set up SharedPreferences to return a sync time
      setTestSharedPreferencesValue(
          'last_cloud_sync', DateTime.now().toIso8601String());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Assert
      expect(find.text('Giriş Yapıldı'), findsOneWidget);
      expect(find.text('E-posta: test@example.com'), findsOneWidget);
      expect(find.text('Yedekle'), findsOneWidget);
      expect(find.text('Geri Yükle'), findsOneWidget);
    });
    testWidgets('should show sign in button when not signed in',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isSignedIn).thenReturn(false);
      when(mockAuthService.currentUser).thenReturn(null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Giriş Yapılmamış'), findsOneWidget);
      expect(find.text('Giriş Yap'), findsOneWidget);
    });
    testWidgets('should show manual backup button',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isSignedIn).thenReturn(true);
      when(mockAuthService.currentUser).thenReturn(mockUser);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act & Assert
      expect(find.text('Yedekle'), findsOneWidget);

      // Tap backup button and check for success message
      await tester.tap(find.text('Yedekle'));
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.text('Veriler buluta yedeklendi'), findsOneWidget);
    });
    testWidgets('should show restore confirmation dialog',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isSignedIn).thenReturn(true);
      when(mockAuthService.currentUser).thenReturn(mockUser);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - tap restore button
      await tester.tap(find.text('Geri Yükle'));
      await tester.pumpAndSettle();

      // Assert - should show confirmation dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Veriyi Geri Yükle'), findsOneWidget);
      expect(
          find.text(
              'Buluttaki veriler mevcut verilerin üzerine yazılacak. Devam etmek istiyor musunuz?'),
          findsOneWidget);
    });
    testWidgets('should display help sections', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll to see help sections
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Bulut Senkronizasyonu'), findsWidgets);
    });
    testWidgets('should show sign out confirmation dialog',
        (WidgetTester tester) async {
      // Arrange
      when(mockAuthService.isSignedIn).thenReturn(true);
      when(mockAuthService.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap sign out button
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Çıkış Yap'));
      await tester.pumpAndSettle();

      // Assert - should show confirmation dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Çıkış Yap'), findsWidgets);
      expect(
          find.text('Hesabınızdan çıkış yapmak istediğinizden emin misiniz?'),
          findsOneWidget);
    });
    testWidgets('should display last sync time', (WidgetTester tester) async {
      // Arrange
      final syncTime = DateTime.now().subtract(const Duration(hours: 2));
      when(mockAuthService.isSignedIn).thenReturn(true);
      when(mockAuthService.currentUser).thenReturn(mockUser);

      // Set up SharedPreferences to return a sync time
      setTestSharedPreferencesValue(
          'last_cloud_sync', syncTime.toIso8601String());

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Son senkronizasyon:'), findsOneWidget);
    });
  });
}
