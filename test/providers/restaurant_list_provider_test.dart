import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:restoranapp/data/model/restaurant_item.dart';
import 'package:restoranapp/data/model/restaurant_list_response.dart';
import 'package:restoranapp/providers/home/restaurant_list_provider.dart';
import 'package:restoranapp/data/api/api_service.dart';
import 'package:restoranapp/static/restaurant_list_result_state.dart';

import 'restaurant_list_provider_test.mocks.dart';

@GenerateMocks([ApiServices])
void main() {
  late MockApiServices mockApi;
  late RestaurantListProvider provider;

  setUp(() {
    mockApi = MockApiServices();
    provider = RestaurantListProvider(mockApi);
    reset(mockApi);
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
      restaurants: [
        RestaurantItem(
          id: "rqdv5juczeskfw1e867",
          name: "Melting Pot",
          description:
              "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. ...",
          pictureId: "14",
          city: "Medan",
          rating: 4.2,
        ),
      ],
    );
    when(mockApi.getRestaurantList()).thenAnswer((_) async {
      return result;
    });

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
