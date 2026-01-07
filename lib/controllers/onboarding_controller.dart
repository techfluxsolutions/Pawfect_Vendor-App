import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:pawfect_vendor_app/services/onboarding_service.dart';
import 'package:pawfect_vendor_app/core/network/api_exceptions.dart';

class OnboardingController extends GetxController {
  final OnboardingService _onboardingService = OnboardingService();

  // Removed unnecessary onInit override

  // Form fields
  RxString storeName = ''.obs;
  RxString businessType = ''.obs;
  RxString panNumber = ''.obs;
  RxString gstNumber = ''.obs;
  RxString fssaiLicense = ''.obs;
  RxString address = ''.obs;
  RxString city = ''.obs;
  RxString state = ''.obs;
  RxString pincode = ''.obs;
  RxString aadhaarProof = ''.obs;
  RxString fssaiCertificate = ''.obs;

  // File names for display
  RxString aadhaarFileName = ''.obs;
  RxString fssaiFileName = ''.obs;

  RxBool isLoading = false.obs;

  // ══════════════════════════════════════════════════════════════════════════
  // SETTERS
  // ══════════════════════════════════════════════════════════════════════════
  void setStoreName(String value) => storeName.value = value;
  void setBusinessType(String value) => businessType.value = value;
  void setPanNumber(String value) => panNumber.value = value.toUpperCase();
  void setGstNumber(String value) => gstNumber.value = value.toUpperCase();
  void setFssaiLicense(String value) => fssaiLicense.value = value;
  void setAddress(String value) => address.value = value;
  void setCity(String value) => city.value = value;
  void setState(String value) => state.value = value;
  void setPincode(String value) => pincode.value = value;

  void setAadhaarProof(String path) {
    aadhaarProof.value = path;
    aadhaarFileName.value = path.split('/').last;
  }

