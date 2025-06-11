import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'lib/config/firebase_config_production.dart';

void main() async {
  try {
    // Initialize Firebase with production config
    await Firebase.initializeApp(
        // options: FirebaseConfigProduction.currentPlatform,
        );

    // Test Firestore connection
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Try to write a test document
    await firestore.collection('test').doc('connection_test').set({
      'timestamp': FieldValue.serverTimestamp(),
      'message': 'Firebase connection test successful',
      'environment': 'production',
      'app_version': '1.0.0-beta',
    });

    // Try to read the test document
    DocumentSnapshot doc =
        await firestore.collection('test').doc('connection_test').get();
    if (doc.exists) {
      // Document read successful
    }

    // Clean up test data
    await firestore.collection('test').doc('connection_test').delete();
  } catch (e) {
    // Handle errors
  }
}
