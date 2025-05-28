import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

class AdvancedSearchModal extends StatefulWidget {
  const AdvancedSearchModal({super.key});

  @override
  State<AdvancedSearchModal> createState() => _AdvancedSearchModalState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvancedSearchModal(),
    );
  }
}

class _AdvancedSearchModalState extends State<AdvancedSearchModal> {
  late SearchFilters _tempFilters;
  RangeValues _ratingRange = const RangeValues(0, 5);
  RangeValues _priceRange = const RangeValues(0, 100);
  double _maxDistance = 50;
  List<String> _selectedLabels = [];
  List<String> _selectedAmenities = [];

  final List<String> _availableLabels = ['crowded', 'comfy'];
  final List<String> _availableAmenities = [
    'WiFi', 'AC', 'Outdoor Seating', 'Parking', 'Cozy Interior',
    'Books', 'Garden View', 'Pet Friendly'
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _tempFilters = appState.searchFilters;
    _initializeFilters();
  }

  void _initializeFilters() {
    _ratingRange = RangeValues(
      _tempFilters.minRating ?? 0,
      _tempFilters.maxRating ?? 5,
    );
    _priceRange = RangeValues(
      (_tempFilters.minPrice ?? 0).toDouble(),
      (_tempFilters.maxPrice ?? 100).toDouble(),
    );
    _maxDistance = _tempFilters.maxDistance ?? 50;
    _selectedLabels = List.from(_tempFilters.labels);
    _selectedAmenities = List.from(_tempFilters.amenities);
  }

  void _applyFilters() {
    final newFilters = SearchFilters(
      minRating: _ratingRange.start == 0 ? null : _ratingRange.start,
      maxRating: _ratingRange.end == 5 ? null : _ratingRange.end,
      minPrice: _priceRange.start == 0 ? null : _priceRange.start.toInt(),
      maxPrice: _priceRange.end == 100 ? null : _priceRange.end.toInt(),
      maxDistance: _maxDistance == 50 ? null : _maxDistance,
      labels: _selectedLabels,
      amenities: _selectedAmenities,
    );

    final appState = Provider.of<AppState>(context, listen: false);
    appState.setAdvancedFilters(newFilters);

    Navigator.pop(context);

    if (newFilters.hasActiveFilters) {
      ErrorHandler.showSuccessSnackBar(
        context,
        'Advanced filters applied! 🎯',
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _ratingRange = const RangeValues(0, 5);
      _priceRange = const RangeValues(0, 100);
      _maxDistance = 50;
      _selectedLabels.clear();
      _selectedAmenities.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXL),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: AppDimensions.paddingM),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingS),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB39DDB), Color(0xFF7B1FA2)],
                      ),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    ),
                    child: const Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  Text(
                    'Advanced Search',
                    style: AppTextStyles.heading4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _clearFilters,
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filters Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating Filter
                    _buildSectionTitle('Rating'),
                    _buildRatingFilter(),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Price Filter
                    _buildSectionTitle('Price Range'),
                    _buildPriceFilter(),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Distance Filter
                    _buildSectionTitle('Maximum Distance'),
                    _buildDistanceFilter(),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Label Filter
                    _buildSectionTitle('Atmosphere'),
                    _buildLabelFilter(),

                    const SizedBox(height: AppDimensions.paddingXL),

                    // Amenities Filter
                    _buildSectionTitle('Amenities'),
                    _buildAmenitiesFilter(),

                    const SizedBox(height: AppDimensions.paddingXL),
                  ],
                ),
              ),
            ),

            // Apply Button
            Container(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Filter Summary
                  if (_hasActiveFilters()) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Filters:',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingXS),
                          Text(
                            _getFilterSummary(),
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                  ],

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeightLarge,
                    child: ElevatedButton.icon(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                      ),
                      icon: const Icon(Icons.search),
                      label: Text(
                        'Apply Filters',
                        style: AppTextStyles.button,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
      child: Text(
        title,
        style: AppTextStyles.subtitle1.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRatingFilter() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_ratingRange.start.toStringAsFixed(1)} ⭐',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_ratingRange.end.toStringAsFixed(1)} ⭐',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _ratingRange,
            min: 0,
            max: 5,
            divisions: 10,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.3),
            onChanged: (values) {
              setState(() {
                _ratingRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${_priceRange.start.toInt()}',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${_priceRange.end.toInt()}',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 100,
            divisions: 10,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.accent.withOpacity(0.3),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Max Distance',
                style: AppTextStyles.body1,
              ),
              Text(
                '${_maxDistance.toInt()} km',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxDistance,
            min: 1,
            max: 50,
            divisions: 49,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.3),
            onChanged: (value) {
              setState(() {
                _maxDistance = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLabelFilter() {
    return Wrap(
      spacing: AppDimensions.paddingS,
      runSpacing: AppDimensions.paddingS,
      children: _availableLabels.map((label) {
        final isSelected = _selectedLabels.contains(label);
        return FilterChip(
          label: Text(
            label.toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.primary,
          backgroundColor: Colors.grey.shade100,
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedLabels.add(label);
              } else {
                _selectedLabels.remove(label);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildAmenitiesFilter() {
    return Wrap(
      spacing: AppDimensions.paddingS,
      runSpacing: AppDimensions.paddingS,
      children: _availableAmenities.map((amenity) {
        final isSelected = _selectedAmenities.contains(amenity);
        return FilterChip(
          label: Text(
            amenity,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          selectedColor: AppColors.accent,
          backgroundColor: Colors.grey.shade100,
          checkmarkColor: Colors.black,
          side: BorderSide(
            color: isSelected ? AppColors.accent : Colors.grey.shade300,
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedAmenities.add(amenity);
              } else {
                _selectedAmenities.remove(amenity);
              }
            });
          },
        );
      }).toList(),
    );
  }

  bool _hasActiveFilters() {
    return _ratingRange != const RangeValues(0, 5) ||
        _priceRange != const RangeValues(0, 100) ||
        _maxDistance != 50 ||
        _selectedLabels.isNotEmpty ||
        _selectedAmenities.isNotEmpty;
  }

  String _getFilterSummary() {
    List<String> summary = [];

    if (_ratingRange != const RangeValues(0, 5)) {
      summary.add('Rating: ${_ratingRange.start.toStringAsFixed(1)}-${_ratingRange.end.toStringAsFixed(1)}');
    }

    if (_priceRange != const RangeValues(0, 100)) {
      summary.add('Price: \$${_priceRange.start.toInt()}-\$${_priceRange.end.toInt()}');
    }

    if (_maxDistance != 50) {
      summary.add('Distance: <${_maxDistance.toInt()}km');
    }

    if (_selectedLabels.isNotEmpty) {
      summary.add('Atmosphere: ${_selectedLabels.join(', ')}');
    }

    if (_selectedAmenities.isNotEmpty) {
      summary.add('Amenities: ${_selectedAmenities.take(2).join(', ')}${_selectedAmenities.length > 2 ? '...' : ''}');
    }

    return summary.join(' • ');
  }
}