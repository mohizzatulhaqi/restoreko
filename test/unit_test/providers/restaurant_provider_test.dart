import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:restoreko/models/restaurant.dart';
import 'package:restoreko/providers/restaurant_provider.dart';
import 'package:restoreko/services/restaurant_service.dart';

class MockRestaurantService extends Mock implements RestaurantService {}

void main() {
  late MockRestaurantService mockService;
  late RestaurantProvider provider;

  final tRestaurants = [
    Restaurant(
      id: '1',
      name: 'Test Restaurant',
      description: 'Test Description',
      pictureId: '1',
      city: 'Test City',
      address: 'Test Address',
      rating: 4.5,
      menu: Menu(foods: [], drinks: []),
      categories: [],
      customerReviews: [],
    ),
  ];

  setUpAll(() {
    registerFallbackValue(tRestaurants);
  });

  setUp(() {
    mockService = MockRestaurantService();
    provider = RestaurantProvider(service: mockService);
  });

  test('initial state should be correct', () {
    expect(provider.state.isLoading, false);
    expect(provider.state.restaurants, isEmpty);
    expect(provider.state.error, isNull);
    expect(provider.state.isSearching, false);
    expect(provider.state.searchResultCount, 0);
  });

  test(
    'should update state with restaurants when fetch is successful',
    () async {
      when(
        () => mockService.fetchRestaurants(),
      ).thenAnswer((_) async => tRestaurants);

      await provider.fetchRestaurants();

      expect(provider.state.isLoading, false);
      expect(provider.state.restaurants, tRestaurants);
      expect(provider.state.error, isNull);

      verify(() => mockService.fetchRestaurants()).called(1);
    },
  );

  test('should update state with error when fetch fails', () async {
    final errorMessage = 'Failed to fetch restaurants';
    when(
      () => mockService.fetchRestaurants(),
    ).thenThrow(Exception(errorMessage));

    await provider.fetchRestaurants();

    expect(provider.state.isLoading, false);
    expect(provider.state.restaurants, isEmpty);
    expect(provider.state.error, isNotNull);
    expect(provider.state.error, contains(errorMessage));

    verify(() => mockService.fetchRestaurants()).called(1);
  });
}
