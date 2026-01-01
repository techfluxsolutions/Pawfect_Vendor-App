import 'package:dio/dio.dart';
import 'dart:io';
import '../core/network/api_client.dart';
import '../core/network/api_response.dart';
import '../core/storage/storage_service.dart';

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
        '/onboarding',
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
      final response = await _apiClient.get('/kyc-status');
      return response;
    } catch (e) {
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
