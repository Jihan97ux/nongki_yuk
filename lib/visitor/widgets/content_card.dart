import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

class ContentCard extends StatelessWidget {
  final List<Place> places;

  const ContentCard({
    super.key,
    required this.places,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingXL + AppDimensions.paddingS,
        ),
        itemCount: places.length,
        itemBuilder: (context, index) {
          return _buildPlaceCard(context, places[index]);
        },
      ),
    );
  }

  Widget _buildPlaceCard(BuildContext context, Place place) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final isFavorite = appState.isFavorite(place.id);

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.selectedPlace,
              arguments: place,
            );
          },
          child: Container(
            width: AppDimensions.cardWidth,
            margin: const EdgeInsets.only(right: AppDimensions.paddingM),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: NetworkImageWithError(
                      imageUrl: place.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Status Label
                  Positioned(
                    top: AppDimensions.paddingM,
                    left: AppDimensions.paddingM,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: _getLabelColor(place.label),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Text(
                        place.label,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Favorite Button
                  Positioned(
                    top: AppDimensions.paddingM,
                    right: AppDimensions.paddingM,
                    child: GestureDetector(
                      onTap: () {
                        appState.toggleFavorite(place.id);
                        final message = isFavorite
                            ? 'Removed from favorites'
                            : 'Added to favorites';
                        ErrorHandler.showSuccessSnackBar(context, message);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? AppColors.error : AppColors.textWhite,
                          size: AppDimensions.iconM,
                        ),
                      ),
                    ),
                  ),

                  // Place Information Overlay
                  Positioned(
                    bottom: AppDimensions.paddingXL,
                    left: AppDimensions.paddingM,
                    right: AppDimensions.paddingM,
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.title,
                            style: AppTextStyles.body1.copyWith(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: AppDimensions.paddingXS),

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
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.textWhite,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingS),
                              const Icon(
                                Icons.star,
                                color: AppColors.accent,
                                size: AppDimensions.iconS,
                              ),
                              const SizedBox(width: AppDimensions.paddingXS),
                              Text(
                                place.rating.toString(),
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppDimensions.paddingXS),

                          Row(
                            children: [
                              const Icon(
                                Icons.directions_walk,
                                color: AppColors.textWhite,
                                size: AppDimensions.iconS,
                              ),
                              const SizedBox(width: AppDimensions.paddingXS),
                              Text(
                                place.distance,
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textWhite,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                place.price,
                                style: AppTextStyles.body1.copyWith(
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
            ),
          ),
        );
      },
    );
  }

  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'crowded':
        return AppColors.crowdedLabel;
      case 'comfy':
        return AppColors.comfyLabel;
      default:
        return AppColors.primary;
    }
  }
}