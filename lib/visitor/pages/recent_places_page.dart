import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

class RecentPlacesPage extends StatefulWidget {
  const RecentPlacesPage({super.key});

  @override
  State<RecentPlacesPage> createState() => _RecentPlacesPageState();
}

class _RecentPlacesPageState extends State<RecentPlacesPage> with TickerProviderStateMixin {
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            final recentPlaces = appState.recentPlaces;

            return Column(
              children: [
                // Header
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFB39DDB), // Light purple
                          Color(0xFF7B1FA2), // Dark purple
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(AppDimensions.radiusXL),
                        bottomRight: Radius.circular(AppDimensions.radiusXL),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingM),
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.paddingS),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                              ),
                              child: const Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.paddingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Recent Places',
                                    style: AppTextStyles.heading3.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Places you\'ve visited recently',
                                    style: AppTextStyles.body1.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (recentPlaces.isNotEmpty)
                              IconButton(
                                onPressed: () => _showClearDialog(context),
                                icon: const Icon(
                                  Icons.clear_all,
                                  color: Colors.white,
                                ),
                                tooltip: 'Clear All',
                              ),
                          ],
                        ),

                        if (recentPlaces.isNotEmpty) ...[
                          const SizedBox(height: AppDimensions.paddingM),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: AppDimensions.paddingS,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: AppDimensions.paddingXS),
                                Text(
                                  '${recentPlaces.length} places visited',
                                  style: AppTextStyles.body2.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Content
                Expanded(
                  child: recentPlaces.isEmpty
                      ? _buildEmptyState()
                      : _buildRecentPlacesList(recentPlaces),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingXL),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.explore_off,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                Text(
                  'No Recent Places Yet',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                Text(
                  'Start exploring and visiting places!\nYour recent adventures will appear here.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.explore),
                  label: const Text('Explore Places'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXL,
                      vertical: AppDimensions.paddingM,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPlacesList(List<RecentPlace> recentPlaces) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        itemCount: recentPlaces.length,
        itemBuilder: (context, index) {
          final recentPlace = recentPlaces[index];
          final place = recentPlace.place;

          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0, 0.5 + (index * 0.1)),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                index * 0.1,
                1.0,
                curve: Curves.easeOutCubic,
              ),
            )),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppDimensions.paddingM),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/review',
                      arguments: place,
                    );
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Row(
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                          child: NetworkImageWithError(
                            imageUrl: place.imageUrl,
                            width: 80,
                            height: 80,
                          ),
                        ),

                        const SizedBox(width: AppDimensions.paddingM),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                place.title,
                                style: AppTextStyles.subtitle1.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: AppDimensions.paddingXS),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: AppDimensions.paddingXS),
                                  Expanded(
                                    child: Text(
                                      place.address,
                                      style: AppTextStyles.body2.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.paddingXS),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppDimensions.paddingS,
                                      vertical: AppDimensions.paddingXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getLabelColor(place.label).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                                    ),
                                    child: Text(
                                      place.label,
                                      style: AppTextStyles.caption.copyWith(
                                        color: _getLabelColor(place.label),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.paddingS),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: AppColors.accent,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        place.rating.toString(),
                                        style: AppTextStyles.body2.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.paddingXS),
                              Text(
                                'Visited ${_formatTimeAgo(recentPlace.visitedAt)}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Price and Arrow
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${place.price}',
                              style: AppTextStyles.subtitle1.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingM),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
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
                Icons.warning_amber,
                color: Colors.red,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.paddingM),
            const Text('Clear Recent Places'),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear all recent places? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final appState = Provider.of<AppState>(context, listen: false);
              appState.clearRecentPlaces();
              Navigator.pop(context);
              ErrorHandler.showSuccessSnackBar(
                context,
                'Recent places cleared successfully',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
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

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}