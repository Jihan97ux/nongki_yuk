import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Text(
                      'Settings',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Settings List
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    children: [
                      const SizedBox(height: AppDimensions.paddingM),

                      // Notification
                      _buildSettingItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notification',
                        onTap: () => _showComingSoon(context, 'Notification settings'),
                      ),

                      // Dark Mode
                      Consumer<AppState>(
                        builder: (context, appState, child) {
                          return _buildSettingItem(
                            icon: appState.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                            title: appState.isDarkMode ? 'Light Mode' : 'Dark Mode',
                            onTap: () {
                              appState.toggleTheme();
                            },
                          );
                        },
                      ),

                      // Privacy and Security
                      _buildSettingItem(
                        icon: Icons.security_outlined,
                        title: 'Privacy and Security',
                        onTap: () => _showComingSoon(context, 'Privacy settings'),
                      ),

                      // Terms and Conditions
                      _buildSettingItem(
                        icon: Icons.description_outlined,
                        title: 'Term and Conditions',
                        onTap: () => _showTermsAndConditions(context),
                      ),

                      // Rate App
                      _buildSettingItem(
                        icon: Icons.star_outline,
                        title: 'Rate App',
                        onTap: () => _showRateApp(context),
                      ),

                      // Share App
                      _buildSettingItem(
                        icon: Icons.share_outlined,
                        title: 'Share App',
                        onTap: () => _showShareApp(context),
                      ),

                      // Help and Support
                      _buildSettingItem(
                        icon: Icons.help_outline,
                        title: 'Help and Support',
                        onTap: () => _showHelpAndSupport(context),
                      ),

                      // About
                      _buildSettingItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        onTap: () => _showAbout(context),
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),

                      // Log Out
                      _buildSettingItem(
                        icon: Icons.logout,
                        title: 'Log Out',
                        onTap: () => _showSignOutDialog(context),
                        isDestructive: true,
                      ),

                      const SizedBox(height: AppDimensions.paddingXL),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingS),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingL,
              vertical: AppDimensions.paddingL,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingS),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red : Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingM),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.subtitle1.copyWith(
                      color: isDestructive ? Colors.red : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).iconTheme.color,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ErrorHandler.showSuccessSnackBar(context, '$feature coming soon!');
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(Icons.description, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Text('Terms and Conditions', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 350,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Nongki Yuk!',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  '1. By using this app, you agree to our terms of service.\n\n'
                      '2. We respect your privacy and protect your personal data.\n\n'
                      '3. The app is provided "as is" without any warranties.\n\n'
                      '4. We reserve the right to update these terms at any time.\n\n'
                      '5. For any questions, please contact our support team.',
                  style: AppTextStyles.body2.copyWith(
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showRateApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(Icons.star, color: Theme.of(context).colorScheme.secondary, size: 20),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Text('Rate Our App', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 350,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'How do you like Nongki Yuk!?',
                style: AppTextStyles.body1.copyWith(color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 32,
                  );
                }),
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Maybe Later', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ErrorHandler.showSuccessSnackBar(
                          context,
                          'Thank you for your rating! ⭐',
                        );
                      },
                      child: Text('Submit', style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showShareApp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share Nongki Yuk!',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Help your friends discover amazing hangout places!',
              style: AppTextStyles.body1.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              child: Text(
                'Check out Nongki Yuk! - the best app to find hangout places in South Jakarta! 🏃‍♀️',
                style: AppTextStyles.body2.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppDimensions.paddingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ErrorHandler.showSuccessSnackBar(
                    context,
                    'Sharing link copied! 📎',
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share App'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpAndSupport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppDimensions.paddingS),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingS),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                      ),
                      child: Icon(
                        Icons.help_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingM),
                    Text(
                      'Help & Support',
                      style: AppTextStyles.heading4,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingL,
                  ),
                  children: [
                    _buildFAQItem(
                      'How do I search for places?',
                      'Use the search bar on the home screen or tap the filter icon for advanced search options.',
                    ),
                    _buildFAQItem(
                      'How do I save favorite places?',
                      'Tap the heart icon on any place card to add it to your favorites.',
                    ),
                    _buildFAQItem(
                      'How accurate is the distance information?',
                      'Distance is calculated using GPS and Google Maps data for accuracy.',
                    ),
                    _buildFAQItem(
                      'Can I suggest new places?',
                      'Yes! Contact our support team with place suggestions.',
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    Card(
                      color: Theme.of(context).cardColor,
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Still need help?',
                              style: AppTextStyles.subtitle1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingS),
                            Text(
                              'Contact our support team at:',
                              style: AppTextStyles.body2.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingS),
                            Text(
                              'support@nongkiyuk.com',
                              style: AppTextStyles.body1.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.subtitle1.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Text(
              answer,
              style: AppTextStyles.body2.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary.withOpacity(0.3), Theme.of(context).colorScheme.secondary.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Icon(Icons.info, color: Theme.of(context).iconTheme.color, size: 20),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            Text('About Nongki Yuk!', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 350,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find the Perfect Hangout on South Jakarta',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  'Version 1.0.0',
                  style: AppTextStyles.body2.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingS),
                Text(
                  'Made with ❤️ for Jakarta hangout enthusiasts',
                  style: AppTextStyles.body2.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  '© 2024 Nongki Yuk! All rights reserved.',
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            const Text('Sign Out'),
          ],
        ),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final appState = Provider.of<AppState>(context, listen: false);
              appState.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacementNamed(context, AppRoutes.landing);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}