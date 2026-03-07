import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restoranapp/data/api/api_service.dart';
import 'package:restoranapp/providers/detail/restaurant_detail_provider.dart';
import 'package:restoranapp/providers/favorite/local_database_provider.dart';
import 'package:restoranapp/screens/detail/detail_screen.dart';
import 'package:restoranapp/screens/home/restaurant_card_widget.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<LocalDatabaseProvider>().loadAllFavoritesValue();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorite List")),
      // todo-03-action-01: change this provider to LocalDatabaseProvider
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari restoran...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                final query = value.trim();
                if (query.isNotEmpty) {
                  context.read<LocalDatabaseProvider>().searchFavorites(query);
                }
              },
              onChanged: (value) {
                if (value.isEmpty) {
                  context
                      .read<LocalDatabaseProvider>()
                      .loadAllFavoritesValue(); // balik ke list
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<LocalDatabaseProvider>(
              builder: (context, value, child) {
                final favoriteList =
                    value.filteredRestaurantList ??
                    value.restaurantItemList ??
                    [];

                if (favoriteList.isEmpty) {
                  return const Center(child: Text("No Favorite"));
                }

                return ListView.builder(
                  itemCount: favoriteList.length,
                  itemBuilder: (context, index) {
                    final restaurant = favoriteList[index];

                    return RestaurantCard(
                      restaurant: restaurant,
                      trailing: IconButton(
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          context
                              .read<LocalDatabaseProvider>()
                              .removeFavoritesValueById(restaurant.id);
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (context) => RestaurantDetailProvider(
                                context.read<ApiServices>(),
                              )..fetchRestaurantDetail(restaurant.id),
                              child: DetailScreen(restaurantId: restaurant.id),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
