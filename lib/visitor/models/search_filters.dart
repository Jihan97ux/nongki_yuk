import 'package:flutter/foundation.dart'; // Import ini untuk listEquals

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

  // Constructor untuk membuat SearchFilters dari Firestore Map
  factory SearchFilters.fromMap(Map<String, dynamic> map) {
    return SearchFilters(
      minRating: (map['minRating'] as num?)?.toDouble(),
      maxRating: (map['maxRating'] as num?)?.toDouble(),
      minPrice: map['minPrice'] as int?,
      maxPrice: map['maxPrice'] as int?,
      maxDistance: (map['maxDistance'] as num?)?.toDouble(),
      labels: List<String>.from(map['labels'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
    );
  }

  // Method untuk mengkonversi SearchFilters ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'minRating': minRating,
      'maxRating': maxRating,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'maxDistance': maxDistance,
      'labels': labels,
      'amenities': amenities,
    };
  }

  // Helper untuk mengecek apakah ada filter aktif
  bool get hasActiveFilters {
    // Membandingkan dengan nilai default yang dianggap "tidak aktif"
    return (minRating != null && minRating != 0) ||
           (maxRating != null && maxRating != 5) ||
           (minPrice != null && minPrice != 0) ||
           (maxPrice != null && maxPrice != 100) || // Asumsi max price default 100
           (maxDistance != null && maxDistance != 50) || // Asumsi max distance default 50
           labels.isNotEmpty ||
           amenities.isNotEmpty;
  }

  // Clone method untuk membuat copy dari objek dengan perubahan
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

  // Method untuk mereset filter ke kondisi default/tidak aktif
  SearchFilters clear() {
    return SearchFilters();
  }

  // Untuk perbandingan objek, penting untuk Provider agar tahu kapan notifyListeners()
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFilters &&
          runtimeType == other.runtimeType &&
          minRating == other.minRating &&
          maxRating == other.maxRating &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          maxDistance == other.maxDistance &&
          listEquals(labels, other.labels) &&
          listEquals(amenities, other.amenities);

  @override
  int get hashCode =>
      minRating.hashCode ^
      maxRating.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      maxDistance.hashCode ^
      listEquals(labels, null).hashCode ^ // Gunakan hash dari hasil listEquals
      listEquals(amenities, null).hashCode;

  @override
  String toString() {
    return 'SearchFilters(minRating: $minRating, maxRating: $maxRating, minPrice: $minPrice, maxPrice: $maxPrice, labels: $labels, amenities: $amenities, maxDistance: $maxDistance)';
  }
}