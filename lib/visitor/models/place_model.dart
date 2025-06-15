import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }

  @override
  String toString() {
    return 'Location{lat: $lat, lng: $lng}';
  }
}

class Review {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> footage;

  Review({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.footage = const [],
  });

  Review copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    double? rating,
    String? comment,
    DateTime? createdAt,
    List<String>? footage,

  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      footage: footage ?? this.footage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'footage': footage,
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatarUrl: json['userAvatarUrl'],
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      footage: List<String>.from(json['footage'] ?? []),
    );
  }

}

class Place {
  final String id;
  final String title;
  final Location location;
  final String address;
  final String neighborhood;
  final String city;
  final String imageUrl;
  final double rating;
  final double totalScore;
  final String distance;
  final String price;
  final String label;
  final String description;
  final List<String> amenities;
  final String operatingHours;
  final bool isFavorite;
  final List<Review> reviews;

  Place({
    required this.id,
    required this.title,
    required this.location,
    required this.address,
    required this.neighborhood,
    required this.city,
    required this.imageUrl,
    required this.rating,
    required this.totalScore,
    required this.distance,
    required this.price,
    required this.label,
    this.description = '',
    this.amenities = const [],
    this.operatingHours = '08:00 - 22:00',
    this.isFavorite = false,
    this.reviews = const [],
  });

  Place copyWith({
    String? id,
    String? title,
    Location? location,
    String? address,
    String? neighborhood,
    String? city,
    String? imageUrl,
    double? rating,
    double? totalScore,
    String? distance,
    String? price,
    String? label,
    String? description,
    List<String>? amenities,
    String? operatingHours,
    bool? isFavorite,
    List<Review>? reviews,
  }) {
    return Place(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      address: address ?? this.address,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      totalScore: totalScore ?? this.totalScore,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      label: label ?? this.label,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      operatingHours: operatingHours ?? this.operatingHours,
      isFavorite: isFavorite ?? this.isFavorite,
      reviews: reviews ?? this.reviews,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location.toJson(),
      'neighborhood': neighborhood,
      'city': city,
      'imageUrl': imageUrl,
      'totalScore': totalScore,
      'distance': distance,
      'price': price,
      'label': label,
      'description': description,
      'amenities': amenities,
      'operatingHours': operatingHours,
      'isFavorite': isFavorite,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    String neighborhood = json['neighborhood'] ?? '';
    String city = json['city'] ?? '';

    String today = _getToday();

    String todaysHours = '08:00 - 22:00';
    if (json['openingHours'] != null && json['openingHours'] is List) {
      for (var entry in json['openingHours']) {
        if (entry is Map<String, dynamic> && entry['day'] == today) {
          todaysHours = entry['hours'] ?? todaysHours;
          break;
        }
      }
    }

    String label = '';
    if (json['popularTimesHistogram'] != null && json['popularTimesHistogram'] is Map<String, dynamic>) {
      final popularTimes = Map<String, dynamic>.from(json['popularTimesHistogram']);
      final dayAbbr = today.substring(0, 2);
      final todayData = popularTimes[dayAbbr];
      if (todayData is List) {
        final nowHour = DateTime.now().hour;
        final match = todayData.firstWhere(
              (entry) => entry['hour'] == nowHour,
          orElse: () => null,
        );
        if (match != null && match['occupancyPercent'] != null) {
          final percent = match['occupancyPercent'];
          if (percent >= 70) {
            label = 'Crowded';
          } else if (percent >= 40) {
            label = 'Sedang';
          } else {
            label = 'Comfy';
          }
        }
      }
    }

    return Place(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
      neighborhood: neighborhood,
      city: city,
      address: _buildLocationName(neighborhood, city),
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['totalScore'] ?? 0.0).toDouble(),
      totalScore: (json['totalScore'] ?? 0.0).toDouble(),
      distance: json['distance'] ?? '',
      price: json['price'] ?? '',
      label: label,
      description: json['description'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      operatingHours: todaysHours,
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  static String _buildLocationName(String neighborhood, String city) {
    if (neighborhood.isNotEmpty && city.isNotEmpty) {
      return '$neighborhood, $city';
    } else if (neighborhood.isNotEmpty) {
      return neighborhood;
    } else if (city.isNotEmpty) {
      return city;
    } else {
      return 'Unknown Location';
    }
  }

  static String _getToday() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      default:
        return '';
    }
  }

  @override
  String toString() {
    return 'Place{id: $id, title: $title, location: $location, address: $address, rating: $totalScore, price: $price, label: $label, operatingHours: $operatingHours}';
  }
}