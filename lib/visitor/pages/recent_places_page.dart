import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';
import '../utils/error_handler.dart';

class RecentPlacesPage extends StatelessWidget {
  const RecentPlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('History', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final recentPlaces = appState.recentPlaces;
          if (recentPlaces.isEmpty) {
            return const Center(child: Text('No recent places.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recentPlaces.length,
            itemBuilder: (context, index) {
              final recentPlace = recentPlaces[index];
              final place = recentPlace.place;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(place.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  title: Text(place.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.address, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('Start from IDR ${place.price}', style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 2),
                          Text(place.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/selected-place', arguments: place);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}