import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';
import '../widgets/filter_modal.dart';

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

  void _showFilter() {
    FilterModal.show(context);
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
                              color: Theme.of(context).colorScheme.onBackground,
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
                            color: Theme.of(context).textTheme.bodySmall?.color ?? AppColors.textSecondary,
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
                      // Navigate to profile page when profile image is tapped
                      Navigator.pushNamed(context, AppRoutes.profile);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: AppDimensions.avatarM / 2,
                        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? AppColors.customPurpleDark,
                        backgroundImage: user?.profileImageUrl != null
                            ? NetworkImage(user!.profileImageUrl!)
                            : null,
                        child: user?.profileImageUrl == null
                            ? Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : 'U',
                          style: AppTextStyles.subtitle1.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                            : null,
                      ),
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
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            onPressed: _showFilter,
                            tooltip: 'Filter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  onChanged: _onSearchChanged,
                  textInputAction: TextInputAction.search,
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                  },
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
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.filter_alt,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppDimensions.paddingXS),
                          Text(
                            'Filter active',
                            style: AppTextStyles.body2.copyWith(
                              color: Theme.of(context).colorScheme.primary,
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
                          'Filter cleared',
                        );
                      },
                      child: Text(
                        'Clear',
                        style: AppTextStyles.body2.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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