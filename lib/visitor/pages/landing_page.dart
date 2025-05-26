import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../widgets/common/gradient_background.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // App Title
              Text(
                AppStrings.appName,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.textWhite,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // App Tagline
              Text(
                AppStrings.appTagline,
                style: AppTextStyles.subtitle2.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.signup);
                  },
                  child: const Text(AppStrings.signUp),
                ),
              ),

              const SizedBox(height: AppDimensions.paddingM),

              // Login Link
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
                      Navigator.pushNamed(context, AppRoutes.login);
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
    );
  }
}