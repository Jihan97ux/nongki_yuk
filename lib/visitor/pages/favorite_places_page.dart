import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../constants/app_constants.dart';

class FavoritePlacesPage extends StatelessWidget {
  const FavoritePlacesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Back button and title
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                ],
              ),
            ),
            Expanded(
              child: Consumer<AppState>(
                builder: (context, appState, child) {
                  final favorites = appState.favoritePlaces;
                  if (favorites.isEmpty) {
                    return Center(
                      child: Text(
                        'Belum ada tempat favorit.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final place = favorites[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/selected_place', // Make sure this matches your route name
                            arguments: place,
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2D223A)
                                : const Color(0xFFF8EAFE),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  place.imageUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      place.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      place.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black.withOpacity(0.6),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Start from IDR ${place.price}',
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFFD1B3FF) : const Color(0xFF7B1FA2),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Icon(Icons.favorite, color: Colors.red, size: 22),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            // Bottom navigation bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BottomNavigationBar(
                  currentIndex: 2,
                  onTap: (index) {
                    // Implement navigation logic for each tab
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.access_time),
                      label: 'History',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.favorite),
                      label: 'Favorites',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
                    ),
                  ],
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Theme.of(context).colorScheme.primary,
                  unselectedItemColor: Colors.grey,
                  showUnselectedLabels: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 