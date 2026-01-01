import '../../libs.dart';
import '../../controllers/payment_methods_controller.dart';

class PaymentMethodsScreen extends StatelessWidget {
  PaymentMethodsScreen({super.key});

  final PaymentMethodsController controller = Get.put(
    PaymentMethodsController(),
  );

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
                  onRefresh: controller.refreshPaymentMethods,
                  child: _buildContent(primaryColor),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPaymentMethodSheet(primaryColor),
        backgroundColor: primaryColor,
        icon: Icon(Icons.add, color: Colors.black),
        label: Text('Add Method', style: TextStyle(color: Colors.black)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
      title: Text('Payment Methods'),
      backgroundColor: primaryColor,
      foregroundColor: Colors.black,
      elevation: 0,
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
            'Loading payment methods...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Color primaryColor) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          _buildInfoCard(primaryColor),

          SizedBox(height: 20),

          // Current Payment Methods
          _buildCurrentMethodsSection(primaryColor),

          SizedBox(height: 20),

          // Available Payment Types
          _buildAvailableTypesSection(primaryColor),

          SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildInfoCard(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
              SizedBox(width: 12),
              Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Manage how you receive payments from customers. You can add multiple payment methods and set a default one.',
            style: TextStyle(fontSize: 14, color: Colors.blue[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMethodsSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Payment Methods',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Obx(
          () =>
              controller.paymentMethods.isEmpty
                  ? _buildEmptyState(primaryColor)
                  : Column(
                    children:
                        controller.paymentMethods
                            .map(
                              (method) =>
                                  _buildPaymentMethodCard(method, primaryColor),
                            )
                            .toList(),
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(32),
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
          Icon(Icons.payment_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No Payment Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add a payment method to start receiving payments',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    Map<String, dynamic> method,
    Color primaryColor,
  ) {
    final isDefault = method['isDefault'] ?? false;
    final isVerified = method['isVerified'] ?? false;
    final typeColor = controller.getPaymentTypeColor(method['type']);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDefault ? Border.all(color: primaryColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    controller.getPaymentTypeIcon(method['type']),
                    color: typeColor,
                    size: 24,
                  ),
                ),

                SizedBox(width: 16),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            method['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          if (isDefault) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        method['details'],
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isVerified ? Icons.verified : Icons.pending,
                            size: 16,
                            color: isVerified ? Colors.green : Colors.orange,
                          ),
                          SizedBox(width: 4),
                          Text(
                            isVerified ? 'Verified' : 'Pending Verification',
                            style: TextStyle(
                              fontSize: 12,
                              color: isVerified ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    switch (value) {
                      case 'default':
                        controller.setDefaultPaymentMethod(method['id']);
                        break;
                      case 'delete':
                        controller.deletePaymentMethod(method);
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        if (!isDefault)
                          PopupMenuItem(
                            value: 'default',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                SizedBox(width: 12),
                                Text('Set as Default'),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),

            // Additional Info
            if (method['lastUsed'] != null) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 6),
                    Text(
                      'Last used: ${method['lastUsed']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableTypesSection(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Payment Types',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Container(
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
            children:
                controller.availablePaymentTypes
                    .map((type) => _buildPaymentTypeItem(type, primaryColor))
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentTypeItem(Map<String, dynamic> type, Color primaryColor) {
    final isEnabled = type['isEnabled'] ?? false;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: type['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(type['icon'], color: type['color'], size: 24),
        ),
        title: Text(
          type['name'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isEnabled ? Colors.grey[800] : Colors.grey[500],
          ),
        ),
        subtitle: Text(
          type['description'],
          style: TextStyle(
            fontSize: 14,
            color: isEnabled ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
        trailing:
            isEnabled
                ? Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                )
                : Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        onTap: isEnabled ? () => controller.addPaymentMethod(type['id']) : null,
      ),
    );
  }

  void _showAddPaymentMethodSheet(Color primaryColor) {
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
            SizedBox(height: 20),

            Text(
              'Add Payment Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 16),

            ...controller.availablePaymentTypes
                .where((type) => type['isEnabled'])
                .map(
                  (type) => ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: type['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(type['icon'], color: type['color'], size: 24),
                    ),
                    title: Text(type['name']),
                    subtitle: Text(type['description']),
                    onTap: () {
                      Get.back();
                      controller.addPaymentMethod(type['id']);
                    },
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
}
