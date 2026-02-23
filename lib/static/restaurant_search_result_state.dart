import 'package:restoranapp/data/model/restaurant_item.dart';

abstract class RestaurantSearchResultState {}

class RestaurantSearchNoneState extends RestaurantSearchResultState {}

class RestaurantSearchLoadingState extends RestaurantSearchResultState {}

class RestaurantSearchLoadedState extends RestaurantSearchResultState {
  final List<RestaurantItem> restaurants;
  RestaurantSearchLoadedState(this.restaurants);
}

class RestaurantSearchErrorState extends RestaurantSearchResultState {
  final String message;
  RestaurantSearchErrorState(this.message);
}
