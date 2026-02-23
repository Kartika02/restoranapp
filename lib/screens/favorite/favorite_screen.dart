import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restoranapp/providers/favorite/local_database_provider.dart';
//import 'package:restoranapp/providers/home/restaurant_search_provider.dart';
import 'package:restoranapp/screens/home/restaurant_card_widget.dart';
import 'package:restoranapp/static/navigation_route.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // String _query = '';
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LocalDatabaseProvider>().loadAllFavoritesValue();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final favoriteProvider = context.watch<LocalDatabaseProvider>();
    // final searchProvider = context.read<RestaurantSearchProvider>();

    // final filteredList = searchProvider.filterFavorites(
    //   favoriteProvider.favorites ?? [],
    //   _query,
    // );
    return Scaffold(
      appBar: AppBar(title: const Text("Favorite List")),
      // todo-03-action-01: change this provider to LocalDatabaseProvider
      body: Consumer<LocalDatabaseProvider>(
        builder: (context, value, child) {
          final favoriteList = value.favorites ?? [];
          return switch (favoriteList.isNotEmpty) {
            true => ListView.builder(
              itemCount: favoriteList.length,
              itemBuilder: (context, index) {
                final restaurant = favoriteList[index];

                return RestaurantCard(
                  restaurant: restaurant,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      NavigationRoute.detailRoute.name,
                      arguments: restaurant.id,
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
      // Column(
      //   children: [
      //     Padding(
      //       padding: const EdgeInsets.all(12),
      //       child: TextField(
      //         decoration: const InputDecoration(
      //           hintText: "Search favorite...",
      //           prefixIcon: Icon(Icons.search),
      //         ),
      //         onChanged: (value) {
      //           setState(() {
      //             _query = value;
      //           });
      //         },
      //       ),
      //     ),

      //     Expanded(
      //       child: filteredList.isNotEmpty
      //           ? ListView.builder(
      //               itemCount: filteredList.length,
      //               itemBuilder: (context, index) {
      //                 final restaurantItem = filteredList[index];

      //                 return RestaurantCard(
      //                   restaurant: restaurantItem,
      //                   onTap: () {
      //                     Navigator.pushNamed(
      //                       context,
      //                       NavigationRoute.detailRoute.name,
      //                       arguments: restaurantItem.id,
      //                     );
      //                   },
      //                 );
      //               },
      //             )
      //           : const Center(child: Text("No favorite restaurant found")),
      //     ),
      //   ],
      // ),
    );
  }
}
