// lib/models/wine_model.dart

class Wine {
  final String id;
  final String name;
  final String type;
  final double rating;
  final String country;
  final String winery;
  final double alcoholLevel;
  final String? imageUrl;
  final double price;
  final String year;

  Wine({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.country,
    required this.winery,
    required this.alcoholLevel,
    this.imageUrl,
    required this.price,
    required this.year,
  });

  factory Wine.fromJson(Map<String, dynamic> json) {
    return Wine(
      id: json['_id'] as String,
      name: json['name'] as String,
      type: json['type'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      country: json['country'] as String? ?? '',
      winery: json['winery'] as String? ?? '',
      alcoholLevel: (json['alcoholLevel'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      year: json['year'] as String? ?? '',
    );
  }
}
