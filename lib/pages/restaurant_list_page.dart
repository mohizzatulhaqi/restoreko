import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../widgets/restaurant_card.dart';
import '../widgets/search_bar.dart';
import '../providers/restaurant_provider.dart';
import 'restaurant_detail_page.dart';
import '../widgets/error_view.dart';

class RestaurantListPage extends StatefulWidget {
  const RestaurantListPage({super.key});

  @override
  _RestaurantListPageState createState() => _RestaurantListPageState();
}

class _RestaurantListPageState extends State<RestaurantListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        context.read<RestaurantProvider>().fetchRestaurants();
      } else {
        context.read<RestaurantProvider>().searchRestaurants(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final state = provider.state;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESTOREKO',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rekomendasi restoran terbaik untuk Anda',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SearchBarWidget(
                      controller: _searchController,
                      onSubmitted: (query) {
                        if (query.isNotEmpty) {
                          provider.searchRestaurants(query);
                        } else {
                          provider.fetchRestaurants();
                        }
                      },
                      onChanged: _onSearchChanged,
                      hintText: 'Cari restoran...',
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          if (state.isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Skeletonizer(
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.horizontal(
                                  left: Radius.circular(16),
                                ),
                                child: Container(
                                  width: 120,
                                  height: 140,
                                  color: Colors.grey[300],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 16,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 16,
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.4,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Container(
                                              height: 14,
                                              color: Colors.grey[300],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        height: 24,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }, childCount: 6),
              ),
            )
          else if (state.error != null)
            SliverFillRemaining(
              child: Center(
                child: ErrorView(
                  title: 'Gagal Memuat Data',
                  message: state.error!,
                  onRetry: () {
                    if (_searchController.text.isNotEmpty) {
                      provider.searchRestaurants(_searchController.text);
                    } else {
                      provider.fetchRestaurants();
                    }
                  },
                ),
              ),
            )
          else if (state.restaurants.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      state.isSearching
                          ? 'Tidak ada hasil untuk "${_searchController.text}"'
                          : 'Tidak ada restoran yang tersedia',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (state.isSearching) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _searchController.clear();
                          provider.fetchRestaurants();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[800],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Tampilkan Semua'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else if (state.restaurants.isNotEmpty) ...[
            if (state.isSearching)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    '${state.restaurants.length} hasil ditemukan',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final restaurant = state.restaurants[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: RestaurantCard(
                      restaurant: restaurant,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RestaurantDetailPage(
                              restaurantId: restaurant.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }, childCount: state.restaurants.length),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
