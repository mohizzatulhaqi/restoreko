import 'dart:async';
import 'package:mockito/mockito.dart';
import 'package:restoreko/models/api_result.dart';
import 'package:restoreko/models/restaurant.dart';
import 'package:restoreko/services/restaurant_service.dart';

class MockRestaurantService extends Mock implements RestaurantService {
  final List<Restaurant> mockRestaurants = [];
  
  MockRestaurantService() {
    mockRestaurants.add(createMockRestaurant());
  }
  
  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    return super.noSuchMethod(
      Invocation.method(#fetchRestaurants, []),
      returnValue: Future.value(mockRestaurants),
      returnValueForMissingStub: Future.value(mockRestaurants),
    );
  }
  
  @override
  Future<Restaurant> fetchRestaurantDetail(String id) async {
    return super.noSuchMethod(
      Invocation.method(#fetchRestaurantDetail, [id]),
      returnValue: Future.value(mockRestaurants.firstWhere((r) => r.id == id)),
      returnValueForMissingStub: Future.value(mockRestaurants.first),
    );
  }
  
  @override
  Future<ApiResult> searchRestaurants(String query) async {
    return super.noSuchMethod(
      Invocation.method(#searchRestaurants, [query]),
      returnValue: Future.value(ApiResult(
        error: false,
        message: 'success',
        count: 1,
        restaurants: mockRestaurants,
      )),
      returnValueForMissingStub: Future.value(ApiResult(
        error: false,
        message: 'success',
        count: 1,
        restaurants: mockRestaurants,
      )),
    );
  }
  
  @override
  Future<Restaurant> getRandomRestaurant() async {
    return super.noSuchMethod(
      Invocation.method(#getRandomRestaurant, []),
      returnValue: Future.value(mockRestaurants.first),
      returnValueForMissingStub: Future.value(mockRestaurants.first),
    );
  }
}

Restaurant createMockRestaurant() {
  return Restaurant(
    id: '1',
    name: 'Test Restaurant',
    description: 'Test Description',
    city: 'Test City',
    address: '123 Test St',
    rating: 4.5,
    pictureId: '1',
    menu: Menu(
      foods: [
        MenuItem(name: 'Food 1'),
        MenuItem(name: 'Food 2'),
      ],
      drinks: [
        MenuItem(name: 'Drink 1'),
        MenuItem(name: 'Drink 2'),
      ],
    ),
  );
}
