import 'dart:async';

import 'package:flutter/material.dart';
import 'package:restoranapp/data/api/api_service.dart';
import 'package:restoranapp/data/model/restaurant_item.dart';
import 'package:restoranapp/static/restaurant_search_result_state.dart';

class RestaurantSearchProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  RestaurantSearchProvider(this._apiServices);

  RestaurantSearchResultState _state = RestaurantSearchNoneState();

  RestaurantSearchResultState get state => _state;

  List<RestaurantItem> _restaurants = [];
  List<RestaurantItem> get restaurants => _restaurants;
  List<RestaurantItem> filterFavorites(
    List<RestaurantItem> favorites,
    String query,
  ) {
    if (query.isEmpty) return favorites;

    return favorites.where((restaurant) {
      return restaurant.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Future<void> searchRestaurant(String query) async {
    if (query.isEmpty) return;

    _state = RestaurantSearchLoadingState();
    notifyListeners();

    try {
      final result = await _apiServices.searchRestaurant(query);

      if (result.restaurants.isEmpty) {
        _state = RestaurantSearchErrorState('Data tidak ditemukan');
      } else {
        _restaurants = result.restaurants;
        _state = RestaurantSearchLoadedState(_restaurants);
      }
    } catch (e) {
      _state = RestaurantSearchErrorState(_mapErrorToMessage(e));
    }

    notifyListeners();
  }

  void reset() {
    _state = RestaurantSearchNoneState();
    _restaurants = [];
    notifyListeners();
  }

  String _mapErrorToMessage(Object error) {
    if (error.toString().contains('SocketException')) {
      return 'Gagal terhubung ke internet. Periksa koneksi kamu dan coba lagi.';
    } else if (error.toString().contains('ClientException')) {
      return 'Gagal terhubung ke server. Silakan coba lagi.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Waktu koneksi habis. Silakan coba beberapa saat lagi.';
    } else if (error.toString().contains('404')) {
      return 'Data restoran tidak ditemukan.';
    } else {
      return 'Ups! Terjadi kesalahan saat memuat data restoran. Coba lagi ya.';
    }
  }
}
