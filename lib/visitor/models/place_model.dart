class Place {
  final String id;
  final String title;
  final String location;
  final String imageUrl;
  final double rating;
  final String distance;
  final String price;
  final String label;
  final String description;
  final List<String> amenities;
  final String operatingHours;
  final bool isFavorite;

  Place({
    required this.id,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.distance,
    required this.price,
    required this.label,
    this.description = '',
    this.amenities = const [],
    this.operatingHours = '08:00 - 22:00',
    this.isFavorite = false,
  });

  Place copyWith({
    String? id,
    String? title,
    String? location,
    String? imageUrl,
    double? rating,
    String? distance,
    String? price,
    String? label,
    String? description,
    List<String>? amenities,
    String? operatingHours,
    bool? isFavorite,
  }) {
    return Place(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      distance: distance ?? this.distance,
      price: price ?? this.price,
      label: label ?? this.label,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      operatingHours: operatingHours ?? this.operatingHours,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'imageUrl': imageUrl,
      'rating': rating,
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
    return Place(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      distance: json['distance'] ?? '',
      price: json['price'] ?? '',
      label: json['label'] ?? '',
      description: json['description'] ?? '',
      amenities: List<String>.from(json['amenities'] ?? []),
      operatingHours: json['operatingHours'] ?? '08:00 - 22:00',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Sample data
  static List<Place> getSamplePlaces() {
    return [
      Place(
        id: '1',
        title: 'Cafe A, Blok M',
        location: 'Blok M, Jaksel',
        imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        rating: 4.8,
        distance: '3.9 km',
        price: '\$40',
        label: 'Crowded',
        description: 'Cafe A adalah tempat nongkrong yang nyaman di Blok M. Cocok untuk kamu yang ingin suasana ramai dengan rating 4.8 dan jarak sekitar 3.9 km.',
        amenities: ['WiFi', 'AC', 'Outdoor Seating', 'Parking'],
        operatingHours: '08:00 - 23:00',
      ),
      Place(
        id: '2',
        title: 'Cafe B, Kebayoran',
        location: 'Kebayoran',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        rating: 4.6,
        distance: '4 km',
        price: '\$30',
        label: 'Comfy',
        description: 'Cafe B adalah tempat nongkrong yang nyaman di Kebayoran. Cocok untuk kamu yang ingin suasana nyaman dengan rating 4.6 dan jarak sekitar 4 km.',
        amenities: ['WiFi', 'AC', 'Cozy Interior', 'Books'],
        operatingHours: '09:00 - 22:00',
      ),
      Place(
        id: '3',
        title: 'Cafe C, Kemang',
        location: 'Kemang',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
        rating: 4.7,
        distance: '4.5 km',
        price: '\$35',
        label: 'Comfy',
        description: 'Cafe C adalah tempat nongkrong yang nyaman di Kemang. Cocok untuk kamu yang ingin suasana nyaman dengan rating 4.7 dan jarak sekitar 4.5 km.',
        amenities: ['WiFi', 'AC', 'Garden View', 'Pet Friendly'],
        operatingHours: '08:30 - 22:30',
      ),
    ];
  }
}