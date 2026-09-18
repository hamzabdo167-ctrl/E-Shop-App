class Product {
  final int id;
  final String title;
  final num price;
  final String image;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String imageUrl = 'https://i.imgur.com/QkIa5tT.jpeg';

    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      String rawImage = json['images'][0].toString();
      rawImage = rawImage.replaceAll(RegExp(r'[\[\]"]'), '').trim();
      if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
        imageUrl = rawImage;
      }
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      String rawImage = json['image']
          .toString()
          .replaceAll(RegExp(r'[\[\]"]'), '')
          .trim();
      if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
        imageUrl = rawImage;
      }
    }

    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      price: json['price'] ?? 0,
      image: imageUrl,
    );
  }
}
