import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'services/profile_service.dart';
import 'widgets/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.loadTheme();
  await ProfileService.load();
  runApp(const BharatiyamPanchangaApp());
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

/// Gates the app — shows ProfileSetupScreen if profile is incomplete.
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
