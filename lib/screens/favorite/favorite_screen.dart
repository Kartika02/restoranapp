import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restoranapp/data/api/api_service.dart';
import 'package:restoranapp/providers/detail/restaurant_detail_provider.dart';
import 'package:restoranapp/providers/favorite/local_database_provider.dart';
import 'package:restoranapp/screens/detail/detail_screen.dart';
import 'package:restoranapp/providers/home/restaurant_search_provider.dart';
import 'package:restoranapp/screens/home/restaurant_card_widget.dart';
import 'package:restoranapp/static/restaurant_search_result_state.dart';

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
    // final favoriteProvider = context.watch<LocalDatabaseProvider>();
    final searchProvider = context.read<RestaurantSearchProvider>();

    // final filteredList = searchProvider.filterFavorites(
    //   favoriteProvider.favorites ?? [],
    //   _query,
    // );
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
                  searchProvider.searchRestaurant(query);
                }
              },
              onChanged: (value) {
                if (value.isEmpty) {
                  searchProvider.reset(); // balik ke list
                }
              },
            ),
          ),
          Expanded(
            child: Consumer2<LocalDatabaseProvider, RestaurantSearchProvider>(
             builder: (context, value, searchProvider, _) {
                final searchState = searchProvider.state;
                
                if (searchState is RestaurantSearchLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (searchState is RestaurantSearchLoadedState) {
                  return ListView.builder(
                    itemCount: searchState.restaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant = searchState.restaurants[index];
                      return RestaurantCard(
                        restaurant: restaurant,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider(
                                create: (context) => RestaurantDetailProvider(
                                  context.read<ApiServices>(),
                                )..fetchRestaurantDetail(restaurant.id),
                                child: DetailScreen(
                                  restaurantId: restaurant.id,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                if (searchState is RestaurantSearchErrorState) {
                  return Center(child: Text(searchState.message));
                }
                
                final favoriteList = value.restaurantItemList ?? [];
                return switch (favoriteList.isNotEmpty) {
                  true => ListView.builder(
                    itemCount: favoriteList.length,
                    itemBuilder: (context, index) {
                      final restaurant = favoriteList[index];

                      return RestaurantCard(
                        restaurant: restaurant,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider(
                                create: (context) => RestaurantDetailProvider(
                                  context.read<ApiServices>(),
                                )..fetchRestaurantDetail(restaurant.id),
                                child: DetailScreen(
                                  restaurantId: restaurant.id,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  _ => const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text("No Favorite")],
                    ),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
