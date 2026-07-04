import 'package:flutter/material.dart';

import 'screens/calculator_screen.dart';
import 'state/calculator_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiterPalApp());
}

class MiterPalApp extends StatefulWidget {
  const MiterPalApp({super.key});

  @override
  State<MiterPalApp> createState() => _MiterPalAppState();
}

class _MiterPalAppState extends State<MiterPalApp> {
  final CalculatorController _controller = CalculatorController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (BuildContext context, _) {
        return MaterialApp(
          title: 'MiterPal',
          debugShowCheckedModeBanner: false,
          themeMode: _controller.themeMode,
          theme: ThemeData(
            colorSchemeSeed: const Color(0xFF6750A4),
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: const Color(0xFF6750A4),
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          home: CalculatorScreen(controller: _controller),
        );
      },
    );
  }
}
