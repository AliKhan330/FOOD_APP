import 'package:flutter/material.dart';

import 'cart_screen.dart';
import 'favourite_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                'https://randomuser.me/api/portraits/men/1.jpg',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ali Khan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'magsialikhan8@gmail.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            _buildProfileItem(Icons.settings, 'Settings'),
            _buildProfileItem(Icons.privacy_tip_outlined, 'Privacy'),
            _buildProfileItem(Icons.dark_mode, 'Theme'),
            _buildProfileItem(Icons.location_on, 'Address'),
            _buildProfileItem(Icons.history, 'Order History'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Add logout logic
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
              ),
              child: const Text('Log Out', style: TextStyle(color: Colors.white, fontSize: 16),),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      onTap: () {},
    );
  }
}