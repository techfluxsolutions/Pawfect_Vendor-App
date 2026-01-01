// class ProductModel {
//   final String id;
//   final String name;
//   final String image;
//   final String petType;
//   final String category;
//   final String foodType;
//   final String weight;
//   final int stockQuantity;
//   final double sellingPrice;
//   final double mrp;
//   final int discount;
//   final String status;

//   ProductModel({
//     required this.id,
//     required this.name,
//     required this.image,
//     required this.petType,
//     required this.category,
//     required this.foodType,
//     required this.weight,
//     required this.stockQuantity,
//     required this.sellingPrice,
//     required this.mrp,
//     required this.discount,
//     required this.status,
//   });

//   String get stockStatus {
//     if (stockQuantity == 0) return 'Out of Stock';
//     if (stockQuantity <= 10) return 'Low Stock';
//     return 'In Stock';
//   }
// }

class ProductModel {
  final String id;
  final String name;
  final List<String> images;
  final String petType; // This comes from 'category' in API
  final String category; // This comes from 'category' in API
  final String foodType;
  final String weight;
  final int stockQuantity;
  final double sellingPrice; // This comes from 'price' in API
  final double mrp;
  final double discount;
  final String status;
  final String description;
  final List<String> benefits;
  final String deliveryEstimate;
  final String stockStatus;

  ProductModel({
    required this.id,
    required this.name,
    required this.images,
    required this.petType,
    required this.category,
    required this.foodType,
    required this.weight,
    required this.stockQuantity,
    required this.sellingPrice,
    required this.mrp,
    required this.discount,
    required this.status,
    required this.description,
    required this.benefits,
    required this.deliveryEstimate,
    required this.stockStatus,
  });

  // Helper getter for first image
  String get image => images.isNotEmpty ? images.first : '';

  // Factory constructor from JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Parse images list
    List<String> imagesList = [];
    if (json['images'] != null && json['images'] is List) {
      imagesList = List<String>.from(json['images']);
    }

    // Parse benefits list
    List<String> benefitsList = [];
    if (json['benefits'] != null && json['benefits'] is List) {
      for (var benefit in json['benefits']) {
        if (benefit is String) {
          // Remove the extra brackets and quotes from "[\"High protein content\"]"
          String cleaned = benefit
              .replaceAll('[', '')
              .replaceAll(']', '')
              .replaceAll('\\"', '')
              .replaceAll('"', '');

          // Split by comma if multiple benefits in one string
          if (cleaned.contains(',')) {
            benefitsList.addAll(cleaned.split(',').map((e) => e.trim()));
          } else {
            benefitsList.add(cleaned.trim());
          }
        }
      }
    }

    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      images: imagesList,
      petType:
          json['category'] ??
          '', // API uses 'category' for pet type (Dog, Cat, etc.)
      category: json['category'] ?? '',
      foodType: json['foodType'] ?? '',
      weight: json['weight'] ?? '',
      stockQuantity: json['stockQuantity'] ?? 0,
      sellingPrice:
          (json['price'] ?? 0).toDouble(), // API uses 'price' for selling price
      mrp: (json['mrp'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      status: json['status'] ?? 'draft',
      description: json['description'] ?? '',
      benefits: benefitsList,
      deliveryEstimate: json['deliveryEstimate'] ?? '',
      stockStatus: json['stockStatus'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'images': images,
      'category': category,
      'foodType': foodType,
      'price': sellingPrice,
      'mrp': mrp,
      'discount': discount,
      'weight': weight,
      'stockQuantity': stockQuantity,
      'description': description,
      'benefits': benefits,
      'deliveryEstimate': deliveryEstimate,
      'status': status,
      'stockStatus': stockStatus,
    };
  }

  // Copy with method
  ProductModel copyWith({
    String? id,
    String? name,
    List<String>? images,
    String? petType,
    String? category,
    String? foodType,
    String? weight,
    int? stockQuantity,
    double? sellingPrice,
    double? mrp,
    double? discount,
    String? status,
    String? description,
    List<String>? benefits,
    String? deliveryEstimate,
    String? stockStatus,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      images: images ?? this.images,
      petType: petType ?? this.petType,
      category: category ?? this.category,
      foodType: foodType ?? this.foodType,
      weight: weight ?? this.weight,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      mrp: mrp ?? this.mrp,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      description: description ?? this.description,
      benefits: benefits ?? this.benefits,
      deliveryEstimate: deliveryEstimate ?? this.deliveryEstimate,
      stockStatus: stockStatus ?? this.stockStatus,
    );
  }
}
