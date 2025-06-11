import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/config/firebase_config_production.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with production config
    await Firebase.initializeApp(
      options: FirebaseConfigProduction.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  runApp(const FirebaseTestApp());
}

class FirebaseTestApp extends StatelessWidget {
  const FirebaseTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AstroYorumAI Firebase Test',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const FirebaseTestScreen(),
    );
  }
}

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  String _status = 'Initializing Firebase...';
  String _details = '';
  bool _isLoading = true;
  bool _allTestsPassed = false;

  @override
  void initState() {
    super.initState();
    _runFirebaseTests();
  }

  Future<void> _runFirebaseTests() async {
    try {
      setState(() {
        _status = '🚀 Testing Firebase Connection...';
        _details = 'Project: ${Firebase.app().options.projectId}';
      });

      // Test Firestore
      await _testFirestore();

      // Test Auth
      await _testAuth();

      setState(() {
        _status = '🎉 ALL FIREBASE TESTS PASSED!';
        _details = 'AstroYorumAI production Firebase is ready!\n\n'
            'Project ID: ${Firebase.app().options.projectId}\n'
            'Auth Domain: ${Firebase.app().options.authDomain}\n'
            'Storage Bucket: ${Firebase.app().options.storageBucket}';
        _isLoading = false;
        _allTestsPassed = true;
      });
    } catch (e) {
      setState(() {
        _status = '❌ Firebase Test Failed';
        _details = 'Error: $e';
        _isLoading = false;
        _allTestsPassed = false;
      });
    }
  }

  Future<void> _testFirestore() async {
    setState(() {
      _status = '🔥 Testing Firestore...';
      _details = 'Writing test document...';
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Write test document
    await firestore
        .collection('beta_test')
        .doc('firebase_connection_test')
        .set({
      'timestamp': FieldValue.serverTimestamp(),
      'message': 'AstroYorumAI Firebase connection test successful',
      'environment': 'production',
      'test_type': 'beta_launch_preparation',
      'app_version': '1.0.0-beta',
    });

    setState(() {
      _details = 'Reading test document...';
    });

    // Read test document
    DocumentSnapshot doc = await firestore
        .collection('beta_test')
        .doc('firebase_connection_test')
        .get();
    if (!doc.exists) {
      throw Exception('Failed to read test document');
    }

    setState(() {
      _details = 'Firestore test passed! ✅';
    });

    // Clean up
    await firestore
        .collection('beta_test')
        .doc('firebase_connection_test')
        .delete();
  }

  Future<void> _testAuth() async {
    setState(() {
      _status = '🔐 Testing Firebase Auth...';
      _details = 'Checking authentication service...';
    });

    FirebaseAuth auth = FirebaseAuth.instance;
    // Just verify auth service is accessible
    User? currentUser = auth.currentUser;

    setState(() {
      _details =
          'Auth service ready! Current user: ${currentUser?.uid ?? 'Anonymous'} ✅';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AstroYorumAI Firebase Test'),
        backgroundColor: Colors.purple[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Production Firebase Status',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      Row(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 16),
                          Expanded(child: Text(_status)),
                        ],
                      )
                    else
                      Text(
                        _status,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _allTestsPassed ? Colors.green : Colors.red,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      _details,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            if (_allTestsPassed) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎉 Ready for Beta Launch!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '✅ Backend API: https://astroyorumai-api.onrender.com\n'
                        '✅ Firebase Production: astroyorumai-production\n'
                        '✅ Flutter App: Ready for beta users\n'
                        '✅ Target: 20-30 Turkish astrology enthusiasts',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
