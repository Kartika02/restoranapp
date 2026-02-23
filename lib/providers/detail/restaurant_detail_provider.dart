import 'package:flutter/widgets.dart';
import 'package:restoranapp/data/api/api_service.dart';
import 'package:restoranapp/static/restaurant_detail_result_state.dart';

class RestaurantDetailProvider extends ChangeNotifier {
  final ApiServices _apiServices;
  bool _reviewSuccess = false;
  bool get reviewSuccess => _reviewSuccess;
  bool _reviewError = false;
  String _reviewErrorMessage = "";

  bool get reviewError => _reviewError;
  String get reviewErrorMessage => _reviewErrorMessage;

  RestaurantDetailProvider(this._apiServices);

  RestaurantDetailResultState _resultState = RestaurantDetailNoneState();

  RestaurantDetailResultState get resultState => _resultState;

  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _resultState = RestaurantDetailLoadingState();
      notifyListeners();

      final result = await _apiServices.getRestaurantDetail(id);

      if (result.error) {
        _resultState = RestaurantDetailErrorState(
          _mapErrorToMessage(result.message),
        );
      } else {
        _resultState = RestaurantDetailLoadedState(result.restaurant);
      }
    } on Exception catch (e) {
      _resultState = RestaurantDetailErrorState(_mapErrorToMessage(e));
    }
    notifyListeners();
  }

  Future<void> addReview(String id, String name, String review) async {
    try {
      await _apiServices.postReview(id, name, review);

      _reviewSuccess = false;
      _reviewError = false;
      _reviewErrorMessage = "";
      notifyListeners();

      await _apiServices.postReview(id, name, review);
      _reviewSuccess = true;
      await fetchRestaurantDetail(id);
    } catch (e) {
      _reviewSuccess = false;
      _reviewError = true;
      _reviewErrorMessage = "Gagal mengirim review. Periksa koneksi internet.";
      notifyListeners();
    }
  }

  void resetReviewStatus() {
    _reviewSuccess = false;
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
