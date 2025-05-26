import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'visitor/pages/selected_place.dart';
import 'visitor/pages/landing_page.dart';
import 'visitor/pages/login_page.dart';
import 'visitor/pages/signup_page.dart';
import 'visitor/pages/home_page.dart';
import '/visitor/constants/app_constants.dart';
import './visitor/theme/app_theme.dart';
import '../visitor/state/app_state.dart';

void main() {
  runApp(const nongkiYukApp());
}

class nongkiYukApp extends StatelessWidget {
  const nongkiYukApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LandingPage(),
        routes: {
          AppRoutes.landing: (context) => const LandingPage(),
          AppRoutes.login: (context) => const LoginPage(),
          AppRoutes.signup: (context) => const SignUpPage(),
          AppRoutes.home: (context) => const HomePage(),
          AppRoutes.selectedPlace: (context) => const SelectedPlacePage(),
        },
      ),
    );
  }
}