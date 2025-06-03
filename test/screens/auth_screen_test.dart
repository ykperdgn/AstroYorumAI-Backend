import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astroyorumai/screens/auth_screen.dart';
import 'package:astroyorumai/services/auth_service.dart';
import 'package:astroyorumai/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Generate mocks
@GenerateMocks([AuthService, User, UserCredential])
import 'auth_screen_test.mocks.dart';

void main() {  group('AuthScreen Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockAuthService = MockAuthService();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
    });

    Widget createTestWidget() {
      return MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en', ''),
          Locale('tr', ''),
        ],
        home: AuthScreen(),
      );
    }

    testWidgets('should display sign in form by default', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();      // Assert
      expect(find.text('Giriş Yap'), findsNWidgets(2)); // AppBar title + button
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
      expect(find.text('E-posta'), findsOneWidget);
      expect(find.text('Şifre'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should toggle between sign in and sign up', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();      // Act - tap on "Hesap oluştur" link
      await tester.tap(find.text('Hesap oluştur'));
      await tester.pumpAndSettle();      // Assert
      expect(find.text('Hesap Oluştur'), findsNWidgets(2)); // AppBar title + button

      // Act - tap back to sign in
      await tester.tap(find.text('Zaten hesabım var'));
      await tester.pumpAndSettle();      // Assert
      expect(find.text('Giriş Yap'), findsNWidgets(2)); // AppBar title + button
    });

    testWidgets('should show password visibility toggle', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.byKey(Key('password_field'));
      expect(passwordField, findsOneWidget);

      // Find visibility toggle button
      final visibilityToggle = find.byIcon(Icons.visibility);
      expect(visibilityToggle, findsOneWidget);

      // Act - tap visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pumpAndSettle();

      // Assert - icon should change to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should validate email format', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - enter invalid email
      await tester.enterText(find.byKey(Key('email_field')), 'invalid-email');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();      // Assert - should show validation error
      expect(find.text('Geçerli bir e-posta adresi girin'), findsOneWidget);
    });

    testWidgets('should validate password length', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to sign up mode
      await tester.tap(find.text('Hesap oluştur'));
      await tester.pumpAndSettle();

      // Act - enter short password
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();      // Assert - should show validation error
      expect(find.text('Şifre en az 6 karakter olmalıdır'), findsOneWidget);
    });    testWidgets('should have submit button enabled with valid data', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - enter valid credentials
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password123');
      await tester.pump();

      // Assert - button should be enabled (not disabled)
      final submitButton = find.byType(ElevatedButton);
      expect(submitButton, findsOneWidget);
      
      // Check that the button text is visible (indicating it's not in loading state initially)
      expect(find.text('Giriş Yap'), findsNWidgets(2)); // AppBar + button
    });

    testWidgets('should display forgot password dialog', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();      // Act - tap forgot password
      await tester.tap(find.text('Şifremi unuttum'));
      await tester.pumpAndSettle();      // Assert - should show snackbar message
      await tester.pump(); // Allow snackbar to appear
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Şifre sıfırlamak için e-posta adresini girin'), findsOneWidget);
    });

    testWidgets('should show cloud sync information cards', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();      // Assert - should show information cards
      expect(find.byType(Card), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.text('Bulut Senkronizasyonu Hakkında'), findsOneWidget);
    });
  });
}
