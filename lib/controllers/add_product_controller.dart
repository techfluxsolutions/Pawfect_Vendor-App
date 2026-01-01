// import 'dart:io';

// import 'package:pawfect_vendor_app/services/product_service.dart';

// import '../libs.dart';

// class AddProductController extends GetxController {
//   final ProductService _productService = ProductService();
//   // Form Keys
//   final formKey = GlobalKey<FormState>();

//   // Text Controllers
//   final nameController = TextEditingController();
//   final categoryController = TextEditingController();
//   final foodTypeController = TextEditingController();
//   final priceController = TextEditingController();
//   final mrpController = TextEditingController();
//   final weightController = TextEditingController();
//   final stockQuantityController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final deliveryEstimateController = TextEditingController();

//   // Observable Values
//   var selectedPetType = ''.obs;
//   var selectedFoodType = ''.obs;
//   var selectedCategory = ''.obs;
//   var isLoading = false.obs;
//   var isSaving = false.obs;

//   // Benefits (dynamic list)
//   var benefits = <String>[].obs;
//   final benefitController = TextEditingController();

//   // Images
//   var productImages = <File>[].obs;
//   final ImagePicker _picker = ImagePicker();

//   // Dropdown Options
//   final List<String> petTypes = ['Dog', 'Cat', 'Bird', 'Fish', 'Other'];
//   final List<String> foodTypes = ['Dry', 'Wet', 'Treats', 'Supplements'];
//   final List<String> categories = [
//     'Food',
//     'Accessories',
//     'Toys',
//     'Grooming',
//     'Health',
//   ];

//   // @override
//   // void onInit() {
//   //   super.onInit();
//   //   fetchProducts(); // ← Load products on init
//   // }

//   @override
//   void onClose() {
//     nameController.dispose();
//     categoryController.dispose();
//     foodTypeController.dispose();
//     priceController.dispose();
//     mrpController.dispose();
//     weightController.dispose();
//     stockQuantityController.dispose();
//     descriptionController.dispose();
//     deliveryEstimateController.dispose();
//     benefitController.dispose();
//     super.onClose();
//   }

//   // Future<void> fetchProducts() async {
//   //   isLoading.value = true;

//   //   final response = await _productService.getAllProducts(
//   //     search: searchQuery.value.isEmpty ? null : searchQuery.value,
//   //     category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
//   //     petType: selectedPetType.value.isEmpty ? null : selectedPetType.value,
//   //     foodType: selectedFoodType.value.isEmpty ? null : selectedFoodType.value,
//   //     stockStatus:
//   //         selectedStockStatus.value.isEmpty ? null : selectedStockStatus.value,
//   //     productStatus:
//   //         selectedProductStatus.value.isEmpty
//   //             ? null
//   //             : selectedProductStatus.value,
//   //     minPrice: priceRange.value.start,
//   //     maxPrice: priceRange.value.end,
//   //     sortBy: sortBy.value,
//   //     sortAscending: sortAscending.value,
//   //   );

//   //   isLoading.value = false;

//   //   if (response.success && response.data != null) {
//   //     // Convert response to ProductModel list
//   //     final List<dynamic> productsJson = response.data['products'] ?? [];
//   //     products.value =
//   //         productsJson.map((json) => ProductModel.fromJson(json)).toList();
//   //   }
//   // }

//   // ✅ UPDATE deleteProduct method
//   Future<void> deleteProduct(ProductModel product) async {
//     final confirm = await Get.dialog<bool>(
//       AlertDialog(
//         title: Text('Delete Product'),
//         content: Text('Are you sure you want to delete "${product.name}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(result: false),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Get.back(result: true),
//             child: Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       final response = await _productService.deleteProduct(product.id);

//       if (response.success) {
//         Get.snackbar('Success', 'Product deleted successfully');
//         // fetchProducts(); // Refresh list
//       } else {
//         Get.snackbar('Error', response.message ?? 'Failed to delete product');
//       }
//     }
//   }

//   // Image Picker Methods
//   Future<void> pickImage(ImageSource source) async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: source,
//         imageQuality: 80,
//       );

