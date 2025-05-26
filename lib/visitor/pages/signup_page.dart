import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import '../widgets/common/gradient_background.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
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
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
            child: Column(
              children: [
                const SizedBox(height: AppDimensions.paddingXL),

                // Header
                Column(
                  children: [
                    Text(
                      AppStrings.createAccount,
                      style: AppTextStyles.heading2.copyWith(
                        color: AppColors.textWhite,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    Text(
                      AppStrings.joinUs,
                      style: AppTextStyles.subtitle2.copyWith(
                        color: AppColors.textLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingXL * 2),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Full Name Field
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: AppStrings.fullName,
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: AppValidators.validateName,
                      ),

                      const SizedBox(height: AppDimensions.paddingM),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: AppStrings.email,
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: AppValidators.validateEmail,
                      ),

                      const SizedBox(height: AppDimensions.paddingM),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: AppStrings.password,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.next,
                        validator: AppValidators.validatePassword,
                      ),

                      const SizedBox(height: AppDimensions.paddingM),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: AppStrings.confirmPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
                        obscureText: !_isConfirmPasswordVisible,
                        textInputAction: TextInputAction.done,
                        validator: (value) => AppValidators.validateConfirmPassword(
                          _passwordController.text,
                          value,
                        ),
                        onFieldSubmitted: (_) => _handleSignUp(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.paddingL),

                // Sign Up Button
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: appState.authStatus == AuthStatus.loading
                            ? null
                            : _handleSignUp,
                        child: appState.authStatus == AuthStatus.loading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textPrimary,
                            ),
                          ),
                        )
                            : const Text(AppStrings.signUp),
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppDimensions.paddingM),

                // Sign In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        AppStrings.logIn,
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}