import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
        children: [
          _buildPlaceCard(
            context,
            label: 'Crowded',
            imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
            title: 'Cafe A, Blok M',
            location: 'Blok M, Jaksel',
            rating: '4.8',
            distance: '3.9 km',
            price: '\$40',
          ),
          _buildPlaceCard(
            context,
            label: 'Comfy',
            imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
            title: 'Cafe B, Kebayoran',
            location: 'Kebayoran',
            rating: '4.6',
            distance: '4 km',
            price: '\$30',
          ),
          _buildPlaceCard(
            context,
            label: 'Comfy',
            imageUrl: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c',
            title: 'Cafe C, Kemang',
            location: 'Kemang',
            rating: '4.7',
            distance: '4.5 km',
            price: '\$35',
          ),
        ],
      ),
    );
  }

  static Widget _buildPlaceCard(
      BuildContext context, {
        required String label,
        required String imageUrl,
        required String title,
        required String location,
        required String rating,
        required String distance,
        required String price,
      }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/selected-place',
          arguments: {
            'label': label,
            'imageUrl': imageUrl,
            'title': title,
            'location': location,
            'rating': rating,
            'distance': distance,
            'price': price,
          },
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: label == 'Crowded' ? Colors.red : Colors.yellow[700],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                    bottom: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(location,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                        const Spacer(),
                        const Icon(Icons.star, color: Colors.yellow, size: 14),
                        const SizedBox(width: 4),
                        Text(rating,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(distance,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
