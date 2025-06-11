import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CORSTestApp());
}

class CORSTestApp extends StatelessWidget {
  const CORSTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CORS Test',
      home: CORSTestPage(),
    );
  }
}

class CORSTestPage extends StatefulWidget {
  const CORSTestPage({super.key});

  @override
  State<CORSTestPage> createState() => _CORSTestPageState();
}

class _CORSTestPageState extends State<CORSTestPage> {
  String _status = 'Ready to test';
  bool _isLoading = false;
  bool _corsWorking = false;

  Future<void> testCORS() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing CORS...';
      _corsWorking = false;
    });

    try {
      const String apiUrl = 'https://astroyorumai-api.onrender.com';

      // Test natal chart endpoint (this will fail with CORS if not deployed)
      final testData = {
        'date': '1990-01-01',
        'time': '12:00',
        'latitude': 41.0082,
        'longitude': 28.9784,
      };

      final response = await http.post(
        Uri.parse('$apiUrl/natal'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(testData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _status =
              '✅ CORS WORKING!\nAPI Version: ${data['version']}\nAscendant: ${data['ascendant']}';
          _corsWorking = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _status = '❌ API Error: ${response.statusCode}\n${response.body}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status =
            '❌ CORS Error: $e\n\nThis means CORS fixes are not deployed yet.\nPlease deploy commit 0fe3e37 on Render.com';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AstroYorumAI CORS Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _corsWorking ? Icons.check_circle : Icons.web,
              size: 64,
              color: _corsWorking ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'CORS Connectivity Test',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Test Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _corsWorking
                            ? Colors.green
                            : _status.contains('Error')
                                ? Colors.red
                                : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : testCORS,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Test CORS Connection'),
            ),
            if (_corsWorking) ...[
              const SizedBox(height: 20),
              Card(
                color: Colors.green.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.celebration, color: Colors.green, size: 32),
                      SizedBox(height: 10),
                      Text(
                        '🎉 CORS is working!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Flutter app should now work correctly.',
                        style: TextStyle(color: Colors.green),
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
