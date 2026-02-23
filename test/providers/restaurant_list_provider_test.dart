import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:restoranapp/data/model/restaurant_list_response.dart';
import 'package:restoranapp/providers/home/restaurant_list_provider.dart';
import 'package:restoranapp/data/api/api_service.dart';
import 'package:restoranapp/static/restaurant_list_result_state.dart';

class MockApiServices extends Mock implements ApiServices {}



void main() {
  late MockApiServices mockApi;
  late RestaurantListProvider provider;

  setUp(() {
    mockApi = MockApiServices();
    provider = RestaurantListProvider(mockApi);
  });

  /// Test state awal
  test('Initial state should be RestaurantListNoneState', () {
    expect(provider.resultState, isA<RestaurantListNoneState>());
  });

  /// Test API berhasil
  test('Should return loaded state when API call is successful', () async {
    final result = RestaurantListResponse(
      error: false,
      message: '',
      count: 1,
      restaurants: [],
    );

    when(mockApi.getRestaurantList()).thenAnswer((_) async => result);

    await provider.fetchRestaurantList();

    expect(provider.resultState, isA<RestaurantListLoadedState>());
  });

  ///  Test API gagal
  test('Should return error state when API call fails', () async {
    when(mockApi.getRestaurantList()).thenThrow(Exception('Failed'));

    await provider.fetchRestaurantList();

    expect(provider.resultState, isA<RestaurantListErrorState>());
  });
}
