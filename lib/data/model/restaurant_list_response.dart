import 'package:restoranapp/data/model/restaurant_item.dart';

class RestaurantListResponse {
  final bool error;
  final String message;
  final int count;
  final List<RestaurantItem> restaurants;

  RestaurantListResponse({
    required this.error,
    required this.message,
    required this.count,
    required this.restaurants,
  });

  factory RestaurantListResponse.fromJson(Map<String, dynamic> json) {
    return RestaurantListResponse(
      error: json["error"],
      message: json["message"],
      count: json["count"],
      restaurants: json["restaurants"] != null
          ? List<RestaurantItem>.from(
              json["restaurants"]!.map((x) => RestaurantItem.fromJson(x)),
            )
          : <RestaurantItem>[],
    );
  }
}
