// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/onboarding_controller.dart';
// import '../../utils/widgets.dart';

import '../../libs.dart';

class OnboardingScreen extends StatelessWidget {
  final OnboardingController controller = Get.put(OnboardingController());

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
        automaticallyImplyLeading: false,
        title: Text('Complete Your Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: primaryColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  _buildSectionHeader('Store Information', primaryColor),
                  SizedBox(height: 16),
                  CustomTextField(
                    labelText: 'Store Name',
                    hintText: 'Please enter your store name',
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
                    maxLength: 10,
                    onChanged: (value) => controller.setPanNumber(value),
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    labelText: 'GST Number',
                    hintText: 'Enter GST number',
                    onChanged: (value) => controller.setGstNumber(value),
                  ),
                  SizedBox(height: 12),
                  CustomTextField(
                    labelText: 'FSSAI License',
                    hintText: 'Enter FSSAI license number',
                    onChanged: (value) => controller.setFssaiLicense(value),
                  ),
                  SizedBox(height: 24),

                  // Section 3: Address Information
                  _buildSectionHeader('Address Information', primaryColor),
                  SizedBox(height: 16),
                  CustomTextField(
                    labelText: 'Address',
                    hintText: 'Please enter your address',
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
                    ),
                  ),
                  // _buildFileUploadField(
                  //   'Aadhaar Proof',
                  //   '',
                  //   primaryColor,
                  //   () => controller.setAadhaarProof('bird.png'),
                  // ),
                  // SizedBox(height: 12),
                  // _buildFileUploadField(
                  //   'FSSAI Certificate',
                  //   '',
                  //   primaryColor,
                  //   () => controller.setFssaiCertificate('certificate.pdf'),
                  // ),
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
                                  'Complete Onboarding',
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
      ),
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
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasFile ? primaryColor : Colors.grey[300]!,
            width: hasFile ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: hasFile ? primaryColor.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              hasFile ? Icons.check_circle : Icons.file_upload_outlined,
              color: hasFile ? primaryColor : Colors.grey[600],
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
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fileName,
                    style: TextStyle(
                      fontSize: 12,
                      color: hasFile ? primaryColor : Colors.grey[500],
                      fontWeight: hasFile ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
