class ApiUrls {
  static const String baseUrl = "https://api-dev.pawfectcaring.com/api/vendor";
  static const String sendOtp = "/send-otp";
  static const String verifyOtp = "/verify-otp";
  static const String onboarding = "/onboarding";
}

// import '../../libs.dart';

// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Home'), backgroundColor: AppColors.primary),
//       body: Center(
//         child: Text(
//           'Welcome to Pawfect Vendor App!',
//           style: TextStyle(
//             fontSize: 24,
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:pawfect_vendor_app/controllers/home_screen_controller.dart';
// import 'package:pawfect_vendor_app/models/home_screen_model.dart';

// import '../../libs.dart';

// class HomeScreen extends StatelessWidget {
//   HomeScreen({super.key});

//   final HomeScreenController controller = Get.put(HomeScreenController());

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final primaryColor = theme.colorScheme.primary;

//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: RefreshIndicator(
//         onRefresh: controller.refreshData,
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header Section
//               _buildHeader(primaryColor),

//               // Stats Cards Section
//               _buildStatsSection(primaryColor),

//               SizedBox(height: 16),

//               // Alerts Section
//               _buildAlertsSection(primaryColor),

//               SizedBox(height: 16),

//               // Quick Actions Section
//               _buildQuickActions(primaryColor),

//               SizedBox(height: 16),

//               // Recent Orders Section
//               _buildRecentOrdersSection(primaryColor),

//               SizedBox(height: 16),

//               // Top Selling Products Section
//               _buildTopSellingProducts(primaryColor),

