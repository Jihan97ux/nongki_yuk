import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      backgroundColor: AppColors.background,
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final user = appState.currentUser;
          if (user == null) return const SizedBox();

          return Column(
            children: [
              // Header Section with Gradient - Made taller to match design
              Container(
                height: MediaQuery.of(context).size.height * 0.5, // Increased height
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFB39DDB), // Light purple
                      Color(0xFF9575CD), // Medium purple
                      Color(0xFF7B1FA2), // Dark purple
                    ],
                    stops: [0.0, 0.6, 1.0],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // Top Navigation Bar
                          Padding(
                            padding: const EdgeInsets.all(AppDimensions.paddingL),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  'Edit Profile',
                                  style: AppTextStyles.heading3.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(width: 48), // Balance the back button
                              ],
                            ),
                          ),

                          const Spacer(),

                          // Profile Section - Centered and larger
                          Column(
                            children: [
                              // Profile Photo with Camera Button
                              Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 4,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 80, // Increased size
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 76,
                                        backgroundImage: NetworkImage(
                                          user.profileImageUrl ?? 'https://i.pravatar.cc/160',
                                        ),
                                        onBackgroundImageError: (exception, stackTrace) {},
                                        child: user.profileImageUrl == null
                                            ? Text(
                                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                          style: AppTextStyles.heading1.copyWith(
                                            color: AppColors.primary,
                                            fontSize: 40,
                                          ),
                                        )
                                            : null,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => _showImagePicker(context),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: const BoxDecoration(
                                          color: AppColors.accent,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppDimensions.paddingXL),

                              // User Information
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    user.name,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.heading2.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 32,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.paddingS),
                                  GestureDetector(
                                    onTap: () => _showEditProfile(context),
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: Colors.white24,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.paddingS),
                              Text(
                                'Pembalap',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.body1.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Content Section - Your Information Form
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppDimensions.paddingL),

                        Text(
                          'Your Information',
                          style: AppTextStyles.heading4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingXL),

                        // Email Field
                        _buildInputField(
                          value: user.email,
                          hintText: 'Email',
                          readOnly: true,
                        ),

                        const SizedBox(height: AppDimensions.paddingL),

                        // Phone Field
                        _buildInputField(
                          value: '',
                          hintText: 'Phone',
                          onTap: () => _showComingSoon(context, 'Phone editing'),
                        ),

                        const SizedBox(height: AppDimensions.paddingL),

                        // Location Field
                        _buildInputField(
                          value: '',
                          hintText: 'Location',
                          onTap: () => _showComingSoon(context, 'Location editing'),
                        ),

                        const SizedBox(height: AppDimensions.paddingL),

                        // Password Field
                        _buildInputField(
                          value: '********',
                          hintText: 'Password',
                          obscureText: true,
                          suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
                          onTap: () => _showComingSoon(context, 'Password change'),
                        ),

                        const SizedBox(height: AppDimensions.paddingXL * 2),

                        // Save Edit Button
                        SizedBox(
                          width: double.infinity,
                          height: AppDimensions.buttonHeightLarge,
                          child: ElevatedButton(
                            onPressed: () {
                              ErrorHandler.showSuccessSnackBar(
                                context,
                                'Profile saved successfully!',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'SAVE EDIT',
                              style: AppTextStyles.button.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppDimensions.paddingXL),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputField({
    required String value,
    required String hintText,
    bool obscureText = false,
    bool readOnly = false,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingL,
          vertical: AppDimensions.paddingL,
        ),
        decoration: BoxDecoration(
          color: readOnly ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? hintText : value,
                style: AppTextStyles.body1.copyWith(
                  color: value.isEmpty
                      ? Colors.grey.shade500
                      : readOnly
                      ? Colors.grey.shade600
                      : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            if (suffixIcon != null) suffixIcon,
          ],
        ),
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser!;

    final nameController = TextEditingController(text: user.name);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXL),
            ),
          ),
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Edit Name',
                    style: AppTextStyles.heading4,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingL),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await appState.updateProfile(
                        name: nameController.text.trim(),
                      );
                      Navigator.pop(context);
                      ErrorHandler.showSuccessSnackBar(
                        context,
                        'Name updated successfully!',
                      );
                    } catch (e) {
                      ErrorHandler.showErrorSnackBar(
                        context,
                        'Failed to update name',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDimensions.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change Profile Picture',
              style: AppTextStyles.heading4,
            ),
            const SizedBox(height: AppDimensions.paddingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context, 'Camera');
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoon(context, 'Gallery');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: AppDimensions.paddingS),
            Text(label, style: AppTextStyles.body2),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ErrorHandler.showSuccessSnackBar(context, '$feature coming soon!');
  }
}