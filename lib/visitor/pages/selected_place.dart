import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

class SelectedPlacePage extends StatelessWidget {
  final Place? place; // Optional constructor parameter

  const SelectedPlacePage({super.key, this.place});

  @override
  Widget build(BuildContext context) {
    // Try multiple ways to get the Place object
    Place? currentPlace = place; // From constructor

    if (currentPlace == null) {
      // Try to get from route arguments
      final route = ModalRoute.of(context);
      final arguments = route?.settings.arguments;

      print('DEBUG SelectedPlace: Route name: ${route?.settings.name}');
      print('DEBUG SelectedPlace: Arguments: $arguments');
      print('DEBUG SelectedPlace: Arguments type: ${arguments.runtimeType}');

      if (arguments != null && arguments is Place) {
        currentPlace = arguments;
        print('DEBUG SelectedPlace: Got Place from route arguments');
      }
    }

    // If still no place, try to get from app state (fallback)
    if (currentPlace == null) {
      print('DEBUG SelectedPlace: No Place found, showing error');
      return _buildErrorPage(context, 'Place data not found');
    }

    print('DEBUG SelectedPlace: Successfully loaded place: ${currentPlace.title}');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          blurRadius: 16,
                          spreadRadius: -5,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
                      child: NetworkImageWithError(
                        imageUrl: currentPlace.imageUrl,
                        width: double.infinity,
                        height: AppDimensions.cardImageHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: AppDimensions.paddingM,
                  left: AppDimensions.paddingL + AppDimensions.paddingM,
                  child: _buildIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: AppDimensions.paddingM,
                  right: AppDimensions.paddingL + AppDimensions.paddingM,
                  child: Consumer<AppState>(
                    builder: (context, appState, child) {
                      final isFavorite = appState.isFavorite(currentPlace!.id);
                      return _buildIconButton(
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                        onPressed: () {
                          appState.toggleFavorite(currentPlace!.id);
                          final message = isFavorite
                              ? 'Removed from favorites'
                              : 'Added to favorites';
                          ErrorHandler.showSuccessSnackBar(context, message);
                        },
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: AppDimensions.paddingL + AppDimensions.paddingS,
                  right: AppDimensions.paddingL + AppDimensions.paddingS,
                  child: Container(
                    margin: const EdgeInsets.all(AppDimensions.paddingM),
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentPlace.title,
                                style: AppTextStyles.heading4.copyWith(
                                  color: AppColors.textWhite,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.paddingS),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColors.textWhite,
                                    size: AppDimensions.iconS,
                                  ),
                                  const SizedBox(width: AppDimensions.paddingXS),
                                  Expanded(
                                    child: Text(
                                      currentPlace.location,
                                      style: AppTextStyles.body1.copyWith(
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              AppStrings.price,
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textLight,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingS),
                            Text(
                              '\$${currentPlace.price}',
                              style: AppTextStyles.heading4.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.paddingL),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingS,
              ),
              child: Row(
                children: [
                  Text(
                    AppStrings.overview,
                    style: AppTextStyles.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingL),
                  Text(
                    AppStrings.details,
                    style: AppTextStyles.subtitle1.copyWith(
                      color: AppColors.primary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingS,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoIcon(
                    icon: Icons.access_time,
                    label: currentPlace.operatingHours,
                  ),
                  _InfoIcon(
                    icon: Icons.local_offer,
                    label: currentPlace.label,
                  ),
                  _InfoIcon(
                    icon: Icons.star,
                    label: currentPlace.rating.toString(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentPlace.description.isNotEmpty
                            ? currentPlace.description
                            : '${currentPlace.title} adalah tempat nongkrong yang nyaman di ${currentPlace.location}. '
                            'Cocok untuk kamu yang ingin suasana ${currentPlace.label.toLowerCase()} dengan rating ${currentPlace.rating} dan jarak sekitar ${currentPlace.distance}.',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      if (currentPlace.amenities.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.paddingL),
                        Text(
                          'Amenities',
                          style: AppTextStyles.subtitle1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingS),
                        Wrap(
                          spacing: AppDimensions.paddingS,
                          runSpacing: AppDimensions.paddingS,
                          children: currentPlace.amenities.map((amenity) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.paddingM,
                                vertical: AppDimensions.paddingS,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                amenity,
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Updated Go Button with Recent Places tracking
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Consumer<AppState>(
                builder: (context, appState, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeightLarge,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.textPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                      ),
                      icon: const Icon(Icons.send),
                      label: Text(
                        AppStrings.go,
                        style: AppTextStyles.button,
                      ),
                      onPressed: () {
                        // Add to recent places when Go button is clicked
                        appState.addToRecentPlaces(currentPlace!);

                        // Show success message
                        ErrorHandler.showSuccessSnackBar(
                          context,
                          '🎉 Have fun at ${currentPlace.title}!',
                        );

                        // Simulate navigation to the place
                        _showNavigationDialog(context, currentPlace);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error page widget
  Widget _buildErrorPage(BuildContext context, String errorMessage) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: AppDimensions.paddingL),
              Text(
                'Oops! Something went wrong',
                style: AppTextStyles.heading4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                errorMessage,
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNavigationDialog(BuildContext context, Place place) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          title: Row(
            children: [
              const Icon(Icons.navigation, color: AppColors.primary),
              const SizedBox(width: AppDimensions.paddingS),
              Expanded(
                child: Text(
                  'Navigate to ${place.title}',
                  style: AppTextStyles.heading4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your preferred navigation app:',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                  const SizedBox(width: AppDimensions.paddingXS),
                  Expanded(
                    child: Text(
                      place.location,
                      style: AppTextStyles.body2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.paddingXS),
              Row(
                children: [
                  const Icon(Icons.directions_walk, color: AppColors.primary, size: 16),
                  const SizedBox(width: AppDimensions.paddingXS),
                  Text(
                    place.distance,
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ErrorHandler.showSuccessSnackBar(
                  context,
                  'Opening Google Maps... 🗺️',
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('Google Maps'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ClipOval(
      child: Material(
        color: Colors.black.withOpacity(0.3),
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: AppDimensions.iconS),
          const SizedBox(width: AppDimensions.paddingXS),
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}