//               SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader(Color primaryColor) {
//     return Container(
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: primaryColor,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//       ),
//       child: Column(
//         children: [
//           SizedBox(height: 25),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Hello,',
//                       style: TextStyle(fontSize: 14, color: Colors.black87),
//                     ),
//                     SizedBox(height: 4),
//                     Obx(
//                       () => Text(
//                         controller.storeName.value,
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Row(
//                 children: [
//                   // Store Status Toggle
//                   Obx(
//                     () => Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color:
//                             controller.isStoreActive.value
//                                 ? Colors.green[100]
//                                 : Colors.red[100],
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Container(
//                             width: 8,
//                             height: 8,
//                             decoration: BoxDecoration(
//                               color:
//                                   controller.isStoreActive.value
//                                       ? Colors.green
//                                       : Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                           SizedBox(width: 6),
//                           Text(
//                             controller.isStoreActive.value
//                                 ? 'Active'
//                                 : 'Inactive',
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color:
//                                   controller.isStoreActive.value
//                                       ? Colors.green[800]
//                                       : Colors.red[800],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 12),
//                   // Notification Bell
//                   Stack(
//                     children: [
//                       IconButton(
//                         icon: Icon(
//                           Icons.notifications_outlined,
//                           color: Colors.black,
//                         ),
//                         onPressed: controller.openNotifications,
//                       ),
//                       Obx(
//                         () =>
//                             controller.notificationCount.value > 0
//                                 ? Positioned(
//                                   right: 8,
//                                   top: 8,
//                                   child: Container(
//                                     padding: EdgeInsets.all(4),
//                                     decoration: BoxDecoration(
//                                       color: Colors.red,
//                                       shape: BoxShape.circle,
//                                     ),
//                                     constraints: BoxConstraints(
//                                       minWidth: 18,
//                                       minHeight: 18,
//                                     ),
//                                     child: Text(
//                                       '${controller.notificationCount.value}',
//                                       style: TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 10,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 )
//                                 : SizedBox.shrink(),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsSection(Color primaryColor) {
//     return Obx(
//       () =>
//           controller.isLoading.value
//               ? _buildStatsLoading()
//               : Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   children: [
//                     // Row 1
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildStatCard(
//                             'Monthly Sales',
//                             '₹${controller.monthlySales.value.toStringAsFixed(0)}',
//                             Icons.trending_up,
//                             Colors.green,
//                             primaryColor,
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: _buildStatCard(
//                             'Weekly Sales',
//                             '₹${controller.weeklySales.value.toStringAsFixed(0)}',
//                             Icons.calendar_view_week,
//                             Colors.blue,
//                             primaryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 12),
//                     // Row 2
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildStatCard(
//                             'Daily Sales',
//                             '₹${controller.dailySales.value.toStringAsFixed(0)}',
//                             Icons.today,
//                             Colors.orange,
//                             primaryColor,
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: _buildStatCard(
//                             'Total Orders',
//                             '${controller.totalOrders.value}',
//                             Icons.shopping_bag,
//                             Colors.purple,
//                             primaryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 12),
//                     // Row 3
//                     Row(
//                       children: [
//                         Expanded(
//                           child: _buildStatCard(
//                             'Total Products',
//                             '${controller.totalProducts.value}',
//                             Icons.inventory_2,
//                             Colors.teal,
//                             primaryColor,
//                           ),
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: _buildStatCard(
//                             'Out of Stock',
//                             '${controller.outOfStockProducts.value}',
//                             Icons.warning_amber,
//                             Colors.red,
//                             primaryColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }

//   Widget _buildStatsLoading() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         children: List.generate(
//           3,
//           (index) => Padding(
//             padding: EdgeInsets.only(bottom: 12),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Container(
//                     height: 100,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     String title,
//     String value,
//     IconData icon,
//     Color iconColor,
//     Color primaryColor,
//   ) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: iconColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(icon, color: iconColor, size: 20),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           SizedBox(height: 4),
//           Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//         ],
//       ),
//     );
//   }

//   Widget _buildAlertsSection(Color primaryColor) {
//     return Obx(() {
//       if (controller.alerts.isEmpty) return SizedBox.shrink();

//       return Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Alerts',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey[800],
//               ),
//             ),
//             SizedBox(height: 12),
//             ...controller.alerts.map(
//               (alert) => _buildAlertCard(alert, primaryColor),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildAlertCard(AlertModel alert, Color primaryColor) {
//     Color alertColor;
//     IconData alertIcon;

//     switch (alert.type) {
//       case AlertType.lowStock:
//         alertColor = Colors.orange;
//         alertIcon = Icons.inventory_2;
//         break;
//       case AlertType.newOrder:
//         alertColor = Colors.green;
//         alertIcon = Icons.shopping_bag;
//         break;
//       default:
//         alertColor = Colors.grey;
//         alertIcon = Icons.info;
//     }

//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: alertColor.withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: alertColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(alertIcon, color: alertColor, size: 20),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   alert.title,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   alert.message,
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//           Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActions(Color primaryColor) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Quick Actions',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//           SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildQuickActionCard(
//                   'Add Product',
//                   Icons.add_box,
//                   Colors.green,
//                   controller.navigateToAddProduct,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: _buildQuickActionCard(
//                   'View Orders',
//                   Icons.receipt_long,
//                   Colors.blue,
//                   controller.navigateToOrders,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildQuickActionCard(
//                   'Inventory',
//                   Icons.inventory,
//                   Colors.orange,
//                   controller.navigateToInventory,
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: _buildQuickActionCard(
//                   'Analytics',
//                   Icons.bar_chart,
//                   Colors.purple,
//                   controller.navigateToAnalytics,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActionCard(
//     String title,
//     IconData icon,
//     Color color,
//     VoidCallback onTap,
//   ) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: color, size: 28),
//             ),
//             SizedBox(height: 12),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentOrdersSection(Color primaryColor) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Recent Orders',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey[800],
//                 ),
//               ),
//               TextButton(
//                 onPressed: controller.navigateToOrders,
//                 child: Text('View All'),
//               ),
//             ],
//           ),
//           SizedBox(height: 12),
//           Obx(() {
//             if (controller.isLoading.value) {
//               return _buildOrdersLoading();
//             }

//             if (controller.recentOrders.isEmpty) {
//               return _buildEmptyOrders();
//             }

//             return Column(
//               children:
//                   controller.recentOrders
//                       .take(5)
//                       .map((order) => _buildOrderCard(order, primaryColor))
//                       .toList(),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildOrdersLoading() {
//     return Column(
//       children: List.generate(
//         3,
//         (index) => Container(
//           margin: EdgeInsets.only(bottom: 12),
//           height: 80,
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyOrders() {
//     return Container(
//       padding: EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Column(
//           children: [
//             Icon(
//               Icons.shopping_bag_outlined,
//               size: 60,
//               color: Colors.grey[300],
//             ),
//             SizedBox(height: 12),
//             Text(
//               'No Recent Orders',
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderCard(OrderModel order, Color primaryColor) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 12),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(Icons.shopping_bag, color: primaryColor, size: 20),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Order #${order.id}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   order.customerName,
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '₹${order.amount.toStringAsFixed(0)}',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: primaryColor,
//                 ),
//               ),
//               SizedBox(height: 4),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(order.status).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   order.status,
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                     color: _getStatusColor(order.status),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Colors.orange;
//       case 'processing':
//         return Colors.blue;
//       case 'delivered':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildTopSellingProducts(Color primaryColor) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 16),
//           child: Text(
//             'Top Selling Products',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey[800],
//             ),
//           ),
//         ),
//         SizedBox(height: 12),
//         Obx(() {
//           if (controller.isLoading.value) {
//             return _buildProductsLoading();
//           }

//           if (controller.topSellingProducts.isEmpty) {
//             return Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: _buildEmptyProducts(),
//             );
//           }

//           return SizedBox(
//             height: 220,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               itemCount: controller.topSellingProducts.length,
//               itemBuilder: (context, index) {
//                 final product = controller.topSellingProducts[index];
//                 return _buildProductCard(product, primaryColor);
//               },
//             ),
//           );
//         }),
//       ],
//     );
//   }

//   Widget _buildProductsLoading() {
//     return SizedBox(
//       height: 220,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         itemCount: 3,
//         itemBuilder: (context, index) {
//           return Container(
//             width: 160,
//             margin: EdgeInsets.only(right: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey[200],
//               borderRadius: BorderRadius.circular(12),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildEmptyProducts() {
//     return Container(
//       padding: EdgeInsets.all(32),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Column(
//           children: [
//             Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey[300]),
//             SizedBox(height: 12),
//             Text(
//               'No Products Yet',
//               style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductCard(TopSellingProductModel product, Color primaryColor) {
//     return Container(
//       width: 160,
//       margin: EdgeInsets.only(right: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Product Image
//           ClipRRect(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//             child: Container(
//               height: 120,
//               width: double.infinity,
//               color: Colors.grey[200],
//               child:
//                   product.imageUrl.isNotEmpty
//                       ? Image.network(
//                         product.imageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Icon(
//                             Icons.image,
//                             size: 40,
//                             color: Colors.grey[400],
//                           );
//                         },
//                       )
//                       : Icon(Icons.image, size: 40, color: Colors.grey[400]),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   product.name,
//                   style: TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[800],
//                   ),
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '₹${product.price.toStringAsFixed(0)}',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: primaryColor,
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.green[50],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         '${product.soldCount} sold',
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.green[700],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
