import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:pawfect_vendor_app/core/network/api_exceptions.dart';

import '../libs.dart';

class OnboardingController extends GetxController {
  final OnboardingService _onboardingService = OnboardingService();

  // ✅ Use TextEditingControllers for better control
  final storeNameController = TextEditingController();
  final panNumberController = TextEditingController();
  final gstNumberController = TextEditingController();
  final fssaiLicenseController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

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
  RxBool isResubmission = false.obs; // ✅ Track if this is a resubmission
  RxBool isFetchingData = false.obs; // ✅ Track data fetching state
  String? onboardingId; // ✅ Store onboarding ID for updates

  // ✅ Track which fields have errors
  RxMap<String, String> fieldErrors = <String, String>{}.obs;
  RxString rejectionReason = ''.obs; // ✅ Store full rejection reason
  RxBool isEditMode =
      false.obs; // ✅ Track if user is just editing (not resubmitting rejection)

  @override
  void onInit() {
    super.onInit();
    // ✅ Check if we need to load existing data for resubmission
    fetchOnboardingDataIfNeeded();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FETCH EXISTING DATA FOR RESUBMISSION
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> fetchOnboardingDataIfNeeded() async {
    isFetchingData.value = true;

    try {
      final response = await _onboardingService.getOnboardingData();

      if (response.success && response.data != null) {
        final data = response.data;

        // ✅ Check if KYC is rejected - then populate form
        final kycStatus = data['kycStatus'] ?? '';

        if (kycStatus == 'rejected' ||
            kycStatus == 'pending' ||
            kycStatus == 'approved') {
          isResubmission.value = true;
          onboardingId = data['_id'];

          // ✅ Determine if this is edit mode (approved) or rejection mode
          isEditMode.value = (kycStatus == 'approved');

          // ✅ Populate form fields using controllers
          storeNameController.text = data['storeName'] ?? '';
          storeName.value = data['storeName'] ?? '';

          businessType.value = data['businessType'] ?? '';

          panNumberController.text = data['panNumber'] ?? '';
          panNumber.value = data['panNumber'] ?? '';

          gstNumberController.text = data['gstNumber'] ?? '';
          gstNumber.value = data['gstNumber'] ?? '';

          fssaiLicenseController.text = data['fssaiLicense'] ?? '';
          fssaiLicense.value = data['fssaiLicense'] ?? '';

          // ✅ Populate address fields
          if (data['storeAddress'] != null) {
            final storeAddress = data['storeAddress'];

            addressController.text = storeAddress['address'] ?? '';
            address.value = storeAddress['address'] ?? '';

            cityController.text = storeAddress['city'] ?? '';
            city.value = storeAddress['city'] ?? '';

            state.value = storeAddress['state'] ?? '';

            pincodeController.text = storeAddress['pincode'] ?? '';
            pincode.value = storeAddress['pincode'] ?? '';
          }

          // ✅ Store existing file URLs (don't download, just keep reference)
          if (data['aadhaarProof'] != null &&
              data['aadhaarProof'].toString().isNotEmpty) {
            aadhaarProof.value = data['aadhaarProof'];
            aadhaarFileName.value = 'Existing Aadhaar Document';
          }

          if (data['fssaiCertificate'] != null &&
              data['fssaiCertificate'].toString().isNotEmpty) {
            fssaiCertificate.value = data['fssaiCertificate'];
            fssaiFileName.value = 'Existing FSSAI Certificate';
          }

          log(
            '✅ Form populated with existing data for ${isEditMode.value ? "editing" : "resubmission"}',
          );

          // ✅ Store rejection reason and parse field errors ONLY if rejected
          if (kycStatus == 'rejected' && data['kycRejectionReason'] != null) {
            rejectionReason.value = data['kycRejectionReason'];
            _parseRejectionReason(data['kycRejectionReason']);

            // ✅ Show rejection message
            Get.snackbar(
              'KYC Rejected',
              rejectionReason.value,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
              snackPosition: SnackPosition.TOP,
              margin: EdgeInsets.all(16),
              borderRadius: 8,
              duration: Duration(seconds: 6),
              icon: Icon(Icons.error_outline, color: Colors.red.shade900),
            );
          } else if (kycStatus == 'approved') {
            // Clear any previous errors for edit mode
            rejectionReason.value = '';
            fieldErrors.clear();

            // ✅ Show edit mode message
            // Get.snackbar(
            //   'Edit KYC Documents',
            //   'You can update your KYC information below.',
            //   backgroundColor: Colors.blue.shade100,
            //   colorText: Colors.blue.shade900,
            //   snackPosition: SnackPosition.TOP,
            //   margin: EdgeInsets.all(16),
            //   borderRadius: 8,
            //   duration: Duration(seconds: 3),
            //   icon: Icon(Icons.edit, color: Colors.blue.shade900),
            // );
          } else {
            // ✅ Show info message for pending
            Get.snackbar(
              'Resubmission Mode',
              'Your previous data has been loaded. Update any fields and resubmit.',
              backgroundColor: Colors.blue.shade100,
              colorText: Colors.blue.shade900,
              snackPosition: SnackPosition.TOP,
              margin: EdgeInsets.all(16),
              borderRadius: 8,
              duration: Duration(seconds: 4),
            );
          }
        }
      }
    } catch (e) {
      log('❌ Error fetching onboarding data: $e');
      // Don't show error - user can still fill form manually
    } finally {
      isFetchingData.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SETTERS
  // ══════════════════════════════════════════════════════════════════════════
  void setStoreName(String value) {
    storeName.value = value;
    fieldErrors.remove('storeName'); // Clear error when user edits
  }

  void setBusinessType(String value) {
    businessType.value = value;
    fieldErrors.remove('businessType');
  }

  void setPanNumber(String value) {
    panNumber.value = value.toUpperCase();
    fieldErrors.remove('panNumber');
  }

  void setGstNumber(String value) {
    gstNumber.value = value.toUpperCase();
    fieldErrors.remove('gstNumber');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PARSE REJECTION REASON TO IDENTIFY PROBLEMATIC FIELDS
  // ══════════════════════════════════════════════════════════════════════════
  void _parseRejectionReason(String reason) {
    fieldErrors.clear();

    final reasonLower = reason.toLowerCase();

    // ✅ Map keywords to field names
    final fieldKeywords = {
      'store name': 'storeName',
      'storename': 'storeName',
      'business type': 'businessType',
      'businesstype': 'businessType',
      'pan': 'panNumber',
      'pan number': 'panNumber',
      'pannumber': 'panNumber',
      'gst': 'gstNumber',
      'gst number': 'gstNumber',
      'gstnumber': 'gstNumber',
      'fssai': 'fssaiCertificate',
      'fssai license': 'fssaiLicense',
      'fssai certificate': 'fssaiCertificate',
      'fssailicense': 'fssaiLicense',
      'fssaicertificate': 'fssaiCertificate',
      'aadhaar': 'aadhaarProof',
      'aadhar': 'aadhaarProof',
      'aadhaar proof': 'aadhaarProof',
      'aadhar proof': 'aadhaarProof',
      'aadhaarproof': 'aadhaarProof',
      'aadharproof': 'aadhaarProof',
      'address': 'address',
      'city': 'city',
      'state': 'state',
      'pincode': 'pincode',
      'pin code': 'pincode',
    };

    // ✅ Check which fields are mentioned in the rejection reason
    fieldKeywords.forEach((keyword, fieldName) {
      if (reasonLower.contains(keyword)) {
        fieldErrors[fieldName] = reason;
        log('🔴 Field error detected: $fieldName');
      }
    });

    // ✅ If no specific field found, mark all document fields as potential issues
    if (fieldErrors.isEmpty) {
      log('⚠️ No specific field found in rejection reason, marking documents');
      fieldErrors['aadhaarProof'] = reason;
      fieldErrors['fssaiCertificate'] = reason;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CHECK IF FIELD HAS ERROR
  // ══════════════════════════════════════════════════════════════════════════
  bool hasFieldError(String fieldName) {
    return fieldErrors.containsKey(fieldName);
  }

  String? getFieldError(String fieldName) {
    return fieldErrors[fieldName];
  }

  void setFssaiLicense(String value) {
    fssaiLicense.value = value;
    fieldErrors.remove('fssaiLicense');
  }

  void setAddress(String value) {
    address.value = value;
    fieldErrors.remove('address');
  }

  void setCity(String value) {
    city.value = value;
    fieldErrors.remove('city');
  }

  void setState(String value) {
    state.value = value;
    fieldErrors.remove('state');
  }

  void setPincode(String value) {
    pincode.value = value;
    fieldErrors.remove('pincode');
  }

  void setAadhaarProof(String path) {
    aadhaarProof.value = path;
    aadhaarFileName.value = path.split('/').last;
    fieldErrors.remove(
      'aadhaarProof',
    ); // Clear error when user uploads new file
  }

  void setFssaiCertificate(String path) {
    fssaiCertificate.value = path;
    fssaiFileName.value = path.split('/').last;
    fieldErrors.remove(
      'fssaiCertificate',
    ); // Clear error when user uploads new file
    fieldErrors.remove('fssaiLicense'); // Also clear fssai license error
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

    // ✅ Verify files exist (only for local files, not URLs)
    if (!aadhaarProof.value.startsWith('http') &&
        !File(aadhaarProof.value).existsSync()) {
      _showError('Aadhaar proof file not found');
      return false;
    }

    if (!fssaiCertificate.value.startsWith('http') &&
        !File(fssaiCertificate.value).existsSync()) {
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
      final ApiResponse response;

      // ✅ Check if this is a resubmission or new submission
      if (isResubmission.value) {
        log('📤 Resubmitting onboarding data...');

        response = await _onboardingService.updateOnboarding(
          storeName: storeName.value.trim(),
          businessType: businessType.value,
          panNumber: panNumber.value,
          gstNumber: gstNumber.value.trim(),
          fssaiLicense: fssaiLicense.value.trim(),
          address: address.value.trim(),
          city: city.value.trim(),
          state: state.value,
          pincode: pincode.value,
          // ✅ Only send files if they are new (local paths, not URLs)
          aadhaarProof:
              aadhaarProof.value.startsWith('http') ? null : aadhaarProof.value,
          fssaiCertificate:
              fssaiCertificate.value.startsWith('http')
                  ? null
                  : fssaiCertificate.value,
        );
      } else {
        log('📤 Submitting new onboarding data...');

        response = await _onboardingService.submitOnboarding(
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
      }

      if (response.success) {
        _showSuccess(
          response.message ??
              (isEditMode.value
                  ? 'KYC documents updated successfully'
                  : (isResubmission.value
                      ? 'KYC resubmitted successfully'
                      : 'Onboarding submitted successfully')),
        );

        // Navigate based on mode
        await Future.delayed(Duration(milliseconds: 500));

        if (isEditMode.value) {
          // In edit mode, go back to profile or home
          Get.back(); // Go back to profile screen
          Get.snackbar(
            'Success',
            'Your KYC documents have been updated successfully',
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
            snackPosition: SnackPosition.BOTTOM,
            margin: EdgeInsets.all(16),
            borderRadius: 8,
            duration: Duration(seconds: 3),
            icon: Icon(Icons.check_circle, color: Colors.green.shade900),
          );
        } else {
          // For new submission or resubmission, go to waiting screen
          Get.offNamed('/onboardingWaiting');
        }
      } else {
        log('❌ Onboarding submission failed: ${response.message}');

        // ✅ Special handling for approved KYC update restriction
        if (isEditMode.value &&
            response.message?.toLowerCase().contains('already approved') ==
                true) {
          Get.dialog(
            AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Update Not Allowed',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your KYC is already approved and cannot be updated at this time.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'If you need to update your documents, please contact our support team.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Get.back(), child: Text('Close')),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    // TODO: Open support contact
                    Get.snackbar(
                      'Contact Support',
                      'Email: support@pawfect.com\nPhone: +91 1800-XXX-XXXX',
                      backgroundColor: Colors.blue.shade100,
                      colorText: Colors.blue.shade900,
                      duration: Duration(seconds: 5),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                  ),
                  child: Text(
                    'Contact Support',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            barrierDismissible: false,
          );
        } else {
          // Handle other API validation errors
          _handleApiError(response);
        }
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
    storeNameController.clear();
    panNumberController.clear();
    gstNumberController.clear();
    fssaiLicenseController.clear();
    addressController.clear();
    cityController.clear();
    pincodeController.clear();

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
    // Dispose controllers
    storeNameController.dispose();
    panNumberController.dispose();
    gstNumberController.dispose();
    fssaiLicenseController.dispose();
    addressController.dispose();
    cityController.dispose();
    pincodeController.dispose();

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
