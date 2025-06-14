import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/place_model.dart';
import '../service/place_service.dart';
import 'package:geolocator/geolocator.dart';
import '../service/user_position_service.dart';
import '../service/distance_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

enum AuthStatus { authenticated, unauthenticated, loading }
enum PlaceFilter { mostViewed, nearby, latest }

AuthStatus _authStatus = AuthStatus.unauthenticated;
User? _currentUser;
String? _authError;

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

  // Review state
  final Map<String, List<Review>> _reviews = {};

  // Theme state
  bool _isDarkMode = false;

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

  // Review Getters
  Map<String, List<Review>> get reviews => _reviews;

  // Theme Getters
  bool get isDarkMode => _isDarkMode;

  // Authentication methods
  Future<void> signIn(String email, String password) async {
    _authStatus = AuthStatus.loading;
    _authError = null;
    notifyListeners();

    try {
      final credential = await fb_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;
      await fbUser?.reload();
      final refreshedUser = fb_auth.FirebaseAuth.instance.currentUser;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(fbUser!.uid)
          .get();

      final data = userDoc.data();

      _currentUser = User(
        id: fbUser.uid,
        name: fbUser.displayName ?? '',
        email: fbUser.email ?? '',
        profileImageUrl: data?['profileImageUrl'] ?? 'https://i.pravatar.cc/100',
        createdAt: DateTime.now(),
      );

      _authStatus = AuthStatus.authenticated;
      _favoriteIds = [];
      _recentPlaces = [];
    } on fb_auth.FirebaseAuthException catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      _authError = e.message;
    } catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      _authError = e.toString();
      print(e);
    }

    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    _authStatus = AuthStatus.loading;
    _authError = null;
    notifyListeners();

    try {
      final credential = await fb_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await credential.user?.updateDisplayName(name);
      // await credential.user?.reload();
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;

      _currentUser = User(
        id: fbUser?.uid ?? '',
        name: fbUser?.displayName ?? name,
        email: fbUser?.email ?? email,
        profileImageUrl: 'https://i.pravatar.cc/100',
        createdAt: DateTime.now(),
      );

      _authStatus = AuthStatus.authenticated;
      _favoriteIds = [];
      _recentPlaces = [];
    } on fb_auth.FirebaseAuthException catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      _authError = e.message;
    } catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      _authError = e.toString();
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

    List<Place> results;

    if (query.isEmpty) {
      results = List<Place>.from(_places);
    } else {
      results = _places.where((place) {
        final lowerQuery = query.toLowerCase();
        return place.title.toLowerCase().contains(lowerQuery) ||
            place.address.toLowerCase().contains(lowerQuery) ||
            place.label.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    if (_searchFilters.hasActiveFilters) {
      results = _applyAdvancedFilters(results);
      _isAdvancedSearchActive = true;
    } else {
      _isAdvancedSearchActive = false;
    }

    _searchResults = results;
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

      // Price filter (extract number from price string like "Rp.40k")
      String priceStr = place.price.replaceAll(RegExp(r'[^0-9]'), '');
      int priceRaw = int.tryParse(priceStr) ?? 0;

      int price = priceRaw > 1000 ? (priceRaw / 1000).round() : priceRaw;

      if (_searchFilters.minPrice != null && price < _searchFilters.minPrice!) {
        return false;
      }
      if (_searchFilters.maxPrice != null && price > _searchFilters.maxPrice!) {
        return false;
      }

      // Distance filter - perbaikan parsing distance
      String distanceStr = place.distance.replaceAll(RegExp(r'[^0-9.]'), '');
      double distance = double.tryParse(distanceStr) ?? 0;

      if (_searchFilters.maxDistance != null && distance > _searchFilters.maxDistance!) {
        return false;
      }

      // Label filter
      if (_searchFilters.labels.isNotEmpty) {
        bool hasMatchingLabel = _searchFilters.labels.any((filterLabel) =>
        place.label.toLowerCase() == filterLabel.toLowerCase());
        if (!hasMatchingLabel) {
          return false;
        }
      }

      // Amenities filter
      if (_searchFilters.amenities.isNotEmpty) {
        bool allAmenitiesExist = _searchFilters.amenities.every((filterAmenity) =>
            place.amenities.any((placeAmenity) =>
            placeAmenity.toLowerCase() == filterAmenity.toLowerCase()));
        if (!allAmenitiesExist) {
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
    searchPlaces(_searchQuery);
    notifyListeners();
  }

  void clearAdvancedSearch() {
    _searchFilters = SearchFilters();
    _isAdvancedSearchActive = false;
    searchPlaces(_searchQuery);
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
  Future<String?> uploadImageToCloudinary(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);

    if (picked == null) return null;

    final file = File(picked.path);

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/djj9ofual/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = 'NongkiYuk'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = json.decode(resStr);
      return data['secure_url'];
    } else {
      print('Error uploading to Cloudinary: $resStr');
      return null;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? password,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;

    try {
      final fbUser = fb_auth.FirebaseAuth.instance.currentUser;

      if (name != null) {
        await fbUser?.updateDisplayName(name);
      }

      if (password != null && password.isNotEmpty) {
        await fbUser?.updatePassword(password);
      }

      if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
        await fbUser?.updatePhotoURL(profileImageUrl);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.id)
            .set({
          'profileImageUrl': profileImageUrl,
        }, SetOptions(merge: true));
      }

      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
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

  // Review methods
  void addReview(String placeId, Review review) {
    if (_reviews[placeId] == null) {
      _reviews[placeId] = [];
    }
    _reviews[placeId]!.insert(0, review);
    notifyListeners();
  }

  void updateReview(String placeId, Review updatedReview) {
    if (_reviews[placeId] == null) return;
    
    final index = _reviews[placeId]!.indexWhere((review) => review.id == updatedReview.id);
    if (index != -1) {
      _reviews[placeId]![index] = updatedReview;
      notifyListeners();
    }
  }

  void deleteReview(String placeId, String reviewId) {
    if (_reviews[placeId] == null) return;
    
    _reviews[placeId]!.removeWhere((review) => review.id == reviewId);
    notifyListeners();
  }

  List<Review> getReviews(String placeId) {
    return _reviews[placeId] ?? [];
  }

  // Theme methods
  void setAuthStatus(AuthStatus status) {
    _authStatus = status;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}