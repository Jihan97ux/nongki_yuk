import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'visitor/pages/landing_page.dart';
import 'visitor/pages/login_page.dart';
import 'visitor/pages/signup_page.dart';
import 'visitor/pages/home_page.dart';
import 'visitor/pages/selected_place.dart';
import 'visitor/pages/profile_page.dart';
import 'visitor/pages/recent_places_page.dart';
import 'visitor/pages/settings_page.dart';
import 'visitor/pages/favorite_places_page.dart';
import 'visitor/pages/review_page.dart';
import 'visitor/pages/view_all_places_page.dart';
import 'visitor/models/place_model.dart';
import 'visitor/state/app_state.dart';
import 'visitor/constants/app_constants.dart';
import 'visitor/theme/app_theme.dart';
import 'visitor/utils/error_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: appState.authStatus == AuthStatus.authenticated
                ? const HomePage()
                : const LandingPage(),

            // Fixed routing configuration
            routes: {
              AppRoutes.landing: (context) => const LandingPage(),
              AppRoutes.login: (context) => const LoginPage(),
              AppRoutes.signup: (context) => const SignUpPage(),
              AppRoutes.home: (context) => _buildAuthGuard(const HomePage(), appState),
              AppRoutes.profile: (context) => _buildAuthGuard(const ProfilePage(), appState), // Updated
              AppRoutes.recentPlaces: (context) => _buildAuthGuard(const RecentPlacesPage(), appState),
              AppRoutes.settings: (context) => _buildAuthGuard(const SettingsPage(), appState),
              AppRoutes.favorites: (context) => _buildAuthGuard(const FavoritePlacesPage(), appState),
              AppRoutes.review: (context) => _buildAuthGuard(const ReviewPage(), appState),
              AppRoutes.viewAllPlaces: (context) => _buildAuthGuard(const ViewAllPlacesPage(), appState),
            },

            // Route generator for dynamic routes (with arguments)
            onGenerateRoute: (RouteSettings settings) {
              print('DEBUG Main: Generating route for: ${settings.name}');
              print('DEBUG Main: Arguments: ${settings.arguments}');
              print('DEBUG Main: Arguments type: ${settings.arguments.runtimeType}');

              switch (settings.name) {
                case AppRoutes.selectedPlace:
                  final arguments = settings.arguments;
                  print('DEBUG Main: SelectedPlace route - Arguments: $arguments');

                  if (arguments == null || arguments is! Place) {
                    print('DEBUG Main: Invalid arguments, redirecting to home');
                    return MaterialPageRoute(
                      builder: (context) => const HomePage(),
                      settings: settings,
                    );
                  }

                  print('DEBUG Main: Valid Place arguments, creating SelectedPlacePage');
                  return MaterialPageRoute(
                    builder: (context) => const SelectedPlacePage(),
                    settings: settings, // Pass settings with arguments
                  );

                default:
                  print('DEBUG Main: Unknown route: ${settings.name}');
                  return MaterialPageRoute(
                    builder: (context) => const NotFoundPage(),
                    settings: settings,
                  );
              }
            },

            // Handle unknown routes
            onUnknownRoute: (RouteSettings settings) {
              print('DEBUG Main: Unknown route: ${settings.name}');
              return MaterialPageRoute(
                builder: (context) => const NotFoundPage(),
                settings: settings,
              );
            },
          );
        },
      ),
    );
  }

  // Auth guard helper
  Widget _buildAuthGuard(Widget page, AppState appState) {
    if (appState.authStatus != AuthStatus.authenticated) {
      return const LandingPage();
    }
    return page;
  }
}

// 404 Not Found Page - Enhanced with better styling
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon with gradient background
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXL),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingXL),

                // Error Title
                Text(
                  '404',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.primary,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Error Message
                Text(
                  'Page Not Found',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingM),

                Text(
                  'The page you are looking for doesn\'t exist.\nLet\'s get you back to exploring amazing places!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingXL * 2),

                // Back to Home Button with improved styling
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightLarge,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final appState = Provider.of<AppState>(
                          context, listen: false);
                      if (appState.authStatus == AuthStatus.authenticated) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                              (route) => false,
                        );
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.landing,
                              (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppDimensions.radiusL),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.home),
                    label: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Secondary Action
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}