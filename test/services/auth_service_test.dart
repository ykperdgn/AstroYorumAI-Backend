import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:astroyorumai/services/auth_service.dart';
import '../test_setup.dart';
import '../helpers/firebase_test_helper.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  UserCredential,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot
])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;
    late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;

    setUpAll(() async {
      // Firebase test mock'larını ayarla
      setupFirebaseTestMocks();
      await setupFirebaseForTest();
    });
    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();
      mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();

      // Create a mock Firestore
      final mockFirestore = MockFirebaseFirestore();
      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);

      // Reset service singletons first
      resetServiceSingletons();

      // Create a new AuthService instance with mocked dependencies
      authService =
          AuthService(auth: mockFirebaseAuth, firestore: mockFirestore);

      // Set the test instance
      AuthService.testInstance = authService;
    });

    tearDown(() {
      // Reset the test instance
      AuthService.testInstance = null;
    });

    group('signInWithEmailAndPassword', () {
      test('should return user when sign in is successful', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);

        // Act
        final result =
            await authService.signInWithEmailAndPassword(email, password);

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });
      test('should throw exception when sign in fails', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(email, password),
          throwsA(equals('Yanlış şifre.')),
        );
      });
    });

    group('createUserWithEmailAndPassword', () {
      test('should return user when registration is successful', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenAnswer((_) async => mockUserCredential);

        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-uid');

        // Act
        final result =
            await authService.createUserWithEmailAndPassword(email, password);

        // Assert
        expect(result, equals(mockUserCredential));
        verify(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).called(1);
      });
      test('should throw exception when registration fails', () async {
        // Arrange
        const email = 'existing@example.com';
        const password = 'password123';

        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

        // Act & Assert
        expect(
          () => authService.createUserWithEmailAndPassword(email, password),
          throwsA(equals('Bu e-posta adresi zaten kullanımda.')),
        );
      });
    });

    group('signOut', () {
      test('should call Firebase signOut', () async {
        // Arrange
        when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        await authService.signOut();

        // Assert
        verify(mockFirebaseAuth.signOut()).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return current user when signed in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

        // Act
        final result = authService.getCurrentUser();

        // Assert
        expect(result, equals(mockUser));
      });

      test('should return null when not signed in', () {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = authService.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('sendPasswordResetEmail', () {
      test('should send password reset email successfully', () async {
        // Arrange
        const email = 'test@example.com';
        when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
            .thenAnswer((_) async {});

        // Act
        await authService.sendPasswordResetEmail(email);

        // Assert
        verify(mockFirebaseAuth.sendPasswordResetEmail(email: email)).called(1);
      });
      test('should throw exception when email is invalid', () async {
        // Arrange
        const email = 'invalid-email';
        when(mockFirebaseAuth.sendPasswordResetEmail(email: email))
            .thenThrow(FirebaseAuthException(code: 'invalid-email'));

        // Act & Assert
        expect(
          () => authService.sendPasswordResetEmail(email),
          throwsA(equals('Geçersiz e-posta adresi.')),
        );
      });
    });
  });
  group('AuthService User Sign-In/Sign-Out Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockFirebaseFirestore mockFirestore;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockFirestore = MockFirebaseFirestore();

      // Reset service singletons
      resetServiceSingletons();

      // Create AuthService with mocks
      authService =
          AuthService(auth: mockFirebaseAuth, firestore: mockFirestore);
      AuthService.testInstance = authService;

      // Setup default mock behavior
      when(mockFirebaseAuth.currentUser).thenReturn(null);
    });

    test('Kullanıcı varsayılan olarak oturum açmamış durumda olmalı', () {
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      expect(authService.isSignedIn, isFalse);
    });

    test('Giriş yaptıktan sonra oturum açık olmalı', () async {
      // Setup mock to return signed in user
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');
      when(mockUser.email).thenReturn('test@example.com');

      // Mock signInWithEmailAndPassword to return success
      final mockUserCredential = MockUserCredential();
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      await authService.signInWithEmailAndPassword(
          'test@example.com', 'password123');
      expect(authService.isSignedIn, isTrue);
    });

    test('Çıkış yaptıktan sonra oturum kapalı olmalı', () async {
      // First sign in
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-uid');

      final mockUserCredential = MockUserCredential();
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      await authService.signInWithEmailAndPassword(
          'test@example.com', 'password123');

      // Then sign out
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();
      expect(authService.isSignedIn, isFalse);
    });
    test('Hatalı giriş bilgileri oturum açmamalı', () async {
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenThrow(FirebaseAuthException(
          code: 'invalid-credential', message: 'Invalid credentials'));

      expect(
        () => authService.signInWithEmailAndPassword('', ''),
        throwsA(equals('Kimlik doğrulama hatası: Invalid credentials')),
      );
      expect(authService.isSignedIn, isFalse);
    });

    tearDownAll(() {
      // Firebase test mock'larını temizle
      tearDownFirebaseTestMocks();
    });
  });
}
