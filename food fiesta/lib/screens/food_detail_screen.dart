import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/screens/profile_screen.dart';
import '../models.dart';
import '../providers.dart';
import 'cart_screen.dart';
import 'favourite_screen.dart';

class FoodDetailScreen extends StatelessWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({super.key, required this.foodItem});

  void _showCustomSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,),),),),
        backgroundColor: Colors.transparent,
        elevation: 1000,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          Row(
            children: [
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
          IconButton(
            icon: Icon(
              !foodProvider.isFavorite(foodItem.id)
                  ? Icons.favorite_border
                  : Icons.favorite,
              color: Colors.white,
            ),
            onPressed: () {
              if (foodProvider.isFavorite(foodItem.id)) {
                foodProvider.removeFromFavorites(foodItem.id);
              } else {
                foodProvider.addToFavorites(foodItem.id);
              }
            },
          ),
        ],

      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: foodItem.id,
                    child: Image.network(
                      foodItem.image,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.fastfood, size: 100),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          foodItem.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'PKR ${foodItem.priceInPkr.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                    Text(
                      foodItem.description.isNotEmpty
                          ? foodItem.description
                          : 'No description available',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                        const SizedBox(height: 20),
                        QuantitySelector(
                          quantity: cartProvider.getItemQuantity(foodItem.id),
                          onIncrement: () => cartProvider.addItem(foodItem),
                          onDecrement: () => cartProvider.removeItem(foodItem.id),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shopping_cart, color: Colors.white,),
              label: const Text('Add to Cart', style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                cartProvider.addItem(foodItem);
                _showCustomSnackBar(context, '${foodItem.name} added to cart');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onDecrement,
          color: Colors.red,
        ),
        Text(
          quantity.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onIncrement,
          color: Colors.green,
        ),
      ],
    );
  }
}