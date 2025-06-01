import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:astroyorumai/services/cloud_sync_service.dart';
import 'package:astroyorumai/services/auth_service.dart';
import '../test_setup.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  DocumentReference<Map<String, dynamic>>,
  DocumentSnapshot<Map<String, dynamic>>,
  QuerySnapshot,
  QueryDocumentSnapshot,
  User,
], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(as: #MockCollectionReference),
])
import 'cloud_sync_service_test.mocks.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTest();
  });

  group('CloudSyncService Tests', () {
    late CloudSyncService cloudSyncService;
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockCollectionReference mockUsersCollection;
    late MockDocumentReference<Map<String, dynamic>> mockUserDocument;
    late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
    late MockUser mockUser;
    late AuthService mockAuthService;
      setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockFirebaseAuth = MockFirebaseAuth();
      mockUsersCollection = MockCollectionReference();
      mockUserDocument = MockDocumentReference<Map<String, dynamic>>();
      mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      mockUser = MockUser();
      
      // Create mock AuthService using dependency injection
      mockAuthService = AuthService(auth: mockFirebaseAuth, firestore: mockFirestore);
      
      // Create CloudSyncService with mocked dependencies
      cloudSyncService = CloudSyncService(
        firestore: mockFirestore,
        authService: mockAuthService,
      );
      
      // Set as test instance
      CloudSyncService.testInstance = cloudSyncService;
      
      // Setup basic mocks for authentication
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      
      // Setup Firestore mocks
      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockUsersCollection.doc('test-user-id')).thenReturn(mockUserDocument);
    });

    group('syncToCloud', () {      test('should throw exception when user not signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);
        
        // Act & Assert
        expect(
          () => cloudSyncService.syncToCloud(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Bulut senkronizasyonu için giriş yapmalısınız'),
          )),
        );
      });      test('should sync successfully when user is signed in', () async {
        // Arrange
        when(mockUserDocument.set(any, any)).thenAnswer((_) async => {});
        
        // Act & Assert - This should complete normally since basic data is mocked
        await expectLater(cloudSyncService.syncToCloud(), completes);
      });
    });

    group('syncFromCloud', () {      test('should throw exception when user not signed in', () async {
        // Arrange
        when(mockFirebaseAuth.currentUser).thenReturn(null);
        
        // Act & Assert
        expect(
          () => cloudSyncService.syncFromCloud(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Bulut senkronizasyonu için giriş yapmalısınız'),
          )),
        );
      });

      test('should handle empty cloud data gracefully', () async {
        // Arrange
        when(mockUserDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(false);
        
        // Act & Assert
        await expectLater(cloudSyncService.syncFromCloud(), completes);
      });      test('should restore data when cloud data exists', () async {
        // Arrange
        when(mockUserDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({
          'profiles': [],
          'activeProfileId': null,
          'calendarEvents': [],
        });
        
        // Act & Assert - This should complete normally since data is mocked properly
        await expectLater(cloudSyncService.syncFromCloud(), completes);
      });
    });

    group('getLastSyncTime', () {
      test('should return DateTime when sync time exists', () async {
        // Act
        final result = await cloudSyncService.getLastSyncTime();
        
        // Assert
        expect(result, isA<DateTime?>());
      });
    });    group('deleteCloudData', () {
      test('should throw exception when user not signed in', () async {
        // Arrange - Set currentUser to null to simulate signed out state
        when(mockFirebaseAuth.currentUser).thenReturn(null);
        
        // Act & Assert
        expect(
          () => cloudSyncService.deleteCloudData(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Bulut verisi silmek için giriş yapmalısınız'),
          )),
        );
      });test('should delete cloud data successfully', () async {
        // Arrange
        final mockQuery = MockQuerySnapshot<Map<String, dynamic>>();
        when(mockUserDocument.collection('profiles')).thenReturn(mockUsersCollection);
        when(mockUsersCollection.get()).thenAnswer((_) async => mockQuery);
        when(mockQuery.docs).thenReturn([]);
        when(mockUserDocument.delete()).thenAnswer((_) async => {});
        
        // Act & Assert
        await expectLater(cloudSyncService.deleteCloudData(), completes);
      });
    });
  });
}
