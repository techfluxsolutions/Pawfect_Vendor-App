import 'package:dio/dio.dart';
import 'dart:io';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/storage/storage_service.dart';
import '../core/api/api_urls.dart';

class OnboardingService {
  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService.instance;

  Future<ApiResponse> submitOnboarding({
    required String storeName,
    required String businessType,
    required String panNumber,
    String? gstNumber,
    String? fssaiLicense,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required String aadhaarProof, // File path
    required String fssaiCertificate, // File path
  }) async {
    try {
      print('📤 Starting onboarding submission...');
      print('📄 Aadhaar Path: $aadhaarProof');
      print('📄 FSSAI Path: $fssaiCertificate');

      // ✅ Convert file paths to MultipartFile
      final aadhaarFile = await MultipartFile.fromFile(
        aadhaarProof,
        filename: aadhaarProof.split('/').last,
      );

      final fssaiFile = await MultipartFile.fromFile(
        fssaiCertificate,
        filename: fssaiCertificate.split('/').last,
      );

      // ✅ Prepare form data with files
      final formData = {
        'storeName': storeName,
        'businessType': businessType,
        'panNumber': panNumber.toUpperCase(),
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
        'aadhaarProof': aadhaarFile, // ✅ Actual file, not path
        'fssaiCertificate': fssaiFile, // ✅ Actual file, not path
      };

      // Add optional fields if provided
      if (gstNumber != null && gstNumber.isNotEmpty) {
        formData['gstNumber'] = gstNumber.toUpperCase();
      }
      if (fssaiLicense != null && fssaiLicense.isNotEmpty) {
        formData['fssaiLicense'] = fssaiLicense;
      }

      print('📦 Form data prepared $formData');

      // ✅ Use uploadFile method instead of post
      final response = await _apiClient.uploadFile(
        ApiUrls.onboarding,
        data: formData,
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(0);
          print('📤 Upload progress: $progress%');
        },
      );

      if (response.success) {
        // Update user verification status if needed
        if (response.data != null && response.data['user'] != null) {
          await _updateUserVerificationStatus(response.data['user']);
        }

        print('✅ Onboarding submitted successfully');
      }

      return response;
    } on FileSystemException catch (e) {
      print('❌ File not found: $e');
      return ApiResponse.error(message: 'File not found: ${e.message}');
    } catch (e) {
      print('❌ Onboarding error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<ApiResponse> checkKycStatus() async {
    try {
      final response = await _apiClient.get(ApiUrls.kycStatus);
      return response;
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  // ✅ Fetch existing onboarding data for resubmission
  Future<ApiResponse> getOnboardingData() async {
    try {
      print('📥 Fetching onboarding data...');
      final response = await _apiClient.get(ApiUrls.onboarding);

      if (response.success) {
        print('✅ Onboarding data fetched successfully');
      }

      return response;
    } catch (e) {
      print('❌ Get onboarding data error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  // ✅ Update existing onboarding data (resubmission)
  Future<ApiResponse> updateOnboarding({
    required String storeName,
    required String businessType,
    required String panNumber,
    String? gstNumber,
    String? fssaiLicense,
    required String address,
    required String city,
    required String state,
    required String pincode,
    String? aadhaarProof, // Optional - only if changed
    String? fssaiCertificate, // Optional - only if changed
  }) async {
    try {
      print('📤 Starting onboarding update...');

      // ✅ Prepare form data
      final Map<String, dynamic> formData = {
        'storeName': storeName,
        'businessType': businessType,
        'panNumber': panNumber.toUpperCase(),
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
      };

      // Add optional fields if provided
      if (gstNumber != null && gstNumber.isNotEmpty) {
        formData['gstNumber'] = gstNumber.toUpperCase();
      }
      if (fssaiLicense != null && fssaiLicense.isNotEmpty) {
        formData['fssaiLicense'] = fssaiLicense;
      }

      // ✅ Add files only if they are new (local file paths)
      if (aadhaarProof != null &&
          aadhaarProof.isNotEmpty &&
          !aadhaarProof.startsWith('http')) {
        final aadhaarFile = await MultipartFile.fromFile(
          aadhaarProof,
          filename: aadhaarProof.split('/').last,
        );
        formData['aadhaarProof'] = aadhaarFile;
        print('📄 New Aadhaar file added');
      }

      if (fssaiCertificate != null &&
          fssaiCertificate.isNotEmpty &&
          !fssaiCertificate.startsWith('http')) {
        final fssaiFile = await MultipartFile.fromFile(
          fssaiCertificate,
          filename: fssaiCertificate.split('/').last,
        );
        formData['fssaiCertificate'] = fssaiFile;
        print('📄 New FSSAI file added');
      }

      print('📦 Form data prepared for update');

      // ✅ Use uploadFile with PUT method
      final response = await _apiClient.put(
        ApiUrls.onboarding,
        data: FormData.fromMap(formData),
      );

      if (response.success) {
        // Update user verification status if needed
        if (response.data != null && response.data['user'] != null) {
          await _updateUserVerificationStatus(response.data['user']);
        }

        print('✅ Onboarding updated successfully');
      }

      return response;
    } on FileSystemException catch (e) {
      print('❌ File not found: $e');
      return ApiResponse.error(message: 'File not found: ${e.message}');
    } catch (e) {
      print('❌ Onboarding update error: $e');
      return ApiResponse.error(message: e.toString());
    }
  }

  Future<void> _updateUserVerificationStatus(
    Map<String, dynamic> userData,
  ) async {
    if (userData['isVerified'] != null) {
      await _storage.saveUserData(
        userId: userData['id'] ?? _storage.getUserId() ?? '',
        mobileNumber:
            userData['mobileNumber'] ?? _storage.getMobileNumber() ?? '',
        isVerified: userData['isVerified'] ?? false,
        userType: userData['userType'] ?? _storage.getUserType() ?? '',
      );
      print('✓ User verification status updated');
    }
  }
}
