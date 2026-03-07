// todo-02-provider-01: create a new provider that handle dependency injection
import 'package:flutter/widgets.dart';
import 'package:restoranapp/data/local/local_database_service.dart';
import 'package:restoranapp/data/model/restaurant_item.dart';

class LocalDatabaseProvider extends ChangeNotifier {
  // todo-02-provider-02: inject sqlite service
  final LocalDatabaseService _service;

  LocalDatabaseProvider(this._service);

  String _message = "";
  String get message => _message;

  List<RestaurantItem>? _restaurantItemList = [];
  List<RestaurantItem>? get restaurantItemList => _restaurantItemList;

  List<RestaurantItem>? _filteredRestaurantList = [];
  List<RestaurantItem>? get filteredRestaurantList => _filteredRestaurantList;

  RestaurantItem? _restaurantItem;
  RestaurantItem? get restaurantItem => _restaurantItem;

  Future<void> searchFavorites(String query) async {
    if (_restaurantItemList == null) return;
    if (query.isEmpty) {
      _filteredRestaurantList = _restaurantItemList;
    } else {
      _filteredRestaurantList = _restaurantItemList!
          .where(
            (restaurant) =>
                restaurant.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }

    notifyListeners();
  }

  // todo-02-provider-04: add a function to save a RestauratItem value
  Future<void> saveFavoritesValue(RestaurantItem value) async {
    try {
      final result = await _service.insertItem(value);

      final isError = result == 0;
      if (isError) {
        _message = "Failed to save your data";
      } else {
        print("INSERT ID: ${value.id}");
        _message = "Your data is saved";
      }
      await loadAllFavoritesValue();
      notifyListeners();
    } catch (e) {
      _message = "Failed to save your data";
      notifyListeners();
    }
  }

  // todo-02-provider-05: add a function to load all RestauratItem value
  Future<void> loadAllFavoritesValue() async {
    try {
      _restaurantItemList = await _service.getAllItems();
      _filteredRestaurantList = _restaurantItemList;
      _message = "All of your data is loaded";
      notifyListeners();
    } catch (e) {
      _message = "Failed to load your all data";
      notifyListeners();
    }
  }

  // todo-02-provider-06: add a function to load RestauratItem value based on id
  Future<void> loadFavoritesValueById(String id) async {
    try {
      _restaurantItem = await _service.getItemById(id);
      _message = "Your data is loaded";
      notifyListeners();
    } catch (e) {
      _message = "Failed to load your data";
      notifyListeners();
    }
  }

  // todo-02-provider-07: add a function to remove tourism value based on id
  Future<void> removeFavoritesValueById(String id) async {
    try {
      await _service.removeItem(id);
      _message = "Your data is removed";
      await loadAllFavoritesValue();
      notifyListeners();
    } catch (e) {
      _message = "Failed to remove your data";
      notifyListeners();
    }
  }

  Future<bool> checkItemFavorite(String id) async {
    final result = await _service.getItemById(id);
    return result != null;
  }
}