  void setFssaiCertificate(String path) {
    fssaiCertificate.value = path;
    fssaiFileName.value = path.split('/').last;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PICK IMAGE OR DOCUMENT
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> pickImage(String type, {required bool isCamera}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);

        log('📸 Image picked: ${image.path}');
        log('📏 File size: ${fileSizeMB.toStringAsFixed(2)} MB');

        // Check file size (max 10MB)
        if (fileSizeMB > 10) {
          _showError('File size too large. Maximum 10MB allowed.');
          return;
        }

        if (type == 'aadhaar') {
          setAadhaarProof(image.path);
        } else if (type == 'fssai') {
          setFssaiCertificate(image.path);
        }
      }
    } catch (e) {
      print('❌ Pick image error: $e');
      _showError('Failed to pick image: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PICK PDF DOCUMENT (Alternative option)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> pickDocument(String type) async {
    try {
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.custom,
      //   allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      // );

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);

        log('📄 Document picked: $filePath');
        log('📏 File size: ${fileSizeMB.toStringAsFixed(2)} MB');

        // Check file size (max 10MB)
        if (fileSizeMB > 10) {
          _showError('File size too large. Maximum 10MB allowed.');
          return;
        }

        if (type == 'aadhaar') {
          setAadhaarProof(filePath);
          _showSuccess('Aadhaar proof uploaded');
        } else if (type == 'fssai') {
          setFssaiCertificate(filePath);
          _showSuccess('FSSAI certificate uploaded');
        }
      }
    } catch (e) {
      log('❌ Pick document error: $e');
      _showError('Failed to pick document: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ══════════════════════════════════════════════════════════════════════════
  bool validateForm() {
    if (storeName.value.trim().isEmpty) {
      _showError('Please enter store name');
      return false;
    }

    if (businessType.value.isEmpty) {
      _showError('Please select business type');
      return false;
    }

    if (panNumber.value.isEmpty) {
      _showError('Please enter PAN number');
      return false;
    }

    if (panNumber.value.length != 10) {
      _showError('PAN number must be 10 characters');
      return false;
    }

    if (!_isValidPAN(panNumber.value)) {
      _showError('Please enter valid PAN number format');
      return false;
    }

    if (address.value.trim().isEmpty) {
      _showError('Please enter address');
      return false;
    }

    if (city.value.trim().isEmpty) {
      _showError('Please enter city');
      return false;
    }

    if (state.value.isEmpty) {
      _showError('Please select state');
      return false;
    }

    if (pincode.value.isEmpty) {
      _showError('Please enter pincode');
      return false;
    }

    if (pincode.value.length != 6) {
      _showError('Pincode must be 6 digits');
      return false;
    }

    if (!_isValidPincode(pincode.value)) {
      _showError('Please enter valid pincode');
      return false;
    }

    if (aadhaarProof.value.isEmpty) {
      _showError('Please upload Aadhaar proof');
      return false;
    }

    if (fssaiCertificate.value.isEmpty) {
      _showError('Please upload FSSAI certificate');
      return false;
    }

    // Verify files exist
    if (!File(aadhaarProof.value).existsSync()) {
      _showError('Aadhaar proof file not found');
      return false;
    }

    if (!File(fssaiCertificate.value).existsSync()) {
      _showError('FSSAI certificate file not found');
      return false;
    }

    return true;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALIDATION HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  bool _isValidPAN(String pan) {
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    return panRegex.hasMatch(pan);
  }

  bool _isValidPincode(String pincode) {
    final pincodeRegex = RegExp(r'^[1-9][0-9]{5}$');
    return pincodeRegex.hasMatch(pincode);
  }

  Future<void> submitForm(BuildContext context) async {
    if (!validateForm()) return;

    isLoading.value = true;

    try {
      final response = await _onboardingService.submitOnboarding(
        storeName: storeName.value.trim(),
        businessType: businessType.value,
        panNumber: panNumber.value,
        gstNumber: gstNumber.value.trim(),
        fssaiLicense: fssaiLicense.value.trim(),
        address: address.value.trim(),
        city: city.value.trim(),
        state: state.value,
        pincode: pincode.value,
        aadhaarProof: aadhaarProof.value,
        fssaiCertificate: fssaiCertificate.value,
      );

      if (response.success) {
        _showSuccess(response.message ?? 'Onboarding submitted successfully');

        // Navigate to waiting screen
        await Future.delayed(Duration(milliseconds: 500));
        Get.offNamed('/onboardingWaiting');
      } else {
        log('❌ Onboarding submission failed: ${response.message}');

        // Handle API validation errors
        _handleApiError(response);
      }
    } catch (e) {
      log('❌ Submit error: $e');
      _handleNetworkError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // API ERROR HANDLING
  // ══════════════════════════════════════════════════════════════════════════
  void _handleApiError(dynamic response) {
    String errorMessage = 'Failed to submit onboarding';

    // Check if response has a message
    if (response.message != null && response.message!.isNotEmpty) {
      errorMessage = response.message!;

      // Parse validation errors from backend
      final validationErrors = _parseValidationErrors(response.message!);
      if (validationErrors.isNotEmpty) {
        _showValidationErrors(validationErrors);
        return;
      }
    }

    // Check if response has error object
    if (response.error != null) {
      if (response.error is Map<String, dynamic>) {
        final errorMap = response.error as Map<String, dynamic>;

        // Handle different error formats
        if (errorMap.containsKey('message')) {
          errorMessage = errorMap['message'].toString();
        } else if (errorMap.containsKey('errors')) {
          _handleFieldErrors(errorMap['errors']);
          return;
        }
      } else {
        errorMessage = response.error.toString();
      }
    }

    _showError(errorMessage);
  }

  // Parse validation errors from message like:
  // "Vendor validation failed: storeName: Store name is required, gstNumber: Invalid GST number format"
  Map<String, String> _parseValidationErrors(String message) {
    Map<String, String> errors = {};

    // Check if message contains validation errors
    if (message.contains('validation failed:')) {
      // Extract the part after "validation failed:"
      final parts = message.split('validation failed:');
      if (parts.length > 1) {
        final errorPart = parts[1].trim();

        // Split by comma to get individual field errors
        final fieldErrors = errorPart.split(',');

        for (String fieldError in fieldErrors) {
          final trimmedError = fieldError.trim();

          // Split by colon to separate field name and error message
          if (trimmedError.contains(':')) {
            final errorParts = trimmedError.split(':');
            if (errorParts.length >= 2) {
              final fieldName = errorParts[0].trim();
              final errorMsg = errorParts.sublist(1).join(':').trim();
              errors[fieldName] = errorMsg;
            }
          }
        }
      }
    }

    return errors;
  }

  // Show validation errors with field-specific messages
  void _showValidationErrors(Map<String, String> errors) {
    List<String> errorMessages = [];

    errors.forEach((field, message) {
      // Map backend field names to user-friendly names
      String fieldDisplayName = _getFieldDisplayName(field);
      errorMessages.add('$fieldDisplayName: $message');
    });

    if (errorMessages.isNotEmpty) {
      _showError(errorMessages.join('\n'));
    }
  }

  // Handle field-specific errors from backend
  void _handleFieldErrors(dynamic errors) {
    Map<String, String> fieldErrors = {};

    if (errors is Map<String, dynamic>) {
      errors.forEach((field, error) {
        if (error is List && error.isNotEmpty) {
          fieldErrors[field] = error.first.toString();
        } else if (error is String) {
          fieldErrors[field] = error;
        }
      });
    }

    if (fieldErrors.isNotEmpty) {
      _showValidationErrors(fieldErrors);
    } else {
      _showError('Validation failed. Please check your input.');
    }
  }

  // Map backend field names to user-friendly display names
  String _getFieldDisplayName(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'storename':
        return 'Store Name';
      case 'businesstype':
        return 'Business Type';
      case 'pannumber':
        return 'PAN Number';
      case 'gstnumber':
        return 'GST Number';
      case 'fssailicense':
        return 'FSSAI License';
      case 'address':
        return 'Address';
      case 'city':
        return 'City';
      case 'state':
        return 'State';
      case 'pincode':
        return 'Pincode';
      case 'aadhaarproof':
        return 'Aadhaar Proof';
      case 'fssaicertificate':
        return 'FSSAI Certificate';
      default:
        return fieldName
            .replaceAll('_', ' ')
            .split(' ')
            .map(
              (word) =>
                  word.isNotEmpty
                      ? word[0].toUpperCase() + word.substring(1)
                      : word,
            )
            .join(' ');
    }
  }

  // Handle network and other errors
  void _handleNetworkError(dynamic error) {
    String errorMessage = 'An error occurred. Please try again.';

    // Handle specific API exceptions
    if (error is NetworkException) {
      errorMessage =
          'No internet connection. Please check your network and try again.';
    } else if (error is TimeoutException) {
      errorMessage =
          'Request timeout. Please check your connection and try again.';
    } else if (error is UnauthorizedException) {
      errorMessage = 'Session expired. Please login again.';
    } else if (error is BadRequestException) {
      // Handle validation errors from 400 responses
      if (error.data != null) {
        _handleApiErrorData(error.data);
        return;
      } else {
        errorMessage = error.message;
      }
    } else if (error is ServerException) {
      errorMessage = 'Server error. Please try again later.';
    } else if (error is NotFoundException) {
      errorMessage = 'Service not found. Please contact support.';
    } else if (error.toString().contains('SocketException')) {
      errorMessage =
          'No internet connection. Please check your network and try again.';
    } else if (error.toString().contains('TimeoutException')) {
      errorMessage =
          'Request timeout. Please check your connection and try again.';
    } else if (error.toString().contains('FormatException')) {
      errorMessage = 'Invalid response from server. Please try again later.';
    } else if (error.toString().contains('FileSystemException')) {
      errorMessage =
          'File upload failed. Please check your files and try again.';
    } else {
      // For debugging, include the actual error
      errorMessage = 'Error: ${error.toString()}';
    }

    _showError(errorMessage);
  }

  // Handle API error data from BadRequestException or other sources
  void _handleApiErrorData(dynamic errorData) {
    if (errorData is Map<String, dynamic>) {
      // Check for validation errors in different formats
      if (errorData.containsKey('message')) {
        final message = errorData['message'].toString();
        final validationErrors = _parseValidationErrors(message);
        if (validationErrors.isNotEmpty) {
          _showValidationErrors(validationErrors);
          return;
        } else {
          _showError(message);
          return;
        }
      }

      if (errorData.containsKey('errors')) {
        _handleFieldErrors(errorData['errors']);
        return;
      }

      if (errorData.containsKey('error')) {
        _showError(errorData['error'].toString());
        return;
      }
    }

    _showError('Validation failed. Please check your input.');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SNACKBAR HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  void _showError(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 5), // Longer duration for validation errors
      maxWidth: Get.width * 0.9, // Ensure it fits on screen
      messageText: Text(
        message,
        style: TextStyle(color: Colors.red.shade900, fontSize: 14, height: 1.3),
        maxLines: 10, // Allow multiple lines for validation errors
        overflow: TextOverflow.visible,
      ),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 2),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CLEAR FORM
  // ══════════════════════════════════════════════════════════════════════════
  void clearForm() {
    storeName.value = '';
    businessType.value = '';
    panNumber.value = '';
    gstNumber.value = '';
    fssaiLicense.value = '';
    address.value = '';
    city.value = '';
    state.value = '';
    pincode.value = '';
    aadhaarProof.value = '';
    fssaiCertificate.value = '';
    aadhaarFileName.value = '';
    fssaiFileName.value = '';
  }

  @override
  void onClose() {
    clearForm();
    super.onClose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TESTING METHODS (Remove in production)
  // ══════════════════════════════════════════════════════════════════════════

  // Test method to simulate the exact backend error format you mentioned
  void testExactBackendError() {
    final mockResponse = {
      'success': false,
      'message':
          'Vendor validation failed: storeName: Store name is required, gstNumber: Invalid GST number format',
    };

    _handleApiError(mockResponse);
  }

  // Test method to simulate API validation errors
  void testValidationError() {
    final mockResponse = {
      'success': false,
      'message':
          'Vendor validation failed: storeName: Store name is required, gstNumber: Invalid GST number format, panNumber: PAN number must be 10 characters',
    };

    _handleApiError(mockResponse);
  }

  // Test method to simulate field-specific errors
  void testFieldErrors() {
    final mockResponse = {
      'success': false,
      'error': {
        'errors': {
          'storeName': ['Store name is required'],
          'gstNumber': ['Invalid GST number format'],
          'panNumber': ['PAN number must be 10 characters'],
        },
      },
    };

    _handleApiError(mockResponse);
  }

  // Test method to simulate network error
  void testNetworkError() {
    _handleNetworkError(NetworkException());
  }
}
