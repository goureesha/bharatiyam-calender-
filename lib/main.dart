import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'widgets/common.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.loadTheme();
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
          home: const HomeScreen(),
        );
      },
    );
  }
}
