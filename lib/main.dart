import 'package:flutter/material.dart';
import 'package:emerency_nearby/screens/home_screen.dart';

void main() {
  runApp(const EmergencyApp());
}

class EmergencyApp extends StatelessWidget {
  const EmergencyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '응급실 찾기 앱 (Beta)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
