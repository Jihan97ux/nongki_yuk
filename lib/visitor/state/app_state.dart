import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/place_model.dart';

enum AuthStatus { authenticated, unauthenticated, loading }
enum PlaceFilter { mostViewed, nearby, latest }

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
    _currentBottomNavIndex = 0;
    clearSearch();
    notifyListeners();
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  // Places methods
  Future<void> loadPlaces() async {
    _isLoadingPlaces = true;
    _placesError = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _places = Place.getSamplePlaces();
      _filterPlaces();
    } catch (e) {
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
    } else {
      _searchResults = _places.where((place) {
        return place.title.toLowerCase().contains(query.toLowerCase()) ||
            place.location.toLowerCase().contains(query.toLowerCase()) ||
            place.label.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
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