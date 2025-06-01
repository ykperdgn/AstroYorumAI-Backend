import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/config/firebase_config_production.dart';

void main() async {
  try {
    print('🚀 Initializing Firebase...');
    
    // Initialize Firebase with production config
    await Firebase.initializeApp(
      options: FirebaseConfigProduction.currentPlatform,
    );
    
    print('✅ Firebase initialized successfully!');
    
    // Test Firestore connection
    print('🔥 Testing Firestore connection...');
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    
    // Try to write a test document
    await firestore.collection('test').doc('connection_test').set({
      'timestamp': FieldValue.serverTimestamp(),
      'message': 'Firebase connection test successful',
      'environment': 'production',
      'app_version': '1.0.0-beta',
    });
    
    print('✅ Firestore write test successful!');
    
    // Try to read the test document
    DocumentSnapshot doc = await firestore.collection('test').doc('connection_test').get();
    if (doc.exists) {
      print('✅ Firestore read test successful!');
      print('📄 Document data: ${doc.data()}');
    }
    
    // Test Firebase Auth
    print('🔐 Testing Firebase Auth...');
    FirebaseAuth auth = FirebaseAuth.instance;
    print('✅ Firebase Auth initialized. Current user: ${auth.currentUser?.uid ?? 'Anonymous'}');
    
    // Clean up test data
    await firestore.collection('test').doc('connection_test').delete();
    print('🧹 Test data cleaned up');
    
    print('\n🎉 ALL FIREBASE TESTS PASSED! 🎉');
    print('✅ Production Firebase is ready for AstroYorumAI');
    
  } catch (e, stackTrace) {
    print('❌ Firebase test failed: $e');
    print('Stack trace: $stackTrace');
  }
}
