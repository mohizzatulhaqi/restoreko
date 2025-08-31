import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:restoreko/models/restaurant.dart';
import 'package:restoreko/pages/restaurant_list_page.dart';
import 'package:restoreko/providers/restaurant_provider.dart';
import 'package:restoreko/services/restaurant_service.dart';

class MockRestaurantService extends Mock implements RestaurantService {
  @override
  Future<List<Restaurant>> fetchRestaurants() async {
    return [
      Restaurant(
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
      ),
    ];
  }

  @override
  Future<Restaurant> fetchRestaurantDetail(String id) async {
    return Restaurant(
      id: id,
      name: 'Test Restaurant',
      description: 'Test Description',
      city: 'Test City',
      address: '123 Test St',
      rating: 4.5,
      pictureId: id,
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
}

void main() {
  late MockRestaurantService mockService;

  setUp(() {
    mockService = MockRestaurantService();
  });

  testWidgets('RestaurantListPage shows restaurant list', (tester) async {
    // Create provider with mock service
    final provider = RestaurantProvider(service: mockService);
    
    // Trigger data fetch
    await provider.fetchRestaurants();
    
    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<RestaurantProvider>.value(
          value: provider,
          child: const RestaurantListPage(),
        ),
      ),
    );

    // Initial build
    await tester.pump();
    
    // Verify loading state is shown (Skeletonizer is used in the UI)
    expect(find.byType(SliverList), findsOneWidget);
    
    // Let the animations complete
    await tester.pumpAndSettle();
    
    // Verify mock data is displayed
    expect(find.text('Test Restaurant'), findsWidgets);
    expect(find.text('Test City'), findsWidgets);
    expect(find.byType(Card), findsWidgets);
  });
}
