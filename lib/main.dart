import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'widgets/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BharatiyamPanchangaApp());
}

class BharatiyamPanchangaApp extends StatelessWidget {
  const BharatiyamPanchangaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      home: const HomeScreen(),
    );
  }
}
