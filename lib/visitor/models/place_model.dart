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

  @override
  String toString() {
    return 'Place{id: $id, title: $title, location: $location, rating: $rating, price: $price, label: $label}';
  }

  // Sample data with more variety
  static List<Place> getSamplePlaces() {
    return [
      // Cafes
      Place(
        id: '1',
        title: 'Anomali Coffee',
        location: 'Blok M Plaza, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
        rating: 4.8,
        distance: '2.1 km',
        price: '35',
        label: 'Crowded',
        description: 'Anomali Coffee adalah pioneer coffee shop di Indonesia yang menyajikan kopi berkualitas tinggi dengan suasana modern dan nyaman. Tempat yang sempurna untuk meeting bisnis atau nongkrong santai.',
        amenities: ['WiFi', 'AC', 'Power Outlet', 'Parking', 'Meeting Room'],
        operatingHours: '07:00 - 23:00',
      ),

      Place(
        id: '2',
        title: 'Common Grounds',
        location: 'Kemang Village, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
        rating: 4.6,
        distance: '3.2 km',
        price: '28',
        label: 'Comfy',
        description: 'Cafe yang nyaman dengan interior cozy dan menu kopi yang beragam. Cocok untuk kerja remote atau study session dengan suasana yang tidak terlalu ramai.',
        amenities: ['WiFi', 'AC', 'Outdoor Seating', 'Books', 'Study Area'],
        operatingHours: '08:00 - 22:00',
      ),

      Place(
        id: '3',
        title: 'Blue Bottle Coffee',
        location: 'Pacific Place, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1493857671505-72967e2e2760?w=800',
        rating: 4.9,
        distance: '4.5 km',
        price: '55',
        label: 'Crowded',
        description: 'Blue Bottle Coffee dari San Francisco menghadirkan pengalaman kopi premium dengan biji kopi pilihan dan brewing method yang precise. Suasana minimalis dengan service yang excellent.',
        amenities: ['WiFi', 'AC', 'Premium Coffee', 'Takeaway', 'Parking'],
        operatingHours: '07:00 - 21:00',
      ),

      Place(
        id: '4',
        title: 'Kedai Kopi Tuku',
        location: 'Senopati, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800',
        rating: 4.7,
        distance: '1.8 km',
        price: '25',
        label: 'Comfy',
        description: 'Local coffee shop dengan specialty Es Kopi Susu Tuku yang legendary. Tempatnya compact tapi selalu ramai karena rasa kopinya yang unique dan harga yang reasonable.',
        amenities: ['WiFi', 'AC', 'Signature Drink', 'Fast Service', 'Instagram Worthy'],
        operatingHours: '08:00 - 22:30',
      ),

      // Restaurants
      Place(
        id: '5',
        title: 'Social House',
        location: 'Grand Indonesia, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800',
        rating: 4.5,
        distance: '5.2 km',
        price: '75',
        label: 'Crowded',
        description: 'Restaurant dengan konsep modern dining yang menyajikan fusion food berkualitas tinggi. Tempat yang perfect untuk dinner dengan suasana upscale dan pelayanan profesional.',
        amenities: ['WiFi', 'AC', 'Fine Dining', 'Bar', 'Private Room', 'Valet Parking'],
        operatingHours: '11:00 - 24:00',
      ),

      Place(
        id: '6',
        title: 'Warung Tekko',
        location: 'Blok M, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
        rating: 4.4,
        distance: '2.5 km',
        price: '20',
        label: 'Comfy',
        description: 'Warung tradisional dengan menu nasi rames yang lezat dan harga terjangkau. Suasana casual dan ramah, cocok untuk makan siang dengan teman-teman.',
        amenities: ['Traditional Food', 'Affordable', 'Local Taste', 'Fast Service'],
        operatingHours: '10:00 - 21:00',
      ),

      // Bars & Lounges
      Place(
        id: '7',
        title: 'Skye Bar & Restaurant',
        location: 'BCA Tower, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1574391884720-bbc3740c59d1?w=800',
        rating: 4.8,
        distance: '6.1 km',
        price: '95',
        label: 'Crowded',
        description: 'Rooftop bar dengan pemandangan city skyline yang menakjubkan. Tempat yang perfect untuk after work drinks atau special occasion dengan cocktail premium dan suasana sophisticated.',
        amenities: ['City View', 'Premium Cocktails', 'Live Music', 'Dress Code', 'Reservation Required'],
        operatingHours: '17:00 - 02:00',
      ),

      Place(
        id: '8',
        title: 'Potato Head',
        location: 'Senayan, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=800',
        rating: 4.6,
        distance: '4.8 km',
        price: '65',
        label: 'Comfy',
        description: 'Creative space yang menggabungkan art, music, dan culinary experience. Suasana casual tapi trendy, cocok untuk hang out sambil menikmati craft cocktail dan good music.',
        amenities: ['Art Gallery', 'Live Music', 'Craft Cocktails', 'Creative Space', 'Events'],
        operatingHours: '12:00 - 01:00',
      ),

      // Coworking Spaces
      Place(
        id: '9',
        title: 'GoWork',
        location: 'Kuningan City, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
        rating: 4.7,
        distance: '3.8 km',
        price: '45',
        label: 'Comfy',
        description: 'Modern coworking space dengan fasilitas lengkap untuk profesional. Suasana produktif dengan high-speed internet, meeting rooms, dan networking opportunities.',
        amenities: ['High-Speed WiFi', 'Meeting Rooms', 'Printing', 'Coffee', 'Networking Events'],
        operatingHours: '07:00 - 22:00',
      ),

      Place(
        id: '10',
        title: 'WeWork',
        location: 'Equity Tower, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1497366858526-0766cadbe8fa?w=800',
        rating: 4.5,
        distance: '5.5 km',
        price: '85',
        label: 'Crowded',
        description: 'Premium coworking space dengan community yang vibrant. Fasilitas world-class dengan design yang inspiring, perfect untuk startup dan creative professionals.',
        amenities: ['Premium Facilities', 'Community Events', 'Phone Booths', 'Beer on Tap', 'Global Network'],
        operatingHours: '24/7',
      ),

      // Entertainment
      Place(
        id: '11',
        title: 'Timezone',
        location: 'Pondok Indah Mall, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1511882150382-421056c89033?w=800',
        rating: 4.3,
        distance: '7.2 km',
        price: '50',
        label: 'Crowded',
        description: 'Family entertainment center dengan berbagai arcade games, bowling, dan karaoke. Tempat yang fun untuk hang out dengan keluarga atau teman-teman.',
        amenities: ['Arcade Games', 'Bowling', 'Karaoke', 'Food Court', 'Family Friendly'],
        operatingHours: '10:00 - 22:00',
      ),

      Place(
        id: '12',
        title: 'CGV Cinemas',
        location: 'Gandaria City, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1489185078296-701ac39ba43c?w=800',
        rating: 4.4,
        distance: '4.1 km',
        price: '35',
        label: 'Comfy',
        description: 'Modern cinema dengan teknologi terbaru dan kenyamanan premium. Perfect untuk movie date atau hanging out sambil menonton film terbaru.',
        amenities: ['Premium Sound', 'Comfortable Seats', 'Snack Bar', 'Online Booking', 'Latest Movies'],
        operatingHours: '10:00 - 24:00',
      ),

      // Bookstores & Libraries
      Place(
        id: '13',
        title: 'Kinokuniya',
        location: 'Plaza Senayan, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800',
        rating: 4.6,
        distance: '4.7 km',
        price: '15',
        label: 'Comfy',
        description: 'Bookstore internasional dengan koleksi buku yang sangat lengkap. Suasana tenang dan nyaman untuk membaca, belajar, atau sekedar browsing buku-buku menarik.',
        amenities: ['Extensive Book Collection', 'Reading Area', 'AC', 'Quiet Environment', 'International Books'],
        operatingHours: '10:00 - 22:00',
      ),

      // Parks & Outdoor
      Place(
        id: '14',
        title: 'Taman Langsat',
        location: 'Kebayoran Baru, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
        rating: 4.2,
        distance: '2.8 km',
        price: '5',
        label: 'Comfy',
        description: 'Taman kota yang asri dan nyaman untuk jogging, picnic, atau sekedar bersantai. Tempat yang perfect untuk escape dari hiruk pikuk kota dengan suasana hijau dan fresh air.',
        amenities: ['Jogging Track', 'Playground', 'Green Space', 'Fresh Air', 'Free Entry'],
        operatingHours: '05:00 - 18:00',
      ),

      // Shopping
      Place(
        id: '15',
        title: 'Senayan City',
        location: 'Senayan, Jakarta Selatan',
        imageUrl: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800',
        rating: 4.5,
        distance: '5.0 km',
        price: '40',
        label: 'Crowded',
        description: 'Premium shopping mall dengan brand-brand internasional dan dining options yang beragam. Perfect untuk shopping therapy atau window shopping sambil hang out.',
        amenities: ['Premium Brands', 'Food Court', 'Cinema', 'Parking', 'AC'],
        operatingHours: '10:00 - 22:00',
      ),
    ];
  }

  // Helper methods for filtering
  static List<Place> filterByRating(List<Place> places, double minRating) {
    return places.where((place) => place.rating >= minRating).toList();
  }

  static List<Place> filterByPrice(List<Place> places, int minPrice, int maxPrice) {
    return places.where((place) {
      int price = int.tryParse(place.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return price >= minPrice && price <= maxPrice;
    }).toList();
  }

  static List<Place> filterByDistance(List<Place> places, double maxDistance) {
    return places.where((place) {
      double distance = double.tryParse(place.distance.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      return distance <= maxDistance;
    }).toList();
  }

  static List<Place> filterByLabel(List<Place> places, List<String> labels) {
    if (labels.isEmpty) return places;
    return places.where((place) =>
        labels.any((label) => place.label.toLowerCase() == label.toLowerCase())
    ).toList();
  }

  static List<Place> filterByAmenities(List<Place> places, List<String> amenities) {
    if (amenities.isEmpty) return places;
    return places.where((place) =>
        amenities.any((amenity) =>
            place.amenities.any((placeAmenity) =>
                placeAmenity.toLowerCase().contains(amenity.toLowerCase())
            )
        )
    ).toList();
  }

  static List<Place> searchPlaces(List<Place> places, String query) {
    if (query.isEmpty) return places;

    final lowercaseQuery = query.toLowerCase();
    return places.where((place) =>
    place.title.toLowerCase().contains(lowercaseQuery) ||
        place.location.toLowerCase().contains(lowercaseQuery) ||
        place.description.toLowerCase().contains(lowercaseQuery) ||
        place.amenities.any((amenity) => amenity.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }
}