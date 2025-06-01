import 'package:flutter/material.dart';

class TransitScreen extends StatefulWidget {
  const TransitScreen({Key? key}) : super(key: key);

  @override
  _TransitScreenState createState() => _TransitScreenState();
}

class _TransitScreenState extends State<TransitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transit Analizi'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline, size: 64, color: Colors.deepPurple),
            SizedBox(height: 24),
            Text(
              'Transit analizi yakında burada olacak!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
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
