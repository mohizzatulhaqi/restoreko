import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:restoreko/models/restaurant.dart';
import 'package:restoreko/pages/restaurant_list_page.dart';
import 'package:restoreko/providers/restaurant_provider.dart';
import 'package:restoreko/services/restaurant_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MockRestaurantService extends Mock implements RestaurantService {}

Restaurant createMockRestaurant() {
  return Restaurant(
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
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockRestaurantService mockService;
  late RestaurantProvider provider;
  final mockRestaurant = createMockRestaurant();

  setUp(() {
    mockService = MockRestaurantService();
    provider = RestaurantProvider(service: mockService);
  });

  testWidgets('App shows loading state when fetching restaurants', (
    tester,
  ) async {
    when(() => mockService.fetchRestaurants()).thenAnswer(
      (_) => Future.delayed(const Duration(seconds: 1), () => [mockRestaurant]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<RestaurantProvider>.value(
          value: provider,
          child: const RestaurantListPage(),
        ),
      ),
    );

    provider.fetchRestaurants();
    await tester.pump();

    final loadingIndicators = find.byWidgetPredicate(
      (widget) =>
          widget is CircularProgressIndicator ||
          widget is Skeletonizer ||
          (widget is Text &&
              (widget.data?.toLowerCase().contains('loading') ?? false)),
    );

    expect(
      loadingIndicators,
      findsAtLeast(1),
      reason: 'Expected to find at least one loading indicator',
    );
  });

  testWidgets('App shows restaurant list after successful load', (
    tester,
  ) async {
    when(
      () => mockService.fetchRestaurants(),
    ).thenAnswer((_) async => [mockRestaurant]);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<RestaurantProvider>.value(
          value: provider,
          child: const RestaurantListPage(),
        ),
      ),
    );

    await provider.fetchRestaurants();
    await tester.pumpAndSettle();

    expect(find.text('Test Restaurant'), findsOneWidget);
    expect(find.text('Test City'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
  });

  testWidgets('App shows error message when fetch fails', (tester) async {
    final errorMessage = 'Test error message';
    when(
      () => mockService.fetchRestaurants(),
    ).thenThrow(Exception(errorMessage));

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<RestaurantProvider>.value(
          value: provider,
          child: const RestaurantListPage(),
        ),
      ),
    );

    await provider.fetchRestaurants();
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(
      find.text('Terjadi Kesalahan'),
      findsOneWidget,
      reason: 'Expected to find error message "Terjadi Kesalahan"',
    );

    expect(
      find.byType(SliverFillRemaining),
      findsOneWidget,
      reason: 'Expected to see error state with SliverFillRemaining',
    );
  });
}