//       if (image != null) {
//         productImages.add(File(image.path));
//         Get.snackbar(
//           'Success',
//           'Image added successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//           duration: Duration(seconds: 2),
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to pick image: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   void removeImage(int index) {
//     productImages.removeAt(index);
//   }

//   void showImagePickerOptions(BuildContext context) {
//     Get.bottomSheet(
//       Container(
//         padding: EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: Icon(
//                 Icons.camera_alt,
//                 color: Theme.of(context).primaryColor,
//               ),
//               title: Text('Camera'),
//               onTap: () {
//                 Get.back();
//                 pickImage(ImageSource.camera);
//               },
//             ),
//             ListTile(
//               leading: Icon(
//                 Icons.photo_library,
//                 color: Theme.of(context).primaryColor,
//               ),
//               title: Text('Gallery'),
//               onTap: () {
//                 Get.back();
//                 pickImage(ImageSource.gallery);
//               },
//             ),
//             SizedBox(height: 10),
//             TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
//           ],
//         ),
//       ),
//     );
//   }

//   // Benefits Management
//   void addBenefit() {
//     if (benefitController.text.trim().isNotEmpty) {
//       benefits.add(benefitController.text.trim());
//       benefitController.clear();
//     }
//   }

//   void removeBenefit(int index) {
//     benefits.removeAt(index);
//   }

//   // Form Validation
//   String? validateRequired(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return '$fieldName is required';
//     }
//     return null;
//   }

//   String? validateNumber(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return '$fieldName is required';
//     }
//     if (double.tryParse(value) == null) {
//       return 'Please enter a valid number';
//     }
//     return null;
//   }

//   String? validatePrice(String? value) {
//     final error = validateNumber(value, 'Price');
//     if (error != null) return error;

//     if (double.parse(value!) <= 0) {
//       return 'Price must be greater than 0';
//     }
//     return null;
//   }

//   // Calculate Discount
//   double calculateDiscount() {
//     final price = double.tryParse(priceController.text) ?? 0;
//     final mrp = double.tryParse(mrpController.text) ?? 0;

//     if (mrp > 0 && price < mrp) {
//       return ((mrp - price) / mrp * 100);
//     }
//     return 0;
//   }

//   // Save Product
//   Future<void> saveProduct() async {
//     if (!formKey.currentState!.validate()) {
//       Get.snackbar(
//         'Validation Error',
//         'Please fill all required fields correctly',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     // Check if category is selected
//     if (selectedCategory.value.isEmpty) {
//       Get.snackbar(
//         'Validation Error',
//         'Please select a category',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     // Check if at least one image is added
//     if (productImages.isEmpty) {
//       Get.snackbar(
//         'Validation Error',
//         'Please add at least one product image',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orange,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     isSaving.value = true;

//     try {
//       // ✅ REPLACE the entire try block with this:
//       final response = await _productService.createProduct(
//         name: nameController.text.trim(),
//         category: selectedCategory.value,
//         foodType: selectedFoodType.value,
//         price: double.parse(priceController.text),
//         mrp: double.parse(mrpController.text),
//         weight: weightController.text.trim(),
//         stockQuantity: int.parse(stockQuantityController.text),
//         description: descriptionController.text.trim(),
//         benefits: benefits.toList(),
//         deliveryEstimate: deliveryEstimateController.text.trim(),
//         images: productImages,
//       );

//       isSaving.value = false;

//       if (response.success) {
//         Get.snackbar(
//           'Success',
//           response.message ?? 'Product added successfully',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//         Get.back(result: true);
//       } else {
//         Get.snackbar(
//           'Error',
//           response.message ?? 'Failed to add product',
//           snackPosition: SnackPosition.BOTTOM,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       isSaving.value = false;
//       Get.snackbar(
//         'Error',
//         'Failed to add product: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // Clear Form
//   void clearForm() {
//     nameController.clear();
//     categoryController.clear();
//     foodTypeController.clear();
//     priceController.clear();
//     mrpController.clear();
//     weightController.clear();
//     stockQuantityController.clear();
//     descriptionController.clear();
//     deliveryEstimateController.clear();
//     benefitController.clear();
//     selectedPetType.value = '';
//     selectedFoodType.value = '';
//     selectedCategory.value = '';
//     benefits.clear();
//     productImages.clear();
//   }
// }
