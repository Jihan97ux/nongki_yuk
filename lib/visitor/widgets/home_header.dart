import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

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
                      // TODO: Navigate to profile page
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

          // Search Field
          Consumer<AppState>(
            builder: (context, appState, child) {
              return TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchPlaces,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: appState.searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                      : const Icon(Icons.tune),
                ),
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
              );
            },
          ),
        ],
      ),
    );
  }
}