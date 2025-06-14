import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart'; // Pastikan ini ada dan berisi AppDimensions, AppColors, AppTextStyles
import '../utils/error_handler.dart'; // Pastikan ini ada dan berfungsi untuk snackbar

// Import model SearchFilters yang sudah dipindah ke file terpisah
import '../models/search_filters.dart'; // <--- PASTIKAN PATH INI BENAR

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
  // Gunakan _tempFilters untuk menyimpan perubahan sementara di UI
  // Sebelum di-apply ke AppState dan Firebase
  late SearchFilters _tempFilters;

  // Variables UI states, akan diinisialisasi dari _tempFilters
  late RangeValues _ratingRange;
  late RangeValues _priceRange;
  late double _maxDistance;
  late List<String> _selectedLabels;
  late List<String> _selectedAmenities;

  final List<String> _availableLabels = ['crowded', 'comfy'];
  final List<String> _availableAmenities = [
    'WiFi', 'AC', 'Outdoor Seating', 'Parking', 'Cozy Interior',
    'Books', 'Garden View', 'Pet Friendly'
  ];

  @override
  void initState() {
    super.initState();
    // Ambil filter saat ini dari AppState sebagai nilai awal untuk UI
    final appState = Provider.of<AppState>(context, listen: false);
    // Gunakan copyWith() agar perubahan di _tempFilters tidak langsung memengaruhi objek di AppState
    _tempFilters = appState.searchFilters.copyWith();
    _initializeUIFilters();
  }

  // Helper method untuk menginisialisasi state UI dari _tempFilters
  void _initializeUIFilters() {
    _ratingRange = RangeValues(
      _tempFilters.minRating ?? 0,
      _tempFilters.maxRating ?? 5,
    );
    _priceRange = RangeValues(
      (_tempFilters.minPrice ?? 0).toDouble(),
      (_tempFilters.maxPrice ?? 100).toDouble(), // Asumsi default max 100
    );
    _maxDistance = _tempFilters.maxDistance ?? 50; // Asumsi default max 50km
    _selectedLabels = List.from(_tempFilters.labels);
    _selectedAmenities = List.from(_tempFilters.amenities);
  }

  void _applyFilters() async { // Ubah menjadi async
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
    try {
      // Panggil setAdvancedFilters di AppState, yang akan menyimpan ke Firebase
      await appState.setAdvancedFilters(newFilters);
      Navigator.pop(context); // Tutup modal setelah filter diterapkan dan disimpan

      if (newFilters.hasActiveFilters) {
        ErrorHandler.showSuccessSnackBar(
          context,
          'Advanced filters applied! 🎯',
        );
      }
    } catch (e) {
      ErrorHandler.showErrorSnackBar(context, 'Failed to apply filters: $e');
    }
  }

  void _clearFilters() async { // Ubah menjadi async
    // Reset state UI ke nilai default
    setState(() {
      _ratingRange = const RangeValues(0, 5);
      _priceRange = const RangeValues(0, 100);
      _maxDistance = 50;
      _selectedLabels.clear();
      _selectedAmenities.clear();
    });

    final appState = Provider.of<AppState>(context, listen: false);
    try {
      // Panggil clearAdvancedSearch di AppState, yang akan menyimpan filter default ke Firebase
      await appState.clearAdvancedSearch();
      ErrorHandler.showInfoSnackBar(context, 'All filters cleared.');
    } catch (e) {
      ErrorHandler.showErrorSnackBar(context, 'Failed to clear filters: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer untuk mendengarkan perubahan pada `searchFilters` di `AppState`
    // Ini berguna jika ada perubahan filter dari tempat lain (misalnya, setelah user login dan filter dimuat dari Firebase)
    // Walaupun di modal ini kita menggunakan _tempFilters, Consumer bisa membantu re-render jika `searchFilters` di AppState berubah
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
                  // Menggunakan Consumer untuk mendapatkan hasActiveFilters dari _tempFilters
                  Consumer<AppState>( // Tambahkan Consumer di sini
                    builder: (context, appState, child) {
                      // Buat objek SearchFilters sementara dari state UI saat ini untuk mengecek hasActiveFilters
                      final currentUIFilters = SearchFilters(
                        minRating: _ratingRange.start == 0 ? null : _ratingRange.start,
                        maxRating: _ratingRange.end == 5 ? null : _ratingRange.end,
                        minPrice: _priceRange.start == 0 ? null : _priceRange.start.toInt(),
                        maxPrice: _priceRange.end == 100 ? null : _priceRange.end.toInt(),
                        maxDistance: _maxDistance == 50 ? null : _maxDistance,
                        labels: _selectedLabels,
                        amenities: _selectedAmenities,
                      );
                      
                      if (currentUIFilters.hasActiveFilters) { // Gunakan hasActiveFilters dari model SearchFilters
                        return Column(
                          children: [
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
                                    _getFilterSummary(), // Menggunakan _getFilterSummary dari state UI
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppDimensions.paddingM),
                          ],
                        );
                      }
                      return const SizedBox.shrink(); // Sembunyikan jika tidak ada filter aktif
                    },
                  ),


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
                // Contoh: Mengasumsikan 1 unit slider adalah 10000 Rupiah (sesuaikan dengan skala harga Anda)
                'Rp ${(_priceRange.start * 1000).toInt()}', 
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Rp ${(_priceRange.end * 1000).toInt()}', 
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 100, // Max price range, sesuaikan dengan rentang harga data Anda (e.g., 500 untuk 500k)
            divisions: 10, // Atau lebih banyak divisi untuk kontrol yang lebih halus
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
            max: 50, // Max distance, sesuaikan kebutuhan
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

  // Helper function to check if any filter is active based on current UI state
  bool _hasActiveFilters() {
    // Membuat objek SearchFilters sementara dari state UI saat ini
    final currentUIFilters = SearchFilters(
      minRating: _ratingRange.start == 0 ? null : _ratingRange.start,
      maxRating: _ratingRange.end == 5 ? null : _ratingRange.end,
      minPrice: _priceRange.start == 0 ? null : _priceRange.start.toInt(),
      maxPrice: _priceRange.end == 100 ? null : _priceRange.end.toInt(),
      maxDistance: _maxDistance == 50 ? null : _maxDistance,
      labels: _selectedLabels,
      amenities: _selectedAmenities,
    );
    return currentUIFilters.hasActiveFilters; // Menggunakan getter dari model
  }

  // Updated _getFilterSummary to reflect current UI state
  String _getFilterSummary() {
    List<String> summary = [];

    if (_ratingRange.start != 0 || _ratingRange.end != 5) {
      summary.add('Rating: ${_ratingRange.start.toStringAsFixed(1)}-${_ratingRange.end.toStringAsFixed(1)}');
    }

    if (_priceRange.start != 0 || _priceRange.end != 100) {
      // Menampilkan rentang harga yang disesuaikan
      summary.add('Price: Rp ${(_priceRange.start * 1000).toInt()}-Rp ${(_priceRange.end * 1000).toInt()}');
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