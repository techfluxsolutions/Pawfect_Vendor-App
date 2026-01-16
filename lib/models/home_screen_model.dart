// ========== Alert Models ==========

enum AlertType { lowStock, newOrder, general }

class AlertModel {
  final String? id;
  final AlertType type;
  final String title;
  final String message;
  final int count;
  final String? actionRoute;
  final DateTime? date;

  AlertModel({
    this.id,
    required this.type,
    required this.title,
    required this.message,
    this.count = 0,
    this.actionRoute,
    this.date,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id']?.toString(),
      type: _alertTypeFromString(json['type'] ?? 'general'),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      actionRoute: json['actionRoute'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'count': count,
      'actionRoute': actionRoute,
      'date': date?.toIso8601String(),
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

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

// ========== Recent Order Model (for API response) ==========

class RecentOrderModel {
  final String orderId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final DateTime estimatedDate;
  final String clientName;
  final DateTime createdAt;

  RecentOrderModel({
    required this.orderId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.estimatedDate,
    required this.clientName,
    required this.createdAt,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) {
    return RecentOrderModel(
      orderId: json['orderId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Unknown Product',
      productImage: json['productImage']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity']?.toInt() ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'Pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'Pending',
      estimatedDate:
          json['estimatedDate'] != null
              ? DateTime.parse(json['estimatedDate'])
              : DateTime.now(),
      clientName: json['clientName']?.toString() ?? 'Unknown Client',
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'estimatedDate': estimatedDate.toIso8601String(),
      'clientName': clientName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert to OrderModel for compatibility with existing UI
  OrderModel toOrderModel() {
    return OrderModel(
      id: orderId,
      customerName: clientName,
      amount: totalPrice,
      status: status,
      date: createdAt,
      itemCount: quantity,
    );
  }

  String get formattedTotalPrice => '₹${totalPrice.toStringAsFixed(0)}';

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedEstimatedDate {
    return '${estimatedDate.day}/${estimatedDate.month}/${estimatedDate.year}';
  }
}

// ========== Orders API Models ==========

class OrdersSummaryModel {
  final int totalOrders;
  final double totalRevenue;
  final Map<String, int> statusCounts;

  OrdersSummaryModel({
    required this.totalOrders,
    required this.totalRevenue,
    required this.statusCounts,
  });

  factory OrdersSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrdersSummaryModel(
      totalOrders: json['totalOrders']?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      statusCounts: Map<String, int>.from(json['statusCounts'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'totalRevenue': totalRevenue,
      'statusCounts': statusCounts,
    };
  }

  String get formattedRevenue => '₹${totalRevenue.toStringAsFixed(0)}';
}

class OrdersApiModel {
  final String orderId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final double totalPrice;
  final String status;
  final String paymentStatus;
  final DateTime estimatedDate;
  final String clientName;
  final String phoneNumber;

  OrdersApiModel({
    required this.orderId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.estimatedDate,
    required this.clientName,
    required this.phoneNumber,
  });

  factory OrdersApiModel.fromJson(Map<String, dynamic> json) {
    return OrdersApiModel(
      orderId: json['orderId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? 'Unknown Product',
      productImage: json['productImage']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity']?.toInt() ?? 1,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      status: json['status']?.toString() ?? 'Pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'Pending',
      estimatedDate:
          json['estimatedDate'] != null
              ? DateTime.parse(json['estimatedDate'])
              : DateTime.now(),
      clientName: json['clientName']?.toString() ?? 'Unknown Client',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'estimatedDate': estimatedDate.toIso8601String(),
      'clientName': clientName,
      'phoneNumber': phoneNumber,
    };
  }

  String get formattedTotalPrice => '₹${totalPrice.toStringAsFixed(0)}';
  String get formattedPrice => '₹${price.toStringAsFixed(0)}';

  String get formattedEstimatedDate {
    return '${estimatedDate.day}/${estimatedDate.month}/${estimatedDate.year}';
  }
}

class OrdersResponseModel {
  final OrdersSummaryModel summary;
  final List<OrdersApiModel> orders;

  OrdersResponseModel({required this.summary, required this.orders});

  factory OrdersResponseModel.fromJson(Map<String, dynamic> json) {
    return OrdersResponseModel(
      summary: OrdersSummaryModel.fromJson(json['summary'] ?? {}),
      orders:
          (json['orders'] as List<dynamic>? ?? [])
              .map((orderJson) => OrdersApiModel.fromJson(orderJson))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary.toJson(),
      'orders': orders.map((order) => order.toJson()).toList(),
    };
  }
}

// ========== Top Selling Product Models ==========

class TopSellingProductModel {
  final String id;
  final String name;
  final List<String> images;
  final double price;
  final int totalSold;
  final double totalRevenue;
  final String category;

  TopSellingProductModel({
    required this.id,
    required this.name,
    required this.images,
    required this.price,
    required this.totalSold,
    required this.totalRevenue,
    required this.category,
  });

  factory TopSellingProductModel.fromJson(Map<String, dynamic> json) {
    return TopSellingProductModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Product',
      images: List<String>.from(json['images'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      totalSold: json['totalSold']?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      category: json['category']?.toString() ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'images': images,
      'price': price,
      'totalSold': totalSold,
      'totalRevenue': totalRevenue,
      'category': category,
    };
  }

  // Get the first image or empty string if no images
  String get primaryImage => images.isNotEmpty ? images.first : '';

  // Formatted price
  String get formattedPrice => '₹${price.toStringAsFixed(0)}';

  // Formatted revenue
  String get formattedRevenue => '₹${totalRevenue.toStringAsFixed(0)}';

  // Legacy compatibility - use totalSold as soldCount
  int get soldCount => totalSold;

  // Legacy compatibility - use primaryImage as imageUrl
  String get imageUrl => primaryImage;
}

// ========== Dashboard Stats Model ==========

class DashboardStatsModel {
  final double totalSales;
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
    required this.totalSales,
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
      totalSales: (json['totalSales'] ?? json['total_sales'] ?? 0).toDouble(),
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
      'totalSales': totalSales,
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
