import '../../libs.dart';

class OrderScreen extends StatelessWidget {
  OrderScreen({super.key});

  final OrderController controller = Get.find<OrderController>();
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
      title: Text('My Orders'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 0,
      automaticallyImplyLeading:
          false, // Remove back button for bottom nav screen
      actions: [
        IconButton(
          icon: Icon(Icons.sort, color: Colors.black),
          onPressed: () => _showSortBottomSheet(primaryColor),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            switch (value) {
              case 'filter':
                _showFilterBottomSheet(primaryColor);
                break;
              case 'refresh':
                controller.refreshOrders();
                break;
              case 'clear_filters':
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
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 12),
                      Text('Refresh'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'clear_filters',
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
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
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
        // Fixed Search Bar
        _buildSearchBar(primaryColor),

        // Scrollable Content
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                // Summary Cards
                _buildSummarySection(primaryColor),
                SizedBox(height: 16),

                // Active Filters
                Obx(() => _buildActiveFilters(primaryColor)),

                // Orders List
                Obx(
                  () =>
                      controller.filteredOrders.isEmpty
                          ? _buildEmptyState(primaryColor)
                          : _buildOrdersListContent(primaryColor),
                ),
              ],
            ),
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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search orders, customer name, phone...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.filter_list, color: primaryColor),
                onPressed: () => _showFilterBottomSheet(primaryColor),
              ),
              IconButton(
                icon: Icon(Icons.sort, color: primaryColor),
                onPressed: () => _showSortBottomSheet(primaryColor),
              ),
            ],
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Orders',
                  controller.totalOrders.obs,
                  Icons.receipt_long,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Pending',
                  controller.pendingOrders.obs,
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Processing',
                  controller.processingOrders.obs,
                  Icons.settings,
                  Colors.purple,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Completed',
                  controller.completedOrders.obs,
                  Icons.done_all,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
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
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.green,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Total Revenue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Obx(
                  () => Text(
                    controller.formattedTotalRevenue,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
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
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
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
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(height: 8),
          Obx(
            () => Text(
              '${value.value}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters(Color primaryColor) {
    final hasFilters =
        controller.selectedStatus.value != 'all' ||
        controller.selectedDateRange.value != 'all' ||
        controller.searchQuery.value.isNotEmpty ||
        controller.sortBy.value != 'date';

    if (!hasFilters) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (controller.selectedStatus.value != 'all')
              _buildFilterChip(
                'Status: ${controller.statusOptions.firstWhere((s) => s['value'] == controller.selectedStatus.value)['label']}',
                primaryColor,
                () => controller.setStatusFilter('all'),
              ),
            if (controller.selectedDateRange.value != 'all')
              _buildFilterChip(
                'Date: ${controller.dateRangeOptions.firstWhere((d) => d['value'] == controller.selectedDateRange.value)['label']}',
                primaryColor,
                () => controller.setDateRangeFilter('all'),
              ),
            if (controller.searchQuery.value.isNotEmpty)
              _buildFilterChip(
                'Search: ${controller.searchQuery.value}',
                primaryColor,
                () => controller.setSearchQuery(''),
              ),
            if (controller.sortBy.value != 'date')
              _buildFilterChip(
                'Sort: ${controller.sortOptions.firstWhere((s) => s['value'] == controller.sortBy.value)['label']}',
                primaryColor,
                () => controller.setSortBy('date'),
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
        color: primaryColor.withValues(alpha: 0.1),
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
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'No Orders Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Orders will appear here when customers place them.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.refreshOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
              ),
              icon: Icon(Icons.refresh),
              label: Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersListContent(Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ...controller.filteredOrders
              .map((order) => _buildOrderCard(order, primaryColor))
              .toList(),

          // Loading more indicator
          Obx(
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
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(VendorOrderModel order, Color primaryColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: controller
                .getStatusColor(order.status)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            controller.getStatusIcon(order.status),
            color: controller.getStatusColor(order.status),
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'Order ${order.id}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: controller
                    .getStatusColor(order.status)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: controller.getStatusColor(order.status),
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[500]),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(
                  order.customerPhone,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(
                  order.formattedOrderDate,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Spacer(),
                Text(
                  order.formattedTotalAmount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.payment, size: 14, color: Colors.grey[500]),
                SizedBox(width: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        order.paymentStatus == 'paid'
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${order.paymentMethod} • ${order.paymentStatus.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color:
                          order.paymentStatus == 'paid'
                              ? Colors.green
                              : Colors.orange,
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  '${order.items.length} item${order.items.length > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
          onSelected: (value) {
            switch (value) {
              case 'view_details':
                controller.navigateToOrderDetails(order);
                break;
              case 'update_status':
                _showStatusUpdateDialog(order, primaryColor);
                break;
              case 'call_customer':
                Get.snackbar(
                  'Call Customer',
                  'Calling ${order.customerPhone}...',
                );
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'view_details',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 12),
                      Text('View Details'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'update_status',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 12),
                      Text('Update Status'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'call_customer',
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 18, color: Colors.green),
                      SizedBox(width: 12),
                      Text(
                        'Call Customer',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
        ),
        onTap: () => controller.navigateToOrderDetails(order),
      ),
    );
  }

  void _showStatusUpdateDialog(VendorOrderModel order, Color primaryColor) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.75,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Update Order Status',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Order ${order.id}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Current Status Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: controller
                    .getStatusColor(order.status)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.getStatusIcon(order.status),
                    size: 18,
                    color: controller.getStatusColor(order.status),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Current: ${order.status.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: controller.getStatusColor(order.status),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // Status Options Title
            Text(
              'Select New Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),

            // Status Options List
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStatusOption(
                      'Processing',
                      'Order is being prepared',
                      Icons.settings,
                      Colors.blue,
                      order,
                    ),
                    _buildStatusOption(
                      'Shipped',
                      'Order has been shipped',
                      Icons.local_shipping,
                      Colors.teal,
                      order,
                    ),
                    _buildStatusOption(
                      'Out for Delivery',
                      'Order is out for delivery',
                      Icons.delivery_dining,
                      Colors.orange,
                      order,
                    ),
                    _buildStatusOption(
                      'Delivered',
                      'Order has been delivered',
                      Icons.done_all,
                      Colors.green,
                      order,
                    ),
                    Divider(height: 32),
                    _buildStatusOption(
                      'Cancelled',
                      'Order has been cancelled',
                      Icons.cancel,
                      Colors.red,
                      order,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildStatusOption(
    String status,
    String description,
    IconData icon,
    Color color,
    VendorOrderModel order,
  ) {
    final isCurrentStatus = order.status.toLowerCase() == status.toLowerCase();

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentStatus ? color.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentStatus ? color : Colors.grey[300]!,
          width: isCurrentStatus ? 2 : 1,
        ),
      ),
      child: ListTile(
        enabled: !isCurrentStatus,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          status,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isCurrentStatus ? color : Colors.grey[800],
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing:
            isCurrentStatus
                ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'CURRENT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                )
                : Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
        onTap:
            isCurrentStatus
                ? null
                : () {
                  Get.back();
                  controller.updateOrderStatus(order, status);
                },
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
                    _buildFilterSection(
                      'Order Status',
                      controller.statusOptions,
                      controller.selectedStatus,
                      controller.setStatusFilter,
                    ),
                    SizedBox(height: 24),
                    _buildFilterSection(
                      'Date Range',
                      controller.dateRangeOptions,
                      controller.selectedDateRange,
                      controller.setDateRangeFilter,
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
                    color: Colors.black.withValues(alpha: 0.05),
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

  void _showSortBottomSheet(Color primaryColor) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.5,
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
                    'Sort Orders',
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
            // Sort Options
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: controller.sortOptions.length,
                itemBuilder: (context, index) {
                  final option = controller.sortOptions[index];
                  return Obx(
                    () => ListTile(
                      title: Text(option['label']!),
                      leading: Radio<String>(
                        value: option['value']!,
                        groupValue: controller.sortBy.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.setSortBy(value);
                            Get.back();
                          }
                        },
                      ),
                      trailing:
                          controller.sortBy.value == option['value']
                              ? Icon(
                                controller.sortOrder.value == 'asc'
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: primaryColor,
                              )
                              : null,
                      onTap: () {
                        controller.setSortBy(option['value']!);
                        Get.back();
                      },
                    ),
                  );
                },
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
                                    ? Colors.blue.withValues(alpha: 0.1)
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
