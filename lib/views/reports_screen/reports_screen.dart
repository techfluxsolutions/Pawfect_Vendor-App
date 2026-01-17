import '../../libs.dart';
import '../../controllers/reports_controller.dart';

class ReportsScreen extends StatelessWidget {
  ReportsScreen({super.key});

  final ReportsController controller = Get.find<ReportsController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: _buildAppBar(primaryColor),
        body: TabBarView(
          children: [
            _buildAvailableReportsTab(primaryColor),
            _buildGeneratedReportsTab(primaryColor),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
      title: Text('Reports'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 0,
      bottom: TabBar(
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black54,
        indicatorColor: Colors.black,
        tabs: [Tab(text: 'Available Reports'), Tab(text: 'Generated Reports')],
      ),
    );
  }

  Widget _buildAvailableReportsTab(Color primaryColor) {
    return Obx(
      () =>
          controller.isLoading.value
              ? _buildLoadingState()
              : RefreshIndicator(
                onRefresh: controller.refreshReports,
                child: Column(
                  children: [
                    // Search and Filter
                    _buildSearchAndFilter(primaryColor),

                    // Reports List
                    Expanded(child: _buildAvailableReportsList(primaryColor)),
                  ],
                ),
              ),
    );
  }

  Widget _buildGeneratedReportsTab(Color primaryColor) {
    return Obx(
      () =>
          controller.isLoading.value
              ? _buildLoadingState()
              : RefreshIndicator(
                onRefresh: controller.refreshReports,
                child: Column(
                  children: [
                    // Search
                    _buildSearchBar(primaryColor),

                    // Generated Reports List
                    Expanded(child: _buildGeneratedReportsList(primaryColor)),
                  ],
                ),
              ),
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
            'Loading reports...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Search Bar
          Container(
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
                hintText: 'Search reports...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: primaryColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', primaryColor),
                SizedBox(width: 8),
                _buildFilterChip('Sales', 'sales', primaryColor),
                SizedBox(width: 8),
                _buildFilterChip('Products', 'products', primaryColor),
                SizedBox(width: 8),
                _buildFilterChip('Customers', 'customers', primaryColor),
                SizedBox(width: 8),
                _buildFilterChip('Financial', 'financial', primaryColor),
                SizedBox(width: 8),
                _buildFilterChip('Inventory', 'inventory', primaryColor),
              ],
            ),
          ),
        ],
      ),
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
          hintText: 'Search generated reports...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color primaryColor) {
    return Obx(
      () => GestureDetector(
        onTap: () => controller.setReportTypeFilter(value),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color:
                controller.selectedReportType.value == value
                    ? primaryColor
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  controller.selectedReportType.value == value
                      ? primaryColor
                      : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color:
                  controller.selectedReportType.value == value
                      ? Colors.black
                      : Colors.grey[700],
              fontWeight:
                  controller.selectedReportType.value == value
                      ? FontWeight.w600
                      : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableReportsList(Color primaryColor) {
    return Obx(
      () =>
          controller.filteredAvailableReports.isEmpty
              ? _buildEmptyState(
                'No reports found',
                'Try adjusting your search or filters',
              )
              : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredAvailableReports.length,
                itemBuilder: (context, index) {
                  final report = controller.filteredAvailableReports[index];
                  return _buildAvailableReportCard(report, primaryColor);
                },
              ),
    );
  }

  Widget _buildGeneratedReportsList(Color primaryColor) {
    return Obx(
      () =>
          controller.filteredGeneratedReports.isEmpty
              ? _buildEmptyState(
                'No generated reports',
                'Generate your first report from the Available Reports tab',
              )
              : ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.filteredGeneratedReports.length,
                itemBuilder: (context, index) {
                  final report = controller.filteredGeneratedReports[index];
                  return _buildGeneratedReportCard(report, primaryColor);
                },
              ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 80, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableReportCard(ReportTemplate report, Color primaryColor) {
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
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: report.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(report.icon, color: report.color, size: 24),
        ),
        title: Text(
          report.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              report.description,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: report.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.categoryName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: report.color,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                SizedBox(width: 4),
                Flexible(
                  child: Text(
                    report.estimatedTime,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: SizedBox(
          width: 80,
          child: ElevatedButton(
            onPressed: () => _showReportParametersDialog(report, primaryColor),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            ),
            child: Text('Generate', style: TextStyle(fontSize: 11)),
          ),
        ),
      ),
    );
  }

  Widget _buildGeneratedReportCard(GeneratedReport report, Color primaryColor) {
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
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: report.statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            report.status == ReportStatus.completed
                ? Icons.description
                : report.status == ReportStatus.failed
                ? Icons.error
                : Icons.hourglass_empty,
            color: report.statusColor,
            size: 24,
          ),
        ),
        title: Text(
          report.name,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: report.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report.statusText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: report.statusColor,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                if (report.fileSize.isNotEmpty) ...[
                  Flexible(
                    child: Text(
                      '${report.format} • ${report.fileSize}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 4),
            Text(
              report.formattedDate,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            if (report.error != null) ...[
              SizedBox(height: 4),
              Text(
                report.error!,
                style: TextStyle(fontSize: 11, color: Colors.red),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
          onSelected: (value) {
            switch (value) {
              case 'download':
                controller.downloadReport(report);
                break;
              case 'delete':
                controller.deleteReport(report);
                break;
            }
          },
          itemBuilder:
              (context) => [
                if (report.status == ReportStatus.completed)
                  PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 18, color: Colors.grey[700]),
                        SizedBox(width: 12),
                        Text('Download'),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
        ),
      ),
    );
  }

  void _showReportParametersDialog(
    ReportTemplate template,
    Color primaryColor,
  ) {
    final parameters = <String, dynamic>{};

    // Initialize parameters with default values
    for (final param in template.parameters) {
      if (param.defaultValue != null) {
        parameters[param.key] = param.defaultValue;
      }
    }

    Get.dialog(
      AlertDialog(
        title: Text('Generate ${template.name}'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                template.description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              ...template.parameters.map(
                (param) => _buildParameterField(param, parameters),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          Obx(
            () => ElevatedButton(
              onPressed:
                  controller.isGenerating.value
                      ? null
                      : () {
                        Get.back();
                        controller.generateReport(template, parameters);
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.black,
              ),
              child:
                  controller.isGenerating.value
                      ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Text('Generate'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterField(
    ReportParameter param,
    Map<String, dynamic> parameters,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                param.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              if (param.required)
                Text(' *', style: TextStyle(color: Colors.red)),
            ],
          ),
          SizedBox(height: 8),
          _buildParameterInput(param, parameters),
        ],
      ),
    );
  }

  Widget _buildParameterInput(
    ReportParameter param,
    Map<String, dynamic> parameters,
  ) {
    switch (param.type) {
      case ParameterType.dateRange:
        return GestureDetector(
          onTap: () => _selectDateRange(param, parameters),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.date_range, color: Colors.grey[600]),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    parameters[param.key] != null
                        ? 'Selected: ${parameters[param.key]}'
                        : 'Select date range',
                    style: TextStyle(color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );

      case ParameterType.dropdown:
        return DropdownButtonFormField<String>(
          value: parameters[param.key],
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items:
              param.options
                  ?.map(
                    (option) =>
                        DropdownMenuItem(value: option, child: Text(option)),
                  )
                  .toList(),
          onChanged: (value) => parameters[param.key] = value,
        );

      case ParameterType.boolean:
        return CheckboxListTile(
          title: Text('Enable'),
          value: parameters[param.key] ?? false,
          onChanged: (value) => parameters[param.key] = value,
          contentPadding: EdgeInsets.zero,
        );

      default:
        return TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (value) => parameters[param.key] = value,
        );
    }
  }

  void _selectDateRange(
    ReportParameter param,
    Map<String, dynamic> parameters,
  ) {
    // Simplified date range selection
    parameters[param.key] = 'Last 30 days';
    Get.snackbar(
      'Date Range Selected',
      'Last 30 days selected for ${param.label}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
  }
}
