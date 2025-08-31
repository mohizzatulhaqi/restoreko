import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restoreko/providers/favorite_provider.dart';
import 'package:restoreko/widgets/favorite_button.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../models/menu_item.dart' as menu_item_model;
import '../providers/restaurant_detail_provider.dart';
import '../widgets/review_form.dart';
import '../widgets/menu/menu_section.dart';

class RestaurantDetailPage extends StatefulWidget {
  final String restaurantId;

  const RestaurantDetailPage({super.key, required this.restaurantId});

  @override
  _RestaurantDetailPageState createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<RestaurantDetailProvider>().load(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, provider, _) {
          final state = provider.state;

          if (state.isLoading && state.restaurant == null) {
            return _buildLoadingSkeleton();
          }

          if (state.error != null && state.restaurant == null) {
            return _buildErrorState(provider);
          }

          final restaurant = state.restaurant;
          if (restaurant == null) {
            return const Center(child: Text('Restoran tidak ditemukan'));
          }

          return _buildContent(context, restaurant, provider);
        },
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
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
                  Container(height: 20, width: 200, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(width: 16, height: 16, color: Colors.grey[300]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(height: 14, color: Colors.grey[300]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    5,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Container(height: 80, color: Colors.grey[200]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(RestaurantDetailProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gagal memuat data. Silakan periksa koneksi internet Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                provider.load(widget.restaurantId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext ctx,
    Restaurant restaurant,
    RestaurantDetailProvider provider,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.refresh(widget.restaurantId);
      },
      child: CustomScrollView(
        controller: provider.scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            actions: [
              Consumer<FavoriteProvider>(
                builder: (context, favProvider, _) {
                  return FutureBuilder<bool>(
                    future: favProvider.isFavorite(restaurant.id),
                    builder: (context, snapshot) {
                      final isFav = snapshot.data ?? false;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12, top: 2),
                        child: FavoriteButton(
                          isFavorite: isFav,
                          onTap: () => favProvider.toggleFavorite(restaurant),
                          restaurantName: restaurant.name,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
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
                  // Restaurant info
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${restaurant.city}, ${restaurant.address}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Categories
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

                  // Description
                  Text(
                    'Deskripsi',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<RestaurantDetailProvider>(
                    builder: (context, provider, _) {
                      final isExpanded = provider.isDescriptionExpanded;
                      final text = restaurant.description;
                      final textPainter =
                          TextPainter(
                            text: TextSpan(
                              text: text,
                              style: const TextStyle(fontSize: 14),
                            ),
                            maxLines: 3,
                            textDirection: TextDirection.ltr,
                          )..layout(
                            maxWidth: MediaQuery.of(context).size.width - 32,
                          );

                      final shouldShowButton = textPainter.didExceedMaxLines;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            text,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: Colors.grey[700],
                            ),
                            maxLines: isExpanded ? null : 3,
                            overflow: isExpanded ? null : TextOverflow.ellipsis,
                          ),
                          if (shouldShowButton)
                            TextButton(
                              onPressed: () {
                                provider.toggleDescriptionExpanded();
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                isExpanded ? 'Lebih Sedikit' : 'Selengkapnya',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Menu Section
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
                        .map(
                          (item) => menu_item_model.MenuItem(name: item.name),
                        )
                        .toList(),
                    cardColor: const Color(0xFFFFF3E0),
                    icon: Icons.restaurant_menu,
                  ),
                  const SizedBox(height: 8),
                  MenuSection(
                    title: 'Minuman',
                    items: restaurant.menu.drinks
                        .map(
                          (item) => menu_item_model.MenuItem(name: item.name),
                        )
                        .toList(),
                    cardColor: const Color(0xFFE3F2FD),
                    icon: Icons.local_drink,
                  ),
                  const SizedBox(height: 16),

                  ReviewForm(
                    restaurantId: restaurant.id,
                    onSuccess: () {
                      Future.delayed(const Duration(milliseconds: 500), () {
                        provider.scrollToBottom();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Text(
                        'Ulasan Pelanggan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      const Spacer(),
                      if (restaurant.customerReviews.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${restaurant.customerReviews.length} ulasan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[800],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Divider(color: Colors.grey, thickness: 1),
                  const SizedBox(height: 8),

                  if (restaurant.customerReviews.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada ulasan',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Jadilah yang pertama memberikan ulasan!',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: restaurant.customerReviews
                          .map(
                            (review) => _buildReviewCard(ctx, review, provider),
                          )
                          .toList(),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(Category category) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      child: Chip(
        label: Text(
          category.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.orange[600],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildReviewCard(
    BuildContext ctx,
    CustomerReview review,
    RestaurantDetailProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange[100],
                  radius: 20,
                  child: Icon(
                    Icons.person,
                    color: Colors.orange[800],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        provider.formatDate(review.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ) ?? TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                review.review,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      height: 1.5,
                    ) ?? const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}