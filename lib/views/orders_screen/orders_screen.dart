import '../../libs.dart';
import '../../controllers/orders_controller.dart';
import '../../models/order_model.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});

  final OrdersController controller = Get.put(OrdersController());
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Setup infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreOrders();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(primaryColor),
      body: Obx(
        () =>
            controller.isLoading.value
                ? _buildLoadingState()
                : RefreshIndicator(
                  onRefresh: controller.refreshOrders,
                  child: _buildContent(primaryColor),
                ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
      title: Text('Orders'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            switch (value) {
              case 'filter':
                _showFilterBottomSheet(primaryColor);
                break;
              case 'clear':
                controller.clearFilters();
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'filter',
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 12),
                      Text('Filter'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 12),
                      Text('Clear Filters'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Search Bar Shimmer
          Container(
            margin: EdgeInsets.all(16),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Summary Cards Shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Orders List Shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                5,
                (index) => Container(
                  margin: EdgeInsets.only(bottom: 12),
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color primaryColor) {
    return Column(
      children: [
        // Search Bar
        _buildSearchBar(primaryColor),

        // Summary Cards
        _buildSummarySection(primaryColor),

        // Active Filters
        Obx(() => _buildActiveFilters(primaryColor)),
        SizedBox(height: 16),

        // Orders List
        Expanded(
          child: Obx(
            () =>
                controller.filteredOrders.isEmpty
                    ? _buildEmptyState(primaryColor)
                    : _buildOrdersList(primaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(Color primaryColor) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search by order ID, customer name...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.filter_list, color: primaryColor),
            onPressed: () => _showFilterBottomSheet(primaryColor),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSummarySection(Color primaryColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Orders',
              controller.totalOrders,
              Icons.shopping_bag,
              Colors.blue,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Revenue',
              controller.totalRevenue,
              Icons.currency_rupee,
              Colors.green,
              isAmount: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    Rx<num> value,
    IconData icon,
    Color color, {
    bool isAmount = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Obx(
            () => Text(
              isAmount
                  ? '₹${value.value.toStringAsFixed(0)}'
                  : '${value.value}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(Color primaryColor) {
    final hasFilters =
        controller.selectedStatus.value != 'all' ||
        controller.selectedDateRange.value != 'all' ||
        controller.searchQuery.value.isNotEmpty;

    if (!hasFilters) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (controller.selectedStatus.value != 'all')
              _buildFilterChip(
                controller.statusOptions.firstWhere(
                  (f) => f['value'] == controller.selectedStatus.value,
                )['label']!,
                primaryColor,
                () => controller.setStatusFilter('all'),
              ),
            if (controller.selectedDateRange.value != 'all')
              _buildFilterChip(
                controller.dateRangeOptions.firstWhere(
                  (d) => d['value'] == controller.selectedDateRange.value,
                )['label']!,
                primaryColor,
                () => controller.setDateRange('all'),
              ),
            if (controller.searchQuery.value.isNotEmpty)
              _buildFilterChip(
                'Search: ${controller.searchQuery.value}',
                primaryColor,
                () => controller.setSearchQuery(''),
              ),
            GestureDetector(
              onTap: controller.clearFilters,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    Color primaryColor,
    VoidCallback onRemove,
  ) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 16, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            SizedBox(height: 12),
            Text(
              'No Orders Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Orders will appear here when customers place them',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(Color primaryColor) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.filteredOrders.length + 1,
      itemBuilder: (context, index) {
        if (index == controller.filteredOrders.length) {
          return Obx(
            () =>
                controller.isLoadingMore.value
                    ? Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                    : SizedBox.shrink(),
          );
        }

        final order = controller.filteredOrders[index];
        return _buildOrderCard(order, primaryColor);
      },
    );
  }

  Widget _buildOrderCard(ExtendedOrderModel order, Color primaryColor) {
    final statusColor = controller.getStatusColor(order.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(16),
            leading: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                controller.getStatusIcon(order.status),
                color: statusColor,
                size: 24,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${order.id}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    controller.getStatusDisplayName(order.status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                Text(
                  order.customerName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                    SizedBox(width: 4),
                    Text(
                      '${order.date.day}/${order.date.month}/${order.date.year} ${order.date.hour}:${order.date.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    Spacer(),
                    Text(
                      '₹${order.amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            onTap: () => controller.viewOrderDetails(order),
          ),

          // Action Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.callCustomer(order),
                    icon: Icon(Icons.phone, size: 16),
                    label: Text('Call', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),

                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        () => _showStatusUpdateDialog(order, primaryColor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text('Update', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(ExtendedOrderModel order, Color primaryColor) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Order Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Order #${order.id}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children:
                      controller.statusOptions
                          .where((status) => status['value'] != 'all')
                          .map(
                            (status) => ListTile(
                              leading: Icon(
                                controller.getStatusIcon(status['value']!),
                                color: controller.getStatusColor(
                                  status['value']!,
                                ),
                              ),
                              title: Text(status['label']!),
                              onTap: () {
                                Get.back();
                                controller.updateOrderStatus(
                                  order,
                                  status['value']!,
                                );
                              },
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.back(),
              child: Center(child: Text('Cancel')),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(Color primaryColor) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Orders',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            Divider(height: 1),

            // Filter Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter
                    _buildFilterSection(
                      'Order Status',
                      controller.statusOptions,
                      controller.selectedStatus,
                      controller.setStatusFilter,
                    ),

                    SizedBox(height: 24),

                    // Date Range Filter
                    _buildFilterSection(
                      'Date Range',
                      controller.dateRangeOptions,
                      controller.selectedDateRange,
                      controller.setDateRange,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        controller.clearFilters();
                        Get.back();
                      },
                      child: Text('Clear All'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                      ),
                      child: Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<Map<String, String>> options,
    RxString selectedValue,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options
                  .map(
                    (option) => Obx(
                      () => GestureDetector(
                        onTap: () => onSelect(option['value']!),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selectedValue.value == option['value']
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  selectedValue.value == option['value']
                                      ? Colors.blue
                                      : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            option['label']!,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  selectedValue.value == option['value']
                                      ? Colors.blue
                                      : Colors.grey[700],
                              fontWeight:
                                  selectedValue.value == option['value']
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
