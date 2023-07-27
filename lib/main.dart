import 'package:flutter/material.dart';
import 'package:prestige/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const int mainColorValue = 0xFF32578E;

  // Create a MaterialColor from the int value
  static const MaterialColor primarySwatch = MaterialColor(
    mainColorValue,
    <int, Color>{
      50: Color(0xFFE1E7F4),
      100: Color(0xFFB2C5E5),
      200: Color(0xFF809ED2),
      300: Color(0xFF4D77BE),
      400: Color(0xFF32578E),
      500: Color(mainColorValue),
      600: Color(0xFF254373),
      700: Color(0xFF1C3761),
      800: Color(0xFF142C50),
      900: Color(0xFF0C1F3E),
    },
  );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:
            primarySwatch, // Use the primarySwatch as the primary color
      ),
      home: const Splash(),
    );
  }
}
