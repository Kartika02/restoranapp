import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restoranapp/data/api/api_service.dart';
import 'package:restoranapp/providers/detail/restaurant_detail_provider.dart';
import 'package:restoranapp/providers/home/restaurant_list_provider.dart';
import 'package:restoranapp/providers/home/restaurant_search_provider.dart';
import 'package:restoranapp/providers/main/theme_provider.dart';
import 'package:restoranapp/screens/detail/detail_screen.dart';
import 'package:restoranapp/screens/home/restaurant_card_widget.dart';
import 'package:restoranapp/screens/setting/notification_screen.dart';
import 'package:restoranapp/static/restaurant_list_result_state.dart';
import 'package:restoranapp/static/restaurant_search_result_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RestaurantListProvider>().fetchRestaurantList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<RestaurantSearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant'),
        centerTitle: false,
        actions: [
          Row(
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return IconButton(
                    icon: Icon(
                      themeProvider.isDarkMode
                          ? Icons
                                .dark_mode // 🌙
                          : Icons.light_mode, // 🌞
                    ),
                    onPressed: () {
                      themeProvider.toggleTheme(!themeProvider.isDarkMode);
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: "Settings",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsPage()),
                  );
                },
              ),
            ],
          ),
        ],
      ),

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
            child: Consumer2<RestaurantListProvider, RestaurantSearchProvider>(
              builder: (context, listProvider, searchProvider, _) {
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

                final listState = listProvider.resultState;

                return switch (listState) {
                  RestaurantListLoadingState() => const Center(
                    child: CircularProgressIndicator(),
                  ),

                  RestaurantListLoadedState(data: var restaurants) =>
                    ListView.builder(
                      itemCount: restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = restaurants[index];
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

                  RestaurantListErrorState(error: var message) => Center(
                    child: Text(message),
                  ),

                  _ => const SizedBox(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}
