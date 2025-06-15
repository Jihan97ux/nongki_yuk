import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectedPlacePage extends StatefulWidget {
  final Place? place;
  const SelectedPlacePage({super.key, this.place});
  @override
  State<SelectedPlacePage> createState() => _SelectedPlacePageState();
}

class _SelectedPlacePageState extends State<SelectedPlacePage> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    Place? currentPlace = widget.place;
    if (currentPlace == null) {
      final route = ModalRoute.of(context);
      final arguments = route?.settings.arguments;
      if (arguments != null && arguments is Place) {
        currentPlace = arguments;
      }
    }
    if (currentPlace == null) {
      return _buildErrorPage(context, 'Place data not found');
    }
    final appState = Provider.of<AppState>(context);
    final reviews = appState.getReviews(currentPlace.id);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxHeight > 700
                ? AppDimensions.cardImageHeight
                : constraints.maxHeight * 0.45;
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Image Section with responsive height
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
                              imageUrl: currentPlace!.imageUrl,
                              width: double.infinity,
                              height: imageHeight,
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
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                                            currentPlace.address,
                                            style: AppTextStyles.body1.copyWith(
                                              color: AppColors.textLight,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
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
                                    '\Rp.${currentPlace.price}',
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

                  // Tabs Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _tabIndex = 0),
                          child: Column(
                            children: [
                              Text('Overview', style: TextStyle(fontWeight: FontWeight.bold, color: _tabIndex == 0 ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary.withOpacity(0.7), fontSize: 18)),
                              if (_tabIndex == 0) Container(height: 2, width: 80, color: Theme.of(context).colorScheme.onSurface, margin: const EdgeInsets.only(top: 4)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: () => setState(() => _tabIndex = 1),
                          child: Column(
                            children: [
                              Text('Review', style: TextStyle(fontWeight: FontWeight.bold, color: _tabIndex == 1 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary.withOpacity(0.7), fontSize: 18)),
                              if (_tabIndex == 1) Container(height: 2, width: 80, color: Theme.of(context).colorScheme.primary, margin: const EdgeInsets.only(top: 4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Info Section
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingS,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: _InfoIcon(
                            icon: Icons.access_time,
                            label: currentPlace.operatingHours,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Flexible(
                          child: _InfoIcon(
                            icon: Icons.local_offer,
                            label: currentPlace.label,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.paddingS),
                        Flexible(
                          child: _InfoIcon(
                            icon: Icons.star,
                            label: currentPlace.rating.toString(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Content Section
                  if (_tabIndex == 0) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentPlace.description.isNotEmpty
                                ? currentPlace.description
                                : '${currentPlace.title} adalah tempat nongkrong yang nyaman di ${currentPlace.address}. '
                                'Cocok untuk kamu yang ingin suasana ${currentPlace.label.toLowerCase()} dengan rating ${currentPlace.rating} dan jarak sekitar ${currentPlace.distance}.',
                            style: AppTextStyles.body1.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.5,
                            ),
                          ),
                          if (currentPlace.amenities.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.paddingL),
                            Text(
                              'Amenities',
                              style: AppTextStyles.subtitle1.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
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
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    amenity,
                                    style: AppTextStyles.body2.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
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
                  ],
                  if (_tabIndex == 1) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              foregroundColor: Theme.of(context).colorScheme.onSecondary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/review', arguments: currentPlace);
                            },
                            icon: const Icon(Icons.rate_review),
                            label: const Text('Tulis Review'),
                          ),
                          const SizedBox(height: 16),
                          ...reviews.isEmpty
                              ? [const Text('No reviews yet.')]
                              : reviews.map((r) => ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: r.userAvatarUrl.isNotEmpty ? NetworkImage(r.userAvatarUrl) : null,
                                      child: r.userAvatarUrl.isEmpty ? const Icon(Icons.person) : null
                                    ),
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            r.userName,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Row(
                                          children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 18)),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          r.rating.toStringAsFixed(1),
                                          style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      r.comment,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: appState.currentUser?.id == r.userId
                                        ? PopupMenuButton<String>(
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (value) {
                                              if (value == 'edit') {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/review',
                                                  arguments: currentPlace,
                                                ).then((_) {
                                                  setState(() {});
                                                });
                                              } else if (value == 'delete') {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) => AlertDialog(
                                                    title: const Text('Delete Review'),
                                                    content: const Text('Are you sure you want to delete this review?'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          if (r.id.isNotEmpty && currentPlace != null) {
                                                            appState.deleteReview(currentPlace.id, r.id);
                                                            Navigator.pop(context);
                                                            setState(() {});
                                                          }
                                                        },
                                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.edit, size: 20),
                                                    SizedBox(width: 8),
                                                    Text('Edit'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : null,
                                  )).toList(),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Go Button
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
                              // appState.addToRecentPlaces(currentPlace!);
                              _showNavigationDialog(context, currentPlace!);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Extra bottom padding for safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
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
        return Dialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.navigation, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Navigate to ${place.title}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onSurface
                        ),
                        overflow: TextOverflow.ellipsis
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'click and follow this map to go to your hangout spot today!',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.7))
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.address,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface
                        )
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.directions_walk, color: Theme.of(context).colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      place.distance,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () async {
                          final lat = place.location.lat;
                          final lng = place.location.lng;
                          final name = Uri.encodeComponent(place.title);
                          final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng($name)';

                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                            final appState = Provider.of<AppState>(context, listen: false);
                            appState.addToRecentPlaces(place);
                          } else {
                            ErrorHandler.showErrorSnackBar(
                              context,
                              'Could not open directions to ${place.title}',
                            );
                          }
                        },
                        child: const Text('Open in Maps'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 20),
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
        horizontal: AppDimensions.paddingS,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: AppDimensions.iconS),
          const SizedBox(width: AppDimensions.paddingXS),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget untuk NetworkImageWithError jika belum ada
class NetworkImageWithError extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;

  const NetworkImageWithError({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 50,
            ),
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}