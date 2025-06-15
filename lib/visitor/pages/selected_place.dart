import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/review_page.dart';
import '../models/place_model.dart';

class SelectedPlacePage extends StatefulWidget {
  final Place? place;
  const SelectedPlacePage({super.key, this.place});
  @override
  State<SelectedPlacePage> createState() => _SelectedPlacePageState();
}

class _SelectedPlacePageState extends State<SelectedPlacePage> {
  int _tabIndex = 0;

  List<Review> _reviews = [];
  bool _loadingReviews = true;
  bool _reviewsLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  void _onReviewTabTapped() {
    setState(() => _tabIndex = 1);
    if (!_reviewsLoaded) {
      _loadReviews();
    }
  }

  Future<void> _loadReviews() async {
    if (!mounted) return;

    setState(() {
      _loadingReviews = true;
    });

    Place? place = widget.place;
    if (place == null) {
      final route = ModalRoute.of(context);
      final arguments = route?.settings.arguments;
      if (arguments != null && arguments is Place) {
        place = arguments;
      }
    }

    if (place?.id == null) {
      if (mounted) {
        setState(() {
          _reviews = [];
          _loadingReviews = false;
          _reviewsLoaded = true;
        });
      }
      return;
    }

    try {
      // Tambahkan timeout dan limit untuk optimasi
      final snapshot = await FirebaseFirestore.instance
          .collection('places')
          .doc(place!.id)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .limit(20) // Limit hanya 20 review pertama
          .get()
          .timeout(const Duration(seconds: 10)); // Timeout 10 detik

      if (mounted) {
        setState(() {
          _reviews = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Review.fromJson(data);
          }).toList();
          _loadingReviews = false;
          _reviewsLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviews = [];
          _loadingReviews = false;
          _reviewsLoaded = true;
        });

        // Show error message
        ErrorHandler.showErrorSnackBar(
            context,
            'Failed to load reviews. Please check your connection.'
        );
        print('Error loading reviews: $e');
      }
    }
  }

  Future<void> _navigateToReviewPage(BuildContext context, Place place, {Review? existingReview}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewPage(existingReview: existingReview),
        settings: RouteSettings(arguments: place),
      ),
    );

    // If review was submitted/updated, reload reviews
    if (result == true && _tabIndex == 1) {
      _loadReviews();
    }
  }

  void _forceReloadReviews() {
    _reviewsLoaded = false;
    if (_tabIndex == 1) {
      _loadReviews();
    }
  }

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
                          onTap: _onReviewTabTapped,
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
                            onPressed: () async {
                              final appState = Provider.of<AppState>(context, listen: false);
                              final currentUser = appState.currentUser;
                              if (currentUser == null) return;

                              final reviewDoc = await FirebaseFirestore.instance
                                  .collection('places')
                                  .doc(currentPlace!.id)
                                  .collection('reviews')
                                  .where('userId', isEqualTo: currentUser.id)
                                  .limit(1)
                                  .get();

                              Review? existingReview;
                              if (reviewDoc.docs.isNotEmpty) {
                                final data = reviewDoc.docs.first.data();
                                existingReview = Review.fromJson(data);
                              }

                              await _navigateToReviewPage(context, currentPlace!, existingReview: existingReview);
                            },
                            icon: const Icon(Icons.rate_review),
                            label: const Text('Tulis Review'),
                          ),
                          const SizedBox(height: 16),

                          // Optimasi loading state
                          if (_loadingReviews) ...[
                            Container(
                              height: 200,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text('Loading reviews...', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            // Reviews content
                            if (_reviews.isEmpty) ...[
                              Container(
                                height: 150,
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.rate_review, size: 48, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text(
                                        'No reviews yet',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Be the first to review!',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Header info
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  '${_reviews.length} Reviews',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _reviews.length,
                                itemBuilder: (context, index) {
                                  final review = _reviews[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // User info row
                                        Row(
                                          children: [
                                            // Optimasi avatar loading
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundColor: Colors.grey[300],
                                              child: review.userAvatarUrl.isNotEmpty
                                                  ? ClipOval(
                                                child: Image.network(
                                                  review.userAvatarUrl,
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                    );
                                                  },
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Icon(Icons.person, size: 20);
                                                  },
                                                ),
                                              )
                                                  : const Icon(Icons.person, size: 20),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    review.userName,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      ...List.generate(5, (i) => Icon(
                                                        i < review.rating ? Icons.star : Icons.star_border,
                                                        color: Colors.amber,
                                                        size: 16,
                                                      )),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        review.rating.toStringAsFixed(1),
                                                        style: const TextStyle(
                                                          color: Colors.purple,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Menu untuk user sendiri
                                            Consumer<AppState>(
                                              builder: (context, appState, child) {
                                                if (appState.currentUser?.id == review.userId) {
                                                  return PopupMenuButton<String>(
                                                    icon: const Icon(Icons.more_vert),
                                                    onSelected: (value) async {
                                                      if (value == 'edit') {
                                                        await Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (_) => ReviewPage(existingReview: review),
                                                            settings: RouteSettings(arguments: currentPlace),
                                                          ),
                                                        );
                                                        _reviewsLoaded = false;
                                                        _loadReviews();
                                                      } else if (value == 'delete') {
                                                        _showDeleteDialog(context, review, currentPlace!);
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
                                                  );
                                                }
                                                return const SizedBox.shrink();
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Review text
                                        Text(
                                          review.comment,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.4,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        if (review.footage.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 120,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: review.footage.length,
                                              itemBuilder: (context, mediaIndex) {
                                                final mediaUrl = review.footage[mediaIndex];
                                                final isVideo = _isVideoUrl(mediaUrl);

                                                return Container(
                                                  margin: const EdgeInsets.only(right: 8),
                                                  child: GestureDetector(
                                                    onTap: () => _showMediaDialog(context, review.footage, mediaIndex),
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Container(
                                                        width: 100,
                                                        height: 100,
                                                        decoration: BoxDecoration(
                                                          color: Colors.grey[300],
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                        child: Stack(
                                                          fit: StackFit.expand,
                                                          children: [
                                                            // Background image/thumbnail
                                                            Image.network(
                                                              isVideo ? _getCloudinaryThumbnail(mediaUrl) : mediaUrl,
                                                              fit: BoxFit.cover,
                                                              loadingBuilder: (context, child, loadingProgress) {
                                                                if (loadingProgress == null) return child;
                                                                return Center(
                                                                  child: SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child: CircularProgressIndicator(
                                                                      strokeWidth: 2,
                                                                      value: loadingProgress.expectedTotalBytes != null
                                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                                          loadingProgress.expectedTotalBytes!
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Container(
                                                                  color: Colors.grey[300],
                                                                  child: Icon(
                                                                    isVideo ? Icons.video_library : Icons.broken_image,
                                                                    color: Colors.grey[600],
                                                                    size: 24,
                                                                  ),
                                                                );
                                                              },
                                                            ),

                                                            if (isVideo) ...[
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.black.withOpacity(0.3),
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                              ),
                                                              // Play button
                                                              Center(
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.black54,
                                                                    borderRadius: BorderRadius.circular(15),
                                                                  ),
                                                                  child: const Icon(
                                                                    Icons.play_arrow,
                                                                    color: Colors.white,
                                                                    size: 20,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],

                                                            Positioned(
                                                              bottom: 4,
                                                              right: 4,
                                                              child: Container(
                                                                padding: const EdgeInsets.all(2),
                                                                decoration: BoxDecoration(
                                                                  color: Colors.black54,
                                                                  borderRadius: BorderRadius.circular(3),
                                                                ),
                                                                child: Icon(
                                                                  isVideo ? Icons.videocam : Icons.image,
                                                                  color: Colors.white,
                                                                  size: 10,
                                                                ),
                                                              ),
                                                            ),
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
                                        const SizedBox(height: 8),
                                        // Date
                                        Text(
                                          _formatDate(review.createdAt),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Theme.of(context).dialogBackgroundColor,
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('click and follow this map to go to your hangout spot today!', style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.7))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(place.address, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface))),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.directions_walk, color: Theme.of(context).colorScheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(place.distance, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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

  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.wmv', '.flv', '.webm'];
    final lowerUrl = url.toLowerCase();

    for (String ext in videoExtensions) {
      if (lowerUrl.contains(ext)) return true;
    }

    return url.contains('cloudinary.com') && url.contains('video/');
  }

  String _getCloudinaryThumbnail(String videoUrl) {
    if (videoUrl.contains('cloudinary.com')) {
      return videoUrl.replaceAll(
          '/video/upload/',
          '/video/upload/so_0,h_120,w_100,c_fill,f_jpg/'
      );
    }
    return videoUrl;
  }

  void _showDeleteDialog(BuildContext context, Review review, Place place) {
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
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _reviews.removeWhere((r) => r.userId == review.userId);
              });

              try {
                // Delete dari Firestore di background
                await FirebaseFirestore.instance
                    .collection('places')
                    .doc(place.id)
                    .collection('reviews')
                    .where('userId', isEqualTo: review.userId)
                    .get()
                    .then((snapshot) async {
                  for (var doc in snapshot.docs) {
                    await doc.reference.delete();
                  }
                });

                if (mounted) {
                  ErrorHandler.showSuccessSnackBar(context, 'Review deleted successfully');
                }
              } catch (e) {
                // Jika gagal, restore review ke UI dan reload
                if (mounted) {
                  _reviewsLoaded = false;
                  _loadReviews();
                  ErrorHandler.showErrorSnackBar(context, 'Failed to delete review');
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMediaDialog(BuildContext context, List<String> mediaList, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: MediaViewerDialog(
          mediaList: mediaList,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
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

class MediaViewerDialog extends StatefulWidget {
  final List<String> mediaList;
  final int initialIndex;

  const MediaViewerDialog({
    Key? key,
    required this.mediaList,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<MediaViewerDialog> createState() => _MediaViewerDialogState();
}

class _MediaViewerDialogState extends State<MediaViewerDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isVideo(String url) {
    return url.toLowerCase().contains('.mp4') ||
        url.toLowerCase().contains('.mov') ||
        url.toLowerCase().contains('.avi') ||
        url.toLowerCase().contains('video');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Media content
          PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaList.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final mediaUrl = widget.mediaList[index];
              final isVideo = _isVideo(mediaUrl);

              return Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: isVideo ?
                  // Video player placeholder - bisa diganti dengan video player widget
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_circle_filled,
                            color: Colors.white,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tap to play video',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ) :
                  // Image viewer
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      mediaUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          color: Colors.black26,
                          child: const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 48,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Failed to load image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Page indicator
          if (widget.mediaList.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.mediaList.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentIndex
                          ? Colors.white
                          : Colors.white54,
                    ),
                  ),
                ),
              ),
            ),

          // Navigation arrows (untuk desktop/tablet)
          if (widget.mediaList.length > 1) ...[
            // Previous button
            if (_currentIndex > 0)
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),

            // Next button
            if (_currentIndex < widget.mediaList.length - 1)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}