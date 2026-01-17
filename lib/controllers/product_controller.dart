import 'dart:developer';
import 'dart:io';

import '../libs.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();

  // Search
  var searchQuery = ''.obs;
  var isSearching = false.obs;

  // Sort
  var sortBy = 'name'.obs;
  var sortAscending = true.obs;

  // Filters
  var selectedPetType = ''.obs;
  var selectedFoodType = ''.obs;
  var selectedCategory = ''.obs;
  var selectedStockStatus = ''.obs;
  var selectedProductStatus = ''.obs;
  var priceRange = RangeValues(0, 10000).obs;

  // Loading state
  var isLoading = false.obs;
  var isSaving = false.obs;

  // Products list
  var products = <ProductModel>[].obs;
  var filteredProducts = <ProductModel>[].obs;

  // Form Controllers for Add/Edit
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final foodTypeController = TextEditingController();
  final priceController = TextEditingController();
  final mrpController = TextEditingController();
  final weightController = TextEditingController();
  final stockQuantityController = TextEditingController();
  final descriptionController = TextEditingController();
  final deliveryEstimateController = TextEditingController();
  final benefitController = TextEditingController();

  // Form selection variables (separate from filter variables)
  var formSelectedPetType = ''.obs;
  var formSelectedFoodType = ''.obs;
  var formSelectedCategory = ''.obs;

  // Benefits (dynamic list)
  var benefits = <String>[].obs;

  // Images
  var productImages = <File>[].obs;
  var existingImageUrls =
      <String>[].obs; // For storing existing image URLs when editing
  final ImagePicker _picker = ImagePicker();

  // Filter options
  final List<String> petTypes = ['Dog', 'Cat', 'Bird', 'Fish', 'Other'];
  final List<String> foodTypes = ['Dry', 'Wet', 'Treats', 'Supplements'];
  final List<String> categories = [
    'Food',
    'Accessories',
    'Toys',
    'Grooming',
    'Health',
  ];
  final List<String> stockStatuses = ['In Stock', 'Low Stock', 'Out of Stock'];
  final List<String> productStatuses = [
    'Draft',
    'Pending',
    'Approved',
    'Live',
    'Rejected',
  ];
  final List<String> sortOptions = ['Name', 'Price', 'Stock', 'Status'];

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  @override
  void onClose() {
    nameController.dispose();
    categoryController.dispose();
    foodTypeController.dispose();
    priceController.dispose();
    mrpController.dispose();
    weightController.dispose();
    stockQuantityController.dispose();
    descriptionController.dispose();
    deliveryEstimateController.dispose();
    benefitController.dispose();
    super.onClose();
  }

  // Add these methods to your ProductController class

  // ========== Get Product By ID ==========

  /// Fetch single product details by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      print('📥 Fetching product: $productId');

      isLoading.value = true;
      final response = await _productService.getProductById(productId);
      isLoading.value = false;

      if (response.success && response.data != null) {
        print('✅ Product fetched successfully');
        final productJson = response.data['product'];
        final product = ProductModel.fromJson(productJson);
        return product;
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to fetch product',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return null;
      }
    } catch (e) {
      print('❌ Fetch product error: $e');
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to fetch product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  // ========== View Product Details ==========

  /// Navigate to product details screen with product data
  void viewProduct(ProductModel product) {
    Get.toNamed('/product-details', arguments: product);
  }

  // ========== Edit Product ==========

  /// Load product data into form for editing
  Future<void> loadProductForEdit(ProductModel product) async {
    try {
      print('🔄 Loading complete product details for editing: ${product.id}');

      // Fetch complete product details from API
      final completeProduct = await getProductById(product.id);

      if (completeProduct == null) {
        print('❌ Failed to fetch complete product details');
        // Fallback to basic product data
        _populateFormWithBasicData(product);
        return;
      }

      // Populate form controllers with complete product data
      nameController.text = completeProduct.name;
      formSelectedPetType.value = completeProduct.petType;
      formSelectedFoodType.value = completeProduct.foodType;
      formSelectedCategory.value = completeProduct.category;
      priceController.text = completeProduct.sellingPrice.toString();
      mrpController.text = completeProduct.mrp.toString();
      weightController.text = completeProduct.weight;
      stockQuantityController.text = completeProduct.stockQuantity.toString();
      descriptionController.text = completeProduct.description;
      deliveryEstimateController.text = completeProduct.deliveryEstimate;

      // Set benefits
      benefits.value = completeProduct.benefits;

      // Load existing images from API
      productImages.clear();
      if (completeProduct.images.isNotEmpty) {
        print('📸 Loading ${completeProduct.images.length} existing images');
        // Convert image URLs to File objects for display
        // Note: These are network images, not local files
        // We'll handle this in the UI to show existing images
        for (String imageUrl in completeProduct.images) {
          print('🖼️ Image URL: $imageUrl');
        }
        // Store the existing image URLs for reference
        existingImageUrls.value = completeProduct.images;
      }

      print('✅ Complete product loaded for editing: ${completeProduct.name}');
    } catch (e) {
      print('❌ Error loading complete product: $e');
      // Fallback to basic product data
      _populateFormWithBasicData(product);
      Get.snackbar(
        'Warning',
        'Using basic product data. Some details may not be available.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  /// Fallback method to populate form with basic product data
  void _populateFormWithBasicData(ProductModel product) {
    nameController.text = product.name;
    formSelectedPetType.value = product.petType;
    formSelectedFoodType.value = product.foodType;
    formSelectedCategory.value = product.category;
    priceController.text = product.sellingPrice.toString();
    mrpController.text = product.mrp.toString();
    weightController.text = product.weight;
    stockQuantityController.text = product.stockQuantity.toString();
    descriptionController.text = product.description;
    deliveryEstimateController.text = product.deliveryEstimate;
    benefits.value = product.benefits;
    existingImageUrls.value = product.images; // Use basic image URLs
  }

  // ========== Update Product ==========

  /// Update existing product
  Future<void> updateProduct(String productId) async {
    if (!formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (formSelectedPetType.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a pet type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (formSelectedFoodType.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please select a food type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (getTotalImageCount() == 0) {
      Get.snackbar(
        'Validation Error',
        'Please add at least one product image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isSaving.value = true;

    try {
      final response = await _productService.updateProduct(
        productId: productId,
        name: nameController.text.trim(),
        category: formSelectedPetType.value,
        foodType: formSelectedFoodType.value,
        price: double.parse(priceController.text),
        mrp: double.parse(mrpController.text),
        weight: weightController.text.trim(),
        stockQuantity: int.parse(stockQuantityController.text),
        description: descriptionController.text.trim(),
        benefits: benefits.toList(),
        deliveryEstimate: deliveryEstimateController.text.trim(),
        newImages: productImages.isNotEmpty ? productImages.toList() : null,
      );

      isSaving.value = false;

      if (response.success) {
        clearForm();
        Get.back(result: true);
        Get.snackbar(
          'Success',
          response.message ?? 'Product updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
        fetchProducts();
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to update product',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isSaving.value = false;
      Get.snackbar(
        'Error',
        'Failed to update product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  // ========== API Methods ==========

  Future<void> fetchProducts() async {
    isLoading.value = true;

    final response = await _productService.getAllProducts(
      search: searchQuery.value.isEmpty ? null : searchQuery.value,
      category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
      petType: selectedPetType.value.isEmpty ? null : selectedPetType.value,
      foodType: selectedFoodType.value.isEmpty ? null : selectedFoodType.value,
      stockStatus:
          selectedStockStatus.value.isEmpty ? null : selectedStockStatus.value,
      productStatus:
          selectedProductStatus.value.isEmpty
              ? null
              : selectedProductStatus.value,
      minPrice: priceRange.value.start,
      maxPrice: priceRange.value.end,
      sortBy: sortBy.value,
      sortAscending: sortAscending.value,
    );

    isLoading.value = false;

    if (response.success && response.data != null) {
      final List<dynamic> productsJson = response.data['products'] ?? [];
      products.value =
          productsJson.map((json) => ProductModel.fromJson(json)).toList();
      applyFilters();
    } else {
      Get.snackbar(
        'Error',
        response.message ?? 'Failed to fetch products',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteProduct(ProductModel product) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await _productService.deleteProduct(product.id);

      if (response.success) {
        Get.snackbar(
          'Success',
          'Product deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        fetchProducts();
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to delete product',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  // ========== Search & Filter Methods ==========

  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void toggleSearch() {
    isSearching.value = !isSearching.value;
    if (!isSearching.value) {
      searchQuery.value = '';
      applyFilters();
    }
  }

  void setSortBy(String sort) {
    if (sortBy.value == sort.toLowerCase()) {
      sortAscending.value = !sortAscending.value;
    } else {
      sortBy.value = sort.toLowerCase();
      sortAscending.value = true;
    }
    applyFilters();
  }

  void setPetType(String type) {
    selectedPetType.value = selectedPetType.value == type ? '' : type;
  }

  void setFoodType(String type) {
    selectedFoodType.value = selectedFoodType.value == type ? '' : type;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setStockStatus(String status) {
    selectedStockStatus.value =
        selectedStockStatus.value == status ? '' : status;
  }

  void setProductStatus(String status) {
    selectedProductStatus.value =
        selectedProductStatus.value == status ? '' : status;
  }

  void setPriceRange(RangeValues range) {
    priceRange.value = range;
  }

  void clearFilters() {
    selectedPetType.value = '';
    selectedFoodType.value = '';
    selectedCategory.value = '';
    selectedStockStatus.value = '';
    selectedProductStatus.value = '';
    priceRange.value = RangeValues(0, 10000);
    applyFilters();
  }

  void applyFilters() {
    List<ProductModel> result = products;

    // Search filter
    if (searchQuery.value.isNotEmpty) {
      result =
          result
              .where(
                (p) =>
                    p.name.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ) ||
                    p.category.toLowerCase().contains(
                      searchQuery.value.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Pet type filter
    if (selectedPetType.value.isNotEmpty) {
      result = result.where((p) => p.petType == selectedPetType.value).toList();
    }

    // Food type filter
    if (selectedFoodType.value.isNotEmpty) {
      result =
          result.where((p) => p.foodType == selectedFoodType.value).toList();
    }

    // Category filter
    if (selectedCategory.value.isNotEmpty) {
      result =
          result.where((p) => p.category == selectedCategory.value).toList();
    }

    // Stock status filter
    if (selectedStockStatus.value.isNotEmpty) {
      result =
          result.where((p) {
            switch (selectedStockStatus.value) {
              case 'In Stock':
                return p.stockQuantity > 10;
              case 'Low Stock':
                return p.stockQuantity > 0 && p.stockQuantity <= 10;
              case 'Out of Stock':
                return p.stockQuantity == 0;
              default:
                return true;
            }
          }).toList();
    }

    // Product status filter
    if (selectedProductStatus.value.isNotEmpty) {
      result =
          result.where((p) => p.status == selectedProductStatus.value).toList();
    }

    // Price range filter
    result =
        result
            .where(
              (p) =>
                  p.sellingPrice >= priceRange.value.start &&
                  p.sellingPrice <= priceRange.value.end,
            )
            .toList();

    // Sort
    switch (sortBy.value) {
      case 'name':
        result.sort(
          (a, b) =>
              sortAscending.value
                  ? a.name.compareTo(b.name)
                  : b.name.compareTo(a.name),
        );
        break;
      case 'price':
        result.sort(
          (a, b) =>
              sortAscending.value
                  ? a.sellingPrice.compareTo(b.sellingPrice)
                  : b.sellingPrice.compareTo(a.sellingPrice),
        );
        break;
      case 'stock':
        result.sort(
          (a, b) =>
              sortAscending.value
                  ? a.stockQuantity.compareTo(b.stockQuantity)
                  : b.stockQuantity.compareTo(a.stockQuantity),
        );
        break;
      case 'status':
        result.sort(
          (a, b) =>
              sortAscending.value
                  ? a.status.compareTo(b.status)
                  : b.status.compareTo(a.status),
        );
        break;
    }

    filteredProducts.value = result;
  }

  bool hasActiveFilters() {
    return selectedPetType.value.isNotEmpty ||
        selectedFoodType.value.isNotEmpty ||
        selectedCategory.value.isNotEmpty ||
        selectedStockStatus.value.isNotEmpty ||
        selectedProductStatus.value.isNotEmpty ||
        priceRange.value.start > 0 ||
        priceRange.value.end < 10000;
  }

  // ========== Navigation Actions ==========

  void addProduct() {
    // Clear form data before navigating to add product screen
    clearForm();

    Get.toNamed(AppRoutes.addProduct)?.then((result) {
      if (result == true) {
        fetchProducts(); // ✅ This will run after Get.back()
      }
    });
  }

  void editProduct(ProductModel product) async {
    // Load product data into form first
    await loadProductForEdit(product);

    // Then navigate to add product screen with product ID
    final result = await Get.toNamed(
      AppRoutes.addProduct,
      arguments: product.id, // Pass product ID
    );

    // Handle return from edit
    if (result == true) {
      // Product was updated, refresh the list
      fetchProducts();
    }
  }

  void duplicateProduct(ProductModel product) async {
    isSaving.value = true;

    final response = await _productService.duplicateProduct(product.id);

    isSaving.value = false;

    if (response.success) {
      Get.snackbar(
        'Success',
        'Product duplicated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchProducts(); // Refresh the list
    } else {
      Get.snackbar(
        'Error',
        response.message ?? 'Failed to duplicate product',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  // ========== Image Picker Methods ==========

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        productImages.add(File(image.path));
        Get.snackbar(
          'Success',
          'Image added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeImage(int index) {
    productImages.removeAt(index);
  }

  void removeExistingImage(int index) {
    existingImageUrls.removeAt(index);
  }

  int getTotalImageCount() {
    return existingImageUrls.length + productImages.length;
  }

  void showImagePickerOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.camera_alt,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.photo_library,
                color: Theme.of(context).primaryColor,
              ),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
            SizedBox(height: 10),
            TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ],
        ),
      ),
    );
  }

  // ========== Benefits Management ==========

  void addBenefit() {
    if (benefitController.text.trim().isNotEmpty) {
      benefits.add(benefitController.text.trim());
      benefitController.clear();
    }
  }

  void removeBenefit(int index) {
    benefits.removeAt(index);
  }

  // ========== Form Validation ==========

  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  String? validatePrice(String? value) {
    final error = validateNumber(value, 'Price');
    if (error != null) return error;

    if (double.parse(value!) <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  double calculateDiscount() {
    final price = double.tryParse(priceController.text) ?? 0;
    final mrp = double.tryParse(mrpController.text) ?? 0;

    if (mrp > 0 && price < mrp) {
      return ((mrp - price) / mrp * 100);
    }
    return 0;
  }

  // ========== Save Product ==========

  Future<void> saveProduct() async {
    if (!formKey.currentState!.validate()) {
      log('Form validation failed ${formKey.currentState}');
      Get.snackbar(
        'Validation Error',
        'Please fill all required fields correctly',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (formSelectedPetType.value.isEmpty) {
      log('Pet type not selected');
      Get.snackbar(
        'Validation Error',
        'Please select a pet type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // ✅ ADD THIS
    if (formSelectedFoodType.value.isEmpty) {
      log('Food type not selected');
      Get.snackbar(
        'Validation Error',
        'Please select a food type',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (getTotalImageCount() == 0) {
      log('No product images added');
      Get.snackbar(
        'Validation Error',
        'Please add at least one product image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isSaving.value = true;

    try {
      final response = await _productService.createProduct(
        name: nameController.text.trim(),
        category:
            formSelectedPetType.value.isNotEmpty
                ? formSelectedPetType.value
                : 'Dog', // ✅ Use petType instead, with default
        foodType: formSelectedFoodType.value,
        price: double.parse(priceController.text),
        mrp: double.parse(mrpController.text),
        weight: weightController.text.trim(),
        stockQuantity: int.parse(stockQuantityController.text),
        description: descriptionController.text.trim(),
        benefits: benefits.toList(),
        deliveryEstimate: deliveryEstimateController.text.trim(),
        images: productImages,
      );

      isSaving.value = false;

      // CHANGE FROM:

      // CHANGE TO:
      if (response.success) {
        // Clear the form
        clearForm();

        // Navigate back FIRST
        Get.back(result: true);

        // THEN show success message (will show on ProductScreen)
        Get.snackbar(
          'Success',
          response.message ?? 'Product added successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );

        fetchProducts();
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to add product',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isSaving.value = false;
      Get.snackbar(
        'Error',
        'Failed to add product: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== Clear Form ==========

  void clearForm() {
    nameController.clear();
    categoryController.clear();
    foodTypeController.clear();
    priceController.clear();
    mrpController.clear();
    weightController.clear();
    stockQuantityController.clear();
    descriptionController.clear();
    deliveryEstimateController.clear();
    benefitController.clear();
    formSelectedPetType.value = '';
    formSelectedFoodType.value = '';
    formSelectedCategory.value = '';
    benefits.clear();
    productImages.clear();
    existingImageUrls.clear(); // Clear existing image URLs
  }
}
