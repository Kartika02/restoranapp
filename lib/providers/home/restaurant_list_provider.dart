import 'package:flutter/widgets.dart';
import 'package:restoranapp/data/api/api_service.dart';

import 'package:restoranapp/static/restaurant_list_result_state.dart';

class RestaurantListProvider extends ChangeNotifier {
  final ApiServices _apiServices;

  RestaurantListProvider(this._apiServices);

  RestaurantListResultState _resultState = RestaurantListNoneState();

  RestaurantListResultState get resultState => _resultState;

  Future<void> fetchRestaurantList() async {
    try {
      _resultState = RestaurantListLoadingState();
      notifyListeners();

      final result = await _apiServices.getRestaurantList();

      if (result.error) {
        _resultState = RestaurantListErrorState(
          _mapErrorToMessage(result.message),
        );
        notifyListeners();
      } else {
        _resultState = RestaurantListLoadedState(result.restaurants);
        notifyListeners();
      }
    } on Exception catch (e) {
      _resultState = RestaurantListErrorState(_mapErrorToMessage(e));
      notifyListeners();
    }
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
