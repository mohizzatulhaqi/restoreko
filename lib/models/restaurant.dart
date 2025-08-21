class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'] as String,
    );
  }
}

class CustomerReview {
  final String name;
  final String review;
  final String date;

  CustomerReview({
    required this.name,
    required this.review,
    required this.date,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      name: json['name'] as String,
      review: json['review'] as String,
      date: json['date'] as String,
    );
  }
}

class MenuItem {
  final String name;

  MenuItem({required this.name});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'] as String,
    );
  }
}

class Menu {
  final List<MenuItem> foods;
  final List<MenuItem> drinks;

  Menu({required this.foods, required this.drinks});

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      foods: (json['foods'] as List<dynamic>? ?? [])
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      drinks: (json['drinks'] as List<dynamic>? ?? [])
          .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String description;
  final String pictureId;
  final String city;
  final String address;
  final double rating;
  final Menu menu;
  final List<Category> categories;
  final List<CustomerReview> customerReviews;
  final bool isFavorite;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.pictureId,
    required this.city,
    required this.address,
    required this.rating,
    required this.menu,
    List<Category>? categories,
    List<CustomerReview>? customerReviews,
    this.isFavorite = false,
  })  : categories = categories ?? [],
        customerReviews = customerReviews ?? [];

  String get imageUrl => 'https://restaurant-api.dicoding.dev/images/medium/$pictureId';
  String get largeImageUrl => 'https://restaurant-api.dicoding.dev/images/large/$pictureId';

  Restaurant copyWith({
    bool? isFavorite,
  }) {
    return Restaurant(
      id: id,
      name: name,
      description: description,
      pictureId: pictureId,
      city: city,
      address: address,
      rating: rating,
      menu: menu,
      categories: categories,
      customerReviews: customerReviews,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      pictureId: json['pictureId'] as String,
      city: json['city'] as String,
      address: json['address'] as String? ?? '',
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] as num).toDouble(),
      menu: json['menus'] != null 
          ? Menu.fromJson(json['menus'] as Map<String, dynamic>)
          : Menu(foods: [], drinks: []),
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList(),
      customerReviews: (json['customerReviews'] as List<dynamic>? ?? [])
          .map((e) => CustomerReview.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

