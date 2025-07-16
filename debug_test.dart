import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'lib/main.dart';

void main() {
  if (kDebugMode) {
    print('🚀 Starting debug test...');
  }
  
  // Test the basic app structure
  runApp(const DebugApp());
}

class DebugApp extends StatelessWidget {
  const DebugApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debug Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Debug Test'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Debug Test läuft!'),
              SizedBox(height: 16),
              Text('HomeScreen wird getestet...'),
            ],
          ),
        ),
      ),
    );
  }
}