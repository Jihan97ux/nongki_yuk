import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import '../widgets/home_footer.dart';

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
                : constraints.maxHeight * 0.35;
            return Column(
              children: <Widget>[
                // Top image with rounded corners and overlay card
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: NetworkImageWithError(
                          imageUrl: currentPlace!.imageUrl,
                          width: double.infinity,
                          height: imageHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Back button (top left)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _buildIconButton(
                          icon: Icons.arrow_back,
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      // Bookmark button (top right)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Consumer<AppState>(
                          builder: (context, appState, child) {
                            final isFavorite = appState.isFavorite(currentPlace!.id);
                            return _buildIconButton(
                              icon: isFavorite ? Icons.bookmark : Icons.bookmark_border,
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
                      // Overlay card (bottom)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.brown.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentPlace.title,
                                style: AppTextStyles.heading4.copyWith(
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Start from IDR ${currentPlace.price}',
                                style: AppTextStyles.body2.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Tabs (Overview/Review)
                Padding(
                  padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _tabIndex = 0),
                        child: Column(
                          children: [
                            Text(
                              'Overview',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _tabIndex == 0
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 18,
                              ),
                            ),
                            if (_tabIndex == 0)
                              Container(
                                height: 2,
                                width: 80,
                                color: Theme.of(context).colorScheme.primary,
                                margin: const EdgeInsets.only(top: 4),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () => setState(() => _tabIndex = 1),
                        child: Column(
                          children: [
                            Text(
                              'Review',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _tabIndex == 1
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 18,
                              ),
                            ),
                            if (_tabIndex == 1)
                              Container(
                                height: 2,
                                width: 80,
                                color: Theme.of(context).colorScheme.primary,
                                margin: const EdgeInsets.only(top: 4),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: IndexedStack(
                    index: _tabIndex,
                    children: [
                      // Overview Tab
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            // Info Row (time, label, rating)
                            Padding(
                              padding: const EdgeInsets.only(top: 24, left: 32, right: 32),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  _InfoIcon(
                                    icon: Icons.access_time,
                                    label: currentPlace!.operatingHours,
                                  ),
                                  const SizedBox(width: 16),
                                  _InfoIcon(
                                    icon: Icons.local_offer,
                                    label: currentPlace!.label,
                                  ),
                                  const SizedBox(width: 16),
                                  _InfoIcon(
                                    icon: Icons.star,
                                    label: currentPlace!.rating.toString(),
                                  ),
                                ],
                              ),
                            ),
                            // Address (greyed out)
                            Padding(
                              padding: const EdgeInsets.only(top: 16, left: 32, right: 32),
                              child: Text(
                                currentPlace!.address,
                                style: TextStyle(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Spacer
                            const SizedBox(height: 24),
                            // GO Button
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD54F),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  onPressed: () {
                                    appState.addToRecentPlaces(currentPlace!);
                                    ErrorHandler.showSuccessSnackBar(
                                      context,
                                      '🎉 Have fun at \\${currentPlace!.title}!',
                                    );
                                    _showNavigationDialog(context, currentPlace!);
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('GO'),
                                      SizedBox(width: 8),
                                      Icon(Icons.send, size: 22),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Review Tab
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Builder(
                            builder: (context) {
                              final currentUser = appState.currentUser;
                              Review? userReview;
                              if (currentUser != null) {
                                try {
                                  userReview = reviews.firstWhere((r) => r.userId == currentUser.id);
                                } catch (e) {
                                  userReview = null;
                                }
                              } else {
                                userReview = null;
                              }
                              // Hanya tampilkan review user jika ada, jika tidak ada tampilkan button untuk review
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (userReview != null) ...[
                                    _ReviewCard(review: userReview, highlight: true),
                                    const SizedBox(height: 12),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                        height: 36,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.yellow,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 18),
                                            textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/review',
                                              arguments: currentPlace!,
                                            );
                                          },
                                          child: const Text('Edit Review'),
                                        ),
                                      ),
                                    ),
                                  ] else ...[
                                    Align(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.yellow,
                                            foregroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/review',
                                              arguments: currentPlace!,
                                            );
                                          },
                                          child: const Text('Review'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const HomeFooter(),
    );
  }

  // Error page widget
  Widget _buildErrorPage(BuildContext context, String errorMessage) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Error',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Theme.of(context).colorScheme.onPrimary,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.navigation, color: Colors.purple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('Navigate to ${place.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'click and follow this map to go to your hangout spot today!',
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.purple, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(place.address, style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.directions_walk, color: Colors.purple, size: 18),
                    const SizedBox(width: 8),
                    Text(place.distance, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          // TODO: Open Google Maps
                        },
                        child: const Text('Open Maps', style: TextStyle(fontWeight: FontWeight.bold)),
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
                          backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? AppColors.customPurpleDark,
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
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
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
          Icon(icon, color: AppColors.customPurpleIcon, size: AppDimensions.iconS),
          const SizedBox(width: AppDimensions.paddingXS),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textPrimary,
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

class _ReviewCard extends StatelessWidget {
  final Review review;
  final bool highlight;
  const _ReviewCard({required this.review, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: highlight ? Colors.yellow.withOpacity(0.2) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: highlight ? Border.all(color: Colors.yellow, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(review.userAvatarUrl),
            radius: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: highlight ? Colors.amber[900] : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < review.rating.round() ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      )),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  review.comment,
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}