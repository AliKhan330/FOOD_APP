import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled1/screens/profile_screen.dart';
import '../providers.dart';
import '../models.dart';
import 'favourite_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final foodProvider = Provider.of<FoodProvider>(context);

    // Get cart items with details
    final cartItems = cartProvider.items.entries.map((entry) {
      final foodItem = foodProvider.items.firstWhere(
            (item) => item.id == entry.key,
        orElse: () => FoodItem(
          id: '',
          name: 'Unknown',
          image: '',
          price: 0.0,
          category: '',
          description: '',
          ingredients: [],
        ),
      );
      return {
        'item': foodItem,
        'quantity': entry.value,
      };
    }).toList();

    final totalPrice = cartProvider.getTotalPrice(foodProvider.items);

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
      body: cartProvider.itemCount == 0
          ? const Center(child: Text('Your cart is empty'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartItems.length,
              itemBuilder: (ctx, index) {
                final item = cartItems[index]['item'] as FoodItem;
                final quantity = cartItems[index]['quantity'] as int;
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
                      '\$${(item.price * quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () => cartProvider.removeItem(item.id),
                        ),
                        Text(
                          quantity.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => cartProvider.addItem(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                    ),
                    Consumer<CurrencyProvider>(
                      builder: (context, currencyProvider, _) {
                        return Text(
                          currencyProvider.formatPrice(totalPrice), // Use CurrencyProvider
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {  },
                    child: const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 16),),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}