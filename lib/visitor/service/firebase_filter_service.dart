import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/search_filters.dart'; // Sesuaikan path jika berbeda

class FirebaseFilterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId; // Tambahkan ini untuk menyimpan UID user aktif

  // Method untuk mengatur UID user yang sedang login
  void setUserId(String userId) {
    _userId = userId;
  }

  // Path ke dokumen filter untuk user saat ini
  DocumentReference _userFilterDoc() {
    if (_userId == null) {
      // Ini harusnya tidak terjadi jika setUserId dipanggil dengan benar saat user login
      // Atau, jika Anda ingin filter global tanpa autentikasi, gunakan ID statis di sini.
      throw Exception('User ID is not set in FirebaseFilterService. Cannot access user filters.');
    }
    // Koleksi 'user_filters' akan menyimpan dokumen dengan ID sesuai UID pengguna
    return _firestore.collection('user_filters').doc(_userId);
  }

  // Mengambil filter dari Firestore
  Future<SearchFilters?> getFilters() async {
    if (_userId == null) {
      print('FirebaseFilterService: No user ID set, cannot get filters.');
      return null;
    }

    try {
      final docSnapshot = await _userFilterDoc().get();
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return SearchFilters.fromMap(docSnapshot.data() as Map<String, dynamic>);
      }
      return null; // Tidak ada filter tersimpan untuk user ini
    } catch (e, st) {
      print('FirebaseFilterService: Error getting filters from Firestore for user $_userId: $e\n$st');
      // Anda bisa menggunakan ErrorHandler.reportError jika Anda punya sistem logging error
      return null;
    }
  }

  // Menyimpan filter ke Firestore
  Future<void> saveFilters(SearchFilters filters) async {
    if (_userId == null) {
      print('FirebaseFilterService: No user ID set, cannot save filters.');
      return;
    }
    try {
      await _userFilterDoc().set(filters.toMap(), SetOptions(merge: true)); // Gunakan merge agar tidak menimpa dokumen lain
      print('FirebaseFilterService: Filters saved to Firestore for user $_userId successfully.');
    } catch (e, st) {
      print('FirebaseFilterService: Error saving filters to Firestore for user $_userId: $e\n$st');
      // Anda bisa menggunakan ErrorHandler.reportError jika Anda punya sistem logging error
    }
  }
}