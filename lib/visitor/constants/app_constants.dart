import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF7B1FA2); // Dark purple
  static const Color secondary = Color(0xFFB39DDB); // Light purple
  static const Color accent = Color(0xFFFFD54F); // Yellow
  static const Color background = Color(0xFFFBEAFF);
  static const Color surface = Colors.white;
  static const Color error = Colors.red;

  // Gradient colors
  static const Color gradientPrimary = Color(0xFFB39DDB); // Light purple
  static const Color gradientSecondary = Color(0xFF7B1FA2); // Dark purple

  // Text colors
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.black54;
  static const Color textLight = Colors.white70;
  static const Color textWhite = Colors.white;

  // Input field colors
  static const Color inputFill = Color(0xFFE0E0E0); // Light grey for input fields
  static const Color inputHint = Colors.grey;

  // Status colors
  static const Color crowdedLabel = Colors.red;
  static const Color comfyLabel = Color(0xFFFFC107);

  // Shadow
  static Color shadowColor = Colors.grey.withOpacity(0.3);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitle1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subtitle2 = TextStyle(
    fontSize: 16,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 14,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 12,
  );

  static const TextStyle button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}

class AppDimensions {
  // Padding & Margins
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircle = 999.0;

  // Button Heights
  static const double buttonHeight = 50.0;
  static const double buttonHeightLarge = 56.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 20.0;
  static const double iconL = 24.0;
  static const double iconXL = 32.0;

  // Avatar Sizes
  static const double avatarS = 32.0;
  static const double avatarM = 40.0;
  static const double avatarL = 56.0;

  // Card Dimensions
  static const double cardWidth = 250.0;
  static const double cardImageHeight = 480.0;
}

class AppStrings {
  // App
  static const String appName = 'Nongki Yuk!';
  static const String appTagline = 'Find the Perfect Hangout on\nSouth Jakarta';

  // Authentication
  static const String welcomeBack = 'Welcome Back!';
  static const String signUp = 'Sign Up';
  static const String logIn = 'Log In';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String alreadyHaveAccount = 'Already have an account? ';
  static const String dontHaveAccount = "Don't have an account? ";
  static const String createAccount = 'Create Account';
  static const String joinUs = 'Join us and discover amazing places!';

  // Home
  static const String searchPlaces = 'Search places';
  static const String popularPlaces = 'Popular places';
  static const String viewAll = 'View all';
  static const String mostViewed = 'Most Viewed';
  static const String nearby = 'Nearby';
  static const String latest = 'Latest';

  // Place Details
  static const String overview = 'Overview';
  static const String details = 'Details';
  static const String price = 'Price';
  static const String go = 'Go!';

  // Labels
  static const String crowded = 'Crowded';
  static const String comfy = 'Comfy';

  // Common
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String noData = 'No data available';
  static const String retry = 'Retry';
}

class AppRoutes {
  static const String landing = '/landing';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String selectedPlace = '/selected-place';
  static const String profile = '/profile';
  static const String favorites = '/favorites';
  static const String search = '/search';
}

// Input Validation
class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}