import 'dart:developer';

import 'package:dio/dio.dart';
import 'dart:io';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/storage/storage_service.dart';
import '../core/api/api_urls.dart';

class ProductService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService.instance;

  /// Create a new product with images
  Future<ApiResponse> createProduct({
    required String name,
    required String category,
    required String foodType,
    required double price,
    required double mrp,
    required String weight,
    required int stockQuantity,
    required String description,
    required List<String> benefits,
    required String deliveryEstimate,
    required List<File> images,
  }) async {
    try {
      print('📤 Starting product creation...');
      print('🖼️ Images count: ${images.length}');

      // ✅ Convert all image files to MultipartFile
      List<MultipartFile> imageFiles = [];
      for (var image in images) {
        final multipartFile = await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        );
        imageFiles.add(multipartFile);
        print('📄 Image added: ${image.path.split('/').last}');
      }

      // ✅ Calculate discount
      double discount = 0;
      if (mrp > 0 && price < mrp) {
        discount = ((mrp - price) / mrp * 100);
      }

      // ✅ Prepare FormData object
      final formData = FormData();

      // Add text fields
      formData.fields.addAll([
        MapEntry('name', name),
        MapEntry('category', category),
        MapEntry('foodType', foodType),
        MapEntry('price', price.toString()),
        MapEntry('mrp', mrp.toString()),
        MapEntry('weight', weight),
        MapEntry('stockQuantity', stockQuantity.toString()),
        MapEntry('description', description),
        MapEntry('deliveryEstimate', deliveryEstimate),
        MapEntry('discount', discount.toStringAsFixed(2)),
      ]);

      // Add benefits array
      for (var benefit in benefits) {
        formData.fields.add(MapEntry('benefits[]', benefit));
      }

      // Add images
      for (var imageFile in imageFiles) {
        formData.files.add(MapEntry('images', imageFile));
      }

      // ✅ Log the complete payload
      print('📦 Form data prepared:');
      print(
        '📝 Fields: ${formData.fields.map((e) => '${e.key}: ${e.value}').join(', ')}',
      );
      print('🖼️ Images: ${formData.files.length} files');

      // ✅ Use uploadFile method for multipart/form-data
      final response = await _apiClient.uploadFile(
        ApiUrls.products,
        data: formData,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(0);
          print('📤 Upload progress: $progress%');
        },
      );

      if (response.success) {
        print('✅ Product created successfully');
        print('📦 Product data: ${response.data}');
      }

      return response;
    } on FileSystemException catch (e) {
      print('❌ File not found: $e');
      return ApiResponse.error(message: 'Image file not found: ${e.message}');
    } catch (e) {
      print('❌ Product creation error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Duplicate product via API
  Future<ApiResponse> duplicateProduct(String productId) async {
    try {
      print('📋 Duplicating product: $productId');

      final response = await _apiClient.post(
        ApiUrls.duplicateProduct(productId),
      );

      if (response.success) {
        print('✅ Product duplicated successfully');
      }

      return response;
    } catch (e) {
      print('❌ Duplicate product error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get all products for vendor
  Future<ApiResponse> getAllProducts({
    String? search,
    String? category,
    String? petType,
    String? foodType,
    String? stockStatus,
    String? productStatus,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    bool? sortAscending,
  }) async {
    try {
      print('📥 Fetching all products...');

      // ✅ Build query parameters
      Map<String, dynamic> queryParams = {};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (petType != null && petType.isNotEmpty) {
        queryParams['petType'] = petType;
      }
      if (foodType != null && foodType.isNotEmpty) {
        queryParams['foodType'] = foodType;
      }
      if (stockStatus != null && stockStatus.isNotEmpty) {
        queryParams['stockStatus'] = stockStatus;
      }
      if (productStatus != null && productStatus.isNotEmpty) {
        queryParams['status'] = productStatus;
      }
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }
      if (sortAscending != null) {
        queryParams['sortOrder'] = sortAscending ? 'asc' : 'desc';
      }

      print('🔍 Query params: $queryParams');

      // ✅ Make GET request with query parameters
      final response = await _apiClient.get(
        ApiUrls.products,
        queryParameters: queryParams,
      );

      if (response.success) {
        print('✅ Products fetched successfully');
        print('📦 Products count: ${response.data?['products']?.length ?? 0}');
        log('📦 Products data: ${response.data}');
      }

      return response;
    } catch (e) {
      print('❌ Fetch products error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Get single product details
  Future<ApiResponse> getProductById(String productId) async {
    try {
      print('📥 Fetching product: $productId');

      final response = await _apiClient.get(ApiUrls.productById(productId));

      if (response.success) {
        print('✅ Product fetched successfully');
      }

      return response;
    } catch (e) {
      print('❌ Fetch product error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Update product
  Future<ApiResponse> updateProduct({
    required String productId,
    String? name,
    String? category,
    String? foodType,
    double? price,
    double? mrp,
    String? weight,
    int? stockQuantity,
    String? description,
    List<String>? benefits,
    String? deliveryEstimate,
    List<File>? newImages,
  }) async {
    try {
      print('📤 Updating product: $productId');

      // ✅ Use FormData for multipart requests
      final formData = FormData();

      // Add text fields
      if (name != null) formData.fields.add(MapEntry('name', name));
      if (category != null) formData.fields.add(MapEntry('category', category));
      if (foodType != null) formData.fields.add(MapEntry('foodType', foodType));
      if (price != null)
        formData.fields.add(MapEntry('price', price.toString()));
      if (mrp != null) formData.fields.add(MapEntry('mrp', mrp.toString()));
      if (weight != null) formData.fields.add(MapEntry('weight', weight));
      if (stockQuantity != null)
        formData.fields.add(
          MapEntry('stockQuantity', stockQuantity.toString()),
        );
      if (description != null)
        formData.fields.add(MapEntry('description', description));
      if (deliveryEstimate != null)
        formData.fields.add(MapEntry('deliveryEstimate', deliveryEstimate));

      // Calculate discount if price and mrp are provided
      if (price != null && mrp != null && mrp > 0 && price < mrp) {
        final discount = ((mrp - price) / mrp * 100).toStringAsFixed(2);
        formData.fields.add(MapEntry('discount', discount));
      }

      // Add benefits array
      if (benefits != null) {
        for (var benefit in benefits) {
          formData.fields.add(MapEntry('benefits[]', benefit));
        }
      }

      // Add new images if provided
      if (newImages != null && newImages.isNotEmpty) {
        for (var image in newImages) {
          final multipartFile = await MultipartFile.fromFile(
            image.path,
            filename: image.path.split('/').last,
          );
          formData.files.add(MapEntry('images', multipartFile));
        }
      }

      // ✅ Try PUT method first, fallback to POST if needed
      ApiResponse response;
      try {
        // Most REST APIs use PUT for updates
        response = await _apiClient.put(
          ApiUrls.productById(productId),
          data: formData,
        );
      } catch (e) {
        // If PUT fails, try with uploadFile (POST) method
        print('PUT failed, trying POST method...');
        response = await _apiClient.uploadFile(
          ApiUrls.productById(productId),
          data: formData,
        );
      }

      if (response.success) {
        print('✅ Product updated successfully');
      }

      return response;
    } catch (e) {
      print('❌ Update product error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Delete product
  Future<ApiResponse> deleteProduct(String productId) async {
    try {
      print('🗑️ Deleting product: $productId');

      final response = await _apiClient.delete(ApiUrls.productById(productId));

      if (response.success) {
        print('✅ Product deleted successfully');
      }

      return response;
    } catch (e) {
      print('❌ Delete product error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }
}
