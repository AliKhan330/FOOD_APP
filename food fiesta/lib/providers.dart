import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models.dart';

class FoodProvider with ChangeNotifier {

  final List<FoodItem> _allItems = [];
  List<FoodItem> _visibleItems = [];
  final List<FoodItem> _favoriteItems = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCategory;
  String _searchQuery = '';

  List<FoodItem> get items => _visibleItems;
  List<FoodItem> get favoriteItems => _favoriteItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get categories => ['All', 'Seafood', 'Vegetarian', 'Meat', 'Desserts'];
  String? get selectedCategory => _selectedCategory;

  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _fetchCategory('Seafood'),
        _fetchCategory('Vegetarian'),
        _fetchCategory('Meat'),
        _fetchCategory('Desserts'),
      ]);
      _error = null;
      _applyFilters();
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final validItems = (data['meals'] as List)
              .map((item) {
            try {
              return FoodItem.fromJson(item, category);
            } catch (e) {
              return null;
            }
          })
              .whereType<FoodItem>()
              .toList();
          _allItems.addAll(validItems);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching $category: $e');
      }
    }
  }

  void _applyFilters() {
    List<FoodItem> filtered = _allItems;

    if (_selectedCategory != null && _selectedCategory != 'All') {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    _visibleItems = filtered;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void addToFavorites(String itemId) {
    final item = _allItems.firstWhere((item) => item.id == itemId);
    if (!_favoriteItems.contains(item)) {
      _favoriteItems.add(item);
      notifyListeners();
    }
  }

  void removeFromFavorites(String itemId) {
    _favoriteItems.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  bool isFavorite(String itemId) {
    return _favoriteItems.any((item) => item.id == itemId);
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, int> _items = {};

  int get itemCount => _items.length;
  Map<String, int> get items => _items;

  void addItem(FoodItem item) {
    _items.update(
      item.id,
          (value) => value + 1,
      ifAbsent: () => 1,
    );
    notifyListeners();
  }

  void removeItem(String itemId) {
    if (_items.containsKey(itemId)) {
      if (_items[itemId]! > 1) {
        _items.update(itemId, (value) => value - 1);
      } else {
        _items.remove(itemId);
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double getTotalPrice(List<FoodItem> items) {
    return _items.entries.fold(0.0, (total, entry) {
      final item = items.firstWhere((item) => item.id == entry.key);
      return total + (item.price * entry.value);
    });
  }

  int getItemQuantity(String id) => _items[id] ?? 0;
}

class FoodDetailProvider with ChangeNotifier {
  FoodItem? _selectedItem;
  bool _isLoading = false;
  String? _error;

  FoodItem? get selectedItem => _selectedItem;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchItemDetails(String itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/lookup.php?i=$itemId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['meals'] != null) {
          final mealData = data['meals'][0];
          _selectedItem = FoodItem(
            id: mealData['idMeal'] ?? '',
            name: mealData['strMeal'] ?? 'No name available',
            image: mealData['strMealThumb'] ?? '',
            price: _generatePrice(mealData['idMeal'] ?? ''),
            category: mealData['strCategory'] ?? 'General',
            description: mealData['strInstructions'] ?? 'No description available',
            ingredients: _parseIngredients(mealData),
          );
        }
      } else {
        _error = 'Failed to load details: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error fetching details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  double _generatePrice(String id) {
    return (10 + (id.hashCode % 15)).toDouble();
  }

  List<String> _parseIngredients(Map<String, dynamic> mealData) {
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = mealData['strIngredient$i'];
      final measure = mealData['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add('${measure?.trim()} ${ingredient.trim()}');
      }
    }
    return ingredients;
  }

  void clearDetails() {
    _selectedItem = null;
    _error = null;
    notifyListeners();
  }
}


class CurrencyProvider with ChangeNotifier {
  double _usdToPkr = 280.0; // Default fallback rate
  bool _isLoading = false;
  String? _error;
  String _selectedCurrency = 'PKR'; // Default currency

  double get usdToPkr => _usdToPkr;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCurrency => _selectedCurrency;

  Future<void> fetchExchangeRate() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _usdToPkr = data['rates']['PKR'] ?? 280.0; // Fallback to 280 if API fails
        _error = null;
      } else {
        _error = 'Failed to fetch exchange rate';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrency(String currency) {
    _selectedCurrency = currency;
    notifyListeners();
  }

  String formatPrice(double price) {
    if (_selectedCurrency == 'PKR') {
      return 'PKR ${(price * _usdToPkr).toStringAsFixed(2)}';
    } else {
      return '\$${price.toStringAsFixed(2)}';
    }
  }
}