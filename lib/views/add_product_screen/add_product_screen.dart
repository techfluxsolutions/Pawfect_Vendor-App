import 'dart:developer';

import '../../libs.dart';

class AddProductScreen extends StatelessWidget {
  AddProductScreen({super.key});

  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    log("Build");
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final productId = Get.arguments as String?;

    log("Product Autofilled data ${controller.productImages}");
    log("Product Id $productId");

    // ✅ Clear form if no productId (adding new product)
    if (productId == null) {
      controller.clearForm();
    }

    // ✅ If editing, auto-load the product data
    if (productId != null && controller.nameController.text.isEmpty) {}

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(primaryColor),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images Section
                    _buildImagesSection(context, primaryColor),

                    SizedBox(height: 20),

                    // Basic Information
                    _buildSectionCard('Basic Information', primaryColor, [
                      _buildTextField(
                        controller: controller.nameController,
                        label: 'Product Name',
                        hint: 'Enter product name',
                        icon: Icons.inventory_2,
                        validator:
                            (v) =>
                                controller.validateRequired(v, 'Product name'),
                      ),
                      SizedBox(height: 16),
                      _buildCategoryDropdown(primaryColor),
                      SizedBox(height: 16),
                      _buildFoodTypeDropdown(primaryColor),
                    ]),

                    SizedBox(height: 20),

