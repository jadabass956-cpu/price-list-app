class Product {
  final int? id;
  final String name;
  final double price;
  final String? category;
  final String? imagePath;
  final String createdAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.category,
    this.imagePath,
    this.createdAt = '',
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'price': price,
        'category': category,
        'image_path': imagePath,
      };

  factory Product.fromMap(Map<String, dynamic> m) => Product(
        id: m['id'] as int?,
        name: m['name'] as String,
        price: (m['price'] as num).toDouble(),
        category: m['category'] as String?,
        imagePath: m['image_path'] as String?,
        createdAt: (m['created_at'] as String?) ?? '',
      );
}
