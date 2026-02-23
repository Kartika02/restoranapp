import 'package:restoranapp/data/model/restaurant_item.dart';

class RestaurantSearchResponse {
  final bool error;
  final int founded;
  final List<RestaurantItem> restaurants;

  RestaurantSearchResponse({
    required this.error,
    required this.founded,
    required this.restaurants,
  });

  factory RestaurantSearchResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantSearchResponse(
      error: json['error'],
      founded: json['founded'],
      restaurants: (json['restaurants'] as List)
          .map((e) => RestaurantItem.fromJson(e))
          .toList(),
    );
  }
}
