import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart' as menu_item_model;
import '../services/restaurant_service.dart';
import '../widgets/review_form.dart';
import '../widgets/menu/menu_section.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  late Future<Restaurant> _restaurantFuture;
  late final RestaurantService _service;
  final ScrollController _scrollController = ScrollController();
  Restaurant? _restaurantOverride;

  @override
  void initState() {
    super.initState();
    _service = Provider.of<RestaurantService>(context, listen: false);
    _loadRestaurant();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadRestaurant() {
    setState(() {
      _restaurantFuture = _service.fetchRestaurantDetail(widget.restaurantId);
      _restaurantOverride = null;
    });
  }

  void _scrollToReviews() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleReviewSubmitted(
    Restaurant updatedRestaurant,
    CustomerReview optimistic,
  ) {
    setState(() {
      final existing = List<CustomerReview>.from(
        updatedRestaurant.customerReviews,
      );
      final alreadyExists = existing.any(
        (r) => r.name == optimistic.name && r.review == optimistic.review,
      );
      if (!alreadyExists) {
        existing.add(optimistic);
      }

      final merged = Restaurant(
        id: updatedRestaurant.id,
        name: updatedRestaurant.name,
        description: updatedRestaurant.description,
        pictureId: updatedRestaurant.pictureId,
        city: updatedRestaurant.city,
        address: updatedRestaurant.address,
        rating: updatedRestaurant.rating,
        menu: updatedRestaurant.menu,
        categories: updatedRestaurant.categories,
        customerReviews: existing,
        isFavorite: updatedRestaurant.isFavorite,
      );

      _restaurantFuture = Future.value(merged);
      _restaurantOverride = merged;
    });
    _scrollToReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Restaurant>(
        future: _restaurantFuture,
        builder: (context, snapshot) {
          if (_restaurantOverride != null) {
            final restaurant = _restaurantOverride!;
            return _buildContent(restaurant);
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return Skeletonizer(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 250,
                      child: ColoredBox(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            width: 200,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  height: 14,
                                  color: Colors.grey[300],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 40,
                                height: 14,
                                color: Colors.grey[300],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              3,
                              (i) => Container(
                                width: 70,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 18,
                            width: 100,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Container(height: 14, color: Colors.grey[300]),
                          const SizedBox(height: 6),
                          Container(
                            height: 14,
                            width: 280,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 18,
                            width: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 18,
                            width: 160,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          ...List.generate(
                            3,
                            (i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                height: 80,
                                color: Colors.grey[200],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Restoran tidak ditemukan'));
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(Restaurant restaurant) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Hero(
              tag: 'restaurant-title-${restaurant.id}',
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  restaurant.name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 3.0,
                        // ignore: deprecated_member_use
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            background: Hero(
              tag: 'restaurant-${restaurant.id}',
              child: Image.network(
                restaurant.largeImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.restaurant, size: 100),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${restaurant.city}, ${restaurant.address}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    const Icon(Icons.star, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.rating.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (restaurant.categories.isNotEmpty) ...[
                  Text(
                    'Kategori',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: restaurant.categories
                        .map((category) => _buildCategoryChip(category))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                Text(
                  'Deskripsi',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  restaurant.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  'Menu',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const Divider(color: Colors.grey, thickness: 1),

                const SizedBox(height: 8),
                MenuSection(
                  title: 'Makanan',
                  items: restaurant.menu.foods
                      .map((item) => menu_item_model.MenuItem(name: item.name))
                      .toList(),
                  cardColor: const Color(0xFFFFF3E0),
                  icon: Icons.restaurant_menu,
                ),

                const SizedBox(height: 8),
                MenuSection(
                  title: 'Minuman',
                  items: restaurant.menu.drinks
                      .map((item) => menu_item_model.MenuItem(name: item.name))
                      .toList(),
                  cardColor: const Color(0xFFE3F2FD),
                  icon: Icons.local_drink,
                ),

                const SizedBox(height: 16),
                ReviewForm(
                  restaurantId: restaurant.id,
                  onReviewSubmitted: _handleReviewSubmitted,
                ),

                const SizedBox(height: 16),
                Text(
                  'Ulasan Pelanggan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                const Divider(color: Colors.grey, thickness: 1),
                const SizedBox(height: 8),
                if (restaurant.customerReviews.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Tidak ada ulasan',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...restaurant.customerReviews
                      .map((review) => _buildReviewCard(review))
                      .toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(Category category) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Chip(
        label: Text(category.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange[600],
      ),
    );
  }

  Widget _buildReviewCard(CustomerReview review) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  child: Icon(Icons.person, color: Colors.orange[800]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(review.date),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.review, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MM yy', 'id_ID').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
