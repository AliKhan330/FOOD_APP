import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/screens/profile_screen.dart';
import '../providers.dart';
import 'cart_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final foodProvider = Provider.of<FoodProvider>(context);

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
                ],
              ),
            ],
          ),
        ],

      ),
      body: foodProvider.favoriteItems.isEmpty
          ? const Center(
        child: Text(
          'No favorites yet!',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: foodProvider.favoriteItems.length,
        itemBuilder: (context, index) {
          final item = foodProvider.favoriteItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.image,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(item.name),
              subtitle: Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.green),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () {
                  foodProvider.removeFromFavorites(item.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}