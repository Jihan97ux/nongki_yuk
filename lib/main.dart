import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import all pages
import 'visitor/pages/landing_page.dart';
import 'visitor/pages/login_page.dart';
import 'visitor/pages/signup_page.dart';
import 'visitor/pages/home_page.dart';
import 'visitor/pages/selected_place.dart';
import 'visitor/pages/profile_page.dart';
import 'visitor/pages/recent_places_page.dart';

// Import state management
import 'visitor/state/app_state.dart';

// Import constants and utilities
import 'visitor/constants/app_constants.dart';
import 'visitor/theme/app_theme.dart';

void main() {
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

            // Initial route based on authentication status
            initialRoute: appState.authStatus == AuthStatus.authenticated
                ? AppRoutes.home
                : AppRoutes.landing,

            // Route generator
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case AppRoutes.landing:
                  return _createRoute(const LandingPage());

                case AppRoutes.login:
                  return _createRoute(const LoginPage());

                case AppRoutes.signup:
                  return _createRoute(const SignUpPage());

                case AppRoutes.home:
                // Check if user is authenticated
                  if (appState.authStatus != AuthStatus.authenticated) {
                    return _createRoute(const LandingPage());
                  }
                  return _createRoute(const HomePage());

                case AppRoutes.selectedPlace:
                  final place = settings.arguments;
                  if (place == null) {
                    return _createRoute(const HomePage());
                  }
                  return _createRoute(const SelectedPlacePage());

                case AppRoutes.profile:
                // Check if user is authenticated
                  if (appState.authStatus != AuthStatus.authenticated) {
                    return _createRoute(const LandingPage());
                  }
                  return _createRoute(const ProfilePage());

                case AppRoutes.recentPlaces:
                // Check if user is authenticated
                  if (appState.authStatus != AuthStatus.authenticated) {
                    return _createRoute(const LandingPage());
                  }
                  return _createRoute(const RecentPlacesPage());

                default:
                  return _createRoute(const NotFoundPage());
              }
            },

            // Handle unknown routes
            onUnknownRoute: (RouteSettings settings) {
              return _createRoute(const NotFoundPage());
            },
          );
        },
      ),
    );
  }

  // Custom route transition
  PageRouteBuilder _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide transition from right to left
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: AppAnimations.normal,
    );
  }
}

// 404 Not Found Page
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
                // Error Icon
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXL),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
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

                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeightLarge,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final appState = Provider.of<AppState>(context, listen: false);
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
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      ),
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

// Route Guard Widget (Optional)
class AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget fallback;

  const AuthGuard({
    super.key,
    required this.child,
    required this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return appState.authStatus == AuthStatus.authenticated
            ? child
            : fallback;
      },
    );
  }
}

// Splash Screen Widget (Optional)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
    ));

    _animationController.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        final appState = Provider.of<AppState>(context, listen: false);
        Navigator.pushReplacementNamed(
          context,
          appState.authStatus == AuthStatus.authenticated
              ? AppRoutes.home
              : AppRoutes.landing,
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB39DDB), // Light purple
              Color(0xFF7B1FA2), // Dark purple
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo/Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 60,
                      color: Color(0xFF7B1FA2),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // App Name
                  Text(
                    AppStrings.appName,
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // App Tagline
                  Text(
                    AppStrings.appTagline,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingXL * 2),

                  // Loading Indicator
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}