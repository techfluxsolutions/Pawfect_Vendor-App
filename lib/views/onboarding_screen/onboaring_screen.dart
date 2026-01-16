// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/onboarding_controller.dart';
// import '../../utils/widgets.dart';

import '../../libs.dart';

class OnboardingScreen extends StatelessWidget {
  // Use Get.find() since controller is now bound via route binding
  OnboardingController get controller => Get.find<OnboardingController>();

  void _showFilePickerDialog(BuildContext context, String type) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select File Source'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.blue),
                title: Text('Camera'),
                subtitle: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImage(type, isCamera: true);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('Gallery'),
                subtitle: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickImage(type, isCamera: false);
                },
              ),
              ListTile(
                leading: Icon(Icons.insert_drive_file, color: Colors.orange),
                title: Text('Document'),
                subtitle: Text('Choose PDF or image'),
                onTap: () {
                  Navigator.pop(context);
                  controller.pickDocument(type);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Disable default back button
        leading: Obx(() {
          // Show back button ONLY in edit mode
          if (controller.isEditMode.value) {
            return IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            );
          }
          return SizedBox.shrink(); // No back button for new/resubmission
        }),
        title: Obx(
          () => Text(
            controller.isEditMode.value
                ? 'Edit KYC Documents'
                : (controller.isResubmission.value
                    ? 'Resubmit Your KYC'
                    : 'Complete Your Profile'),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        // ✅ Show loading indicator while fetching data
        if (controller.isFetchingData.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: primaryColor),
                SizedBox(height: 16),
                Text(
                  'Loading your data...',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    // ✅ Show rejection reason banner ONLY if there are field errors (not in edit mode)
                    Obx(() {
                      if (controller.rejectionReason.value.isNotEmpty &&
                          controller.fieldErrors.isNotEmpty) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.shade200,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rejection Reason',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade900,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      controller.rejectionReason.value,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red.shade800,
                                        height: 1.4,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Please fix the highlighted fields below',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    }),

                    _buildSectionHeader('Store Information', primaryColor),
                    SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Store Name',
                      hintText: 'Please enter your store name',
                      controller: controller.storeNameController,
                      onChanged: (value) => controller.setStoreName(value),
                    ),
                    SizedBox(height: 12),
                    _buildDropdownField(
                      'Business Type',
                      ['Individual', 'Company'],
                      controller.businessType,
                      (value) => controller.setBusinessType(value),
                    ),
                    SizedBox(height: 24),

                    // Section 2: Legal Information
                    _buildSectionHeader('Legal Information', primaryColor),
                    SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'PAN Number',
                      hintText: 'Please enter your PAN number',
                      controller: controller.panNumberController,
                      maxLength: 10,
                      onChanged: (value) => controller.setPanNumber(value),
                    ),
                    SizedBox(height: 12),
                    CustomTextField(
                      labelText: 'GST Number',
                      hintText: 'Enter GST number',
                      controller: controller.gstNumberController,
                      onChanged: (value) => controller.setGstNumber(value),
                    ),
                    SizedBox(height: 12),
                    CustomTextField(
                      labelText: 'FSSAI License',
                      hintText: 'Enter FSSAI license number',
                      controller: controller.fssaiLicenseController,
                      onChanged: (value) => controller.setFssaiLicense(value),
                    ),
                    SizedBox(height: 24),

                    // Section 3: Address Information
                    _buildSectionHeader('Address Information', primaryColor),
                    SizedBox(height: 16),
                    CustomTextField(
                      labelText: 'Address',
                      hintText: 'Please enter your address',
                      controller: controller.addressController,
                      maxLines: 2,
                      onChanged: (value) => controller.setAddress(value),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            labelText: 'City',
                            hintText: 'Please enter your city',
                            controller: controller.cityController,
                            onChanged: (value) => controller.setCity(value),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdownField(
                            'State',
                            [
                              'Maharashtra',
                              'Delhi',
                              'Bangalore',
                              'Hyderabad',
                              'Chennai',
                            ],
                            controller.state,
                            (value) => controller.setState(value),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    CustomTextField(
                      labelText: 'Pincode',
                      hintText: 'Please enter your pincode',
                      controller: controller.pincodeController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      onChanged: (value) => controller.setPincode(value),
                    ),
                    SizedBox(height: 24),

                    // Section 4: Documents
                    _buildSectionHeader('Upload Documents', primaryColor),
                    SizedBox(height: 16),
                    Obx(
                      () => _buildFileUploadField(
                        'Aadhaar Proof',
                        controller.aadhaarFileName.value.isEmpty
                            ? 'No file selected'
                            : controller.aadhaarFileName.value,
                        controller.aadhaarProof.value.isNotEmpty,
                        primaryColor,
                        () => _showFilePickerDialog(context, 'aadhaar'),
                        hasError: controller.hasFieldError('aadhaarProof'),
                        errorMessage:
                            controller.hasFieldError('aadhaarProof')
                                ? controller.rejectionReason.value
                                : null,
                      ),
                    ),
                    SizedBox(height: 12),

                    // FSSAI Certificate Upload
                    Obx(
                      () => _buildFileUploadField(
                        'FSSAI Certificate',
                        controller.fssaiFileName.value.isEmpty
                            ? 'No file selected'
                            : controller.fssaiFileName.value,
                        controller.fssaiCertificate.value.isNotEmpty,
                        primaryColor,
                        () => _showFilePickerDialog(context, 'fssai'),
                        hasError:
                            controller.hasFieldError('fssaiCertificate') ||
                            controller.hasFieldError('fssaiLicense'),
                        errorMessage:
                            controller.hasFieldError('fssaiCertificate') ||
                                    controller.hasFieldError('fssaiLicense')
                                ? controller.rejectionReason.value
                                : null,
                      ),
                    ),
                    SizedBox(height: 32),

                    // Submit Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              controller.isLoading.value
                                  ? null
                                  : () => controller.submitForm(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child:
                              controller.isLoading.value
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    controller.isEditMode.value
                                        ? 'Update KYC Documents'
                                        : (controller.isResubmission.value
                                            ? 'Resubmit KYC'
                                            : 'Complete Onboarding'),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    RxString selectedValue,
    Function(String) onChanged,
  ) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: selectedValue.value.isEmpty ? null : selectedValue.value,
        hint: Text(label),
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: (value) => onChanged(value ?? ''),
        decoration: InputDecoration(labelText: label, counterText: ''),
      ),
    );
  }

  Widget _buildFileUploadField(
    String label,
    String fileName,
    bool hasFile,
    Color primaryColor,
    VoidCallback onTap, {
    bool hasError = false,
    String? errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color:
                    hasError
                        ? Colors.red
                        : (hasFile ? primaryColor : Colors.grey[300]!),
                width: hasError ? 2 : (hasFile ? 2 : 1),
              ),
              borderRadius: BorderRadius.circular(8),
              color:
                  hasError
                      ? Colors.red.shade50
                      : (hasFile
                          ? primaryColor.withOpacity(0.05)
                          : Colors.white),
            ),
            child: Row(
              children: [
                Icon(
                  hasError
                      ? Icons.error_outline
                      : (hasFile
                          ? Icons.check_circle
                          : Icons.file_upload_outlined),
                  color:
                      hasError
                          ? Colors.red
                          : (hasFile ? primaryColor : Colors.grey[600]),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: hasError ? Colors.red : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        fileName,
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              hasError
                                  ? Colors.red.shade700
                                  : (hasFile ? primaryColor : Colors.grey[500]),
                          fontWeight:
                              hasFile ? FontWeight.w600 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: hasError ? Colors.red : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
        if (hasError && errorMessage != null) ...[
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.only(left: 12),
            child: Text(
              errorMessage,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
