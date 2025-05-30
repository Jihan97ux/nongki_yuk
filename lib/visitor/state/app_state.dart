import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/place_model.dart';
import '../service/place_service.dart';
import 'package:geolocator/geolocator.dart';
import '../service/user_position_service.dart';
import '../service/distance_service.dart';

enum AuthStatus { authenticated, unauthenticated, loading }
enum PlaceFilter { mostViewed, nearby, latest }

// Advanced Search Filters
class SearchFilters {
  final double? minRating;
  final double? maxRating;
  final int? minPrice;
  final int? maxPrice;
  final List<String> labels;
  final List<String> amenities;
  final double? maxDistance;

  SearchFilters({
    this.minRating,
    this.maxRating,
    this.minPrice,
    this.maxPrice,
    this.labels = const [],
    this.amenities = const [],
    this.maxDistance,
  });

  SearchFilters copyWith({
    double? minRating,
    double? maxRating,
    int? minPrice,
    int? maxPrice,
    List<String>? labels,
    List<String>? amenities,
    double? maxDistance,
  }) {
    return SearchFilters(
      minRating: minRating ?? this.minRating,
      maxRating: maxRating ?? this.maxRating,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      labels: labels ?? this.labels,
      amenities: amenities ?? this.amenities,
      maxDistance: maxDistance ?? this.maxDistance,
    );
  }

  bool get hasActiveFilters {
    return minRating != null ||
        maxRating != null ||
        minPrice != null ||
        maxPrice != null ||
        labels.isNotEmpty ||
        amenities.isNotEmpty ||
        maxDistance != null;
  }

  SearchFilters clear() {
    return SearchFilters();
  }
}

// Recent Place Entry
class RecentPlace {
  final Place place;
  final DateTime visitedAt;

  RecentPlace({
    required this.place,
    required this.visitedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'place': place.toJson(),
      'visitedAt': visitedAt.toIso8601String(),
    };
  }

  factory RecentPlace.fromJson(Map<String, dynamic> json) {
    return RecentPlace(
      place: Place.fromJson(json['place']),
      visitedAt: DateTime.parse(json['visitedAt']),
    );
  }
}

class AppState extends ChangeNotifier {
  // Authentication state
  AuthStatus _authStatus = AuthStatus.unauthenticated;
  User? _currentUser;
  String? _authError;

  // Places state
  List<Place> _places = [];
  List<Place> _filteredPlaces = [];
  List<Place> _searchResults = [];
  PlaceFilter _selectedFilter = PlaceFilter.mostViewed;
  String _searchQuery = '';
  bool _isLoadingPlaces = false;
  String? _placesError;

  // Advanced Search
  SearchFilters _searchFilters = SearchFilters();
  bool _isAdvancedSearchActive = false;

  // Recent Places
  List<RecentPlace> _recentPlaces = [];

  // Bottom navigation state
  int _currentBottomNavIndex = 0;

  // Favorites state
  List<String> _favoriteIds = [];

  // Getters
  AuthStatus get authStatus => _authStatus;
  User? get currentUser => _currentUser;
  String? get authError => _authError;

  List<Place> get places => _places;
  List<Place> get filteredPlaces => _filteredPlaces;
  List<Place> get searchResults => _searchResults;
  PlaceFilter get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get isLoadingPlaces => _isLoadingPlaces;
  String? get placesError => _placesError;

  // Advanced Search Getters
  SearchFilters get searchFilters => _searchFilters;
  bool get isAdvancedSearchActive => _isAdvancedSearchActive;

  // Recent Places Getters
  List<RecentPlace> get recentPlaces => _recentPlaces;
  List<Place> get recentPlacesList => _recentPlaces.map((e) => e.place).toList();

  int get currentBottomNavIndex => _currentBottomNavIndex;
  List<String> get favoriteIds => _favoriteIds;
  List<Place> get favoritePlaces => _places.where((place) => _favoriteIds.contains(place.id)).toList();

