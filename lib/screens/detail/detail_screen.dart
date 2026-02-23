import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restoranapp/providers/detail/restaurant_detail_provider.dart';
import 'package:restoranapp/providers/favorite/local_database_provider.dart';
import 'package:restoranapp/screens/detail/favorite_icon_widget.dart';
import 'package:restoranapp/static/restaurant_detail_result_state.dart';

class DetailScreen extends StatefulWidget {
  final String restaurantId;

  const DetailScreen({Key? key, required this.restaurantId}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LocalDatabaseProvider>().loadAllFavoritesValue();
  }

  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final reviewController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Restaurant')),
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, provider, child) {
          final state = provider.resultState;

          if (provider.reviewSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Review berhasil dikirim")),
              );
            });
            provider.resetReviewStatus();
          }
          if (provider.reviewError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.reviewErrorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            });
            provider.resetReviewStatus();
          }
          if (state is RestaurantDetailLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RestaurantDetailErrorState) {
            return Center(child: Text(state.error));
          }

          if (state is RestaurantDetailLoadedState) {
            final restaurant = state.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'hero-${restaurant.id}',
                    child: Image.network(
                      'https://restaurant-api.dicoding.dev/images/medium/${restaurant.pictureId}',
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      FavoriteIconWidget(
                        restaurantItem: restaurant.toRestaurantItem(),
                      ),
                    ],
                  ),

                  Text('${restaurant.city} • ⭐ ${restaurant.rating}'),
                  Text(restaurant.address),
                  const SizedBox(height: 16),
                  ExpandableDescription(text: restaurant.description),
                  const SizedBox(height: 16),
                  // Categories
                  Wrap(
                    spacing: 8,
                    children: restaurant.categories
                        .map((c) => Chip(label: Text(c.name)))
                        .toList(),
                  ),

                  const SizedBox(height: 16),

                  // Foods
                  Text('Foods', style: Theme.of(context).textTheme.titleMedium),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: restaurant.menus.foods.length,
                      itemBuilder: (context, index) {
                        final food = restaurant.menus.foods[index];
                        return SizedBox(
                          width: 140,
                          child: Card(
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.fastfood, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  food.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Drinks
                  Text(
                    'Drinks',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: restaurant.menus.drinks.length,
                      itemBuilder: (context, index) {
                        final drink = restaurant.menus.drinks[index];
                        return SizedBox(
                          width: 140,
                          child: Card(
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.local_drink, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  drink.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 32),

                  const SizedBox(height: 8),
                  Text(
                    'Customer Reviews',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: restaurant.customerReviews.length,
                    itemBuilder: (context, index) {
                      final r = restaurant.customerReviews[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(r.name[0].toUpperCase()),
                          ),
                          title: Text(r.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(r.review),
                              const SizedBox(height: 6),
                              Text(
                                r.date,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 32),
                  Text(
                    "Tambah Review",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Nama",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      labelText: "Review",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty &&
                          reviewController.text.isNotEmpty) {
                        provider.addReview(
                          restaurant.id,
                          nameController.text,
                          reviewController.text,
                        );

                        nameController.clear();
                        reviewController.clear();
                      }
                    },
                    child: const Text("Kirim Review"),
                  ),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class ExpandableDescription extends StatefulWidget {
  final String text;

  const ExpandableDescription({super.key, required this.text});

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: Text(
            widget.text,
            maxLines: _expanded ? null : 3,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Text(
            _expanded ? "Read Less" : "Read More",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
