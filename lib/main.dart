import 'package:flutter/material.dart';
import 'visitor/pages/landing_page.dart';
import 'visitor/pages/login_page.dart';
import 'visitor/pages/home_page.dart';

void main() {
  runApp(const NongkiYukApp());
}

class NongkiYukApp extends StatelessWidget {
  const NongkiYukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LandingPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/landing': (context) => const LandingPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