  // Authentication methods
  Future<void> signIn(String email, String password) async {
    _authStatus = AuthStatus.loading;
    _authError = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock authentication - in real app, call your API
      if (email.isNotEmpty && password.length >= 6) {
        _currentUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: email.split('@')[0].toUpperCase(),
          email: email,
          profileImageUrl: 'https://i.pravatar.cc/100',
          createdAt: DateTime.now(),
        );
        _authStatus = AuthStatus.authenticated;
        _favoriteIds = []; // Reset favorites on new login
        _recentPlaces = []; // Reset recent places on new login
      } else {
        throw Exception('Invalid email or password');
      }
    } catch (e) {
      _authError = e.toString();
      _authStatus = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    _authStatus = AuthStatus.loading;
    _authError = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock sign up - in real app, call your API
      _currentUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        profileImageUrl: 'https://i.pravatar.cc/100',
        createdAt: DateTime.now(),
      );
      _authStatus = AuthStatus.authenticated;
      _favoriteIds = [];
      _recentPlaces = [];
    } catch (e) {
      _authError = e.toString();
      _authStatus = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  void signOut() {
    _currentUser = null;
    _authStatus = AuthStatus.unauthenticated;
    _favoriteIds = [];
    _recentPlaces = [];
    _currentBottomNavIndex = 0;
    clearSearch();
    clearAdvancedSearch();
    notifyListeners();
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  // Places methods
  Future<void> loadPlaces() async {
    if (_isLoadingPlaces) return;
    _isLoadingPlaces = true;
    _placesError = null;
    notifyListeners();

    try {
      // Simulate API call
      print('Getting user position...');
      final Position position = await UserPositionService.getCurrentPosition();

      print('Fetching cafes from Firebase...');
      final rawPlaces = await PlaceService.fetchCafesFromFirebase();

      _places = [];
      for (final place in rawPlaces) {
        print('Calculating distances...');
        final distance = await DistanceService.getDistance(
          userLat: position.latitude,
          userLng: position.longitude,
          placeLat: place.location.lat,
          placeLng: place.location.lng,
        );
        _places.add(place.copyWith(distance: distance));
      }
      _filterPlaces();
    } catch (e, stackTrace) {
      print('Error in loadPlaces: $e');
      print(stackTrace);
      _placesError = e.toString();
    }

    _isLoadingPlaces = false;
    notifyListeners();
  }

  void setFilter(PlaceFilter filter) {
    _selectedFilter = filter;
    _filterPlaces();
    notifyListeners();
  }

  void _filterPlaces() {
    switch (_selectedFilter) {
      case PlaceFilter.mostViewed:
        _filteredPlaces = List<Place>.from(_places)..sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case PlaceFilter.nearby:
        _filteredPlaces = List<Place>.from(_places)..sort((a, b) {
          double distanceA = double.tryParse(a.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          double distanceB = double.tryParse(b.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          return distanceA.compareTo(distanceB);
        });
        break;
      case PlaceFilter.latest:
        final reversedList = _places.reversed.toList();
        _filteredPlaces = List<Place>.from(reversedList);
        break;
    }
  }

  void searchPlaces(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _searchResults = [];
      _isAdvancedSearchActive = false;
    } else {
      List<Place> results = _places.where((place) {
        return place.title.toLowerCase().contains(query.toLowerCase()) ||
            place.address.toLowerCase().contains(query.toLowerCase()) ||
            place.label.toLowerCase().contains(query.toLowerCase());
      }).toList();

      // Apply advanced filters if active
      if (_searchFilters.hasActiveFilters) {
        results = _applyAdvancedFilters(results);
        _isAdvancedSearchActive = true;
      }

      _searchResults = results;
    }

    notifyListeners();
  }

  List<Place> _applyAdvancedFilters(List<Place> places) {
    return places.where((place) {
      // Rating filter
      if (_searchFilters.minRating != null && place.rating < _searchFilters.minRating!) {
        return false;
      }
      if (_searchFilters.maxRating != null && place.rating > _searchFilters.maxRating!) {
        return false;
      }

      // Price filter (extract number from price string like "$40")
      int price = int.tryParse(place.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (_searchFilters.minPrice != null && price < _searchFilters.minPrice!) {
        return false;
      }
      if (_searchFilters.maxPrice != null && price > _searchFilters.maxPrice!) {
        return false;
      }

      // Label filter
      if (_searchFilters.labels.isNotEmpty &&
          !_searchFilters.labels.contains(place.label.toLowerCase())) {
        return false;
      }

      // Amenities filter
      if (_searchFilters.amenities.isNotEmpty) {
        bool hasAmenity = _searchFilters.amenities.any((amenity) =>
            place.amenities.any((placeAmenity) =>
                placeAmenity.toLowerCase().contains(amenity.toLowerCase())));
        if (!hasAmenity) return false;
      }

      // Distance filter
      if (_searchFilters.maxDistance != null) {
        double distance = double.tryParse(place.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        if (distance > _searchFilters.maxDistance!) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _isAdvancedSearchActive = false;
    notifyListeners();
  }

  // Advanced Search Methods
  void setAdvancedFilters(SearchFilters filters) {
    _searchFilters = filters;
    if (_searchQuery.isNotEmpty) {
      searchPlaces(_searchQuery); // Re-apply search with new filters
    }
    notifyListeners();
  }

  void clearAdvancedSearch() {
    _searchFilters = SearchFilters();
    _isAdvancedSearchActive = false;
    if (_searchQuery.isNotEmpty) {
      searchPlaces(_searchQuery); // Re-apply search without filters
    }
    notifyListeners();
  }

  // Recent Places Methods
  void addToRecentPlaces(Place place) {
    // Remove if already exists
    _recentPlaces.removeWhere((recent) => recent.place.id == place.id);

    // Add to beginning
    _recentPlaces.insert(0, RecentPlace(
      place: place,
      visitedAt: DateTime.now(),
    ));

    // Keep only last 20 recent places
    if (_recentPlaces.length > 20) {
      _recentPlaces = _recentPlaces.take(20).toList();
    }

    notifyListeners();
  }

  void clearRecentPlaces() {
    _recentPlaces.clear();
    notifyListeners();
  }

  // Navigation methods
  void setBottomNavIndex(int index) {
    _currentBottomNavIndex = index;
    notifyListeners();
  }

  // Favorites methods
  void toggleFavorite(String placeId) {
    if (_favoriteIds.contains(placeId)) {
      _favoriteIds.remove(placeId);
    } else {
      _favoriteIds.add(placeId);
    }
    notifyListeners();
  }

  bool isFavorite(String placeId) {
    return _favoriteIds.contains(placeId);
  }

  // Profile methods
  Future<void> updateProfile({
    String? name,
    String? email,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        email: email ?? _currentUser!.email,
        profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
      );

      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update profile');
    }
  }

  // Utility methods
  Place? getPlaceById(String id) {
    try {
      return _places.firstWhere((place) => place.id == id);
    } catch (e) {
      return null;
    }
  }

  void refreshPlaces() {
    loadPlaces();
  }
}