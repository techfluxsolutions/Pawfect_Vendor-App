import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import 'package:pawfect_vendor_app/services/onboarding_service.dart';

class OnboardingController extends GetxController {
  final OnboardingService _onboardingService = OnboardingService();

  @override
  void onInit() {
    super.onInit();
    // Save initial pending status when user starts onboarding
    // StorageService.instance.saveOnboardingStatus('pending');
  }

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

        print('📸 Image picked: ${image.path}');
        print('📏 File size: ${fileSizeMB.toStringAsFixed(2)} MB');

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

        print('📄 Document picked: $filePath');
        print('📏 File size: ${fileSizeMB.toStringAsFixed(2)} MB');

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
      print('❌ Pick document error: $e');
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
        // _showError(response.message ?? 'Failed to submit onboarding');
      }
    } catch (e) {
      _showError('An error occurred: ${e.toString()}');
      print('❌ Submit error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SNACKBAR HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(16),
      borderRadius: 8,
      duration: Duration(seconds: 3),
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
}
