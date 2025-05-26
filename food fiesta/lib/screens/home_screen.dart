import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers.dart';
import 'cart_screen.dart';
import 'food_detail_screen.dart';
import 'favourite_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // FIX: Initialize data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FoodProvider>(context, listen: false).initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delivery_dining, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            const Text(
              'FoodFiesta',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () => (),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                  onPressed: () => (),
                      ),

              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => (),
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 5,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          cartProvider.itemCount.toString(),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Search food items...',
              leading: const Icon(Icons.search, color: Colors.green),
              hintStyle: MaterialStateProperty.all(
                  const TextStyle(color: Colors.grey)),
              onChanged: (value) => foodProvider.setSearchQuery(value),
            ),
          ),
        ),
      ),
      body: _buildBody(foodProvider, cartProvider),
    );
  }

  Widget _buildBody(FoodProvider foodProvider, CartProvider cartProvider) {
    if (foodProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (foodProvider.error != null) {
      return Center(child: Text(foodProvider.error!));
    }

    return Column(
      children: [
        _buildCategoryCards(foodProvider),
        Expanded(
          child: _buildFoodList(foodProvider, cartProvider),
        ),
      ],
    );
  }

  Widget _buildCategoryCards(FoodProvider provider) {
    final categories = [
      {'name': 'Seafood', 'icon': Icons.set_meal, 'color': Colors.blue},
      {'name': 'Vegetarian', 'icon': Icons.eco, 'color': Colors.green},
      {'name': 'Meat', 'icon': Icons.kebab_dining, 'color': Colors.red},
      {'name': 'Desserts', 'icon': Icons.cake, 'color': Colors.orange},
      {'name': 'All', 'icon': Icons.all_inclusive, 'color': Colors.purple},
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, index) => GestureDetector(
          onTap: () => provider.setSelectedCategory(
              categories[index]['name'] == 'All' ? null : categories[index]['name'] as String),
          child: Container(
            width: 100,
            decoration: BoxDecoration(
              color: categories[index]['color'] as Color,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
              BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
              )],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  categories[index]['icon'] as IconData,
                  size: 32,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index]['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFoodList(FoodProvider foodProvider, CartProvider cartProvider) {
    final items = foodProvider.items;

    if (items.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, i) => Dismissible(
        // FIX: Use UniqueKey instead of item ID
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.green,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 30),
        ),
        onDismissed: (direction) {
          cartProvider.addItem(items[i]);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('${items[i].name} added to cart'),
            ),
          );
        },
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              items[i].image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[200]),
            ),
          ),
          title: Text(items[i].name),
          subtitle: Consumer<CurrencyProvider>(
            builder: (context, currencyProvider, _) {
              return Text(
                currencyProvider.formatPrice(items[i].price),
                style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold),
              );
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(
                builder: (context) => FoodDetailScreen(foodItem: items[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}