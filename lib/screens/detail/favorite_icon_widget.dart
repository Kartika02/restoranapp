import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restoranapp/data/model/restaurant_item.dart';
import 'package:restoranapp/providers/detail/favorite_icon_provider.dart';
import 'package:restoranapp/providers/favorite/local_database_provider.dart';

class FavoriteIconWidget extends StatefulWidget {
  final RestaurantItem restaurantItem;

  const FavoriteIconWidget({super.key, required this.restaurantItem});
  @override
  State<FavoriteIconWidget> createState() => _FavoriteIconWidgetState();
}

class _FavoriteIconWidgetState extends State<FavoriteIconWidget> {
  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final provider = context.read<LocalDatabaseProvider>();
    final isFav = await provider.checkItemFavorite(widget.restaurantItem.id);

    if (!mounted) return;

    context.read<FavoriteIconProvider>().isFavorite = isFav;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        // todo-03-action-04: change this action using LocalDatabaseProvider
        final localDatabaseProvider = context.read<LocalDatabaseProvider>();
        final favoriteIconWidget = context.read<FavoriteIconProvider>();
        final isFavorite = favoriteIconWidget.isFavorite;

        // todo-03-action-05: change this action using LocalDatabaseProvider
        if (isFavorite) {
          await localDatabaseProvider.removeFavoritesValueById(
            widget.restaurantItem.id,
          );
        } else {
          await localDatabaseProvider.saveFavoritesValue(widget.restaurantItem);
        }
        favoriteIconWidget.isFavorite = !isFavorite;
        // todo-03-action-06: add this action to load the page
        localDatabaseProvider.loadAllFavoritesValue();
      },
      icon: Icon(
        context.watch<FavoriteIconProvider>().isFavorite
            ? Icons.favorite
            : Icons.favorite_border_outlined,
      ),
    );
  }
}
