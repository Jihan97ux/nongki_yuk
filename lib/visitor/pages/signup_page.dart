import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  late AnimationController _animationController;
  late AnimationController _containerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _containerSlideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _containerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _containerSlideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _containerController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      _containerController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _containerController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      await appState.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (appState.authStatus == AuthStatus.authenticated) {
          ErrorHandler.showSuccessSnackBar(context, 'Account created successfully!');
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
        } else if (appState.authError != null) {
          ErrorHandler.showErrorSnackBar(context, appState.authError!);
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, 'Failed to create account. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFB39DDB),
                        Color(0xFF7B1FA2),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header Section - Flexible size
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingXL,
                                vertical: constraints.maxHeight > 700
                                    ? AppDimensions.paddingXL * 2
                                    : AppDimensions.paddingL,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(height: constraints.maxHeight > 700
                                      ? AppDimensions.paddingXL
                                      : AppDimensions.paddingM),

                                  // App Title - Responsive font size
                                  Text(
                                    AppStrings.appName,
                                    style: AppTextStyles.heading1.copyWith(
                                      color: Colors.white,
                                      fontSize: constraints.maxHeight > 700 ? 48 : 36,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),

                                  SizedBox(height: constraints.maxHeight > 700
                                      ? AppDimensions.paddingM
                                      : AppDimensions.paddingS),

                                  // App Tagline
                                  Text(
                                    AppStrings.appTagline,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: constraints.maxHeight > 700 ? 16 : 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Form Container - Takes remaining space
                        Expanded(
                          child: AnimatedBuilder(
                            animation: _containerSlideAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, constraints.maxHeight * _containerSlideAnimation.value * 0.5),
                                child: Container(
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(32),
                                      topRight: Radius.circular(32),
                                    ),
                                  ),
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(AppDimensions.paddingXL),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          SizedBox(height: constraints.maxHeight > 700
                                              ? AppDimensions.paddingL
                                              : AppDimensions.paddingM),

                                          // Full Name Field
                                          _buildInputField(
                                            controller: _nameController,
                                            hintText: 'Full name',
                                            textInputAction: TextInputAction.next,
                                            validator: AppValidators.validateName,
                                          ),

                                          const SizedBox(height: AppDimensions.paddingL),

                                          // Email Field
                                          _buildInputField(
                                            controller: _emailController,
                                            hintText: 'Email address',
                                            keyboardType: TextInputType.emailAddress,
                                            textInputAction: TextInputAction.next,
                                            validator: AppValidators.validateEmail,
                                          ),

                                          const SizedBox(height: AppDimensions.paddingL),

                                          // Password Field
                                          _buildInputField(
                                            controller: _passwordController,
                                            hintText: 'Password',
                                            obscureText: !_isPasswordVisible,
                                            textInputAction: TextInputAction.done,
                                            validator: AppValidators.validatePassword,
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _isPasswordVisible = !_isPasswordVisible;
                                                });
                                              },
                                            ),
                                            onFieldSubmitted: (_) => _handleSignUp(),
                                          ),

                                          SizedBox(height: constraints.maxHeight > 700
                                              ? AppDimensions.paddingXL * 2
                                              : AppDimensions.paddingXL),

                                          // Sign Up Button
                                          Consumer<AppState>(
                                            builder: (context, appState, child) {
                                              return SizedBox(
                                                width: double.infinity,
                                                height: 56,
                                                child: ElevatedButton(
                                                  onPressed: appState.authStatus == AuthStatus.loading
                                                      ? null
                                                      : _handleSignUp,
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: const Color(0xFFFFD54F),
                                                    foregroundColor: Colors.black,
                                                    elevation: 0,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(28),
                                                    ),
                                                  ),
                                                  child: appState.authStatus == AuthStatus.loading
                                                      ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                                    ),
                                                  )
                                                      : const Text(
                                                    'Sign Up',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          const SizedBox(height: AppDimensions.paddingL),

                                          // Login Link
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Already have an account? ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                                                },
                                                child: const Text(
                                                  'Log In',
                                                  style: TextStyle(
                                                    color: Color(0xFFFFD54F),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),

                                          // Extra padding for small screens
                                          SizedBox(height: constraints.maxHeight > 700
                                              ? AppDimensions.paddingL
                                              : AppDimensions.paddingXL),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFE0E0E0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7B1FA2), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingM,
        ),
      ),
    );
  }
}