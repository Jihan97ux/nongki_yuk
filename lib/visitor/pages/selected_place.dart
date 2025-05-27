import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

class SelectedPlacePage extends StatelessWidget {
  const SelectedPlacePage({super.key});

  @override
  Widget build(BuildContext context) {
    final place = ModalRoute.of(context)!.settings.arguments as Place;

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
                        imageUrl: place.imageUrl,
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
                      final isFavorite = appState.isFavorite(place.id);
                      return _buildIconButton(
                        icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                        onPressed: () {
                          appState.toggleFavorite(place.id);
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
                                place.title,
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
                                      place.location,
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
                              place.price,
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
                    label: place.operatingHours,
                  ),
                  _InfoIcon(
                    icon: Icons.local_offer,
                    label: place.label,
                  ),
                  _InfoIcon(
                    icon: Icons.star,
                    label: place.rating.toString(),
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
                        place.description.isNotEmpty
                            ? place.description
                            : '${place.title} adalah tempat nongkrong yang nyaman di ${place.location}. '
                            'Cocok untuk kamu yang ingin suasana ${place.label.toLowerCase()} dengan rating ${place.rating} dan jarak sekitar ${place.distance}.',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      if (place.amenities.isNotEmpty) ...[
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
                          children: place.amenities.map((amenity) {
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

            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: SizedBox(
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
                    ErrorHandler.showSuccessSnackBar(
                      context,
                      'Navigate to ${place.title}',
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
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