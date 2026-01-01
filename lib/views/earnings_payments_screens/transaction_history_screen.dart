import '../../libs.dart';
import '../../controllers/transaction_history_controller.dart';

class TransactionHistoryScreen extends StatelessWidget {
  TransactionHistoryScreen({super.key});

  final TransactionHistoryController controller = Get.put(
    TransactionHistoryController(),
  );
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Setup infinite scroll
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreTransactions();
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
                  onRefresh: controller.refreshTransactions,
                  child: _buildContent(primaryColor),
                ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
      title: Text('Transaction History'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.file_download, color: Colors.black),
          onPressed: controller.exportTransactions,
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            switch (value) {
              case 'filter':
                _showFilterBottomSheet(primaryColor);
                break;
              case 'export':
                controller.exportTransactions();
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
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(
                        Icons.file_download,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 12),
                      Text('Export'),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading transactions...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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

        // Transaction List
        Expanded(
          child: Obx(
            () =>
                controller.filteredTransactions.isEmpty
                    ? _buildEmptyState(primaryColor)
                    : _buildTransactionList(primaryColor),
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
          hintText: 'Search by order ID, transaction ID...',
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
              'Total Credit',
              controller.totalCredit,
              Icons.add_circle,
              Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Total Debit',
              controller.totalDebit,
              Icons.remove_circle,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    RxDouble amount,
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
              '₹${amount.value.toStringAsFixed(2)}',
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
        controller.selectedFilter.value != 'all' ||
        controller.selectedDateRange.value != 'all' ||
        controller.searchQuery.value.isNotEmpty;

    if (!hasFilters) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (controller.selectedFilter.value != 'all')
              _buildFilterChip(
                controller.filterOptions.firstWhere(
                  (f) => f['value'] == controller.selectedFilter.value,
                )['label']!,
                primaryColor,
                () => controller.setFilter('all'),
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
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16),
            Text(
              'No Transactions Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your transaction history will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(Color primaryColor) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: controller.filteredTransactions.length + 1,
      itemBuilder: (context, index) {
        if (index == controller.filteredTransactions.length) {
          return Obx(
            () =>
                controller.isLoadingMore.value
                    ? Container(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : SizedBox.shrink(),
          );
        }

        final transaction = controller.filteredTransactions[index];
        return _buildTransactionCard(transaction, primaryColor);
      },
    );
  }

  Widget _buildTransactionCard(
    Map<String, dynamic> transaction,
    Color primaryColor,
  ) {
    final amount = transaction['amount'] ?? 0.0;
    final isCredit = amount > 0;
    final typeColor = controller.getTransactionTypeColor(transaction['type']);
    final statusColor = controller.getStatusColor(transaction['status']);

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
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: typeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            controller.getTransactionTypeIcon(transaction['type']),
            color: typeColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction['description'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${isCredit ? '+' : '-'}₹${amount.abs().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Text(
                  transaction['orderId'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction['status'].toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(
                  '${transaction['date']} ${transaction['time']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                Spacer(),
                Text(
                  transaction['paymentMethod'],
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        onTap: () => controller.viewTransactionDetails(transaction),
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
                    'Filter Transactions',
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
                    // Transaction Type Filter
                    _buildFilterSection(
                      'Transaction Type',
                      controller.filterOptions,
                      controller.selectedFilter,
                      controller.setFilter,
                    ),

                    SizedBox(height: 24),

                    // Date Range Filter
                    _buildFilterSection(
                      'Date Range',
                      controller.dateRangeOptions,
                      controller.selectedDateRange,
                      controller.setDateRange,
                    ),

                    SizedBox(height: 24),

                    // Custom Date Range (if selected)
                    Obx(
                      () =>
                          controller.selectedDateRange.value == 'custom'
                              ? _buildCustomDateRange(primaryColor)
                              : SizedBox.shrink(),
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

  Widget _buildCustomDateRange(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Custom Date Range',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(true, primaryColor),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.startDate.value.day}/${controller.startDate.value.month}/${controller.startDate.value.year}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(false, primaryColor),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'End Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Obx(
                        () => Text(
                          '${controller.endDate.value.day}/${controller.endDate.value.month}/${controller.endDate.value.year}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _selectDate(bool isStartDate, Color primaryColor) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate:
          isStartDate ? controller.startDate.value : controller.endDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStartDate) {
        controller.startDate.value = picked;
      } else {
        controller.endDate.value = picked;
      }
      controller.applyFilters();
    }
  }
}
