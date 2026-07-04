import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/calculator_screen.dart';
import 'state/calculator_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    DevicePreview(
      // Debug builds get the device-frame preview panel (pick an iPhone or
      // Pixel, rotate, toggle its frame). Release builds run the app
      // directly; DevicePreview compiles to a no-op passthrough there.
      enabled: !kReleaseMode,
      builder: (BuildContext context) => const MiterPalApp(),
    ),
  );
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
          // Let DevicePreview drive the simulated device's MediaQuery/locale.
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
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
