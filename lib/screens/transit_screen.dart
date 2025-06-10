import 'package:flutter/material.dart';

class TransitScreen extends StatefulWidget {
  const TransitScreen({super.key});
  @override
  State<TransitScreen> createState() => _TransitScreenState();
}

class _TransitScreenState extends State<TransitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transit Analizi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timeline, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              'Transit analizi yakında burada olacak!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Gezegen geçişleri ve etkileri için bu ekranı kullanacaksınız.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