                    // Pricing Section
                    _buildSectionCard('Pricing', primaryColor, [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.mrpController,
                              label: 'MRP',
                              hint: 'Enter MRP',
                              icon: Icons.currency_rupee,
                              keyboardType: TextInputType.number,
                              validator: controller.validatePrice,
                              onChanged: (v) => controller.update(),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: controller.priceController,
                              label: 'Selling Price',
                              hint: 'Enter selling price',
                              icon: Icons.sell,
                              keyboardType: TextInputType.number,
                              validator: controller.validatePrice,
                              onChanged: (v) => controller.update(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      GetBuilder<ProductController>(
                        builder: (_) {
                          final discount = controller.calculateDiscount();
                          return discount > 0
                              ? Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_offer,
                                      color: Colors.green[700],
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Discount: ${discount.toStringAsFixed(1)}% OFF',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              : SizedBox.shrink();
                        },
                      ),
                    ]),

                    SizedBox(height: 20),

                    // Stock & Weight
                    _buildSectionCard('Stock & Weight', primaryColor, [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: controller.stockQuantityController,
                              label: 'Stock Quantity',
                              hint: 'Enter stock quantity',
                              icon: Icons.inventory,
                              keyboardType: TextInputType.number,
                              validator:
                                  (v) => controller.validateNumber(
                                    v,
                                    'Stock quantity',
                                  ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: controller.weightController,
                              label: 'Weight',
                              hint: 'Enter weight with unit',
                              icon: Icons.scale,
                              validator:
                                  (v) =>
                                      controller.validateRequired(v, 'Weight'),
                            ),
                          ),
                        ],
                      ),
                    ]),

                    SizedBox(height: 20),

                    // Description Section
                    _buildSectionCard('Description', primaryColor, [
                      _buildTextField(
                        controller: controller.descriptionController,
                        label: 'Product Description',
                        hint: 'Enter product description',
                        icon: Icons.description,
                        maxLines: 4,
                        validator:
                            (v) =>
                                controller.validateRequired(v, 'Description'),
                      ),
                    ]),

                    SizedBox(height: 20),

                    // Benefits Section
                    _buildBenefitsSection(primaryColor),

                    SizedBox(height: 20),

                    // Delivery Information
                    _buildSectionCard('Delivery Information', primaryColor, [
                      _buildTextField(
                        controller: controller.deliveryEstimateController,
                        label: 'Delivery Estimate',
                        hint: 'Enter delivery estimate',
                        icon: Icons.local_shipping,
                        validator:
                            (v) => controller.validateRequired(
                              v,
                              'Delivery estimate',
                            ),
                      ),
                    ]),

                    SizedBox(height: 30),

                    // Action Buttons
                    _buildActionButtons(primaryColor),

                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    Color primaryColor, {
    bool isEditing = false,
  }) {
    return AppBar(
      title: Text(isEditing ? 'Edit Product' : 'Add Product'),
      centerTitle: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    Color primaryColor,
    List<Widget> children,
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
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildCategoryDropdown(Color primaryColor) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value:
            controller
                    .formSelectedPetType
                    .value
                    .isEmpty // ✅ Change to formSelectedPetType
                ? null
                : controller.formSelectedPetType.value,
        hint: Text('Select pet type'),
        items:
            controller.petTypes.map((type) {
              // ✅ Use petTypes instead of categories
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
        onChanged:
            (value) =>
                controller.formSelectedPetType.value =
                    value ?? '', // ✅ Set petType
        decoration: InputDecoration(
          labelText: 'Pet Type', // ✅ Change label
          prefixIcon: Icon(Icons.pets), // ✅ Change icon
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (v) {
          if (controller.formSelectedPetType.value.isEmpty) {
            // ✅ Validate petType
            return 'Please select a pet type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildFoodTypeDropdown(Color primaryColor) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value:
            controller.formSelectedFoodType.value.isEmpty
                ? null
                : controller.formSelectedFoodType.value,
        hint: Text('Select food type'),
        items:
            controller.foodTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
        onChanged:
            (value) => controller.formSelectedFoodType.value = value ?? '',
        decoration: InputDecoration(
          labelText: 'Food Type',
          prefixIcon: Icon(Icons.fastfood),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        // ✅ ADD VALIDATOR
        validator: (v) {
          if (controller.formSelectedFoodType.value.isEmpty) {
            return 'Please select a food type';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildImagesSection(BuildContext context, Color primaryColor) {
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
          Text(
            'Product Images',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Obx(() {
            final hasExistingImages = controller.existingImageUrls.isNotEmpty;
            final hasNewImages = controller.productImages.isNotEmpty;
            final hasAnyImages = hasExistingImages || hasNewImages;

            return hasAnyImages
                ? Column(
                  children: [
                    _buildImageGrid(primaryColor),
                    SizedBox(height: 12),
                    _buildAddImageButton(context, primaryColor),
                  ],
                )
                : _buildAddImageButton(context, primaryColor);
          }),
        ],
      ),
    );
  }

  Widget _buildAddImageButton(BuildContext context, Color primaryColor) {
    return GestureDetector(
      onTap: () => controller.showImagePickerOptions(context),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate, size: 40, color: primaryColor),
              SizedBox(height: 8),
              Text(
                'Add Images',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid(Color primaryColor) {
    return Obx(() {
      final totalImages = controller.getTotalImageCount();

      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: totalImages,
        itemBuilder: (context, index) {
          final existingImagesCount = controller.existingImageUrls.length;

          // Show existing images first, then new images
          if (index < existingImagesCount) {
            // Existing image from API
            return _buildExistingImageItem(index, primaryColor);
          } else {
            // New image from device
            final newImageIndex = index - existingImagesCount;
            return _buildNewImageItem(newImageIndex, primaryColor);
          }
        },
      );
    });
  }

  Widget _buildExistingImageItem(int index, Color primaryColor) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            controller.existingImageUrls[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    value:
                        loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.error, color: Colors.red),
              );
            },
          ),
        ),
        // Existing image indicator
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Existing',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.removeExistingImage(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImageItem(int index, Color primaryColor) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            controller.productImages[index],
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // New image indicator
        Positioned(
          top: 4,
          left: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'New',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => controller.removeImage(index),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection(Color primaryColor) {
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
          Text(
            'Product Benefits',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.benefitController,
                  decoration: InputDecoration(
                    hintText: 'Enter product benefit',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                onPressed: controller.addBenefit,
                icon: Icon(Icons.add_circle, color: primaryColor, size: 32),
              ),
            ],
          ),
          SizedBox(height: 12),
          Obx(() {
            return controller.benefits.isEmpty
                ? Text(
                  'No benefits added yet',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                )
                : Column(
                  children: List.generate(
                    controller.benefits.length,
                    (index) => Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: primaryColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.benefits[index],
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 20,
                            ),
                            onPressed: () => controller.removeBenefit(index),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color primaryColor) {
    final productId = Get.arguments as String?;
    final isEditing = productId != null;

    return Obx(() {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  controller.isSaving.value ? null : controller.clearForm,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[400]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Clear',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed:
                  controller.isSaving.value
                      ? null
                      : () {
                        if (isEditing) {
                          controller.updateProduct(productId!);
                        } else {
                          controller.saveProduct();
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  controller.isSaving.value
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                      : Text(
                        isEditing ? 'Update Product' : 'Add Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
        ],
      );
    });
  }
}
