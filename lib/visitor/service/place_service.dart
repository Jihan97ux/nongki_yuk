import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';

class PlaceService {
  static const String baseUrl = 'https://nongkiyuk-6763e-default-rtdb.asia-southeast1.firebasedatabase.app';

  static Future<List<Place>> fetchCafesFromFirebase() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cafe.json'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return [];
        }

        List<Place> places = [];

        // Process each place
        for (var entry in data.entries) {
          String key = entry.key;
          var value = entry.value;

          if (value is Map<String, dynamic>) {
            value['id'] = value['id'] ?? key;

            Place place = Place.fromJson(value);
            double originalRating = place.rating;

            List<Review> reviews = await fetchReviewsForPlace(place.id);
            double calculatedRating = calculateAverageRating(reviews, originalRating);

            place = place.copyWith(
              reviews: reviews,
              rating: calculatedRating,
              totalScore: calculatedRating,
            );

            places.add(place);
          }
        }

        return places;
      } else {
        throw Exception('Failed to load cafes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching cafes: $e');
    }
  }

  // Fetch reviews for a specific place from Firestore
  static Future<List<Review>> fetchReviewsForPlace(String placeId) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      List<Review> reviews = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        reviews.add(Review.fromJson(data));
      }

      return reviews;
    } catch (e) {
      print('Error fetching reviews for place $placeId: $e');
      return [];
    }
  }

  // Calculate average rating from reviews with fallback to original rating
  static double calculateAverageRating(List<Review> reviews, double originalRating) {
    if (reviews.isEmpty) {
      // If no reviews, use original rating from root cafe/
      return originalRating;
    }

    double totalRating = 0.0;
    for (Review review in reviews) {
      totalRating += review.rating;
    }

    return double.parse((totalRating / reviews.length).toStringAsFixed(1));
  }

  // Save review to Firestore (moved from other service)
  static Future<void> saveReviewToFirestore(String placeId, Review review) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('places')
          .doc(placeId)
          .collection('reviews')
          .doc(review.id);

      await docRef.set(review.toJson());
    } catch (e) {
      throw Exception('Error saving review: $e');
    }
  }

  // Get all places from Firebase with calculated ratings
  static Future<List<Place>> getAllPlaces() async {
    try {
      return await fetchCafesFromFirebase();
    } catch (e) {
      print('Error getting places from Firebase: $e');
      throw Exception('Failed to fetch places from Firebase: $e');
    }
  }

  // Get single place with reviews and calculated rating
  static Future<Place?> getPlaceById(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cafe/$placeId.json'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = json.decode(response.body);

        if (data == null) {
          return null;
        }

        data['id'] = data['id'] ?? placeId;

        // Create place object (this will have original rating from Firebase)
        Place place = Place.fromJson(data);
        double originalRating = place.rating;

        // Fetch reviews and calculate rating
        List<Review> reviews = await fetchReviewsForPlace(placeId);
        double calculatedRating = calculateAverageRating(reviews, originalRating);

        return place.copyWith(
          reviews: reviews,
          rating: calculatedRating,
          totalScore: calculatedRating,
        );
      } else {
        throw Exception('Failed to load place: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting place by id: $e');
      return null;
    }
  }
}