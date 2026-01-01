import '../../libs.dart';
import '../../controllers/analytics_controller.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  AnalyticsScreen({super.key});

  final AnalyticsController controller = Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(primaryColor),
      body: Obx(
        () =>
            controller.isLoading.value
                ? _buildLoadingState()
                : RefreshIndicator(
                  onRefresh: controller.refreshAnalytics,
                  child: _buildContent(primaryColor),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.reports),
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        icon: Icon(Icons.description),
        label: Text('Reports'),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
      title: Text('Analytics & Reports'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.black),
          onSelected: (value) {
            switch (value) {
              case 'export_pdf':
                controller.exportReport('PDF');
                break;
              case 'export_excel':
                controller.exportReport('Excel');
                break;
              case 'date_range':
                _showDateRangeSelector(primaryColor);
                break;
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'date_range',
                  child: Row(
                    children: [
                      Icon(Icons.date_range, size: 18, color: Colors.grey[700]),
                      SizedBox(width: 12),
                      Text('Date Range'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export_pdf',
                  child: Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 12),
                      Text('Export PDF'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'export_excel',
                  child: Row(
                    children: [
                      Icon(
                        Icons.table_chart,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      SizedBox(width: 12),
                      Text('Export Excel'),
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
            'Loading analytics...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color primaryColor) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Selector
          _buildDateRangeSelector(primaryColor),
          SizedBox(height: 20),

          // Key Metrics Cards
          _buildKeyMetrics(primaryColor),
          SizedBox(height: 20),

          // Sales Chart
          _buildSalesChart(primaryColor),
          SizedBox(height: 20),

          // Orders Chart
          _buildOrdersChart(primaryColor),
          SizedBox(height: 20),

          // Category Distribution
          _buildCategoryChart(primaryColor),
          SizedBox(height: 20),

          // Customer Analytics
          _buildCustomerAnalytics(primaryColor),
          SizedBox(height: 20),

          // Product Analytics
          _buildProductAnalytics(primaryColor),
          SizedBox(height: 20),

          // Top Products
          _buildTopProducts(primaryColor),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(Color primaryColor) {
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
      child: Row(
        children: [
          Icon(Icons.date_range, color: primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date Range',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Obx(
                  () => Text(
                    controller.selectedDateRangeLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: primaryColor),
            onPressed: () => _showDateRangeSelector(primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Metrics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildMetricCard(
                  'Total Revenue',
                  controller.formattedTotalRevenue,
                  controller.formattedRevenueGrowth,
                  Icons.trending_up,
                  Colors.green,
                  controller.revenueGrowth.value >= 0,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _buildMetricCard(
                  'Total Orders',
                  '${controller.totalOrders.value}',
                  controller.formattedOrderGrowth,
                  Icons.shopping_bag,
                  Colors.blue,
                  controller.orderGrowth.value >= 0,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => _buildMetricCard(
                  'Avg Order Value',
                  controller.formattedAverageOrderValue,
                  '',
                  Icons.attach_money,
                  Colors.orange,
                  true,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _buildMetricCard(
                  'Conversion Rate',
                  controller.formattedConversionRate,
                  '',
                  Icons.trending_up,
                  Colors.purple,
                  true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String growth,
    IconData icon,
    Color color,
    bool isPositive,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              if (growth.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? Colors.green : Colors.red).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    growth,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildSalesChart(Color primaryColor) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: Obx(
              () =>
                  controller.salesChartData.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots:
                                  controller.salesChartData
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => FlSpot(
                                          entry.key.toDouble(),
                                          entry.value.revenue,
                                        ),
                                      )
                                      .toList(),
                              isCurved: true,
                              color: primaryColor,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: primaryColor.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersChart(Color primaryColor) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders Trend',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            child: Obx(
              () =>
                  controller.orderChartData.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : BarChart(
                        BarChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          barGroups:
                              controller.orderChartData
                                  .asMap()
                                  .entries
                                  .map(
                                    (entry) => BarChartGroupData(
                                      x: entry.key,
                                      barRods: [
                                        BarChartRodData(
                                          toY: entry.value.orders.toDouble(),
                                          color: Colors.blue,
                                          width: 16,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(Color primaryColor) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sales by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  height: 200,
                  child: Obx(
                    () =>
                        controller.categoryChartData.isEmpty
                            ? Center(child: CircularProgressIndicator())
                            : PieChart(
                              PieChartData(
                                sections:
                                    controller.categoryChartData
                                        .map(
                                          (data) => PieChartSectionData(
                                            value: data.value,
                                            title:
                                                '${data.value.toStringAsFixed(1)}%',
                                            color: data.color,
                                            radius: 60,
                                            titleStyle: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                centerSpaceRadius: 40,
                              ),
                            ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  children:
                      controller.categoryChartData
                          .map(
                            (data) => _buildLegendItem(
                              data.category,
                              data.color,
                              '${data.value.toStringAsFixed(1)}%',
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerAnalytics(Color primaryColor) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Analytics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildCustomerMetric(
                    'Total Customers',
                    '${controller.totalCustomers.value}',
                    controller.formattedCustomerGrowth,
                    Icons.people,
                    Colors.blue,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _buildCustomerMetric(
                    'New Customers',
                    '${controller.newCustomers.value}',
                    '',
                    Icons.person_add,
                    Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildCustomerMetric(
                    'Returning',
                    '${controller.returningCustomers.value}',
                    '',
                    Icons.repeat,
                    Colors.orange,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _buildCustomerMetric(
                    'Retention Rate',
                    controller.formattedRetentionRate,
                    '',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerMetric(
    String title,
    String value,
    String growth,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              if (growth.isNotEmpty)
                Text(
                  growth,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildProductAnalytics(Color primaryColor) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Analytics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildProductMetric(
                    'Total Products',
                    '${controller.totalProducts.value}',
                    Icons.inventory_2,
                    Colors.blue,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _buildProductMetric(
                    'Active',
                    '${controller.activeProducts.value}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => _buildProductMetric(
                    'Out of Stock',
                    '${controller.outOfStockProducts.value}',
                    Icons.warning,
                    Colors.red,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => _buildProductMetric(
                    'Low Stock',
                    '${controller.lowStockProducts.value}',
                    Icons.warning_amber,
                    Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductMetric(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTopProducts(Color primaryColor) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performing Products',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Obx(
            () => Column(
              children:
                  controller.topProductsData
                      .map((product) => _buildTopProductItem(product))
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductItem(ProductAnalytics product) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.inventory_2, color: Colors.blue, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '${product.unitsSold} units sold',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                product.formattedRevenue,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: product.growthColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  product.formattedGrowth,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: product.growthColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDateRangeSelector(Color primaryColor) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(Get.context!).size.height * 0.6,
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
                    'Select Date Range',
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

            // Date Range Options
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(20),
                itemCount: controller.dateRangeOptions.length,
                itemBuilder: (context, index) {
                  final option = controller.dateRangeOptions[index];
                  return Obx(
                    () => ListTile(
                      title: Text(option['label']!),
                      leading: Radio<String>(
                        value: option['value']!,
                        groupValue: controller.selectedDateRange.value,
                        onChanged: (value) {
                          if (value != null) {
                            controller.setDateRange(value);
                            Get.back();
                          }
                        },
                      ),
                      onTap: () {
                        controller.setDateRange(option['value']!);
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
}
