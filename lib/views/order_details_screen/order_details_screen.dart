import '../../libs.dart';
import '../../controllers/order_controller.dart';
import '../../models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Handle both VendorOrderModel and ExtendedOrderModel
    final arguments = Get.arguments;
    VendorOrderModel order;

    if (arguments is VendorOrderModel) {
      order = arguments;
    } else if (arguments is ExtendedOrderModel) {
      // Convert ExtendedOrderModel to VendorOrderModel
      order = _convertExtendedToVendorOrder(arguments);
    } else {
      // Fallback - should not happen
      Get.back();
      Get.snackbar('Error', 'Invalid order data');
      return Scaffold(body: Center(child: Text('Error loading order')));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(order, primaryColor),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Order Status Timeline
            _buildStatusTimeline(order, primaryColor),

            SizedBox(height: 16),

            // Customer Information
            _buildCustomerInfo(order, primaryColor),

            SizedBox(height: 16),

            // Order Items
            _buildOrderItems(order, primaryColor),

            SizedBox(height: 16),

            // Payment Information
            _buildPaymentInfo(order, primaryColor),

            SizedBox(height: 16),

            // Price Breakdown
            _buildPriceBreakdown(order, primaryColor),

            SizedBox(height: 100), // Space for floating button
          ],
        ),
      ),
      floatingActionButton: _buildActionButton(order, primaryColor),
    );
  }

  PreferredSizeWidget _buildAppBar(VendorOrderModel order, Color primaryColor) {
    return AppBar(
      title: Text('Order ${order.id}'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            switch (value) {
              case 'call_customer':
                _callCustomer(order.customerPhone);
                break;
              case 'message_customer':
                _messageCustomer(order.customerPhone);
                break;
              case 'print_invoice':
                _printInvoice(order);
                break;
              case 'share_tracking':
                _shareTracking(order);
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'call_customer',
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 12),
                      Text('Call Customer'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'message_customer',
                  child: Row(
                    children: [
                      Icon(Icons.message, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 12),
                      Text('Message Customer'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'print_invoice',
                  child: Row(
                    children: [
                      Icon(Icons.print, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 12),
                      Text('Print Invoice'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'share_tracking',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 12),
                      Text('Share Tracking'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(VendorOrderModel order, Color primaryColor) {
    final statuses = [
      {'key': 'pending', 'label': 'Order Placed', 'icon': Icons.shopping_cart},
      {'key': 'confirmed', 'label': 'Confirmed', 'icon': Icons.check_circle},
      {'key': 'processing', 'label': 'Processing', 'icon': Icons.settings},
      {'key': 'packed', 'label': 'Packed', 'icon': Icons.inventory_2},
      {'key': 'shipped', 'label': 'Shipped', 'icon': Icons.local_shipping},
      {'key': 'delivered', 'label': 'Delivered', 'icon': Icons.done_all},
    ];

    final currentStatusIndex = statuses.indexWhere(
      (s) => s['key'] == order.status,
    );

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          ...statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = index <= currentStatusIndex;
            final isCurrent = index == currentStatusIndex;
            final isLast = index == statuses.length - 1;

            return Row(
              children: [
                // Timeline indicator
                Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? (isCurrent ? primaryColor : Colors.green)
                                : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        status['icon'] as IconData,
                        color: isCompleted ? Colors.white : Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 30,
                        color: isCompleted ? Colors.green : Colors.grey[300],
                      ),
                  ],
                ),
                SizedBox(width: 16),
                // Status info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status['label'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.w500,
                          color:
                              isCompleted ? Colors.grey[800] : Colors.grey[500],
                        ),
                      ),
                      if (isCurrent)
                        Text(
                          order.formattedOrderDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(VendorOrderModel order, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: primaryColor, size: 24),
              SizedBox(width: 12),
              Text(
                'Customer Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoRow(Icons.person_outline, 'Name', order.customerName),
          SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, 'Phone', order.customerPhone),
          SizedBox(height: 12),
          _buildInfoRow(Icons.email_outlined, 'Email', order.customerEmail),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.location_on_outlined,
            'Address',
            order.customerAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(VendorOrderModel order, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag, color: primaryColor, size: 24),
              SizedBox(width: 12),
              Text(
                'Order Items (${order.items.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...order.items.map((item) => _buildOrderItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItemModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                item.imageUrl.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.inventory_2,
                            color: Colors.grey[400],
                          );
                        },
                      ),
                    )
                    : Icon(Icons.inventory_2, color: Colors.grey[400]),
          ),
          SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Text(
                  '${item.formattedPrice} each',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Price
          Text(
            item.formattedTotalPrice,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(VendorOrderModel order, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: primaryColor, size: 24),
              SizedBox(width: 12),
              Text(
                'Payment Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Method',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.paymentMethod,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Status',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      order.paymentStatus == 'paid'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.paymentStatus.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        order.paymentStatus == 'paid'
                            ? Colors.green
                            : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(VendorOrderModel order, Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt, color: primaryColor, size: 24),
              SizedBox(width: 12),
              Text(
                'Price Breakdown',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildPriceRow('Subtotal', '₹${order.subtotal.toStringAsFixed(2)}'),
          SizedBox(height: 8),
          _buildPriceRow(
            'Delivery Fee',
            '₹${order.deliveryFee.toStringAsFixed(2)}',
          ),
          SizedBox(height: 8),
          _buildPriceRow(
            'Discount',
            '-₹${order.discount.toStringAsFixed(2)}',
            isDiscount: true,
          ),
          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 12),
          _buildPriceRow(
            'Total Amount',
            order.formattedTotalAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey[isTotal ? 800 : 600],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color:
                isDiscount
                    ? Colors.green
                    : isTotal
                    ? Colors.grey[800]
                    : Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(VendorOrderModel order, Color primaryColor) {
    String buttonText = '';
    String nextStatus = '';

    switch (order.status) {
      case 'pending':
        buttonText = 'Confirm Order';
        nextStatus = 'confirmed';
        break;
      case 'confirmed':
        buttonText = 'Start Processing';
        nextStatus = 'processing';
        break;
      case 'processing':
        buttonText = 'Mark as Packed';
        nextStatus = 'packed';
        break;
      case 'packed':
        buttonText = 'Mark as Shipped';
        nextStatus = 'shipped';
        break;
      case 'shipped':
        buttonText = 'Mark as Delivered';
        nextStatus = 'delivered';
        break;
      default:
        return SizedBox.shrink();
    }

    return FloatingActionButton.extended(
      onPressed: () => _updateOrderStatus(order, nextStatus),
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      label: Text(buttonText),
      icon: Icon(_getNextStatusIcon(nextStatus)),
    );
  }

  IconData _getNextStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'processing':
        return Icons.settings;
      case 'packed':
        return Icons.inventory_2;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.done_all;
      default:
        return Icons.arrow_forward;
    }
  }

  void _updateOrderStatus(VendorOrderModel order, String newStatus) {
    Get.dialog(
      AlertDialog(
        title: Text('Update Order Status'),
        content: Text('Are you sure you want to update this order status?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Update order status logic here
              Get.snackbar(
                'Success',
                'Order status updated successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              Get.back(); // Go back to orders list
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _callCustomer(String phone) {
    Get.snackbar('Call Customer', 'Calling $phone...');
  }

  void _messageCustomer(String phone) {
    Get.snackbar('Message Customer', 'Opening messages for $phone...');
  }

  void _printInvoice(VendorOrderModel order) {
    Get.snackbar('Print Invoice', 'Printing invoice for order ${order.id}...');
  }

  void _shareTracking(VendorOrderModel order) {
    Get.snackbar(
      'Share Tracking',
      'Sharing tracking info for order ${order.id}...',
    );
  }

  // Convert ExtendedOrderModel to VendorOrderModel for compatibility
  VendorOrderModel _convertExtendedToVendorOrder(
    ExtendedOrderModel extendedOrder,
  ) {
    // Convert items from Map to OrderItemModel
    List<OrderItemModel> orderItems =
        extendedOrder.items.map((item) {
          return OrderItemModel(
            productId: item['productId']?.toString() ?? '',
            productName:
                item['productName']?.toString() ??
                item['name']?.toString() ??
                'Unknown Product',
            quantity: item['quantity'] ?? 1,
            price: (item['price'] ?? 0).toDouble(),
            imageUrl:
                item['imageUrl']?.toString() ?? item['image']?.toString() ?? '',
          );
        }).toList();

    return VendorOrderModel(
      id: extendedOrder.id,
      customerName: extendedOrder.customerName,
      customerPhone: extendedOrder.customerPhone ?? '',
      customerEmail: extendedOrder.customerEmail ?? '',
      customerAddress: extendedOrder.shippingAddress ?? '',
      orderDate: extendedOrder.date,
      status: extendedOrder.status,
      paymentMethod: extendedOrder.paymentMethod ?? 'Unknown',
      paymentStatus: 'paid', // Default assumption
      totalAmount: extendedOrder.amount,
      deliveryFee: 0.0, // Not available in ExtendedOrderModel
      discount: 0.0, // Not available in ExtendedOrderModel
      items: orderItems,
    );
  }
}
