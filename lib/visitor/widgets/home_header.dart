import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import '../widgets/advanced_search_modal.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    Provider.of<AppState>(context, listen: false).searchPlaces(query);
  }

  void _clearSearch() {
    _searchController.clear();
    Provider.of<AppState>(context, listen: false).clearSearch();
  }

  void _showAdvancedSearch() {
    AdvancedSearchModal.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Consumer<AppState>(
                  builder: (context, appState, child) {
                    final user = appState.currentUser;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Hai, ',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primary,
                            ),
                            children: [
                              TextSpan(
                                text: '${user?.name ?? 'User'} 👋',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          'Nongki dimana hari ini?',
                          style: AppTextStyles.subtitle2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.paddingM),
              Consumer<AppState>(
                builder: (context, appState, child) {
                  final user = appState.currentUser;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                    child: NetworkImageWithError(
                      imageUrl: user?.profileImageUrl ?? 'https://i.pravatar.cc/100',
                      width: AppDimensions.avatarM,
                      height: AppDimensions.avatarM,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusCircle),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.paddingL + AppDimensions.paddingS),

          // Search Field with Advanced Search Button
          Consumer<AppState>(
            builder: (context, appState, child) {
              return Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppStrings.searchPlaces,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Clear button when searching
                        if (appState.searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          ),

                        // Advanced search button
                        Container(
                          margin: const EdgeInsets.only(right: AppDimensions.paddingXS),
                          child: IconButton(
                            icon: Stack(
                              children: [
                                const Icon(Icons.tune),
                                // Active indicator
                                if (appState.searchFilters.hasActiveFilters)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onPressed: _showAdvancedSearch,
                            tooltip: 'Advanced Search',
                          ),
                        ),
                      ],
                    ),
                  ),
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                ),
              );
            },
          ),

          // Active filters indicator
          Consumer<AppState>(
            builder: (context, appState, child) {
              if (!appState.isAdvancedSearchActive) return const SizedBox();

              return Container(
                margin: const EdgeInsets.only(top: AppDimensions.paddingS),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingS,
                        vertical: AppDimensions.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_alt,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppDimensions.paddingXS),
                          Text(
                            'Advanced filters active',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingS),
                    GestureDetector(
                      onTap: () {
                        appState.clearAdvancedSearch();
                        ErrorHandler.showSuccessSnackBar(
                          context,
                          'Advanced filters cleared',
                        );
                      },
                      child: Text(
                        'Clear',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}