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
import 'package:awesome_notifications/awesome_notifications.dart';

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
  void setAdvancedSearchActive(bool value) {
    _isAdvancedSearchActive = value;
    notifyListeners();
  }

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

  String? _watchedLabel;
  String? _watchedPlaceId;
  bool _labelNotified = false;
  String? get watchedLabel => _watchedLabel;


  Future<void> trackLabelChange(String placeId, String label) async{
    _watchedPlaceId = placeId;
    _watchedLabel = label;
    _labelNotified = false;

    print('[DEBUG] Tracking label "$_watchedLabel" for place $_watchedPlaceId');

    final updatedPlace = await PlaceService.getPlaceById(placeId);
    if (updatedPlace != null) {
      await checkLabelChangeAndNotify(updatedPlace);
    }
  }

  List<Place> get popularPlaces => _places.where((place) => place.rating >= 4.0).toList()..sort((a, b) => b.rating.compareTo(a.rating));

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
    if (_searchQuery.isNotEmpty || _searchFilters.hasActiveFilters) {
      searchPlaces(_searchQuery);
    }
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
      results = List<Place>.from(_filteredPlaces);
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

    results = _applyBasicFilter(results);

    _searchResults = results;
    notifyListeners();
  }

  List<Place> _applyBasicFilter(List<Place> places) {
    switch (_selectedFilter) {
      case PlaceFilter.mostViewed:
        return List<Place>.from(places)..sort((a, b) => b.rating.compareTo(a.rating));
      case PlaceFilter.nearby:
        return List<Place>.from(places)..sort((a, b) {
          double distanceA = double.tryParse(a.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          double distanceB = double.tryParse(b.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
          return distanceA.compareTo(distanceB);
        });
      case PlaceFilter.latest:
        return places.reversed.toList();
    }
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

      String priceStr = place.price.replaceAll(RegExp(r'[^0-9]'), '');
      int priceRaw = int.tryParse(priceStr) ?? 0;

      int price = priceRaw > 1000 ? (priceRaw / 1000).round() : priceRaw;

      if (_searchFilters.minPrice != null && price < _searchFilters.minPrice!) {
        return false;
      }
      if (_searchFilters.maxPrice != null && price > _searchFilters.maxPrice!) {
        return false;
      }

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
    _searchFilters = SearchFilters();
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

  Future<List<String>> uploadMultipleFootage(List<XFile> files) async {
    List<String> uploadedUrls = [];

    for (var file in files) {
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/djj9ofual/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'NongkiYuk'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final resStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(resStr);
        uploadedUrls.add(data['secure_url']);
      }
    }

    return uploadedUrls;
  }

  Future<void> saveReviewToFirestore(String placeId, Review review) async {
    final docRef = FirebaseFirestore.instance
        .collection('places')
        .doc(placeId)
        .collection('reviews')
        .doc(review.id);

    await docRef.set(review.toJson());
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

  Future<void> reloadPlaceFromService(String placeId) async {
    try {
      // Ambil data place terbaru dari PlaceService (sudah termasuk rating yang ter-update)
      final updatedPlace = await PlaceService.getPlaceById(placeId);

      if (updatedPlace != null) {
        // Hitung ulang distance jika diperlukan
        Position? position;
        try {
          position = await UserPositionService.getCurrentPosition();
        } catch (e) {
          print('Error getting position: $e');
        }

        Place finalPlace = updatedPlace;
        if (position != null) {
          final distance = await DistanceService.getDistance(
            userLat: position.latitude,
            userLng: position.longitude,
            placeLat: updatedPlace.location.lat,
            placeLng: updatedPlace.location.lng,
          );
          finalPlace = updatedPlace.copyWith(distance: distance);
        }

        // Update place di semua list yang ada
        _updatePlaceInAllLists(finalPlace);

        setFilter(_selectedFilter);

        notifyListeners();
      }
    } catch (e) {
      print('Error reloading place from service: $e');
    }
  }

  void _updatePlaceInAllLists(Place updatedPlace) {
    // Update di _places
    final mainIndex = _places.indexWhere((place) => place.id == updatedPlace.id);
    if (mainIndex != -1) {
      _places[mainIndex] = updatedPlace;
    }

    // Update di _filteredPlaces
    final filteredIndex = _filteredPlaces.indexWhere((place) => place.id == updatedPlace.id);
    if (filteredIndex != -1) {
      _filteredPlaces[filteredIndex] = updatedPlace;
    }

    // Update di _searchResults
    final searchIndex = _searchResults.indexWhere((place) => place.id == updatedPlace.id);
    if (searchIndex != -1) {
      _searchResults[searchIndex] = updatedPlace;
    }

    // Update current place jika sedang dilihat
    if (_currentPlace?.id == updatedPlace.id) {
      _currentPlace = updatedPlace;
    }

    // Update di recent places
    for (int i = 0; i < _recentPlaces.length; i++) {
      if (_recentPlaces[i].place.id == updatedPlace.id) {
        _recentPlaces[i] = RecentPlace(
          place: updatedPlace,
          visitedAt: _recentPlaces[i].visitedAt,
        );
      }
    }
  }

  Place? _currentPlace;
  Place? get currentPlace => _currentPlace;

  void setCurrentPlace(Place place) {
    _currentPlace = place;
    notifyListeners();
  }

  void removeReview(String placeId, String userId) {
    if (_reviews.containsKey(placeId)) {
      _reviews[placeId]!.removeWhere((review) => review.userId == userId);
      notifyListeners();
    }
  }

  Future<void> checkLabelChangeAndNotify(Place place) async {
    // Notifikasi DEBUG
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1002,
        channelKey: 'label_changes',
        title: 'Your destination atmosphere now!',
        body: 'watched label: "$_watchedLabel"\nplace label now: "${place.label}"',
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'DISMISS',
          label: 'Dismiss',
        ),
        NotificationActionButton(
          key: 'SEE_RECOMMENDATION',
          label: 'See Recommendation',
          actionType: ActionType.Default,
        ),
      ],
    );

    if (_labelNotified || place.id != _watchedPlaceId || _watchedLabel == null) return;

    if (place.label != _watchedLabel) {
      _labelNotified = true;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1001,
          channelKey: 'label_changes',
          title: 'Your destination atmosphere changed!',
          body: 'It changed from "$_watchedLabel" to "${place.label}".',
          notificationLayout: NotificationLayout.Default,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
          ),
          NotificationActionButton(
            key: 'SEE_RECOMMENDATION',
            label: 'See Recommendation',
            actionType: ActionType.Default,
          ),
        ],
      );
    }
  }

  void applyLabelOnlySearch(String label) {
    _searchResults = _places.where((place) => place.label == label).toList();
    notifyListeners();
  }


}