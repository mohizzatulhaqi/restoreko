import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restoreko/models/restaurant.dart';
import 'package:restoreko/widgets/restaurant_card.dart';

void main() {
  final testRestaurant = Restaurant(
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

  testWidgets('RestaurantCard displays restaurant information', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantCard(restaurant: testRestaurant),
        ),
      ),
    );

    expect(find.text('Test Restaurant'), findsOneWidget);
    expect(find.text('Test City'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
  });

  testWidgets('RestaurantCard shows correct image', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestaurantCard(restaurant: testRestaurant),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as NetworkImage).url,
      contains('https://restaurant-api.dicoding.dev/images/medium/1'),
    );
  });

  testWidgets('RestaurantCard has tap functionality', (WidgetTester tester) async {
    bool wasTapped = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              GestureDetector(
                key: const Key('test_gesture_detector'),
                onTap: () => wasTapped = true,
                child: RestaurantCard(restaurant: testRestaurant),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('test_gesture_detector')));
    await tester.pump();

    expect(wasTapped, isTrue);
  });
}
