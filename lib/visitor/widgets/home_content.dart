import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import 'content_card.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    // Load places when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).loadPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // Show search results if user is searching
        if (appState.searchQuery.isNotEmpty) {
          return _buildSearchResults(appState);
        }

        // Show main content
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Popular places and View all
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.popularPlaces,
                    style: AppTextStyles.heading4,
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all places page
                    },
                    child: Text(
                      AppStrings.viewAll,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingM,
                vertical: AppDimensions.paddingS,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab(
                      AppStrings.mostViewed,
                      PlaceFilter.mostViewed,
                      appState.selectedFilter == PlaceFilter.mostViewed,
                    ),
                    _buildTab(
                      AppStrings.nearby,
                      PlaceFilter.nearby,
                      appState.selectedFilter == PlaceFilter.nearby,
                    ),
                    _buildTab(
                      AppStrings.latest,
                      PlaceFilter.latest,
                      appState.selectedFilter == PlaceFilter.latest,
                    ),
                  ],
                ),
              ),
            ),

            // Content
            _buildMainContent(appState),
          ],
        );
      },
    );
  }

  Widget _buildTab(String label, PlaceFilter filter, bool selected) {
    return GestureDetector(
      onTap: () {
        Provider.of<AppState>(context, listen: false).setFilter(filter);
      },
      child: Container(
        margin: const EdgeInsets.only(right: AppDimensions.paddingM),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS + 6,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: !selected ? Border.all(color: Colors.grey.shade300) : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.subtitle1.copyWith(
            color: selected ? AppColors.textWhite : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(AppState appState) {
    if (appState.isLoadingPlaces) {
      return const Expanded(
        child: LoadingWidget(message: 'Loading places...'),
      );
    }

    if (appState.placesError != null) {
      return Expanded(
        child: CustomErrorWidget(
          message: appState.placesError!,
          onRetry: () => appState.refreshPlaces(),
        ),
      );
    }

    if (appState.filteredPlaces.isEmpty) {
      return const Expanded(
        child: EmptyStateWidget(
          message: 'No places found',
          icon: Icons.location_off,
        ),
      );
    }

    return ContentCard(places: appState.filteredPlaces);
  }

  Widget _buildSearchResults(AppState appState) {
    if (appState.searchResults.isEmpty) {
      return Expanded(
        child: EmptyStateWidget(
          message: 'No places found for "${appState.searchQuery}"',
          icon: Icons.search_off,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
          child: Text(
            'Search Results (${appState.searchResults.length})',
            style: AppTextStyles.heading4,
          ),
        ),
        const SizedBox(height: AppDimensions.paddingM),
        ContentCard(places: appState.searchResults),
      ],
    );
  }
}