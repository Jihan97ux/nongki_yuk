import 'package:flutter/material.dart';
import 'package:nongki_yuk/app_export.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).loadPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        if (appState.searchQuery.isNotEmpty ||
            appState.isAdvancedSearchActive) {
          return _buildSearchResults(appState);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.popularPlaces,
                    style: AppTextStyles.heading4.copyWith(
                      color: Theme
                          .of(context)
                          .colorScheme
                          .onBackground,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: Navigate to all places page
                    },
                    child: Text(
                      AppStrings.viewAll,
                      style: AppTextStyles.body1.copyWith(
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimensions.paddingM),

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
          color: selected
              ? Theme
              .of(context)
              .colorScheme
              .primary
              : Theme
              .of(context)
              .cardColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          border: !selected
              ? Border.all(color: Theme
              .of(context)
              .dividerColor)
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.subtitle1.copyWith(
            color: selected
                ? Theme
                .of(context)
                .colorScheme
                .onPrimary
                : Theme
                .of(context)
                .colorScheme
                .onSurface,
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

    List<Place> placesToShow;

    if (appState.searchQuery.isNotEmpty || appState.isAdvancedSearchActive) {
      placesToShow = appState.searchResults;
    } else {
      placesToShow = appState.filteredPlaces;
    }

    if (placesToShow.isEmpty) {
      String message = 'No places found';
      if (appState.searchQuery.isNotEmpty) {
        message = 'No places found for "${appState.searchQuery}"';
      } else if (appState.isAdvancedSearchActive) {
        message = 'No places match your filters';
      }

      return Expanded(
        child: EmptyStateWidget(
          message: message,
          icon: Icons.location_off,
        ),
      );
    }

    return ContentCard(places: placesToShow);
  }

  Widget _buildSearchResults(AppState appState) {
    if (appState.searchResults.isEmpty) {
      String message = 'No places found';
      if (appState.searchQuery.isNotEmpty) {
        message = 'No places found for "${appState.searchQuery}"';
      } else if (appState.isAdvancedSearchActive) {
        message = 'No places match your filters';
      }

      return Expanded(
        child: EmptyStateWidget(
          message: message,
          icon: Icons.search_off,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions
              .paddingL),
          child: Row(
            children: [
              Text(
                appState.searchQuery.isNotEmpty
                    ? 'Search Results (${appState.searchResults.length})'
                    : 'Filtered Results (${appState.searchResults.length})',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
        ),
        ContentCard(places: appState.searchResults),
      ],
    );
  }
}