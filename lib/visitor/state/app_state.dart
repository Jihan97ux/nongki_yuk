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
// lib/visitor/state/app_state.dart
import '../models/search_filters.dart'; 
import '../service/firebase_filter_service.dart'; 


enum AuthStatus { authenticated, unauthenticated, loading }
enum PlaceFilter { mostViewed, nearby, latest }

// Hapus deklarasi global ini karena sudah ada di dalam kelas AppState
// AuthStatus _authStatus = AuthStatus.unauthenticated;
// User? _currentUser;
// String? _authError;

// Hapus definisi SearchFilters di sini karena sudah dipindah ke models/search_filters.dart
/*
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
*/

// Recent Place Entry - tetap di sini seperti yang Anda inginkan
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
  List<Place> _filteredPlaces = []; // Ini akan menyimpan hasil filter dasar (mostViewed, nearby, latest)
  List<Place> _searchResults = []; // Ini akan menyimpan hasil pencarian teks mentah
  PlaceFilter _selectedFilter = PlaceFilter.mostViewed;
  String _searchQuery = '';
  bool _isLoadingPlaces = false;
  String? _placesError;

  // Advanced Search
  SearchFilters _searchFilters = SearchFilters();
  // bool _isAdvancedSearchActive = false; // <--- DIHAPUS, gunakan _searchFilters.hasActiveFilters

  // Recent Places
  List<RecentPlace> _recentPlaces = [];

  // Bottom navigation state
  int _currentBottomNavIndex = 0;

  // Favorites state
  List<String> _favoriteIds = [];

  // Review state
  final Map<String, List<Review>> _reviews = {};

  // Firebase Filter Service Instance <--- BARU
  late final FirebaseFilterService _firebaseFilterService;

  AppState() {
    _firebaseFilterService = FirebaseFilterService(); // <--- BARU: Inisialisasi service
    _setupAuthListener(); // <--- BARU: Setup listener autentikasi
    // _loadFiltersFromFirebase(); // Ini akan dipanggil di dalam _setupAuthListener
  }

  // --- Start: New/Modified Methods for Firebase Filter Integration ---

  void _setupAuthListener() { // <--- BARU
    fb_auth.FirebaseAuth.instance.authStateChanges().listen((fb_auth.User? user) {
      if (user == null) {
        _authStatus = AuthStatus.unauthenticated;
        _currentUser = null;
        _favoriteIds = [];
        _recentPlaces = [];
        _currentBottomNavIndex = 0;
        clearSearch();
        clearAdvancedSearch(); // Clear local filters and Firebase filters on sign out
        print('User is currently signed out!');
      } else {
        // User signed in
        // Anda mungkin perlu fetch data user dari Firestore juga jika ada data tambahan
        // untuk memastikan data seperti 'name' atau 'profileImageUrl' yang disave di Firestore
        // konsisten dengan yang ditampilkan.
        FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((docSnapshot) {
          final data = docSnapshot.data();
          _currentUser = User(
            id: user.uid,
            name: user.displayName ?? data?['name'] ?? '', // Prioritaskan displayName dari FB Auth
            email: user.email ?? '',
            profileImageUrl: user.photoURL ?? data?['profileImageUrl'] ?? 'https://i.pravatar.cc/100', // Prioritaskan photoURL dari FB Auth
            createdAt: data?['createdAt'] != null ? (data!['createdAt'] as Timestamp).toDate() : DateTime.now(), // Sesuaikan jika Anda menyimpan createdAt di Firestore
          );
          _authStatus = AuthStatus.authenticated;
          print('User is signed in as ${user.email}');
          _loadFiltersFromFirebase(user.uid); // Load filters setelah user login
          notifyListeners(); // Notify setelah _currentUser di set
        }).catchError((e) {
          print('Error fetching user data from Firestore: $e');
          _authStatus = AuthStatus.unauthenticated; // Set unauthenticated jika gagal fetch user data
          _authError = 'Failed to load user data.';
          notifyListeners();
        });
      }
      // notifyListeners(); // Pindahkan ini ke dalam blok then() di atas untuk menghindari double notify
    });
  }

  // Modifikasi _loadFiltersFromFirebase untuk menerima UID <--- MODIFIED
  Future<void> _loadFiltersFromFirebase(String userId) async {
    try {
      // Set user ID di service FirebaseFilterService
      _firebaseFilterService.setUserId(userId);
      final storedFilters = await _firebaseFilterService.getFilters();
      if (storedFilters != null) {
        _searchFilters = storedFilters;
        print('Filters loaded from Firebase: $_searchFilters');
      } else {
        _searchFilters = SearchFilters(); // Default jika tidak ada
        print('No filters found in Firebase for user $userId. Using default.');
      }
      // Panggil `_applyAllFilters()` untuk memperbarui daftar tempat yang terlihat
      _applyAllFilters(); // <--- BARU: Panggil method untuk menerapkan semua filter
    } catch (e) {
      print('Failed to load filters from Firebase: $e');
      // Handle error, maybe show a message to the user
    } finally {
      notifyListeners(); // Tetap notifyListeners walaupun ada error agar UI bisa bereaksi
    }
  }

  // Method untuk menerapkan semua filter (dasar dan lanjutan)
  void _applyAllFilters() { // <--- BARU
    List<Place> currentPlaces = [];

    if (_searchQuery.isNotEmpty) {
      // Jika ada search query, mulai dari hasil search mentah
      currentPlaces = List<Place>.from(_places.where((place) {
        return place.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            place.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            place.label.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList());
      _searchResults = currentPlaces; // Update _searchResults juga
    } else {
      // Jika tidak ada search query, mulai dari semua tempat dan terapkan filter dasar
      List<Place> tempPlaces = List<Place>.from(_places);
      switch (_selectedFilter) {
        case PlaceFilter.mostViewed:
          tempPlaces.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case PlaceFilter.nearby:
          tempPlaces.sort((a, b) {
            double distanceA = double.tryParse(a.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
            double distanceB = double.tryParse(b.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
            return distanceA.compareTo(distanceB);
          });
          break;
        case PlaceFilter.latest:
          tempPlaces = tempPlaces.reversed.toList();
          break;
      }
      _filteredPlaces = tempPlaces; // Update _filteredPlaces dengan filter dasar
      currentPlaces = _filteredPlaces;
    }

    // Kemudian terapkan advanced filters pada `currentPlaces`
    _filteredPlaces = _applyAdvancedFilters(currentPlaces); // Hasil akhir disimpan di _filteredPlaces
  }


  // Advanced Search Methods
  // Modifikasi setAdvancedFilters untuk menyimpan ke Firebase <--- MODIFIED
  Future<void> setAdvancedFilters(SearchFilters newFilters) async {
    // Cek apakah filter berubah sebelum menyimpan dan memberitahu listener
    if (_searchFilters != newFilters) { // Menggunakan operator == dari SearchFilters
      _searchFilters = newFilters;
      _applyAllFilters(); // <--- MODIFIED: Panggil _applyAllFilters
      notifyListeners(); // Notify setelah update lokal
      
      // Simpan filter yang baru ke Firebase
      if (_currentUser != null) { // Pastikan user login sebelum menyimpan filter
        _firebaseFilterService.setUserId(_currentUser!.id); // Set user ID di service
        await _firebaseFilterService.saveFilters(newFilters);
      } else {
        print('User not authenticated, cannot save filters to Firebase.');
      }
    }
  }

  // Modifikasi clearAdvancedSearch untuk menyimpan ke Firebase <--- MODIFIED
  Future<void> clearAdvancedSearch() async {
    final defaultFilters = SearchFilters();
    if (_searchFilters != defaultFilters) { // Menggunakan operator == dari SearchFilters
      _searchFilters = defaultFilters;
      // _isAdvancedSearchActive = false; // Dihapus karena getter
      _applyAllFilters(); // <--- MODIFIED: Panggil _applyAllFilters
      notifyListeners(); // Notify setelah update lokal

      // Simpan filter default ke Firebase
      if (_currentUser != null) { // Pastikan user login sebelum menyimpan filter
        _firebaseFilterService.setUserId(_currentUser!.id); // Set user ID di service
        await _firebaseFilterService.saveFilters(defaultFilters);
      } else {
        print('User not authenticated, cannot clear filters in Firebase.');
      }
    }
  }

  // --- End: New/Modified Methods ---

  // Getters
  AuthStatus get authStatus => _authStatus;
  User? get currentUser => _currentUser;
  String? get authError => _authError;

  List<Place> get places => _places;
  List<Place> get filteredPlaces { // <--- MODIFIED: Getter ini sekarang langsung mengembalikan _filteredPlaces
    // Karena _filteredPlaces sudah diupdate oleh _applyAllFilters
    return _filteredPlaces;
  }
  
  List<Place> get searchResults => _searchResults; // Ini adalah hasil pencarian teks mentah sebelum advanced filter
  PlaceFilter get selectedFilter => _selectedFilter;
  String get searchQuery => _searchQuery;
  bool get isLoadingPlaces => _isLoadingPlaces;
  String? get placesError => _placesError;

  // Advanced Search Getters
  SearchFilters get searchFilters => _searchFilters;
  // Getter ini sekarang bisa langsung dari model SearchFilters <--- MODIFIED
  bool get isAdvancedSearchActive => _searchFilters.hasActiveFilters;

  // Recent Places Getters
  List<RecentPlace> get recentPlaces => _recentPlaces;
  List<Place> get recentPlacesList => _recentPlaces.map((e) => e.place).toList();

  int get currentBottomNavIndex => _currentBottomNavIndex;
  List<String> get favoriteIds => _favoriteIds;
  List<Place> get favoritePlaces => _places.where((place) => _favoriteIds.contains(place.id)).toList();

  // Review Getters
  Map<String, List<Review>> get reviews => _reviews;

  // Authentication methods
  Future<void> signIn(String email, String password) async {
    _authStatus = AuthStatus.loading;
    _authError = null;
    notifyListeners();

    try {
      final credential = await fb_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // _setupAuthListener akan menangani pengaturan _currentUser dan pemuatan filter
      // Tidak perlu memanggil notifyListeners() di sini karena listener akan melakukannya.
    } on fb_auth.FirebaseAuthException catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      _authError = e.message;
      notifyListeners(); // Notify hanya jika ada error
    } catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      _authError = e.toString();
      print(e);
      notifyListeners(); // Notify hanya jika ada error
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    _authStatus = AuthStatus.loading;
    _authError = null;
    notifyListeners();

    try {
      final credential = await fb_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await credential.user?.updateDisplayName(name); // Update display name di Firebase Auth

      // Simpan data user tambahan ke Firestore
      await FirebaseFirestore.instance.collection('users').doc(credential.user?.uid).set({
        'name': name,
        'email': email,
        'profileImageUrl': 'https://i.pravatar.cc/100', // Default image
        'createdAt': FieldValue.serverTimestamp(),
      });

      // _setupAuthListener akan menangani pengaturan _currentUser dan pemuatan filter
      // Tidak perlu memanggil notifyListeners() di sini karena listener akan melakukannya.
    } on fb_auth.FirebaseAuthException catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      _authError = e.message;
      notifyListeners(); // Notify hanya jika ada error
    } catch (e) {
      _authStatus = AuthStatus.unauthenticated;
      _authError = e.toString();
      print(e);
      notifyListeners(); // Notify hanya jika ada error
    }
  }

  void signOut() async { // Ubah menjadi async
    await fb_auth.FirebaseAuth.instance.signOut(); // Sign out dari Firebase Auth
    // _setupAuthListener akan menangani reset state dan notifyListeners
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
      print('Getting user position...');
      final Position position = await UserPositionService.getCurrentPosition();

      print('Fetching cafes from Firebase...');
      final rawPlaces = await PlaceService.fetchCafesFromFirebase();

      _places = []; // Reset _places
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
      _applyAllFilters(); // <--- MODIFIED: Panggil _applyAllFilters setelah data mentah dimuat
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
    _applyAllFilters(); // <--- MODIFIED: Panggil _applyAllFilters
    notifyListeners();
  }

  // _filterPlaces sekarang hanya melakukan filtering dasar tanpa advanced filter
  void _filterPlaces() { // <--- MODIFIED
    // Logika ini dipindahkan ke _applyAllFilters()
    // Karena _applyAllFilters() akan mengelola `_filteredPlaces`
    // Untuk menjaga kompatibilitas, fungsi ini bisa tetap ada namun tidak dipanggil langsung
    // dari setFilter atau loadPlaces jika _applyAllFilters yang akan menjadi orkestrator utama.
    // Jika masih ada tempat yang memanggil _filterPlaces() secara langsung,
    // pastikan itu diikuti dengan pemanggilan _applyAdvancedFilters() atau _applyAllFilters().
  }

  void searchPlaces(String query) {
    _searchQuery = query;
    _applyAllFilters(); // <--- MODIFIED: Panggil _applyAllFilters
    notifyListeners();
  }

  // _applyAdvancedFilters tetap sama, sekarang dipanggil oleh _applyAllFilters
  List<Place> _applyAdvancedFilters(List<Place> placesToFilter) { // <--- MODIFIED
    if (!_searchFilters.hasActiveFilters) {
      return placesToFilter; // Tidak ada filter aktif, kembalikan semua
    }

    return placesToFilter.where((place) {
      // Rating filter
      if (_searchFilters.minRating != null && place.rating < _searchFilters.minRating!) {
        return false;
      }
      if (_searchFilters.maxRating != null && place.rating > _searchFilters.maxRating!) {
        return false;
      }

      // Price filter (extract number from price string like "$40" or "Rp 40000")
      int priceValue = 0;
      try {
        String cleanedPrice = place.price.replaceAll(RegExp(r'[^0-9.]'), '');
        priceValue = (double.tryParse(cleanedPrice) ?? 0).toInt();
      } catch (e) {
        print('Error parsing price: ${place.price}, $e');
      }
      
      if (_searchFilters.minPrice != null && priceValue < _searchFilters.minPrice!) {
        return false;
      }
      if (_searchFilters.maxPrice != null && priceValue > _searchFilters.maxPrice!) {
        return false;
      }

      // Label filter
      // Asumsi place.label adalah string tunggal yang bisa berisi beberapa label dipisahkan koma atau spasi
      // Atau, jika place.label sebenarnya adalah List<String>, maka disesuaikan
      if (_searchFilters.labels.isNotEmpty) {
        bool labelMatch = false;
        for (String filterLabel in _searchFilters.labels) {
          if (place.label.toLowerCase().contains(filterLabel.toLowerCase())) {
            labelMatch = true;
            break;
          }
        }
        if (!labelMatch) return false;
      }

      // Amenities filter
      if (_searchFilters.amenities.isNotEmpty) {
        bool allAmenitiesMatch = _searchFilters.amenities.every((filterAmenity) =>
            place.amenities.any((placeAmenity) =>
                placeAmenity.toLowerCase().contains(filterAmenity.toLowerCase())));
        if (!allAmenitiesMatch) return false;
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
    _applyAllFilters(); // <--- MODIFIED: Panggil _applyAllFilters
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

      if (name != null && name.isNotEmpty && fbUser?.displayName != name) {
        await fbUser?.updateDisplayName(name);
      }

      if (password != null && password.isNotEmpty) {
        await fbUser?.updatePassword(password);
      }

      // Update photo URL di Firebase Auth dan Firestore
      if (profileImageUrl != null && profileImageUrl.isNotEmpty && fbUser?.photoURL != profileImageUrl) {
        await fbUser?.updatePhotoURL(profileImageUrl);

        // Hanya update Firestore jika URL berubah atau memang ingin memastikan sinkron
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.id)
            .set({
          'profileImageUrl': profileImageUrl,
        }, SetOptions(merge: true));
      }

      // Perbarui _currentUser lokal setelah Firebase Auth diperbarui dan mungkin Firestore juga
      await fbUser?.reload(); // Penting untuk mendapatkan data terbaru dari Firebase Auth
      final refreshedUser = fb_auth.FirebaseAuth.instance.currentUser;

      _currentUser = _currentUser!.copyWith(
        name: refreshedUser?.displayName ?? _currentUser!.name,
        profileImageUrl: refreshedUser?.photoURL ?? _currentUser!.profileImageUrl,
      );

      notifyListeners();
    } on fb_auth.FirebaseAuthException catch (e) {
      // Tangani error spesifik dari Firebase Auth
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      print('General Error updating profile: $e');
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
}