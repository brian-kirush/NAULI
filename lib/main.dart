import 'package:flutter/material.dart';
import 'splash_screen.dart'; // Remove the 'screens/' prefix

void main() {
  runApp(const NauliTapApp());
}

class NauliTapApp extends StatelessWidget {
  const NauliTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nauli Tap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
