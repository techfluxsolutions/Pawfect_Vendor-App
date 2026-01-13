import '../../libs.dart';

class ProductScreen extends StatelessWidget {
  ProductScreen({super.key});

  final ProductController controller = Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(primaryColor),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  _buildSearchBar(primaryColor),

                  SizedBox(height: 16),

                  // Filter & Sort Row
                  _buildFilterSortRow(context, primaryColor),

                  SizedBox(height: 16),

                  // Active Filters
                  Obx(
                    () =>
                        controller.hasActiveFilters()
                            ? _buildActiveFilters(primaryColor)
                            : SizedBox.shrink(),
                  ),

                  // Product Count
                  Obx(
                    () => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        '${controller.filteredProducts.length} Products',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  // Product List
                  Obx(
                    () =>
                        controller.isLoading.value
                            ? _buildLoadingState()
                            : controller.filteredProducts.isEmpty
                            ? _buildEmptyState(primaryColor)
                            : _buildProductList(primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.addProduct,
        backgroundColor: primaryColor,
        icon: Icon(Icons.add, color: Colors.black),
        label: Text('Add Product', style: TextStyle(color: Colors.black)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryColor) {
    return AppBar(
      title: Text(
        'My Products',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
    );
  }

  Widget _buildSearchBar(Color primaryColor) {
    return Container(
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
          hintText: 'Search by name, category...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: primaryColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterSortRow(BuildContext context, Color primaryColor) {
    return Row(
      children: [
        // Filter Button
        Expanded(
          child: Obx(
            () => _buildActionButton(
              icon: Icons.filter_list,
              label: 'Filter',
              hasActive: controller.hasActiveFilters(),
              primaryColor: primaryColor,
              onTap: () => _showFilterBottomSheet(context, primaryColor),
            ),
          ),
        ),

        SizedBox(width: 12),

        // Sort Button
        Expanded(
          child: Obx(
            () => _buildActionButton(
              icon: Icons.sort,
              label: 'Sort: ${controller.sortBy.value.capitalize}',
              hasActive: false,
              primaryColor: primaryColor,
              onTap: () => _showSortBottomSheet(context, primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool hasActive,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hasActive ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasActive ? primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: hasActive ? primaryColor : Colors.grey[700],
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: hasActive ? primaryColor : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (hasActive) ...[
              SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilters(Color primaryColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (controller.selectedPetType.value.isNotEmpty)
              _buildFilterChip(
                controller.selectedPetType.value,
                primaryColor,
                () => controller.setPetType(controller.selectedPetType.value),
              ),

            if (controller.selectedFoodType.value.isNotEmpty)
              _buildFilterChip(
                controller.selectedFoodType.value,
                primaryColor,
                () => controller.setFoodType(controller.selectedFoodType.value),
              ),

            if (controller.selectedCategory.value.isNotEmpty)
              _buildFilterChip(
                controller.selectedCategory.value,
                primaryColor,
                () => controller.setCategory(''),
              ),

            if (controller.selectedStockStatus.value.isNotEmpty)
              _buildFilterChip(
                controller.selectedStockStatus.value,
                primaryColor,
                () => controller.setStockStatus(
                  controller.selectedStockStatus.value,
                ),
              ),

            if (controller.selectedProductStatus.value.isNotEmpty)
              _buildFilterChip(
                controller.selectedProductStatus.value,
                primaryColor,
                () => controller.setProductStatus(
                  controller.selectedProductStatus.value,
                ),
              ),

            // Clear All
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

  Widget _buildLoadingState() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 5, // Show 5 skeleton loaders
      itemBuilder: (context, index) {
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Skeleton
              Container(
                width: 100,
                height: 140, // ✅ Match the new image height
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),

              // Details Skeleton
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title skeleton
                      Container(
                        height: 14,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8),

                      // Subtitle skeleton
                      Container(
                        height: 12,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8),

                      // Details skeleton
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 8),

                      // Price skeleton
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'No Products Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first product or adjust filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(Color primaryColor) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: controller.filteredProducts.length,
      itemBuilder: (context, index) {
        final product = controller.filteredProducts[index];
        return _buildProductCard(product, primaryColor);
      },
    );
  }

  Widget _buildProductCard(ProductModel product, Color primaryColor) {
    return GestureDetector(
      onTap: () => controller.viewProduct(product),
      child: Container(
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side - Image
            _buildProductImage(product, primaryColor),

            // Right Side - Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row - Name & Menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildPopupMenu(product, primaryColor),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Pet Type & Category
                    Row(
                      children: [
                        _buildPetTypeBadge(product.petType, primaryColor),
                        SizedBox(width: 8),
                        Text(
                          product.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Weight & Stock
                    Row(
                      children: [
                        Icon(Icons.scale, size: 14, color: Colors.grey[500]),
                        SizedBox(width: 4),
                        Text(
                          product.weight,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(width: 16),
                        _buildStockBadge(product),
                      ],
                    ),

                    SizedBox(height: 8),

                    // Status & Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(product.status),
                        _buildPriceRow(product, primaryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductModel product, Color primaryColor) {
    return Container(
      width: 100,
      height: 140, // ✅ Increased height from 120 to 140 for better visual
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: Container(
              width: 100,
              height: 140,
              color: Colors.grey[200],
              child:
                  product.images.isNotEmpty
                      ? Image.network(
                        product
                            .images[0], // ✅ Use the full URL directly from API
                        fit: BoxFit.cover,
                        width: 100,
                        height: 140,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey[400],
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          );
                        },
                      )
                      : Icon(Icons.image, size: 40, color: Colors.grey[400]),
            ),
          ),

          // Discount Badge
          if (product.discount > 0)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${product.discount.toStringAsFixed(0)}% OFF',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPetTypeBadge(String petType, Color primaryColor) {
    IconData icon;
    switch (petType.toLowerCase()) {
      case 'dog':
        icon = Icons.pets;
        break;
      case 'cat':
        icon = Icons.pets;
        break;
      case 'bird':
        icon = Icons.flutter_dash;
        break;
      case 'fish':
        icon = Icons.water;
        break;
      default:
        icon = Icons.pets;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: primaryColor),
          SizedBox(width: 4),
          Text(
            petType,
            style: TextStyle(
              fontSize: 11,
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(ProductModel product) {
    Color color;
    if (product.stockQuantity == 0) {
      color = Colors.red;
    } else if (product.stockQuantity <= 10) {
      color = Colors.orange;
    } else {
      color = Colors.green;
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4),
        Text(
          '${product.stockQuantity} units',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'draft':
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
        break;
      case 'pending':
        bgColor = Colors.amber[100]!;
        textColor = Colors.amber[800]!;
        break;
      case 'approved':
      case 'live':
        bgColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      case 'rejected':
        bgColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      default:
        bgColor = Colors.grey[200]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriceRow(ProductModel product, Color primaryColor) {
    return Row(
      children: [
        Text(
          '₹${product.sellingPrice.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        SizedBox(width: 6),
        Text(
          '₹${product.mrp.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
            decoration: TextDecoration.lineThrough,
          ),
        ),
      ],
    );
  }

  Widget _buildPopupMenu(ProductModel product, Color primaryColor) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
      onSelected: (value) {
        switch (value) {
          case 'view':
            controller.viewProduct(product);
            break;
          case 'edit':
            controller.editProduct(product);
            break;
          case 'duplicate':
            controller.duplicateProduct(product);
            break;
          case 'delete':
            controller.deleteProduct(product);
            break;
        }
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 18, color: Colors.grey[700]),
                  SizedBox(width: 12),
                  Text('View Details'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.grey[700]),
                  SizedBox(width: 12),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Icons.copy, size: 18, color: Colors.grey[700]),
                  SizedBox(width: 12),
                  Text('Duplicate'),
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
    );
  }

  // Filter Bottom Sheet
  void _showFilterBottomSheet(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _FilterBottomSheet(
            controller: controller,
            primaryColor: primaryColor,
          ),
    );
  }

  // Sort Bottom Sheet
  void _showSortBottomSheet(BuildContext context, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.all(20),
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
                  'Sort By',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(height: 16),

                ...controller.sortOptions.map(
                  (option) => Obx(
                    () => ListTile(
                      title: Text(option),
                      leading: Radio<String>(
                        value: option.toLowerCase(),
                        groupValue: controller.sortBy.value,
                        onChanged: (value) {
                          controller.setSortBy(value!);
                          Get.back();
                        },
                        activeColor: primaryColor,
                      ),
                      trailing:
                          controller.sortBy.value == option.toLowerCase()
                              ? Icon(
                                controller.sortAscending.value
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: primaryColor,
                                size: 18,
                              )
                              : null,
                      onTap: () {
                        controller.setSortBy(option);
                        Get.back();
                      },
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
    );
  }
}

// Filter Bottom Sheet Widget
class _FilterBottomSheet extends StatelessWidget {
  final ProductController controller;
  final Color primaryColor;

  const _FilterBottomSheet({
    required this.controller,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Products',
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

          // Filters Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet Type
                  _buildFilterSection(
                    'Pet Type',
                    controller.petTypes,
                    controller.selectedPetType,
                    controller.setPetType,
                  ),

                  SizedBox(height: 24),

                  // Food Type
                  _buildFilterSection(
                    'Food Type',
                    controller.foodTypes,
                    controller.selectedFoodType,
                    controller.setFoodType,
                  ),

                  SizedBox(height: 24),

                  // Category Dropdown
                  _buildSectionTitle('Category'),
                  SizedBox(height: 8),
                  Obx(
                    () => DropdownButtonFormField<String>(
                      value:
                          controller.selectedCategory.value.isEmpty
                              ? null
                              : controller.selectedCategory.value,
                      hint: Text('Select Category'),
                      items:
                          controller.categories
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ),
                              )
                              .toList(),
                      onChanged: (value) => controller.setCategory(value ?? ''),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Stock Status
                  _buildFilterSection(
                    'Stock Status',
                    controller.stockStatuses,
                    controller.selectedStockStatus,
                    controller.setStockStatus,
                  ),

                  SizedBox(height: 24),

                  // Product Status
                  _buildFilterSection(
                    'Product Status',
                    controller.productStatuses,
                    controller.selectedProductStatus,
                    controller.setProductStatus,
                  ),

                  SizedBox(height: 24),

                  // Price Range
                  _buildSectionTitle('Price Range'),
                  SizedBox(height: 8),
                  Obx(
                    () => Column(
                      children: [
                        RangeSlider(
                          values: controller.priceRange.value,
                          min: 0,
                          max: 10000,
                          divisions: 100,
                          activeColor: primaryColor,
                          labels: RangeLabels(
                            '₹${controller.priceRange.value.start.toStringAsFixed(0)}',
                            '₹${controller.priceRange.value.end.toStringAsFixed(0)}',
                          ),
                          onChanged: controller.setPriceRange,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹${controller.priceRange.value.start.toStringAsFixed(0)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            Text(
                              '₹${controller.priceRange.value.end.toStringAsFixed(0)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyFilters();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(color: Colors.white),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    RxString selectedValue,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              options
                  .map(
                    (option) => Obx(
                      () => GestureDetector(
                        onTap: () => onSelect(option),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selectedValue.value == option
                                    ? primaryColor.withOpacity(0.1)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  selectedValue.value == option
                                      ? primaryColor
                                      : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 13,
                              color:
                                  selectedValue.value == option
                                      ? primaryColor
                                      : Colors.grey[700],
                              fontWeight:
                                  selectedValue.value == option
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
