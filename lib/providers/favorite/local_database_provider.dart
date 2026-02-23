// todo-02-provider-01: create a new provider that handle dependency injection
import 'package:flutter/widgets.dart';
import 'package:restoranapp/data/local/local_database_service.dart';
import 'package:restoranapp/data/model/restaurant_item.dart';

class LocalDatabaseProvider extends ChangeNotifier {
  // todo-02-provider-02: inject sqlite service
  final LocalDatabaseService _service;

  LocalDatabaseProvider(this._service);

  // todo-02-provider-03: add a state to load a saving process and load a getting value process
  String _message = "";
  String get message => _message;

  List<RestaurantItem>? _restaurantItemList = [];
  List<RestaurantItem>? get favorites => _restaurantItemList;

  RestaurantItem? _restaurantItem;
  RestaurantItem? get restaurantItem => _restaurantItem;

  // todo-02-provider-04: add a function to save a RestauratItem value
  Future<void> saveFavoritesValue(RestaurantItem value) async {
    try {
      final result = await _service.insertItem(value);

      final isError = result == 0;
      if (isError) {
        _message = "Failed to save your data";
        notifyListeners();
      } else {
        _message = "Your data is saved";
        await loadAllFavoritesValue();
        notifyListeners();
      }
    } catch (e) {
      _message = "Failed to save your data";
      notifyListeners();
    }
  }

  // todo-02-provider-05: add a function to load all RestauratItem value
  Future<void> loadAllFavoritesValue() async {
    try {
      _restaurantItemList = await _service.getAllItems();
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

  bool checkItemFavorite(String id) {
    final isSameRestaurant = _restaurantItem?.id == id;
    return isSameRestaurant;
  }
}
