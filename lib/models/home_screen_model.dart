// ========== Alert Models ==========

enum AlertType { lowStock, newOrder, general }

class AlertModel {
  final AlertType type;
  final String title;
  final String message;
  final int count;
  final String? actionRoute;

  AlertModel({
    required this.type,
    required this.title,
    required this.message,
    this.count = 0,
    this.actionRoute,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      type: _alertTypeFromString(json['type'] ?? 'general'),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      actionRoute: json['actionRoute'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'count': count,
      'actionRoute': actionRoute,
    };
  }

  static AlertType _alertTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'lowstock':
        return AlertType.lowStock;
      case 'neworder':
        return AlertType.newOrder;
      default:
        return AlertType.general;
    }
  }
}

// ========== Order Models ==========

class OrderModel {
  final String id;
  final String customerName;
  final double amount;
  final String status;
  final DateTime date;
  final int itemCount;
  final String? customerPhone;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.date,
    this.itemCount = 1,
    this.customerPhone,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName'] ?? json['customer_name'] ?? 'Unknown',
      amount: (json['amount'] ?? json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      itemCount: json['itemCount'] ?? json['item_count'] ?? 1,
      customerPhone: json['customerPhone'] ?? json['customer_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'amount': amount,
      'status': status,
      'date': date.toIso8601String(),
      'itemCount': itemCount,
      'customerPhone': customerPhone,
    };
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// ========== Top Selling Product Models ==========

class TopSellingProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final int soldCount;
  final String? category;
  final double? rating;

  TopSellingProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.soldCount,
    this.category,
    this.rating,
  });

  factory TopSellingProductModel.fromJson(Map<String, dynamic> json) {
    return TopSellingProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Product',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      price: (json['price'] ?? json['selling_price'] ?? 0).toDouble(),
      soldCount: json['soldCount'] ?? json['sold_count'] ?? 0,
      category: json['category'],
      rating: json['rating']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'soldCount': soldCount,
      'category': category,
      'rating': rating,
    };
  }

  String get fullImageUrl {
    if (imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('http')) return imageUrl;
    return 'https://api-dev.pawfectcaring.com$imageUrl';
  }
}

// ========== Dashboard Stats Model ==========

class DashboardStatsModel {
  final double monthlySales;
  final double weeklySales;
  final double dailySales;
  final int totalOrders;
  final int todayOrders;
  final int totalProducts;
  final int outOfStockProducts;
  final int lowStockProducts;
  final double pendingSettlements;

  DashboardStatsModel({
    required this.monthlySales,
    required this.weeklySales,
    required this.dailySales,
    required this.totalOrders,
    required this.todayOrders,
    required this.totalProducts,
    required this.outOfStockProducts,
    required this.lowStockProducts,
    required this.pendingSettlements,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      monthlySales:
          (json['monthlySales'] ?? json['monthly_sales'] ?? 0).toDouble(),
      weeklySales:
          (json['weeklySales'] ?? json['weekly_sales'] ?? 0).toDouble(),
      dailySales: (json['dailySales'] ?? json['daily_sales'] ?? 0).toDouble(),
      totalOrders: json['totalOrders'] ?? json['total_orders'] ?? 0,
      todayOrders: json['todayOrders'] ?? json['today_orders'] ?? 0,
      totalProducts: json['totalProducts'] ?? json['total_products'] ?? 0,
      outOfStockProducts:
          json['outOfStockProducts'] ?? json['out_of_stock_products'] ?? 0,
      lowStockProducts:
          json['lowStockProducts'] ?? json['low_stock_products'] ?? 0,
      pendingSettlements:
          (json['pendingSettlements'] ?? json['pending_settlements'] ?? 0)
              .toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monthlySales': monthlySales,
      'weeklySales': weeklySales,
      'dailySales': dailySales,
      'totalOrders': totalOrders,
      'todayOrders': todayOrders,
      'totalProducts': totalProducts,
      'outOfStockProducts': outOfStockProducts,
      'lowStockProducts': lowStockProducts,
      'pendingSettlements': pendingSettlements,
    };
  }
}

// ========== Store Info Model ==========

class StoreInfoModel {
  final String id;
  final String name;
  final bool isActive;
  final String? ownerName;
  final String? phone;
  final String? email;
  final String? address;

  StoreInfoModel({
    required this.id,
    required this.name,
    required this.isActive,
    this.ownerName,
    this.phone,
    this.email,
    this.address,
  });

  factory StoreInfoModel.fromJson(Map<String, dynamic> json) {
    return StoreInfoModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown Store',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      ownerName: json['ownerName'] ?? json['owner_name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isActive': isActive,
      'ownerName': ownerName,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }
}
