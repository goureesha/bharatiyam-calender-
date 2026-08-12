import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'services/profile_service.dart';
import 'widgets/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.loadTheme();
  await ProfileService.load();

  // Firebase init — background with 3s timeout, never blocks app launch
  _initFirebase();

  runApp(const BharatiyamPanchangaApp());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        debugPrint('Firebase init timed out — will retry in background');
        throw Exception('timeout');
      },
    );
    debugPrint('Firebase initialized successfully');
    // Check Firestore connection
    ProfileService.checkFirebase();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }
}

class BharatiyamPanchangaApp extends StatelessWidget {
  const BharatiyamPanchangaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, themeId, _) {
        return MaterialApp(
          title: 'ಭಾರತೀಯಮ್ ಪಂಚಾಂಗ',
          debugShowCheckedModeBanner: false,
          theme: appTheme(),
          home: const _AppGate(),
        );
      },
    );
  }
}

class _AppGate extends StatefulWidget {
  const _AppGate();
  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  bool _profileDone = ProfileService.isProfileComplete;

  @override
  Widget build(BuildContext context) {
    if (!_profileDone) {
      return ProfileSetupScreen(
        onComplete: () => setState(() => _profileDone = true),
      );
    }
    return const HomeScreen();
  }
}
