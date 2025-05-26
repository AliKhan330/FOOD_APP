class FoodItem {
  final String id;
  final String name;
  final String image;
  final double price;
  final String category;
  final String description;
  final List<String> ingredients;

  FoodItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    required this.description,
    required this.ingredients,
  });

  double get priceInPkr => price * 280; // Convert to PKR

    factory FoodItem.fromJson(Map<String, dynamic> json, String category) {
      return FoodItem(
        id: json['idMeal'], // NOT 'id'
        name: json['strMeal'], // NOT 'name'
        image: json['strMealThumb'],
        category: category,
        price: 10.0,
        description: '',
        ingredients: [], // Default price (API doesn't provide this)
      );
    }
  }
