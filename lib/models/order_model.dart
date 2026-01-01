class ExtendedOrderModel {
  final String id;
  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final double amount;
  final String status;
  final DateTime date;
  final List<Map<String, dynamic>> items;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? orderNotes;
  final int itemCount;

  ExtendedOrderModel({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.status,
    required this.date,
    this.customerPhone,
    this.customerEmail,
    this.items = const [],
    this.shippingAddress,
    this.paymentMethod,
    this.orderNotes,
    this.itemCount = 1,
  });

  factory ExtendedOrderModel.fromJson(Map<String, dynamic> json) {
    return ExtendedOrderModel(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName'] ?? json['customer_name'] ?? 'Unknown',
      customerPhone: json['customerPhone'] ?? json['customer_phone'],
      customerEmail: json['customerEmail'] ?? json['customer_email'],
      amount: (json['amount'] ?? json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      shippingAddress: json['shippingAddress'] ?? json['shipping_address'],
      paymentMethod: json['paymentMethod'] ?? json['payment_method'],
      orderNotes: json['orderNotes'] ?? json['order_notes'],
      itemCount: json['itemCount'] ?? json['item_count'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'amount': amount,
      'status': status,
      'date': date.toIso8601String(),
      'items': items,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'orderNotes': orderNotes,
      'itemCount': itemCount,
    };
  }

  ExtendedOrderModel copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    double? amount,
    String? status,
    DateTime? date,
    List<Map<String, dynamic>>? items,
    String? shippingAddress,
    String? paymentMethod,
    String? orderNotes,
    int? itemCount,
  }) {
    return ExtendedOrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      date: date ?? this.date,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderNotes: orderNotes ?? this.orderNotes,
      itemCount: itemCount ?? this.itemCount,
    );
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
